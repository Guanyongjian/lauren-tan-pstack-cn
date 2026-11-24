### Autopilot-stack

运行 Autopilot-full playbook，但不 merge。

1. **取代 step 5，停在 verified。** 当每个 PR 都在其当前 head 上验证并变绿时就停，然后把 PR 交给 operator。交接之后，没有 operator 的许可谁都不 push。每次 loop tick 的 prompt 都点名这个 file，所以每个 tick 都能看到 no-merge 规则。
2. **只有当某个 PR 建立在另一个 PR 之上时才 stack。** 这是 step 3 唯一的例外。按 `playbooks/opening-a-pr.md` 的 **Size and stacks**，让该 PR 基于另一个 PR 的 branch，而不是 trunk。取代 step 2 的 rebase onto trunk，每个 PR 改为 rebase 到其 parent PR 的 branch 上，而 stack root 则 rebase 到 trunk 上。底下那个 PR 有了新 head 会重新 stack 它上面的 PR，而 `git patch-id` 在重新 stack 后未变的 PR 保留其 verdict。

**Reply：** 取代「merge 了什么」，列出每个 PR 及其 verdict。