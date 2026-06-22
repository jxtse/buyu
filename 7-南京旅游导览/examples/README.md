# 示例说明

本目录提供一个“老城南文化路线 - 中华门”点位示例：

- `zhonghuamen.yaml`：点位配置文件。
- 示例资料放在 `data/raw/` 中。

运行：

```powershell
python tools/build_prompts.py examples/zhonghuamen.yaml
```

运行后会生成：

- `data/facts/zhonghuamen_fact_card_draft.md`
- `outputs/prompts_ready/` 下的可复制 prompt
- `outputs/scripts/` 下的讲稿占位文件

注意：示例资料不是权威来源，只用于演示工具流程。
