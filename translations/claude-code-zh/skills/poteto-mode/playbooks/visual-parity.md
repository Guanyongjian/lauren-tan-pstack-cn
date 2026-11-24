### Visual parity

**你负责像素级的一致性。baseline 就是 spec。你不去动它。** 一致性靠 image diff 验证，不靠肉眼。

1. 在任何 migration 之前先建立 baseline：一个 visual regression harness，对当前 component 的各状态截图；当是在匹配两个实现时，也要截目标实现。没有 baseline 就不许声称 parity。这是阻塞性的前置条件，不是后续事项。
2. 明文写下并守住反取巧条款：不改 harness、不动 baseline、不为让 diff 通过而重构 component。如果 baseline 看起来不对，就停下来问，不要去编辑它。
3. 一次迁移一个 component。跨 worktree 并行，一个 component 一个 owner（**separate-before-serializing-shared-state** 原则 skill）。共享 primitive 作为阻塞性 phase 先行迁移。
4. 通过 control skill 在对应 surface 上用 image diff 逐个 component 对照其 baseline 验证。diff 非零即为 fail。去查清这点像素差异。对每个 component 跑 `/loop` 直到 diff 为零。
5. 按 component 或按安全的批次运行 **Opening a PR**。

**Reply：** 已迁移的 component、各自 diff 的结果、baseline harness 的位置、还剩什么。