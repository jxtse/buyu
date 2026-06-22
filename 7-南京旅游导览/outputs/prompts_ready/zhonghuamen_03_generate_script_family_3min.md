# 任务：生成语音导览讲稿

你是南京文化路线语音导览撰稿人。请根据点位配置、事实卡和讲述角度，生成指定版本的原创语音讲稿。

## 本次讲稿版本

```yaml
{
  "id": "family_3min",
  "label": "亲子版 3 分钟",
  "target_audience": "带孩子游览的家庭",
  "duration": "3分钟",
  "language": "zh-CN",
  "tone": "轻松、互动、少术语，加入少量观察问题"
}
```

## 点位配置

```yaml
route_name: 老城南文化路线
stop_name: 中华门
location_note: 南京明城墙南段、老城南交通咽喉位置；城门坐北朝南，连接城墙、秦淮河、长干桥、镇淮桥等空间线索。
target_audience: 普通游客
duration: 3分钟
language: zh-CN
tone: 温和、清晰、有画面感、适合边走边听
human_review_status: needs_review

source_materials:
  - id: source_wlj_001
    title: 小课堂 | 天下第一瓮城——南京城墙中华门
    type: government_webpage_notes
    url: https://wlj.nanjing.gov.cn/ztzl/mcq/gzqk/202302/t20230228_3838766.html
    path: data/raw/zhonghuamen_wlj_notes.txt
    usage_note: 南京市文化和旅游局网站发布，文章来源为南京城墙保护管理中心；建议作为主来源。
  - id: source_sohu_001
    title: 历史上“最坚固”的南京城墙，却只有一座城门保存完整，规模第一
    type: secondary_webpage_notes
    url: https://www.sohu.com/a/452699824_100184549
    path: data/raw/zhonghuamen_sohu_notes.txt
    usage_note: 旅行作者文章，可作调研补充；涉及“规模第一”等表述需回到权威来源核查。
  - id: source_toutiao_001
    title: 南京明城墙（中华门瓮城）是怎样一个景点？有哪些历史文化？
    type: secondary_webpage_user_supplied_text
    url: https://www.toutiao.com/article/7424362615339500042/
    path: data/raw/zhonghuamen_toutiao_pending.txt
    usage_note: 用户已补充正文，可作调研补充；涉及战争、拆墙、人物轶事、大报恩寺强判断的内容需回到权威来源核查。

verified_facts:
  - claim: 中华门原名聚宝门，是明代南京都城城墙十三座城门之一。
    source_ids: source_wlj_001
    confidence: high
  - claim: 中华门坐北朝南，前后有内、外秦淮河横贯东西，是南京老城南交通咽喉，也是明代南京都城地理位置上的正南门。
    source_ids: source_wlj_001
    confidence: high
  - claim: 聚宝门名称的民间故事常与沈万三、聚宝盆相关，但官方资料指出其真正得名与城南聚宝山，即今雨花台有关。
    source_ids: source_wlj_001
    confidence: high
  - claim: 民国十七年，即 1928 年，聚宝门更名为中华门。
    source_ids: source_wlj_001
    confidence: high
  - claim: 中华门瓮城位于城门内侧，设有三道内瓮城，整体俯视近似“目”字形结构。
    source_ids: source_wlj_001
    confidence: high
  - claim: 现存中华门瓮城东西宽 118.5 米，南北长 128 米，占地 15168 平方米。
    source_ids: source_wlj_001
    confidence: high
  - claim: 现存结构包括主城台、三道内瓮城、27 个藏兵洞、东西马道，以及 20 世纪 80 年代为游客登城游览修建的一条登城曲道。
    source_ids: source_wlj_001
    confidence: high
  - claim: 官方资料估算，中华门瓮城可藏兵三千、藏粮万担。
    source_ids: source_wlj_001
    confidence: high
  - claim: 中华门主城门与三道内瓮城城门南北贯通，每道门都设门和闸，闸为千斤闸。
    source_ids: source_wlj_001
    confidence: high
  - claim: 1988 年，南京城墙被列为全国重点文物保护单位。
    source_ids: source_wlj_001
    confidence: high
  - claim: 2006 年和 2012 年，以南京城墙为首的“中国明清城墙”联合申遗项目两次被列入《中国世界遗产预备名单》。
    source_ids: source_wlj_001
    confidence: high
  - claim: 1937 年 12 月，中华门是南京保卫战主战场之一；城顶原有城楼毁于侵华日军炮火，之后未复建。
    source_ids: source_wlj_001
    confidence: high
  - claim: 今日头条补充文本也提到聚宝门得名与聚宝山、1928 年更名中华门等信息，可与南京市文旅局来源互相参照。
    source_ids: source_toutiao_001, source_wlj_001
    confidence: medium
  - claim: 今日头条补充文本提到瓮城防御可形成“瓮中捉鳖”的效果，可作为口语化解释，但应避免夸张成不可攻破的绝对结论。
    source_ids: source_toutiao_001
    confidence: medium

story_angles:
  - 从“老城南正南门”进入南京城的空间关系
  - 从聚宝门之名区分史实和传说
  - 从三道内瓮城理解古代城门防御
  - 从“目”字形俯视结构讲设计巧思
  - 从藏兵洞、马道、千斤闸讲军事功能
  - 从 1937 年城楼被毁讲遗产记忆和抗战纪念
  - 从中华门连接秦淮河和老城南街巷讲城市生活
  - 从远望大报恩寺讲老城南文化地标之间的空间关系

script_versions:
  - id: normal_3min
    label: 普通版 3 分钟
    target_audience: 初次到访南京的普通游客
    duration: 3分钟
    language: zh-CN
    tone: 清晰、亲切、适合边走边听
  - id: family_3min
    label: 亲子版 3 分钟
    target_audience: 带孩子游览的家庭
    duration: 3分钟
    language: zh-CN
    tone: 轻松、互动、少术语，加入少量观察问题
  - id: fun_3min
    label: 趣味版 3 分钟
    target_audience: 喜欢故事和冷知识的年轻游客
    duration: 3分钟
    language: zh-CN
    tone: 有节奏、有悬念、但不夸张
  - id: expert_5min
    label: 专业版 5 分钟
    target_audience: 对历史建筑、城防体系和城市史感兴趣的游客
    duration: 5分钟
    language: zh-CN
    tone: 稍专业、信息密度更高、引用意识明确
  - id: english_3min
    label: 英文版 3 分钟
    target_audience: English-speaking visitors
    duration: 3 minutes
    language: en
    tone: Clear, vivid, accessible, suitable for audio touring

script_output:
  normal_3min: outputs/scripts/zhonghuamen_normal_3min.md
  family_3min: outputs/scripts/zhonghuamen_family_3min.md
  fun_3min: outputs/scripts/zhonghuamen_fun_3min.md
  expert_5min: outputs/scripts/zhonghuamen_expert_5min.md
  english_3min: outputs/scripts/zhonghuamen_english_3min.md

uncertain_claims:
  - claim: “天下第一瓮城”是常见称号，可用于讲稿，但应作为称誉或通称，不宜解释为严格排名。
    reason: 虽见于官方标题和表述，但“第一”类表达上线前仍建议保留语境。
    review_label: 需人工核查
  - claim: “全世界现存规模最大、结构最复杂的古城门”等表述。
    reason: 搜狐文章使用类似表述，但属于强比较结论，需以权威文博或学术来源核查。
    review_label: 需人工核查
  - claim: 沈万三、聚宝盆和戴鼎成的具体故事情节。
    reason: 官方资料明确以“传说”叙述，不能写成确定史实。
    review_label: 需人工核查
  - claim: 今日头条页面中的具体事实。
    reason: 正文已补充，但来源属于二手平台文章；其中多数延展信息需要权威来源复核。
    review_label: 需人工核查
  - claim: 南京古代城门夜间 7 点左右关闭、凌晨 5 点再次打开。
    reason: 今日头条补充文本提供该说法，但需要制度史或地方志来源核查。
    review_label: 需人工核查
  - claim: 明朝设置 13 个千户所用于加强南京城防。
    reason: 今日头条补充文本提供该说法，需核查军事制度和南京城防资料。
    review_label: 需人工核查
  - claim: 中华门一直没有被从正面攻克过。
    reason: 属于强结论，需要权威史料支撑，讲稿中不宜直接使用。
    review_label: 需人工核查
  - claim: 南京保卫战中防守雨花台和中华门的 88 师官兵几乎都打光。
    reason: 涉及具体战史和伤亡判断，必须查证权威史料，表达需庄重克制。
    review_label: 需人工核查
  - claim: 1929 年蒋介石下令拆除南京城墙，徐悲鸿和南京市民反对后拆墙令作罢。
    reason: 今日头条补充文本提供该叙述，需查证南京城墙保护史来源。
    review_label: 需人工核查
  - claim: 1956 年朱偰奔走呼吁，使中华门城堡和石头城免于被拆。
    reason: 可作为城墙保护史线索，但需以朱偰研究、南京城墙保护资料或文博来源核实。
    review_label: 需人工核查
  - claim: 大报恩寺相关的“第二座寺庙”“南方第一座佛寺”“中世纪世界七大奇迹”“天下第一塔”“规格最高、规模最大、保存最完整”等表述。
    reason: 属于中华门路线延展点位信息，且包含多处强比较结论；若写进中华门讲稿只能作为远望提示，不能当作中华门事实。
    review_label: 需人工核查

citations:
  - source_id: source_wlj_001
    citation_note: 南京市文化和旅游局网站《小课堂 | 天下第一瓮城——南京城墙中华门》，文章来源：南京城墙保护管理中心，发布时间：2023-02-20。
  - source_id: source_sohu_001
    citation_note: 搜狐号“行者老张”文章《历史上“最坚固”的南京城墙，却只有一座城门保存完整，规模第一》，发布时间：2021-02-26；仅作补充调研。
  - source_id: source_toutiao_001
    citation_note: 今日头条页面《南京明城墙（中华门瓮城）是怎样一个景点？有哪些历史文化？》；用户已补充正文，仅作补充调研，关键事实需另行核查。
```

## 事实卡

# 事实卡草稿：中华门

> 这是工具根据点位配置生成的初始事实卡草稿。请先运行 `01_extract_facts` prompt，再由人工审核。

```json
{
  "route_name": "老城南文化路线",
  "stop_name": "中华门",
  "location_note": "南京明城墙南段、老城南交通咽喉位置；城门坐北朝南，连接城墙、秦淮河、长干桥、镇淮桥等空间线索。",
  "core_facts": [
    {
      "claim": "中华门原名聚宝门，是明代南京都城城墙十三座城门之一。",
      "source_ids": "source_wlj_001",
      "confidence": "high"
    },
    {
      "claim": "中华门坐北朝南，前后有内、外秦淮河横贯东西，是南京老城南交通咽喉，也是明代南京都城地理位置上的正南门。",
      "source_ids": "source_wlj_001",
      "confidence": "high"
    },
    {
      "claim": "聚宝门名称的民间故事常与沈万三、聚宝盆相关，但官方资料指出其真正得名与城南聚宝山，即今雨花台有关。",
      "source_ids": "source_wlj_001",
      "confidence": "high"
    },
    {
      "claim": "民国十七年，即 1928 年，聚宝门更名为中华门。",
      "source_ids": "source_wlj_001",
      "confidence": "high"
    },
    {
      "claim": "中华门瓮城位于城门内侧，设有三道内瓮城，整体俯视近似“目”字形结构。",
      "source_ids": "source_wlj_001",
      "confidence": "high"
    },
    {
      "claim": "现存中华门瓮城东西宽 118.5 米，南北长 128 米，占地 15168 平方米。",
      "source_ids": "source_wlj_001",
      "confidence": "high"
    },
    {
      "claim": "现存结构包括主城台、三道内瓮城、27 个藏兵洞、东西马道，以及 20 世纪 80 年代为游客登城游览修建的一条登城曲道。",
      "source_ids": "source_wlj_001",
      "confidence": "high"
    },
    {
      "claim": "官方资料估算，中华门瓮城可藏兵三千、藏粮万担。",
      "source_ids": "source_wlj_001",
      "confidence": "high"
    },
    {
      "claim": "中华门主城门与三道内瓮城城门南北贯通，每道门都设门和闸，闸为千斤闸。",
      "source_ids": "source_wlj_001",
      "confidence": "high"
    },
    {
      "claim": "1988 年，南京城墙被列为全国重点文物保护单位。",
      "source_ids": "source_wlj_001",
      "confidence": "high"
    },
    {
      "claim": "2006 年和 2012 年，以南京城墙为首的“中国明清城墙”联合申遗项目两次被列入《中国世界遗产预备名单》。",
      "source_ids": "source_wlj_001",
      "confidence": "high"
    },
    {
      "claim": "1937 年 12 月，中华门是南京保卫战主战场之一；城顶原有城楼毁于侵华日军炮火，之后未复建。",
      "source_ids": "source_wlj_001",
      "confidence": "high"
    },
    {
      "claim": "今日头条补充文本也提到聚宝门得名与聚宝山、1928 年更名中华门等信息，可与南京市文旅局来源互相参照。",
      "source_ids": "source_toutiao_001, source_wlj_001",
      "confidence": "medium"
    },
    {
      "claim": "今日头条补充文本提到瓮城防御可形成“瓮中捉鳖”的效果，可作为口语化解释，但应避免夸张成不可攻破的绝对结论。",
      "source_ids": "source_toutiao_001",
      "confidence": "medium"
    }
  ],
  "story_angles": [
    "从“老城南正南门”进入南京城的空间关系",
    "从聚宝门之名区分史实和传说",
    "从三道内瓮城理解古代城门防御",
    "从“目”字形俯视结构讲设计巧思",
    "从藏兵洞、马道、千斤闸讲军事功能",
    "从 1937 年城楼被毁讲遗产记忆和抗战纪念",
    "从中华门连接秦淮河和老城南街巷讲城市生活",
    "从远望大报恩寺讲老城南文化地标之间的空间关系"
  ],
  "uncertain_claims": [
    {
      "claim": "“天下第一瓮城”是常见称号，可用于讲稿，但应作为称誉或通称，不宜解释为严格排名。",
      "reason": "虽见于官方标题和表述，但“第一”类表达上线前仍建议保留语境。",
      "review_label": "需人工核查"
    },
    {
      "claim": "“全世界现存规模最大、结构最复杂的古城门”等表述。",
      "reason": "搜狐文章使用类似表述，但属于强比较结论，需以权威文博或学术来源核查。",
      "review_label": "需人工核查"
    },
    {
      "claim": "沈万三、聚宝盆和戴鼎成的具体故事情节。",
      "reason": "官方资料明确以“传说”叙述，不能写成确定史实。",
      "review_label": "需人工核查"
    },
    {
      "claim": "今日头条页面中的具体事实。",
      "reason": "正文已补充，但来源属于二手平台文章；其中多数延展信息需要权威来源复核。",
      "review_label": "需人工核查"
    },
    {
      "claim": "南京古代城门夜间 7 点左右关闭、凌晨 5 点再次打开。",
      "reason": "今日头条补充文本提供该说法，但需要制度史或地方志来源核查。",
      "review_label": "需人工核查"
    },
    {
      "claim": "明朝设置 13 个千户所用于加强南京城防。",
      "reason": "今日头条补充文本提供该说法，需核查军事制度和南京城防资料。",
      "review_label": "需人工核查"
    },
    {
      "claim": "中华门一直没有被从正面攻克过。",
      "reason": "属于强结论，需要权威史料支撑，讲稿中不宜直接使用。",
      "review_label": "需人工核查"
    },
    {
      "claim": "南京保卫战中防守雨花台和中华门的 88 师官兵几乎都打光。",
      "reason": "涉及具体战史和伤亡判断，必须查证权威史料，表达需庄重克制。",
      "review_label": "需人工核查"
    },
    {
      "claim": "1929 年蒋介石下令拆除南京城墙，徐悲鸿和南京市民反对后拆墙令作罢。",
      "reason": "今日头条补充文本提供该叙述，需查证南京城墙保护史来源。",
      "review_label": "需人工核查"
    },
    {
      "claim": "1956 年朱偰奔走呼吁，使中华门城堡和石头城免于被拆。",
      "reason": "可作为城墙保护史线索，但需以朱偰研究、南京城墙保护资料或文博来源核实。",
      "review_label": "需人工核查"
    },
    {
      "claim": "大报恩寺相关的“第二座寺庙”“南方第一座佛寺”“中世纪世界七大奇迹”“天下第一塔”“规格最高、规模最大、保存最完整”等表述。",
      "reason": "属于中华门路线延展点位信息，且包含多处强比较结论；若写进中华门讲稿只能作为远望提示，不能当作中华门事实。",
      "review_label": "需人工核查"
    }
  ],
  "citations": [
    {
      "source_id": "source_wlj_001",
      "citation_note": "南京市文化和旅游局网站《小课堂 | 天下第一瓮城——南京城墙中华门》，文章来源：南京城墙保护管理中心，发布时间：2023-02-20。"
    },
    {
      "source_id": "source_sohu_001",
      "citation_note": "搜狐号“行者老张”文章《历史上“最坚固”的南京城墙，却只有一座城门保存完整，规模第一》，发布时间：2021-02-26；仅作补充调研。"
    },
    {
      "source_id": "source_toutiao_001",
      "citation_note": "今日头条页面《南京明城墙（中华门瓮城）是怎样一个景点？有哪些历史文化？》；用户已补充正文，仅作补充调研，关键事实需另行核查。"
    }
  ],
  "human_review_status": "draft: generated from config, needs AI extraction and human review"
}
```

## 人工审核提醒

- 核查关键事实是否有可靠来源。
- 将传说、推测和宣传性表述从事实中拆出来。
- 补充正式引用信息，例如机构名、文章名、发布日期、URL 或书目信息。

## 讲述角度

```json
[
  "从“老城南正南门”进入南京城的空间关系",
  "从聚宝门之名区分史实和传说",
  "从三道内瓮城理解古代城门防御",
  "从“目”字形俯视结构讲设计巧思",
  "从藏兵洞、马道、千斤闸讲军事功能",
  "从 1937 年城楼被毁讲遗产记忆和抗战纪念",
  "从中华门连接秦淮河和老城南街巷讲城市生活",
  "从远望大报恩寺讲老城南文化地标之间的空间关系"
]
```

## 输出格式

请输出：

1. `title`：讲稿标题
2. `version`：版本名称
3. `estimated_duration`：预计时长
4. `script`：完整口播讲稿
5. `citation_map`：讲稿中关键事实对应的来源编号
6. `uncertain_claims_used`：如果使用了不确定信息，必须标注“需人工核查”
7. `human_review_notes`：给人工审核员的提示

## 写作要求

- 讲稿必须是原创表达，不要直接搬运资料原句。
- 适合听，不适合只给人读；句子要短，转场要自然。
- 如果是亲子版，请降低术语密度，加入少量观察问题。
- 如果是趣味版，可以有悬念和轻松表达，但不能编造事实。
- 如果是专业版，可以提高信息密度，但必须保持可听性。
- 如果是英文版，请使用自然英文，不要逐字翻译中文稿。
- 所有不确定事实必须写成“传说”“有说法认为”“需人工核查”，不能写成确定史实。
