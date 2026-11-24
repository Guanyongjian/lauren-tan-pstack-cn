# Reproduce automation prompt

> 供被复制的 setup workflow 使用的源料。在 `automate` 确认被复制的 pack 已 commit 到该 automation 将要运行的 repository 之后，把这份意图改写进一个内置的 `automate` 草稿。

本次运行请阅读并遵循 `.cursor/automations/benny/skills/reproduce-and-fix-issues/SKILL.md`。

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

创建意图应把它描述为配置好的 source Slack channel 里的一份新的顶层 report。它应包含配置好的 repository、默认 branch、issue tracker、control adapter、feature map，以及开 draft pull request 的能力。

把 source channel 和 root thread 时间戳视为不可变。若其中之一缺失或与配置不符，就停下，不要发帖。

在这个确切的 thread 里，等待来自配置好的 triage 身份的、配置好的 triage 标记。只有当标记是 `[benny:bug]` 或 `[benny:performance]` 时才继续。

尝试 repro 之前，先要求配置好的 control-adapter skill 就位。通过真实 UI 把这个确切的区分性 symptom 复现两次。核实已有的 pull request 或 commit，但不要在其之上另写。只有在 repro 已确认、且满足 operational file 的 fix gate 之后，才尝试一个有界的修复。

coordinator 是唯一的 Slack 发帖者。每一份 child prompt 都必须禁止 `SendSlackMessage`、`PostToSlack`、`chat.postMessage` 以及一切其他 Slack 写入。child 只返回 finding。

绝不要在 source channel 里发 root message。