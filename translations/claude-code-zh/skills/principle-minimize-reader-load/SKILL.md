---
name: principle-minimize-reader-load
description: "在评审或塑造难以追踪的 code 时适用。数一数从 question 到 answer 隔了几层，以及 reader 脑子里要记住多少 hidden state；把只有一个 caller 的 wrapper 折叠掉，缩小 mutable scope。"
disable-model-invocation: true
---

# Minimize Reader Load（最小化读者负担）

maintainability 就是 reader 理解 code 所必须付出的劳动。看两个轴：**layers to trace**（question 与 answer 之间的 indirection）和 **state to hold**（reader 脑子里必须保留的 hidden 或 mutable context）。LOC、cyclomatic complexity 和「clean architecture」都是 proxy。真正重要的是 reader load。这两个轴相互独立：一个含 50 个 global 的平铺 file，和一个 6 层 adapter stack，可能一样难以推理。两个都要 guard。这是 [Guard the Context Window](../principle-guard-the-context-window/SKILL.md) 在人类身上的 analog——reader 的 working memory 同样是有限的。

- **折叠那些 cost 大于收益的 layer**：只有一个 caller 的 wrapper、没有第二种 implementation 的 adapter、从来不需要的 speculative indirection。把它们 inline 掉。
- **让相邻 layer 改变 abstraction。** 一个只是重复相同 method 和 argument 的 layer，增加了 reader load 却没有压缩信息。把这种 pass-through layer 折叠掉。
- **要求 interface 有压缩力。** 一个宽 interface 如果几乎不隐藏 complexity，就会逼 reader 同时学 surface 和 implementation。优先选择能隐藏有意义 decision 的 boundary。
- **缩小 state scope：** 优先纯函数（return 而非 mutation）、local 优于 field、field 优于 module state、module state 优于 global。用 derive 代替 sync。
- **在 boundary 处为 invariant 命名**，而不是在每个 consumer 各写一遍，这样 reader 只需学一次。
- 增加一层 layer 或一份 state 之前先问：它在别处减少的 reader load，至少和它带来的一样多吗？

**The test:** 一个新 reader 能否在 30 秒内回答「X 是从哪来的？」和「什么能改动 X？」如果不能，就砍 layer 或砍 state。
