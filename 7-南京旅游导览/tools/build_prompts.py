#!/usr/bin/env python
"""Build ready-to-copy prompts for the Nanjing audio guide pipeline.

This tool does not call any model API. It reads one stop configuration file,
loads local source texts, and writes prompt files that can be pasted into
ChatGPT or another LLM.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


DEFAULT_SCRIPT_VERSIONS = [
    {
        "id": "normal_3min",
        "label": "普通版 3 分钟",
        "target_audience": "初次到访南京的普通游客",
        "duration": "3分钟",
        "language": "zh-CN",
        "tone": "清晰、亲切、适合边走边听",
    },
    {
        "id": "family_3min",
        "label": "亲子版 3 分钟",
        "target_audience": "带孩子游览的家庭",
        "duration": "3分钟",
        "language": "zh-CN",
        "tone": "轻松、互动、少术语",
    },
    {
        "id": "fun_3min",
        "label": "趣味版 3 分钟",
        "target_audience": "喜欢故事和冷知识的年轻游客",
        "duration": "3分钟",
        "language": "zh-CN",
        "tone": "有节奏、有悬念、但不夸张",
    },
    {
        "id": "expert_5min",
        "label": "专业版 5 分钟",
        "target_audience": "对历史建筑和城市史感兴趣的游客",
        "duration": "5分钟",
        "language": "zh-CN",
        "tone": "稍专业、信息密度更高、引用意识明确",
    },
    {
        "id": "english_3min",
        "label": "英文版 3 分钟",
        "target_audience": "English-speaking visitors",
        "duration": "3 minutes",
        "language": "en",
        "tone": "Clear, vivid, accessible, suitable for audio touring",
    },
]


def count_indent(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def parse_scalar(value: str) -> Any:
    value = value.strip()
    if value == "":
        return ""
    if value in {"true", "True"}:
        return True
    if value in {"false", "False"}:
        return False
    if value in {"null", "None", "~"}:
        return None
    if (value.startswith('"') and value.endswith('"')) or (
        value.startswith("'") and value.endswith("'")
    ):
        return value[1:-1]
    return value


def split_key_value(text: str) -> tuple[str, str]:
    if ":" not in text:
        raise ValueError(f"Expected key: value, got: {text}")
    key, value = text.split(":", 1)
    return key.strip(), value.strip()


def parse_simple_yaml(text: str) -> dict[str, Any]:
    """Parse the small YAML subset used by this prototype.

    Supported shapes:
    - dictionaries with `key: value`
    - nested dictionaries with indentation
    - lists using `- value` or `- key: value`

    For production use, install PyYAML and this tool will use it automatically.
    """

    raw_lines = text.splitlines()
    lines = []
    for line in raw_lines:
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        lines.append(line.rstrip())

    def parse_block(index: int, indent: int) -> tuple[Any, int]:
        if index >= len(lines):
            return {}, index

        current = lines[index]
        current_indent = count_indent(current)
        if current_indent < indent:
            return {}, index

        is_list = current.lstrip().startswith("- ")
        if is_list:
            items = []
            while index < len(lines):
                line = lines[index]
                line_indent = count_indent(line)
                stripped = line.strip()
                if line_indent != indent or not stripped.startswith("- "):
                    break

                item_text = stripped[2:].strip()
                index += 1
                if item_text == "":
                    child, index = parse_block(index, indent + 2)
                    items.append(child)
                elif ":" in item_text:
                    key, value = split_key_value(item_text)
                    item: dict[str, Any] = {}
                    if value == "":
                        child, index = parse_block(index, indent + 2)
                        item[key] = child
                    else:
                        item[key] = parse_scalar(value)
                    if index < len(lines) and count_indent(lines[index]) >= indent + 2:
                        child, index = parse_block(index, indent + 2)
                        if isinstance(child, dict):
                            item.update(child)
                        else:
                            item["_items"] = child
                    items.append(item)
                else:
                    items.append(parse_scalar(item_text))
            return items, index

        data: dict[str, Any] = {}
        while index < len(lines):
            line = lines[index]
            line_indent = count_indent(line)
            stripped = line.strip()
            if line_indent < indent or stripped.startswith("- "):
                break
            if line_indent > indent:
                raise ValueError(f"Unexpected indentation near: {line}")

            key, value = split_key_value(stripped)
            index += 1
            if value == "":
                child, index = parse_block(index, indent + 2)
                data[key] = child
            else:
                data[key] = parse_scalar(value)
        return data, index

    parsed, final_index = parse_block(0, 0)
    if final_index != len(lines):
        raise ValueError("Could not parse the full YAML file.")
    if not isinstance(parsed, dict):
        raise ValueError("Top-level YAML must be a dictionary.")
    return parsed


def load_config(config_path: Path) -> tuple[dict[str, Any], str]:
    raw = config_path.read_text(encoding="utf-8")
    if config_path.suffix.lower() == ".json":
        return json.loads(raw), raw

    try:
        import yaml  # type: ignore

        loaded = yaml.safe_load(raw)
        if not isinstance(loaded, dict):
            raise ValueError("Config top level must be a dictionary.")
        return loaded, raw
    except ModuleNotFoundError:
        return parse_simple_yaml(raw), raw


def project_root_from_config(config_path: Path) -> Path:
    current = config_path.resolve().parent
    while current != current.parent:
        if (current / "prompts").exists() and (current / "data").exists():
            return current
        current = current.parent
    return config_path.resolve().parent.parent


def slugify(value: str, fallback: str) -> str:
    ascii_slug = re.sub(r"[^a-zA-Z0-9_-]+", "_", value).strip("_").lower()
    return ascii_slug or fallback


def read_source_materials(config: dict[str, Any], root: Path) -> str:
    materials = config.get("source_materials") or []
    if not isinstance(materials, list):
        raise ValueError("source_materials must be a list.")

    sections = []
    for material in materials:
        if not isinstance(material, dict):
            continue
        source_id = material.get("id", "unknown_source")
        title = material.get("title", "Untitled")
        source_type = material.get("type", "unknown")
        usage_note = material.get("usage_note", "")
        path_value = material.get("path")
        url_value = material.get("url")

        content = ""
        location = url_value or path_value or "no path/url"
        if path_value:
            source_path = (root / str(path_value)).resolve()
            if not source_path.exists():
                content = f"[Missing local file: {source_path}]"
            else:
                content = source_path.read_text(encoding="utf-8")
        elif url_value:
            content = "[URL source listed. Paste article text into data/raw/ before production use.]"
        else:
            content = "[No source text supplied.]"

        sections.append(
            "\n".join(
                [
                    f"### Source ID: {source_id}",
                    f"- Title: {title}",
                    f"- Type: {source_type}",
                    f"- Location: {location}",
                    f"- Usage note: {usage_note}",
                    "",
                    "```text",
                    content.strip(),
                    "```",
                ]
            )
        )
    return "\n\n".join(sections)


def render_template(template: str, values: dict[str, str]) -> str:
    rendered = template
    for key, value in values.items():
        rendered = rendered.replace("{{" + key + "}}", value)
    return rendered


def json_block(data: Any) -> str:
    return "```json\n" + json.dumps(data, ensure_ascii=False, indent=2) + "\n```"


def make_fact_card(config: dict[str, Any]) -> str:
    fact_card = {
        "route_name": config.get("route_name", ""),
        "stop_name": config.get("stop_name", ""),
        "location_note": config.get("location_note", ""),
        "core_facts": config.get("verified_facts", []),
        "story_angles": config.get("story_angles", []),
        "uncertain_claims": config.get("uncertain_claims", []),
        "citations": config.get("citations", []),
        "human_review_status": "draft: generated from config, needs AI extraction and human review",
    }
    return "\n".join(
        [
            f"# 事实卡草稿：{config.get('stop_name', '未命名点位')}",
            "",
            "> 这是工具根据点位配置生成的初始事实卡草稿。请先运行 `01_extract_facts` prompt，再由人工审核。",
            "",
            json_block(fact_card),
            "",
            "## 人工审核提醒",
            "",
            "- 核查关键事实是否有可靠来源。",
            "- 将传说、推测和宣传性表述从事实中拆出来。",
            "- 补充正式引用信息，例如机构名、文章名、发布日期、URL 或书目信息。",
        ]
    )


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")


def build(config_path: Path) -> list[Path]:
    config_path = config_path.resolve()
    config, raw_config = load_config(config_path)
    root = project_root_from_config(config_path)
    slug = slugify(config_path.stem, fallback="stop")

    source_bundle = read_source_materials(config, root)
    fact_card = make_fact_card(config)
    story_angles = json_block(config.get("story_angles", []))
    versions = config.get("script_versions") or DEFAULT_SCRIPT_VERSIONS

    fact_path = root / "data" / "facts" / f"{slug}_fact_card_draft.md"
    write_text(fact_path, fact_card)

    templates_dir = root / "prompts"
    prompts_out = root / "outputs" / "prompts_ready"
    scripts_out = root / "outputs" / "scripts"

    base_values = {
        "point_config": raw_config.strip(),
        "source_bundle": source_bundle,
        "fact_card": fact_card,
        "story_angles": story_angles,
        "script_versions": json.dumps(versions, ensure_ascii=False, indent=2),
        "draft_script_placeholder": "[请先把上一轮生成的讲稿粘贴到这里，再运行本 prompt。]",
    }

    written = [fact_path]

    all_in_one_template = (templates_dir / "00_all_in_one_pipeline.md").read_text(encoding="utf-8")
    all_in_one_path = prompts_out / f"{slug}_00_ALL_IN_ONE_COPY_TO_GPT.md"
    write_text(all_in_one_path, render_template(all_in_one_template, base_values))
    written.append(all_in_one_path)

    one_off_templates = [
        ("01_extract_facts.md", f"{slug}_01_extract_facts.md"),
        ("02_generate_story_angles.md", f"{slug}_02_generate_story_angles.md"),
    ]
    for template_name, output_name in one_off_templates:
        template = (templates_dir / template_name).read_text(encoding="utf-8")
        output = render_template(template, base_values)
        out_path = prompts_out / output_name
        write_text(out_path, output)
        written.append(out_path)

    script_template = (templates_dir / "03_generate_script.md").read_text(encoding="utf-8")
    oral_template = (templates_dir / "04_oralize_script.md").read_text(encoding="utf-8")
    check_template = (templates_dir / "05_fact_check.md").read_text(encoding="utf-8")

    for version in versions:
        if not isinstance(version, dict):
            continue
        version_id = slugify(str(version.get("id", version.get("label", "version"))), "version")
        version_values = {
            **base_values,
            "script_version": json.dumps(version, ensure_ascii=False, indent=2),
        }

        script_prompt = render_template(script_template, version_values)
        oral_prompt = render_template(oral_template, version_values)
        check_prompt = render_template(check_template, version_values)

        for suffix, content in [
            (f"03_generate_script_{version_id}.md", script_prompt),
            (f"04_oralize_script_{version_id}.md", oral_prompt),
            (f"05_fact_check_{version_id}.md", check_prompt),
        ]:
            out_path = prompts_out / f"{slug}_{suffix}"
            write_text(out_path, content)
            written.append(out_path)

        script_placeholder = "\n".join(
            [
                f"# {config.get('stop_name', slug)} - {version.get('label', version_id)}",
                "",
                "状态：待生成",
                "",
                "使用方法：",
                f"1. 打开 `outputs/prompts_ready/{slug}_03_generate_script_{version_id}.md`。",
                "2. 复制给 AI，得到讲稿。",
                "3. 将讲稿粘贴回本文件。",
                "4. 再运行对应的口播优化和事实核查 prompt。",
            ]
        )
        script_path = scripts_out / f"{slug}_{version_id}.md"
        write_text(script_path, script_placeholder)
        written.append(script_path)

    index_lines = [
        f"# Prompt 输出索引：{config.get('stop_name', slug)}",
        "",
        f"- 事实卡草稿：`data/facts/{slug}_fact_card_draft.md`",
        "- 推荐顺序：",
        f"  1. `outputs/prompts_ready/{slug}_01_extract_facts.md`",
        f"  2. `outputs/prompts_ready/{slug}_02_generate_story_angles.md`",
        "  3. 选择对应版本的 `03_generate_script`",
        "  4. 将讲稿粘贴进 `04_oralize_script`",
        "  5. 将最终稿粘贴进 `05_fact_check`",
        "",
        "## 本次生成文件",
        "",
    ]
    index_lines.extend(f"- `{path.relative_to(root).as_posix()}`" for path in written)
    index_path = prompts_out / f"{slug}_INDEX.md"
    write_text(index_path, "\n".join(index_lines))
    written.append(index_path)

    return written


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build prompt files for the Nanjing audio guide content pipeline."
    )
    parser.add_argument("config", help="Path to a stop config file, such as examples/zhonghuamen.yaml")
    args = parser.parse_args()

    try:
        written = build(Path(args.config))
    except Exception as exc:  # noqa: BLE001 - CLI should show a concise error.
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    print("Generated files:")
    for path in written:
        print(f"- {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
