# 南京文化路线语音讲稿生成流水线 SOP

## 1. 准备原始资料

把每个点位相关资料放入 `data/raw/`。建议每个来源单独保存为一个 `.txt` 文件。

可用来源包括：

- 景区、博物馆、文旅局、地方志、学术或出版资料。
- 已授权或可引用的机构文章。
- 自己整理的采访笔记或现场观察。

谨慎来源包括：

- 小红书、公众号、短视频评论、游客上传图片。
- 媒体图片、社交平台图片、未说明授权的摄影作品。
- 带有“最大”“第一”“唯一”等宣传性表述的二手文章。

这些材料可以用于调研，但不能默认作为产品素材或确定事实。

## 2. 清洗资料

把明显无关内容、广告、导航、重复段落删除后，放入 `data/clean/`。

清洗时不要改写事实含义。若原文有不确定、夸张或明显需要核查的说法，在旁边标注“需人工核查”。

## 3. 填写点位配置

复制 `docs/point_schema.yaml` 或 `examples/zhonghuamen.yaml`，新建一个点位配置文件，例如：

```powershell
examples/your_stop.yaml
```

至少填写：

- `route_name`
- `stop_name`
- `location_note`
- `source_materials`
- `target_audience`
- `duration`
- `language`
- `tone`
- `human_review_status`

如果已经人工确认过事实，可先写入 `verified_facts`。没有确认的内容放入 `uncertain_claims`。

## 4. 生成 prompt 和事实卡草稿

在项目根目录运行：

```powershell
python tools/build_prompts.py examples/zhonghuamen.yaml
```

脚本会生成：

- `data/facts/{点位}_fact_card_draft.md`
- `outputs/prompts_ready/` 下的可复制 prompt
- `outputs/scripts/` 下的讲稿占位文件

## 5. 按顺序使用 prompt

建议顺序：

1. 使用 `01_extract_facts` 提取事实卡。
2. 使用 `02_generate_story_angles` 生成讲述角度。
3. 分别使用 5 个 `03_generate_script` 生成讲稿：
   - 普通版 3 分钟
   - 亲子版 3 分钟
   - 趣味版 3 分钟
   - 专业版 5 分钟
   - 英文版 3 分钟
4. 把每个讲稿粘贴进对应 `04_oralize_script`，改成口播稿。
5. 把最终稿粘贴进对应 `05_fact_check`，做事实核查。

## 6. 人工审核

人工审核必须检查：

- 是否直接搬运原文。
- 是否每条关键事实都有来源编号。
- 是否把传说、推测、广告语写成确定事实。
- 是否存在没有强来源支撑的“最大”“第一”“唯一”。
- 是否误用了游客图片、小红书笔记、媒体图片等素材。
- 是否适合对应受众和时长。
- 是否保留了“需人工核查”标记。

审核完成后，将 `human_review_status` 改为：

- `draft`：草稿
- `needs_review`：待审核
- `approved`：已审核可用
- `rejected`：退回重写

## 7. 归档输出

最终讲稿保存到 `outputs/scripts/`。建议文件名包含：

- 路线名或点位名
- 版本
- 日期
- 审核状态

例如：

```text
zhonghuamen_normal_3min_approved_2026-06-20.md
```

导出音频前，再做一次听感检查：语速、停顿、专名读音、事实标注和游客现场动线是否自然。
