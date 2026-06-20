"""步语 BuYu · Step-Audio 2.5 Realtime 语音桥接层。

浏览器 (麦克风 PCM16) ──ws──> 本服务 /ws/voice ──ws──> 阶跃 Step-Audio Realtime
                       <─字幕+语音流─              <─response.audio/transcript.delta─

这一层是"实时语音模型 + 文旅 Harness"技术叙事的真实实现：
- 冻结的实时语音模型 = 阶跃 stepaudio-2.5-realtime（全双工、可打断、副语言感知）
- Harness 注入 = session.update 的 instructions 里塞进【策展数据】(可信知识库) +
  【地理位置】(当前点位) + 【Memory】(本会话游客问过/爱听什么)
- RAG 在这里降级为 harness 的"数据组件"之一，不再是卖点。

端点路径用 Step Plan 套餐前缀 /step_plan/v1/realtime（实测通）。
"""
from __future__ import annotations

import asyncio
import json
import os
from pathlib import Path

import websockets

STEP_WSS = "wss://api.stepfun.com/step_plan/v1/realtime?model=stepaudio-2.5-realtime"


def _load_step_key() -> str | None:
    # 1) 环境变量  2) ~/.stepfun/credentials  (锚定值前缀躲过 secret-redaction)
    k = os.environ.get("STEP_API_KEY")
    if k:
        return k.strip()
    cred = Path.home() / ".stepfun" / "credentials"
    if cred.exists():
        for line in cred.read_text().splitlines():
            if "=" in line:
                return line.split("=", 1)[1].strip()
    return None


STEP_KEY = _load_step_key()


def build_instructions(point: dict, version_meta: dict, memory: dict | None) -> str:
    """把 Harness 三件套编进 system instructions。"""
    facts = "\n".join(f"- {f['text']}" for f in point["facts"])
    parts = [
        f"你是「步语 BuYu」——南京老城南文化历史路线的 AI 实时语音导览员。",
        f"游客现在【走到】了：{point['name']}（{point['era']}）。",
        "",
        "【策展数据 · 可信知识库】（你只能基于这些史实讲解，不得编造任何史实/年代/人物）：",
        facts,
        "",
        f"【讲解风格】{version_meta['label']}：{version_meta['style']}",
    ]
    if point.get("en_reference"):
        parts.append(f"【跨文化参照系（讲英文版时可用）】{point['en_reference']}")
    if memory and memory.get("interests"):
        parts.append(f"【Memory · 这位游客的兴趣】{('、'.join(memory['interests']))}——讲解时有所侧重。")
    if memory and memory.get("asked"):
        parts.append(f"【Memory · 游客刚问过】{('；'.join(memory['asked'][-3:]))}——别重复，可顺势深入。")
    parts.append("")
    parts.append("开口像一个真正懂行、有温度的本地人，自然、口语化、不堆术语。每次只讲 2-4 句，"
                 "讲完可以反问游客一个有意思的小问题。游客随时可能打断你，被打断就停下听他说。")
    return "\n".join(parts)


class StepVoiceBridge:
    """一个浏览器连接 ↔ 一个 Step-Audio realtime 会话。"""

    def __init__(self, client_ws):
        self.client = client_ws        # 浏览器 WebSocket（FastAPI）
        self.step = None               # 阶跃 WebSocket
        self.closed = False

    async def connect_step(self, instructions: str, voice: str = "cixingnansheng"):
        # 屏蔽 Clash SOCKS 代理（proxy=None），否则 websockets 报 python-socks
        self.step = await websockets.connect(
            STEP_WSS,
            additional_headers=[("Authorization", f"Bearer {STEP_KEY}")],
            max_size=None, open_timeout=20, proxy=None,
        )
        await self._step_send({
            "type": "session.update",
            "session": {
                "modalities": ["text", "audio"],
                "instructions": instructions,
                "voice": voice,
                "input_audio_format": "pcm16",
                "output_audio_format": "pcm16",
            },
        })

    async def _step_send(self, obj: dict):
        await self.step.send(json.dumps(obj, ensure_ascii=True))

    async def trigger_text(self, text: str):
        """以文本输入触发一次讲解（demo 里点位卡 / 追问框用这条；语音走 append/commit）。"""
        await self._step_send({"type": "conversation.item.create", "item": {
            "type": "message", "role": "user",
            "content": [{"type": "input_text", "text": text}]}})
        await self._step_send({"type": "response.create"})

    async def append_audio(self, b64_pcm: str):
        await self._step_send({"type": "input_audio_buffer.append", "audio": b64_pcm})

    async def commit_audio(self):
        await self._step_send({"type": "input_audio_buffer.commit"})
        await self._step_send({"type": "response.create"})

    async def interrupt(self):
        """打断当前语音输出（全双工的灵魂）。"""
        try:
            await self._step_send({"type": "response.cancel"})
        except Exception:
            pass

    async def pump_step_to_client(self):
        """把阶跃的 server events 转发给浏览器（字幕 + 语音 + 状态）。"""
        try:
            async for raw in self.step:
                if self.closed:
                    break
                ev = json.loads(raw)
                t = ev.get("type", "")
                if t == "response.audio.delta":
                    await self._to_client({"kind": "audio", "pcm": ev.get("delta", "")})
                elif t == "response.audio_transcript.delta":
                    await self._to_client({"kind": "transcript", "text": ev.get("delta", "")})
                elif t in ("response.created",):
                    await self._to_client({"kind": "status", "status": "speaking"})
                elif t in ("response.done", "response.completed"):
                    await self._to_client({"kind": "status", "status": "done"})
                elif t == "error":
                    await self._to_client({"kind": "error", "error": ev.get("error", {})})
        except Exception as e:  # noqa: BLE001
            await self._to_client({"kind": "error", "error": {"message": str(e)}})

    async def _to_client(self, obj: dict):
        try:
            await self.client.send_text(json.dumps(obj, ensure_ascii=False))
        except Exception:
            self.closed = True

    async def close(self):
        self.closed = True
        if self.step:
            try:
                await self.step.close()
            except Exception:
                pass


def step_available() -> bool:
    return bool(STEP_KEY)
