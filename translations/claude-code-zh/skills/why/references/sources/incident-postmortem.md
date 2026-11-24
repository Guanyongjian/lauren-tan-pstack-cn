# Incident & Postmortem Context

- **Linear**：找带 `incident`、`sev-*`、`postmortem-action-item`、`reliability` label 的 ticket
- **Slack**：在目标 code 被加入的日期前后，搜 `#sev-*` 和 `#incident-*` channel
- **Git**：message 形如 "fix for incident"、"add defensive check"，或 "revert" 之后跟着 "re-apply with..." 的 commit，都是强 signal