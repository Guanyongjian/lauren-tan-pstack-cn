---
name: principle-guard-the-context-window
description: "context 正在被填满时适用：大量 output、长 file、重复 read、fan-out 规划。把 bulk 路由给 subagent；main thread 只留 summary，不留 raw payload。"
disable-model-invocation: true
---

# Guard the Context Window（守住 context window）

**Why:** context overflow 会降低 reasoning 质量、产生 compression artifact，并让进展停摆。

**Pattern:**

- **给 phase 定量，给 scope 设上限。** 限制每个 phase 处理的 file 数，设定 turn budget，把 mechanism 本身的开销也算进去。
