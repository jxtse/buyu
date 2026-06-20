# 步语 BuYu · 南京老城南实时语音导览

> **Walk the Story of a City** — 让走到历史现场的人，第一次真的"走进"那段历史。

策展人把关的可信知识库（symbolic，防幻觉）× 实时语音大模型的千人千面讲解（neural，个性化）——
一套面向中外游客的南京文化历史路线 AI 语音导览。首发**老城南线**：中华门 → 城墙博物馆 → 老门东 → 小西湖 → 朱雀桥。

本仓库是参加 **南京大学 × 鼓楼区 创新创业大赛 2026** 的产品原型实现（可本地运行的导览后端 + 前端）。

---

## 为什么是现在（why now）

- **RAG（检索增强）** 是 2020 年提出、2023 年起就标配化的成熟技术——给大模型外挂知识库不新鲜，**不构成壁垒**。
- **实时端到端语音模型** 过去约一年才集中成熟（speech-to-speech、延迟约 0.4s、可随时打断、能听出语气），旧的「识别→生成→合成」三级管线做不到。
- 真正的差距落在 **编排层（agent harness / context engineering）**：上下文怎么组织、检索怎么调度、长程记忆怎么维护。**这是步语构建的部分。**

## 核心设计：人划定可信边界，模型在边界内自由发挥

```
  策展知识库（symbolic / 可信底座）
        │   每个点位的史实都带 source，人工策展把关
        ▼
  RAG 锚定（讲解生成 + 问答都把 KB 片段作为事实锚点 → 防幻觉）
        │
        ▼
  实时语音模型（neural / 个性化）：四个版本 普通 / 深度 / 亲子 / 英文
        │
        ▼
  端：定位触发 · 四版切换 · 知识库问答 · 兴趣匹配路线推荐
```

**两条设计红线：**

1. LLM 只能在 KB 检索到的可信片段之上生成；问答检索不到就**诚实说"资料里没有"，绝不编造**。
2. LLM 不可用 / 超时 → 回退到 KB 原文拼装（deterministic），保证 demo 不翻车。

## 文旅 Harness 三件套

| 组件 | 角色 | 解决 |
|---|---|---|
| **策展数据** | SYMBOLIC · 防幻觉 | 人工精选路线、把关每条史实的官方/文献出处 | 纯生成会胡说 |
| **地理位置** | CONTEXT · 千景千讲 | GPS 走到哪、注入哪个点位的上下文与路线进度 | 单点固定录音 |
| **Memory** | STATE · 千人千讲 | 记住兴趣、问过的问题、走过的点位 | 千人一面 |

---

## 快速开始

```bash
# 1) 依赖（推荐 uv）
uv venv && source .venv/bin/activate
uv pip install -r requirements.txt

# 2) 配置 LLM 网关（任意 OpenAI 兼容端点：云端或本地自建均可）
cp .env.example .env
#   编辑 .env，填入你自己的 PLANNER_KEY / PLANNER_BASE_URL / PLANNER_MODEL

# 3) （可选）实时语音：把 Step-Audio key 写到 ~/.stepfun/credentials
#   形如  STEP_API_KEY=sk-xxxx   不填则降级为文本讲解，demo 仍可跑

# 4) 启动
python -m uvicorn tour.server:app --host 127.0.0.1 --port 8000
#   打开 http://127.0.0.1:8000
```

> **健康检查**：`GET /api/health` 返回 `{ok, llm, points, voice, voice_model}`。

## API

| 方法 | 路径 | 作用 |
|---|---|---|
| GET | `/` | 前端单页 |
| GET | `/api/route` | 路线 + 点位 + 兴趣 + 讲解版本元数据 |
| POST | `/api/narrate` | 生成某点位的某版本讲解（`{point_id, version}`），KB 锚定 + 容错兜底 |
| POST | `/api/ask` | 知识库问答（`{point_id, question}`），检索不到诚实拒答 |
| POST | `/api/recommend` | 兴趣匹配 → 路线重排（`{interests:[...]}`），纯规则排序，不调 LLM |
| GET | `/api/health` | 服务 / LLM / 语音可用性 |
| WS | `/ws/voice` | 实时语音导览：浏览器麦克风 PCM16 ↔ 实时语音模型，字幕 + 语音流 + 可打断 |

## 项目结构

```
tour/
  server.py              # FastAPI:讲解生成 / 问答 / 路线推荐 / 实时语音 WebSocket
  voice.py               # 实时语音桥接层(Step-Audio Realtime),harness 三件套注入 instructions
  data/
    knowledge_base.json  # 老城南 5 点位策展知识库:每条史实带 source,4 版讲解风格,5 兴趣标签
  static/
    index.html           # 前端单页
    img/                 # 5 个点位配图
app/
  llm.py                 # OpenAI 兼容 LLM 客户端(仅依赖 httpx)
  config.py              # 配置加载(.env + 进程环境变量)
```

## 技术栈

FastAPI · WebSocket(SSE 式事件流) · 任意 OpenAI 兼容 LLM 网关 · Step-Audio 2.5 Realtime(端到端实时语音，可替换为其他 speech-to-speech 模型)。

整套设计是 **Harness Engineering** 母题在文旅领域的落地：冻结一个 SOTA 实时语音模型，把领域知识与可信约束做进 harness，而不是去训练/微调模型本身——模型换代，harness 自动受益。

## License

MIT（见 [LICENSE](./LICENSE)）。知识库史实来源以官方陈列、地方志、权威媒体报道为准，已在 `knowledge_base.json` 内逐条标注 `source`。
