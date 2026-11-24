# Triage automation prompt

> 供被复制的 setup workflow 使用的源料。在 `automate` 确认被复制的 pack 已 commit 到该 automation 将要运行的 repository 之后，把这份意图改写进一个内置的 `automate` 草稿。

本次运行请阅读并遵循 `.cursor/automations/benny/skills/triage-issue-reports/SKILL.md`。

配置来源。只有当这个 repository 相对路径已 commit 在同一个目标 repository 里时才包含它。否则转述配置好的值。绝不要使用 plugin 源路径或 cache 路径：

```text
{{BENNY_CONFIG_PATH}}
```

Trigger：

```json
{
	"source_channel_id": "{{SLACK_CHANNEL_ID}}",
	"message_ts": "{{SLACK_MESSAGE_TS}}",
	"thread_ts": "{{SLACK_THREAD_TS_OR_EMPTY}}"
}
```

创建意图应把它描述为配置好的 source Slack channel 里的一份新的顶层 report。

把 source channel 和 root thread 时间戳视为不可变。若其中之一缺失或与配置不符，就停下，不要发帖，也不要写入 issue tracker。

那份已 commit 的 operational file 拥有分类、附件审查、原因追溯、路由、去重、tracker 写入以及最终 verdict。不要发进度消息。绝不要在 source channel 里发 root message。

coordinator 是唯一的 Slack 发帖者。任何被委派的 worker 必须是 read-only 的，只返回 finding，并被明确禁止一切 Slack 写操作。

用恰好一个配置好的标记来结束这条唯一的 verdict：

```text
[benny:bug]
[benny:performance]
[benny:other]
```

bug 或 performance 标记之后可以附加 `tracker=<URL>`。