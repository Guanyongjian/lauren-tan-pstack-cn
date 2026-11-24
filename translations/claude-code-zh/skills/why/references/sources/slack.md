# Slack Conversations

## How to search it

Slack MCP 工具各不相同。先确认有哪个 Slack MCP 可用，并查看它的 tool schema。它可能需要 `mcp_auth`。如果认证失败，停下并报告这个缺口。

1. **Author-bounded 检索。** 在 PR merge 日期前后，找该 PR 作者发的 message。这能大幅缩小范围，而且常常一击中的。
3. **PR URL 检索。** Slack 里常在 review 或讨论时贴出 PR。搜这个 PR 的 URL（或者只搜 `/pull/<number>`）。
4. **错误字符串检索。** 如果 code 处理某个特定的错误，就搜那个错误字符串。事故 thread 常会浮现出来。

## Common pitfalls

- **Channel 考古的边界。** 很旧的 message 可能因保留策略而消失。如果在某个日期之前什么都找不到，就记下这条保留断崖。
- **搜不到的 DM。** 很多决定发生在不可检索的 DM 里。你会漏掉它们。这是已知的局限。
- **把玩笑当成「决定」。** Slack 是随意的。"Lol just do the thing" 不算决定，即便它出现在那个 commit 之前。要找经过斟酌的讨论。
- **单条 message 里的 context 塌缩。** 脱离了 thread，一条 message 的读法常常与在上下文里不同。永远去取完整 thread。
- **认证失败。** 如果该 MCP 未认证，就停下。不要编造 finding。报告 Slack 无法检索。