---
name: principle-separate-before-serializing-shared-state
description: "当 concurrent actor 可能写同一个 file、branch、key 或 state object 时适用。先消除 sharing；只有当「单一 shared writer」是真正的 invariant 时，才在结构上做 serialization。"
disable-model-invocation: true
---

# Separate Before Serializing Shared State（先拆分再串行化共享状态）

当多个 concurrent actor 可能共享 mutable state 时，先问它们是否真的需要同一个 mutable object。如果不需要，就消除 sharing。当 sharing 是真实存在的时候，用结构来强制 serialization：lockfile、sequential phase、exclusive ownership。instruction 和 convention 不是 concurrency control。

**Why:** 对 shared state 的 concurrent write 会造成 race condition，这种 race 是间歇性的、难以复现，且 debug 成本很高。

**Pattern:**

1. **识别 shared mutable state**（双方都读写同一个 file、双方都 push 同一个 branch、双方都 define 并 consume 同一套 API）。
2. **默认做法：消除 shared write target。** 问：这些 actor 是需要同一个 canonical object，还是各自在发布独立的事实？给每个 actor 各自独占的 file、key、branch 或 state directory，只在读与汇报的 boundary 上 merge。两个 worker 各把自己的 `lastX` 字段写进同一个 `state.json`，那仍然是 shared mutation；`indexer-state.json` + `metrics-state.json` 则不是。
3. **只有当「单一 shared write target」是真正的 invariant 时，才在结构上 serialize 访问**（lockfile、sequential phase、single-writer actor，或 atomic compare-and-swap）。把「we need a lock」当作需要核查的 design smell，而不是默认答案。
