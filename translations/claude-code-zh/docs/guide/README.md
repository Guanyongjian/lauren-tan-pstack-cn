# pstack 指南

当你不再微观管理 agent 时，pstack 的效果最好。你描述想要什么，以及你如何知道它做完了。`/poteto-mode` 挑一个 playbook，在步骤需要时运行其他 skill，并把证据给你看。本指南用真实感的 prompt 教你这个习惯。

你将学到：

1. [安装 pstack](./01-setup.md)。安装 plugin 并挑选你的 model。
2. [让工作走 `/poteto-mode`](./02-poteto-mode.md)。给它一个目标，看它挑出一个 playbook。
3. [理解代码](./03-understand.md)。先做一次 read-only 的调查，然后在动任何东西之前用 `/how`、`/why`、`/teach` 和 `/recall`。
4. [设计这次改动](./04-design.md)。在 code 锁定形状之前，用 `/architect`、`/arena`、`/swarm`、`/interrogate`、原型与计划。
5. [实现并清理这次改动](./05-build-and-clean.md)。那些 build playbook、`/tdd`、`/unslop` 和 `/no-comments`。
6. [验证并交付](./06-verify-and-ship.md)。在真实的 app 上证明行为，对测试很少触及的部分做形式化验证，用 `/benchmark-checklist` 审查数字，然后开一个聚焦的 PR 并把它推到已 merge。
7. [在你睡觉时继续干活](./07-overnight.md)。循环之前先建立信任、一份隔夜合同、一份你可以审计的决策日志，以及能扩展到不止一个 agent 的 Projects 与 automations。
8. [用原则的名字来掌舵](./08-principles.md)。那 24 个能在 task 中途把 agent 拨回来的名字。
9. [变成你自己的](./09-make-it-yours.md)。你自己的 mode、用于反复犯的错误的 `/correct`，以及如何测试一次 skill 改动。
10. [配方与陷阱](./10-recipes-and-pitfalls.md)。可以直接复制的 prompt，以及可以跳过的错误。

第一次请按顺序读这些页面。之后每一页都可以单独读。

卡住了，或者分不清哪个 skill 合适时，带着你的问题输入 [`/poteto-help`](../../skills/poteto-help/SKILL.md)：

```text
/poteto-help which skill should i use to review this branch?
```

它会回答，递给你一段可以发送的 prompt，并链上答案出自的那个 skill 或指南页。它不开始干活，因为一次 pstack run 会花掉真实的 token，所以你在准备好时自己发送那段 prompt。只有你输入它时它才运行。

## 如果你只记住一件事

用你自己的话，给 agent 一个目标和一个检查它的办法：

```text
/poteto-mode the export writes duplicate rows when a retry lands mid-run. repro first, then fix and verify.
```

你不需要点名 playbook，也不需要列出 skill。「repro first」加上一个可核查的结果，就是 `/poteto-mode` 所需的全部路由 signal。它会匹配上 Bug fix playbook，把步骤抄进一个 todo list，并在每个步骤触发时调用正确的 skill。

下一节：[安装 pstack](./01-setup.md)。