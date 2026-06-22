# 南京文化路线语音讲稿生成流水线

这是一个内容生产工具原型，不是完整 APP。它帮助你把景点资料整理成事实卡，并为同一个点位生成 5 种语音导览讲稿的 AI prompt：

- 普通版 3 分钟
- 亲子版 3 分钟
- 趣味版 3 分钟
- 专业版 5 分钟
- 英文版 3 分钟

## 文件夹说明

```text
data/raw/              原始文本
data/clean/            清洗后的文本
data/facts/            事实卡
prompts/               prompt 模板
outputs/prompts_ready/ 拼接好的 prompt
outputs/scripts/       生成后的讲稿
docs/SOP.md            完整操作流程
examples/              老城南路线示例
tools/                 命令行工具
```

## 你如何使用

### 第一步：放入资料

把景点文章、网页正文、书摘笔记或自己整理的资料保存成 `.txt` 文件，放进：

```text
data/raw/
```

不要直接使用游客图片、小红书笔记、媒体图片作为产品素材。它们只能作为调研参考。

### 第二步：填写点位配置

复制示例文件：

```text
examples/zhonghuamen.yaml
```

改成你的点位名称、来源文件、受众、时长和语气。字段说明可看：

```text
docs/point_schema.yaml
```

### 第三步：运行脚本

在项目文件夹中打开 PowerShell，运行：

```powershell
python tools/build_prompts.py examples/zhonghuamen.yaml
```

如果你新建了别的配置文件，把命令最后的文件名换成你的文件名。

### 第四步：复制 prompt 给 AI

打开：

```text
outputs/prompts_ready/
```

如果想省事，直接复制：

```text
zhonghuamen_00_ALL_IN_ONE_COPY_TO_GPT.md
```

这个文件会让 AI 一次性输出事实卡、讲述角度、5 个版本讲稿、口播建议和事实核查。

如果想更精细地控制质量，再按下面的分阶段方式使用。

按这个顺序复制给 ChatGPT 或其他模型：

1. `01_extract_facts`
2. `02_generate_story_angles`
3. 你需要的 `03_generate_script`
4. 对应的 `04_oralize_script`
5. 对应的 `05_fact_check`

### 第五步：人工审核讲稿

重点检查：

- 有没有直接搬运原文。
- 关键事实有没有来源。
- 传说和不确定信息有没有标注“需人工核查”。
- 有没有把“最大”“第一”“唯一”等宣传语当成事实。
- 语气、时长、受众是否合适。

### 第六步：导出成音频讲稿

审核通过后，把最终口播稿保存到：

```text
outputs/scripts/
```

再交给真人录音或 TTS 工具生成音频。导出音频前，建议先通读一遍，检查停顿、专名读音和现场游览动线。

## 示例命令

```powershell
python tools/build_prompts.py examples/zhonghuamen.yaml
```

运行成功后，会看到生成的文件列表。

## 内容合规原则

- 不直接搬运原文。
- 只提取事实和可引用信息。
- 讲稿必须是原创表达。
- 不确定事实标注“需人工核查”。
- 游客上传图片、小红书笔记、媒体图片不能默认用于产品。
- 每条关键事实尽量保留来源记录。
