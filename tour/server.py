"""步语 BuYu · 老城南文化历史导览 —— 后端。

复用 buyu 既有基础设施（app/llm.py 的 LLMClient + app/config.py 的 load_config），
在其上构建文化导览领域层：

  策展知识库（symbolic / 可信底座）
        │  每个点位的史实都带 source，人工策展把关
        ▼
  RAG 锚定（讲解生成 + 问答都把 KB 片段作为事实锚点 → 防幻觉）
        │
        ▼
  AI 生成（neural / 个性化）：四个版本 普通/深度/亲子/英文
        │
        ▼
  端：定位触发 · 四版切换 · 知识库问答 · 兴趣匹配路线推荐

设计红线（与 BP/PPT 一致）：
- LLM 只能在 KB 检索到的可信片段之上生成；问答检索不到就诚实说“资料里没有”，绝不编造。
- LLM 不可用/超时 → 回退到 KB 原文拼装（deterministic），保证 demo 不翻车。
"""
from __future__ import annotations

import asyncio
import json
import sys
from pathlib import Path

from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

# 复用 buyu 既有基础设施
_REPO = Path(__file__).resolve().parents[1]      # buyu/
sys.path.insert(0, str(_REPO))
from app.llm import LLMClient                      # noqa: E402
from app.config import load_config                 # noqa: E402
from tour import voice as voicemod                 # noqa: E402

HERE = Path(__file__).resolve().parent
KB = json.loads((HERE / "data" / "knowledge_base.json").read_text(encoding="utf-8"))

# ---------------- LLM（懒加载 + 容错） ----------------
_llm: LLMClient | None = None
_llm_ready = False
_LLM_CFG: dict = {}


def get_llm() -> LLMClient | None:
    global _llm, _llm_ready
    if _llm_ready:
        return _llm
    _llm_ready = True
    try:
        cfg = load_config()
        _LLM_CFG["base_url"] = cfg.base_url
        _LLM_CFG["api_key"] = cfg.api_key
        _LLM_CFG["model"] = cfg.model
        _LLM_CFG["timeout"] = max(cfg.llm_timeout_seconds, 60.0)
        _llm = LLMClient(base_url=cfg.base_url, api_key=cfg.api_key,
                         model=cfg.model, timeout=_LLM_CFG["timeout"])
    except Exception as e:  # noqa: BLE001
        print(f"[tour] LLM 不可用，将走 KB 兜底：{e}", file=sys.stderr)
        _llm = None
    return _llm


def _llm_complete(system: str, user: str, max_tokens: int = 360) -> str:
    """直连 LLM 网关的轻量补全。比 buyu LLMClient.chat() 更省（小 max_tokens、
    非推理模型走 chat/completions），适合 demo 现场的低延迟讲解生成。
    返回正文字符串；失败抛异常由调用方兜底。"""
    import httpx  # noqa: PLC0415
    base = _LLM_CFG["base_url"].rstrip("/")
    model = _LLM_CFG["model"]
    headers = {"content-type": "application/json"}
    if _LLM_CFG.get("api_key"):
        headers["authorization"] = f"Bearer {_LLM_CFG['api_key']}"
    body = {
        "model": model,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "max_tokens": max_tokens,
        "temperature": 0.6,
    }
    with httpx.Client(timeout=_LLM_CFG.get("timeout", 60.0), trust_env=False) as c:
        r = c.post(f"{base}/v1/chat/completions", json=body, headers=headers)
        r.raise_for_status()
        return (r.json()["choices"][0]["message"].get("content") or "").strip()


# ---------------- 讲解生成 ----------------
SYS_GUIDE = (
    "你是“步语 BuYu”——南京老城南文化历史导览的 AI 讲解员。"
    "你必须严格基于【可信史实】生成讲解，不得编造任何史实、年代、人物或典故；"
    "可信史实之外的内容一律不要写。讲解要像一个真正懂行的本地人在现场开口，"
    "自然、有温度、不堆砌。只输出讲解正文，不要前言、不要标题、不要 markdown。"
)


def _facts_block(pt: dict) -> str:
    lines = [f"点位：{pt['name']}（{pt['era']}）"]
    for f in pt["facts"]:
        lines.append(f"- {f['text']}")
    if pt.get("en_reference"):
        lines.append(f"（可用的跨文化参照系：{pt['en_reference']}）")
    return "\n".join(lines)


def generate_narration(point_id: str, version: str) -> dict:
    pt = KB["points"].get(point_id)
    if not pt:
        raise HTTPException(404, "unknown point")
    vmeta = KB["versions"].get(version) or KB["versions"]["normal"]
    llm = get_llm()
    facts = _facts_block(pt)

    if llm is not None:
        user = (
            f"【可信史实】\n{facts}\n\n"
            f"【讲解版本】{vmeta['label']} —— {vmeta['style']}\n\n"
            f"请基于上面的可信史实，生成 120-200 字的现场讲解"
            f"（英文版 80-140 词）。只用史实里有的内容。"
        )
        try:
            text = _llm_complete(SYS_GUIDE, user, max_tokens=420)
            if text:
                return {"point": pt["name"], "version": version,
                        "version_label": vmeta["label"], "text": text,
                        "grounded": True, "fallback": False,
                        "sources": [f["source"] for f in pt["facts"]],
                        "observe": pt["observe"], "ask_back": pt["ask_back"]}
        except Exception as e:  # noqa: BLE001
            print(f"[tour] 讲解生成失败，走兜底：{e}", file=sys.stderr)

    # 兜底：KB 原文拼装（deterministic，保证不翻车）
    if version == "english":
        body = pt.get("en_reference") or pt["one_line"]
        text = f"{pt['name_en']} ({pt['era']}). {body} " + " ".join(
            f["text"] for f in pt["facts"][:2])
    else:
        text = pt["one_line"] + " " + "".join(f["text"] for f in pt["facts"][:2])
    return {"point": pt["name"], "version": version, "version_label": vmeta["label"],
            "text": text, "grounded": True, "fallback": True,
            "sources": [f["source"] for f in pt["facts"]],
            "observe": pt["observe"], "ask_back": pt["ask_back"]}


# ---------------- 知识库问答（RAG 锚定 + 防幻觉） ----------------
SYS_QA = (
    "你是“步语 BuYu”导览员。只能根据下面提供的【知识库片段】回答游客问题。"
    "如果知识库片段里没有能回答这个问题的信息，必须如实说"
    "“这一点资料里没有记录，我不敢替你编”，绝对不要编造史实。"
    "回答简洁、口语化，2-4 句。只输出回答正文。"
)


def answer_question(point_id: str, question: str) -> dict:
    pt = KB["points"].get(point_id)
    if not pt:
        raise HTTPException(404, "unknown point")
    facts = _facts_block(pt)
    llm = get_llm()
    if llm is not None:
        try:
            text = _llm_complete(
                SYS_QA, f"【知识库片段】\n{facts}\n\n【游客问题】{question}", max_tokens=300)
            if text:
                return {"answer": text, "grounded": True, "fallback": False,
                        "sources": [f["source"] for f in pt["facts"]]}
        except Exception as e:  # noqa: BLE001
            print(f"[tour] 问答失败，走兜底：{e}", file=sys.stderr)
    # 兜底：返回该点位 one_line + 首条史实，并标注
    return {"answer": f"（离线兜底）{pt['one_line']} {pt['facts'][0]['text']}",
            "grounded": True, "fallback": True,
            "sources": [pt["facts"][0]["source"]]}


# ---------------- 兴趣匹配 → 路线推荐 ----------------
def recommend_route(interests: list[str]) -> dict:
    pts = KB["route"]["points"]
    interest_set = set(interests)
    # 稳定排序：命中兴趣标签数多的排前面，同分保持原始时间线顺序
    def score(pid: str) -> int:
        return sum(1 for t in KB["points"][pid].get("tags", []) if t in interest_set)
    order = sorted(pts, key=lambda pid: (-score(pid), pts.index(pid)))
    highlight = [pid for pid in order if score(pid) > 0]
    return {
        "ordered": order,
        "highlight": highlight,
        "reason": _route_reason(interests, highlight),
    }


def _route_reason(interests: list[str], highlight: list[str]) -> str:
    if not interests:
        return "按经典时间线顺序游览：从明代中华门一路走到东晋朱雀桥。"
    labels = [i["label"] for i in KB["interests"] if i["id"] in interests]
    names = [KB["points"][p]["name"] for p in highlight[:3]]
    if not names:
        return f"你选了「{ '、'.join(labels) }」，老城南线整体都契合，按时间线游览即可。"
    return (f"你选了「{ '、'.join(labels) }」——已把最契合的 "
            f"{ '、'.join(names) } 提到前面重点讲。")


# ==================== FastAPI ====================
app = FastAPI(title="步语 BuYu · 老城南文化导览")
app.mount("/static", StaticFiles(directory=str(HERE / "static")), name="static")
# 复用 buyu 既有的点位配图（hero 图也软链过来）
app.mount("/img", StaticFiles(directory=str(HERE / "static" / "img")), name="img")
# 各点位真实实拍图（高德 POI 实拍 + 策展精选）——抵达点位时弹出
app.mount("/photos", StaticFiles(directory=str(HERE / "static" / "photos")), name="photos")


class NarrateReq(BaseModel):
    point_id: str
    version: str = "normal"


class AskReq(BaseModel):
    point_id: str
    question: str


class RouteReq(BaseModel):
    interests: list[str] = []


@app.get("/", response_class=HTMLResponse)
def index() -> str:
    return (HERE / "static" / "index.html").read_text(encoding="utf-8")


@app.get("/api/route")
def api_route() -> dict:
    return {"route": KB["route"], "points": KB["points"],
            "interests": KB["interests"], "versions": KB["versions"]}


@app.post("/api/narrate")
def api_narrate(req: NarrateReq) -> JSONResponse:
    return JSONResponse(generate_narration(req.point_id, req.version))


@app.post("/api/ask")
def api_ask(req: AskReq) -> JSONResponse:
    if not req.question.strip():
        raise HTTPException(400, "empty question")
    return JSONResponse(answer_question(req.point_id, req.question))


@app.post("/api/recommend")
def api_recommend(req: RouteReq) -> JSONResponse:
    return JSONResponse(recommend_route(req.interests))


@app.get("/api/health")
def api_health() -> dict:
    llm = get_llm()
    return {"ok": True, "llm": llm is not None,
            "model": (llm.model if llm else None),
            "points": len(KB["points"]),
            "voice": voicemod.step_available(),
            "voice_model": "stepaudio-2.5-realtime" if voicemod.step_available() else None}


# ==================== Memory（Harness 三件套之一） ====================
# 按浏览器会话保存：游客的兴趣、问过的问题、走过的点位。
# 实时语音讲解时注入 instructions，做到"记得你"。
_MEMORY: dict[str, dict] = {}


def _mem(sid: str) -> dict:
    return _MEMORY.setdefault(sid, {"interests": [], "asked": [], "visited": []})


# ==================== WebSocket：实时语音导览 ====================
# 浏览器 ──(麦克风PCM16 / 文本触发)──> 本端点 ──> Step-Audio Realtime
#         <──────(字幕 + 语音流 + 状态)──────────────────────────┘
@app.websocket("/ws/voice")
async def ws_voice(client: WebSocket):
    await client.accept()
    if not voicemod.step_available():
        await client.send_text(json.dumps({"kind": "error",
            "error": {"message": "STEP_API_KEY 未配置"}}, ensure_ascii=False))
        await client.close()
        return

    bridge = voicemod.StepVoiceBridge(client)
    pump_task = None
    sid = "anon"
    try:
        while True:
            msg = await client.receive_text()
            data = json.loads(msg)
            kind = data.get("kind")

            if kind == "start":
                # 走到一个点位 → 起一个新的 Step-Audio 会话，注入 harness
                sid = data.get("session_id", "anon")
                pid = data["point_id"]
                version = data.get("version", "normal")
                pt = KB["points"][pid]
                vmeta = KB["versions"].get(version) or KB["versions"]["normal"]
                mem = _mem(sid)
                if pid not in mem["visited"]:
                    mem["visited"].append(pid)
                instr = voicemod.build_instructions(pt, vmeta, mem)
                voice = "linjiajiejie" if version in ("kids", "english") else "cixingnansheng"
                # 关掉旧会话再开新的（切点位/切版本）
                if pump_task:
                    await bridge.close(); pump_task.cancel(); bridge = voicemod.StepVoiceBridge(client)
                await bridge.connect_step(instr, voice=voice)
                pump_task = asyncio.create_task(bridge.pump_step_to_client())
                await bridge.trigger_text(f"我走到了{pt['name']}，给我讲讲吧。")

            elif kind == "ask":
                # 语音/文字追问 → 记进 Memory，转给 Step-Audio
                q = (data.get("text") or "").strip()
                if q:
                    _mem(sid)["asked"].append(q)
                    await bridge.interrupt()
                    await bridge.trigger_text(q)

            elif kind == "audio":
                # 浏览器麦克风的 PCM16 base64 分片
                await bridge.append_audio(data.get("pcm", ""))

            elif kind == "commit":
                await bridge.commit_audio()

            elif kind == "interrupt":
                await bridge.interrupt()

            elif kind == "set_interest":
                ints = data.get("interests", [])
                _mem(data.get("session_id", "anon"))["interests"] = ints

    except WebSocketDisconnect:
        pass
    except Exception as e:  # noqa: BLE001
        try:
            await client.send_text(json.dumps({"kind": "error",
                "error": {"message": str(e)}}, ensure_ascii=False))
        except Exception:
            pass
    finally:
        if pump_task:
            pump_task.cancel()
        await bridge.close()
