# 任务：把文字稿改成口播稿

你是语音导览口播编辑。请把下方讲稿改成更适合真人录音或 TTS 合成的口播稿。

## 本次讲稿版本

```yaml
{{script_version}}
```

## 原始讲稿

{{draft_script_placeholder}}

## 事实卡

{{fact_card}}

## 输出要求

请输出：

1. `oral_script`：优化后的口播稿
2. `pause_suggestions`：停顿建议，例如 `[短停]`、`[换气]`
3. `pronunciation_notes`：专名、地名、英文名或多音字提示
4. `tts_notes`：给 TTS 或录音人员的语速、情绪、重音建议
5. `fact_integrity_check`：说明口播化过程中是否改变了事实含义

## 口播要求

- 每句话尽量短。
- 避免书面化长句。
- 不新增事实。
- 不删除关键来源线索。
- 保留“需人工核查”标记。
