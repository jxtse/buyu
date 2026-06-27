const fs = require("node:fs");
const path = require("node:path");

const outDir = path.resolve("outputs");
fs.mkdirSync(outDir, { recursive: true });

const W = 1600;
const H = 860;
const C = {
  bg: "#FAFAF8",
  ink: "#101410",
  muted: "#6f7670",
  line: "#D9DEDA",
  soft: "#F5F7F5",
  accent: "#1F7A5A",
  accent2: "#36A582",
  amber: "#C99A53",
  blue: "#51A8E8",
  teal: "#44BFAE",
  black: "#0B0B0B",
};

function esc(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

function text(x, y, value, size = 24, fill = C.ink, weight = 400, anchor = "start", extra = "") {
  return `<text x="${x}" y="${y}" font-size="${size}" font-weight="${weight}" fill="${fill}" text-anchor="${anchor}" ${extra}>${esc(value)}</text>`;
}

function rect(x, y, w, h, r, fill, stroke = "none", sw = 1, extra = "") {
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" ${extra}/>`;
}

function multiline(x, y, lines, size = 22, fill = C.ink, weight = 400, leading = 1.35, anchor = "start") {
  return lines.map((line, i) =>
    text(x, y + i * size * leading, line, size, fill, weight, anchor),
  ).join("\n");
}

function phoneItem(x, y, icon, label) {
  return [
    rect(x, y, 280, 56, 9, "#FFFFFF", C.line, 1.4),
    text(x + 54, y + 36, `${icon}  ${label}`, 22, C.ink, 500),
  ].join("\n");
}

function harnessBlock(x, y, color, num, title, body, code) {
  return [
    rect(x, y, 520, 106, 10, "#FFFFFF", color, 2.6),
    text(x + 32, y + 38, `⓵`.replace("1", num), 24, C.accent, 700),
    text(x + 68, y + 38, title, 25, C.accent, 700),
    text(x + 68, y + 72, body, 20, C.muted, 400),
    text(x + 68, y + 94, code, 17, color, 600, "start", 'font-family="JetBrains Mono, Consolas, monospace"'),
  ].join("\n");
}

const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
  <defs>
    <marker id="arrow" markerWidth="14" markerHeight="14" refX="12" refY="7" orient="auto" markerUnits="strokeWidth">
      <path d="M0,0 L14,7 L0,14 Z" fill="${C.accent}"/>
    </marker>
    <marker id="arrowGrey" markerWidth="14" markerHeight="14" refX="12" refY="7" orient="auto" markerUnits="strokeWidth">
      <path d="M0,0 L14,7 L0,14 Z" fill="#7E8580"/>
    </marker>
    <filter id="softShadow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="8" stdDeviation="10" flood-color="#000000" flood-opacity="0.07"/>
    </filter>
  </defs>
  <style>
    text { font-family: "Microsoft YaHei UI", "Noto Sans SC", "PingFang SC", Arial, sans-serif; dominant-baseline: alphabetic; }
  </style>
  <rect width="${W}" height="${H}" fill="${C.bg}"/>

  <!-- Left phone endpoint -->
  ${rect(86, 74, 350, 680, 12, "#FFFFFF", C.line, 2, 'filter="url(#softShadow)"')}
  ${text(261, 120, "端 · 游客手机", 26, C.ink, 700, "middle")}
  ${phoneItem(121, 160, "🎙", "麦克风 · 语音输入")}
  ${phoneItem(121, 238, "📍", "GPS 定位触发")}
  ${phoneItem(121, 316, "🎯", "现场任务互动")}
  ${phoneItem(121, 394, "🔊", "语音播放 + 字幕")}
  ${phoneItem(121, 472, "✋", "随时打断 · 追问")}
  ${phoneItem(121, 550, "🗺", "路线手账")}

  <!-- Harness -->
  ${rect(535, 74, 610, 680, 12, "#F7FBF8", C.accent, 3)}
  ${text(840, 120, "文旅 Harness（我们的壁垒）", 28, C.accent, 800, "middle")}
  ${harnessBlock(572, 152, C.amber, "1", "策展数据", "人工把关的可信知识库 · 每条史实标注出处", "symbolic · 防幻觉")}
  ${harnessBlock(572, 290, C.blue, "2", "地理位置", "走到哪 · 注入当前点位上下文与路线进度", "context · 千景千讲")}
  ${harnessBlock(572, 428, C.teal, "3", "Memory", "记住兴趣 · 问过什么 · 走过哪", "state · 千人千讲")}
  ${rect(572, 590, 520, 64, 9, C.accent, C.accent, 2)}
  ${text(832, 631, "编排 → 注入 session.update / instructions", 23, "#FFFFFF", 800, "middle")}
  ${multiline(840, 694, ["+ 人工策展（搭档）：选路线 · 选信源 · 设计讲解逻辑", "= 划定「可信边界」的那只手"], 20, C.muted, 500, 1.35, "middle")}

  <!-- Realtime model -->
  ${rect(1230, 244, 310, 292, 12, C.black, C.black, 1.5, 'filter="url(#softShadow)"')}
  ${text(1385, 310, "实时语音模型", 29, "#FFFFFF", 800, "middle")}
  ${text(1385, 354, "FROZEN", 19, C.accent2, 800, "middle", 'font-family="JetBrains Mono, Consolas, monospace"')}
  ${multiline(1385, 414, ["Step-Audio 2.5", "Realtime"], 25, "#D8D8D8", 400, 1.35, "middle")}
  ${multiline(1385, 502, ["端到端 · 全双工", "不训练 · 不微调"], 20, "#A9ADA9", 500, 1.35, "middle")}

  <!-- Main arrows -->
  <path d="M436 260 L522 260" stroke="${C.accent}" stroke-width="4" fill="none" marker-end="url(#arrow)"/>
  <path d="M436 344 L522 344" stroke="${C.accent}" stroke-width="4" fill="none" marker-end="url(#arrow)"/>
  <path d="M436 498 L522 498" stroke="${C.accent}" stroke-width="4" fill="none" marker-end="url(#arrow)"/>
  <path d="M1145 395 L1215 395" stroke="${C.accent}" stroke-width="4" fill="none" marker-end="url(#arrow)"/>

  <!-- Feedback loop -->
  <path d="M1220 445 C1130 600 870 690 440 530" stroke="#7E8580" stroke-width="3" fill="none" stroke-dasharray="9 10" marker-end="url(#arrowGrey)"/>

  <!-- Labels -->
  ${text(480, 232, "触发", 18, C.accent, 700, "middle", 'font-family="JetBrains Mono, Consolas, monospace"')}
  ${text(480, 318, "任务", 18, C.accent, 700, "middle", 'font-family="JetBrains Mono, Consolas, monospace"')}
  ${text(480, 472, "反馈", 18, C.accent, 700, "middle", 'font-family="JetBrains Mono, Consolas, monospace"')}
  ${text(1186, 368, "注入 harness", 18, C.accent, 700, "middle", 'font-family="JetBrains Mono, Consolas, monospace"')}

  <!-- Footer -->
  ${text(86, 820, "步语：实时语音导览 × 现场任务交互 × 记录路线手账", 20, C.muted, 500)}
</svg>`;

const svgPath = path.join(outDir, "buyu-tech-architecture-task-interaction.svg");

fs.writeFileSync(svgPath, svg, "utf8");
console.log(svgPath);
