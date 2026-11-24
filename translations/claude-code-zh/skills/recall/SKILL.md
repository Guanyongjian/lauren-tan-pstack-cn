---
name: recall
description: "从你自己的 chat history、live state 和 shared record（user 反馈、previous fix、incident）重建最近的工作 context，然后交回一份紧凑的 current-state brief。用于 'recall my work on X'、'catch me up'、'what have I been working on'、'where did I leave off'，以及开始或恢复工作之前。"
disable-model-invocation: true
---

# Recall

在 Claude Code 中，遵循本 skill 之前，每个 session 先读一次 [Claude Code 适配说明](../../docs/harness/claude-code.md)。它把 pstack skill 里的 Cursor 名字映射到 Claude Code。

**在你开始或恢复工作之前，重建 user 最近的工作 context，并交回一份紧凑的 capsule：现在处于什么状态、下一步做什么。**

保持紧凑、扣题。只读 in-scope thread 需要的东西，然后停下。

你的 context 存在两份记录里。你自己的 chat history 保存你做过什么、决定了什么。shared record 保存同一段 code 周边以其他名义发生的一切：user 反复报告的 symptom、已经上线又被回滚的 fix、仍在 prod 里触发的 error。第二份记录正是 **why** skill 所搜索的东西，横跨 source control、issue tracker、chat 与 issue channel、long-form docs 以及 error tracking。如果某个 feature 拖着一条很长的 bug 尾巴，它的大部分故事都在那里，所以不要只凭 transcript 去重建。

transcript 位于 `~/.cursor/projects/<slug>/agent-transcripts/<uuid>/<uuid>.jsonl`，其中 `<slug>` 是 workspace 路径去掉前导斜杠、并把每个 "/" 换成 "-"（于是 `/Users/you/proj` 变成 `Users-you-proj`）。每一行是一条 chat message。

1. 先归类，再路由。要恢复某一个特定的旧 chat，用 `session-pickup` playbook，不是这个。把习惯固化成持久 skill 是 `automate-me`。对工作做一份人类可读的总结是另一件事。recall 是在你行动之前加载最近若干 chat 的工作 context。如果 user 已经给了你完整的状态 capsule（path、branch、change），就用它，跳过挖掘。
2. 搜索之前先锁定 scope。固定时间窗（"recent" 是一个真实区间，默认最近 7 天）、主题（如果点了名）以及 workspace（默认当前这个。未经要求绝不读其他项目的 transcript）。把你理解的 scope 复述回去。绝不把 "all" 悄悄变成 "recent N"。
3. 在 chat history 里 fan out。用快而便宜的 model spawn 并行 subagent，每个负责 corpus 的一个切片。告诉每个 subagent：按真实修改时间（`ls -t`）排序候选，绝不按 UUID 名称排序；先 grep 主题，然后只读匹配的 chat、且只读其中相关的区域；跳过当前 chat 以及明显的噪声（subagent、eval 和 test chat）。每个都按同一 schema 返回，每个 chat 一块：topic、user 的 goal、decision、open thread、struggle 与 correction，以及 artifact（PR、ticket、branch），每项都引用 chat UUID。只有一两个 chat 时，跳过 fan-out，直接搜。原始 transcript 留在 subagent 里，主线程只拿它们的 finding。按 **poteto-mode** skill 的 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。
4. 只要主题点名了某个 feature、file、subsystem、area 或 bug，就清扫 shared record。这是默认动作，不是可自由裁量的判断，而 "my work on X" 并不豁免它。交给 **why** skill 的 source investigator，但把问题从 "why was this built this way" 转向 "what's the current state, what's been tried and didn't hold, and what are users still reporting"。复用它的 per-source playbook，让 investigator 与 chat-history 挖掘并行跑，并继承它的姿态：每个 source 一个 investigator、null 结果也是 finding、跳过不可用的 MCP 并说明。把返回的东西折进 brief。只有在没有点名目标的纯活动回顾（如 "what did I do this week"）时才跳过这一步——那种情况下你自己的 history 和 live state 就是全部答案。
5. 对着 live state 验证。把挖掘与清扫浮现出的 PR、branch、ticket 用 `git` 和 `gh` 核对一遍。当答案取决于某个 agent 实际做了什么（它跑了哪些 tool、读了哪些 file、撞到哪些 error）时，读完整 transcript，而不只是裁剪过的本地副本。
6. 按下面的 contract 写 brief。按 thread 分组。紧扣点名的主题。

## Output contract

先 capsule，再 thread 状态，再问题，最后下一步。更深的细节放在下面，或直接砍掉。

- **Capsule。** 最多 5 条 bullet。这项工作是什么、整体处于什么位置。
- **Threads。** 每行一条，前缀恰好是一个状态 tag：`[merged #N]`、`[open PR #N]`、`[in flight <branch>]`、`[verified, uncommitted]`、`[reverted #N]`，或 `[planned, not started]`。没有 tag 的 thread 还没做完，所以要打 tag。
- **Problems。** 最多 5 条，是反复出现的那些。包括 user 持续报告的 symptom，以及任何上线后又被回滚的 fix，好让下一次尝试从上次失败处起步。
- **Next move。** 唯一最有价值的下一步行动，要具体。

相邻的 feature 或 ticket 除非阻塞当前这项，否则不要写进来。当 capsule 和 thread 行超出一屏时，先砍细节再砍 thread。brief 要通过 **unslop** skill 来写；chat 里的 finding 用 UUID 引用，shared record 的 finding 按其来源引用（PR #、ticket ID、chat permalink、error-tracker issue）；任何对外输出前先对私有 context 做 sanitize。

**Reply：** 按上面的 contract 给出 brief。
