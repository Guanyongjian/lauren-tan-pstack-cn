---
name: principle-build-the-lever
description: "适用于任何非平凡的工作，不只是批量工作：edits、migrations、analyses、checks。去造做这件事或证明这件事的工具（codemod、script、generator，或一个让 subagents 遵循的 skill），而不是手工完成。工具就是 reviewer 可以重跑的 artifact。"
disable-model-invocation: true
---

# Build the Lever（造杠杆）

当工作不是平凡级别时，去造做这件事的工具，而不是手工去做。

codemod、generator 或 script 每次都以同样的方式完成工作，并且可以免费重跑。工具是一个 artifact，reviewer 可以读它、重跑它来核对工作。手工做的改动只能靠重做来重新验证。一个确定性的 script 把「相信我」变成「跑这个」。

默认去造 lever。只有任务确实平凡（几处一眼可见的明显改动）才跳过。

- 先手工做第一个单元以摸清 recipe，然后造工具。在那个单元上重跑工具、与你手做的版本做 diff，以此证明工具可用。让 lever 可以安全重跑。
- edits 用 codemod 或 script，重复文件用 generator，分析用 dump-to-sqlite 查询，验证用可重跑的 check。
- 确定性的 lever 胜过 fan-out。如果工具能一趟处理完所有单元，就自己跑。不要把 script 能做的事 fan out 给 delegates 去手做。
- 当你把工作 fan out 给 subagents 时，把这个 lever 写成一个它们都会读的 skill：recipe、verification contract 和 do-not-touch fences 都放在一个 artifact 里。把它放在 delegates 的写范围之外，这样它们无法悄悄改掉 contract。
- 应用本原则会产生一个文件。如果你引用了本原则，而 diff 里没有 codemod、script、generator 或 delegate skill，那你并没有应用它。
- 当工作的生命周期超过本次 session 时，把 lever 提交进仓库。

门槛是「是否平凡」，不是「是否重复」。一次性的活儿同样值得造 lever，只要 lever 才是让这项工作可校验的东西。按 [Laziness Protocol](../principle-laziness-protocol/SKILL.md)，造能完成或证明这件事的最小 script，绝不造框架。

与 [Encode Lessons in Structure](../principle-encode-lessons-in-structure/SKILL.md) 不同：后者把一条反复出现的指令变成持久的护栏。本原则管的是眼前这项工作的吞吐和可评审性。关于把验证本身写成脚本，见 [Prove It Works](../principle-prove-it-works/SKILL.md)。
