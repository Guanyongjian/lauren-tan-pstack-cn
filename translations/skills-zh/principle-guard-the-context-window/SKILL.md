---
name: principle-guard-the-context-window
description: "context 正在被填满时适用：大量输出、长文件、重复读取、fan-out 规划。把批量活儿路由给 subagents；主线程只留摘要，不留原始 payload。"
disable-model-invocation: true
---

# Guard the Context Window（守住上下文窗口）

**Why:** context 溢出会降低推理质量、产生压缩伪影，并让进展停摆。

**Pattern:**

- **给阶段定量，给范围设上限。** 限制每个阶段处理的文件数，设定 turn budget，把机制本身的开销也算进去。
