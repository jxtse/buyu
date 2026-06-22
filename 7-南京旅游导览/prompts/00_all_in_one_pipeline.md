# 任务：一次性生成中华文化路线点位事实卡与 5 个版本语音讲稿

你是南京文化路线语音导览内容团队，负责完成“资料整理 -> 事实卡 -> 讲述角度 -> 语音讲稿 -> 风险核查”的完整流程。

请基于下方点位配置和来源资料包，直接输出完整结果。不要直接搬运来源原文，所有讲稿必须是原创表达。

## 点位配置

```yaml
{{point_config}}
```

## 来源资料包

{{source_bundle}}

## 需要生成的讲稿版本

```json
{{script_versions}}
```

## 输出内容

请按以下结构输出：

### 1. 事实卡

输出结构化事实卡，包括：

- `route_name`
- `stop_name`
- `location_note`
- `core_facts`：每条包含 `claim`、`source_ids`、`confidence`、`citation_note`
- `context_facts`
- `story_materials`：必须区分“史实”“传说”“推测”
- `uncertain_claims`：每条标注“需人工核查”
- `do_not_use_as_fact`

### 2. 讲述角度

输出 8 到 12 个讲述角度，每个角度包括：

- `angle_title`
- `suitable_audience`
- `opening_hook`
- `facts_to_use`
- `avoid_risks`
- `recommended_version`

### 3. 五个版本讲稿

分别生成：

1. 普通版 3 分钟
2. 亲子版 3 分钟
3. 趣味版 3 分钟
4. 专业版 5 分钟
5. 英文版 3 分钟

每个版本包含：

- `title`
- `version`
- `estimated_duration`
- `script`
- `citation_map`
- `uncertain_claims_used`
- `human_review_notes`

### 4. 口播优化建议

对每个版本给出：

- 建议语速
- 停顿建议
- 专名读音提示
- 哪些句子适合录音时放慢

### 5. 事实与合规核查

最后输出一个总审核表，包括：

- `pass_status`：pass / revise / reject
- `issues`
- `line_or_sentence`
- `reason`
- `suggested_revision`
- `required_human_checks`
- `citation_gaps`

## 强制合规要求

- 不要直接搬运原文。
- 只提取事实和可引用信息。
- 讲稿必须是原创表达。
- 对不确定事实标注“需人工核查”。
- 游客上传图片、小红书笔记、媒体图片不能默认用于产品，只能作为调研参考。
- 每条关键事实尽量保留来源记录。
- “最大”“第一”“唯一”“从未被攻克”等强判断，除非有权威来源支撑，否则必须放入“需人工核查”。
- 民间传说只能写成传说，不能写成确定史实。
- 战争、伤亡和历史创伤相关内容应庄重克制，不要娱乐化。
