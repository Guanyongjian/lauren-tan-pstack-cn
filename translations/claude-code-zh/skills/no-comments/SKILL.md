---
name: no-comments
description: "spawn Comment Sicko，修掉被采纳的 finding，并为自称的 constraint 提供 encoding 方案。"
disable-model-invocation: true
---

# No comments

在 Claude Code 中，遵循本 skill 之前，每个 session 先读一次 [Claude Code 适配说明](../../docs/harness/claude-code.md)。它把 pstack skill 里的 Cursor 名字映射到 Claude Code。

spawn Comment Sicko。对被采纳的 finding 采取行动。

以 Comment Sicko 的新鲜视角为准。

## Scope

用 caller 给的 file 或 diff。否则用当前 diff 对 base branch（默认 `main`），包含 working tree。

## Steps

1. 用 `Task` 配 `subagent_type: "comment-sicko"` spawn。把 scope 传过去。按 **poteto-mode** skill 的 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。不要复述它的规则。
2. 检查它的 report 和 diff。以下一律驳回：application-code 的编辑、scope escape、被 exception 保护的 deletion、说错的 `MUST KILL` 理由，以及把保留下来的 intentional code 判为有罪的 flag。针对「our-code surprise」的 reshape flag 仍然可执行。不要恢复那些 comment。只有当 keep 能证明它涉及我们无法改变的东西时才成立。审查漏掉的 scoped lint 和 TypeScript suppression。涉及 correctness 或 safety 的 suppression 仍然是可执行的 `MUST KILL`。只有在给出确切 exception 和 scoped proof 时才恢复 deletion。在接受单薄的 `IMPORTANT` 或 `do not remove` 类 kill 或 keep 之前，对其 symbol 跑一次 `/how` 或 `/why`。如果某个 kill 含糊，不要恢复。如果某个 keep 被驳倒或仍然含糊，就删掉它。撤回并重跑一份被驳回的 report，并点名失败原因。第二份被驳回就上报为 open，并让 `/no-comments` 失败。
3. 直接修掉简单的已采纳 flag：删掉死路径、去掉一个 parameter，或用真正的 API。如果某个 fix 需要 shape，就对已采纳的那批和周边 code 跑一次 `/architect`。停在 sketch。architect 负责 shape，step 4 负责实现。
4. 在 scope 内实现最小的 root-cause fix。移除每一个被点名的 workaround。如果 root cause 在 scope 之外，就落地 scope 内最小的 fix，并把其余上报为 open。**principle-fix-root-causes** 和 **principle-redesign-from-first-principles** 这两个 skill 只提供意图指引。它们都不授权扩大 fence，也不授权修 fence 之外的实例。绝不要硬加 symptom guard。
5. constraint comment 会写 `do not remove`、`do not change wording`，或 `talk to X before changing`。涉及我们无法改变之物的 keep 予以保留。提供 scope 内最便宜的 type、runtime、test 或 CI lint 方案。等待交互式批准。unattended 与 eval 场景需要 caller 预先批准。若获批准，先 encode 再删除。否则删除、把 constraint 上报为 open，并勾勒 scope 之外的工作。
6. 汇报 deletion 数量、被恢复的 comment、重跑情况、architect sketch、fix、encoding offer、已执行的 encoding、未被强制的 constraint，以及其他 open 的工作。
