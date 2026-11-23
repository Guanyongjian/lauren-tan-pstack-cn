---
name: principle-separate-before-serializing-shared-state
description: "当并发方可能写同一个文件、分支、key 或状态对象时适用。先消除共享；只有当「单一共享写者」是真正的不变量时，才在结构上做串行化。"
disable-model-invocation: true
---

# Separate Before Serializing Shared State（先拆分再串行化共享状态）

当多个并发方可能共享可变状态时，先问它们是否真的需要同一个可变对象。如果不需要，就消除共享。当共享是真实存在的时候，用结构来强制串行化：lockfile、顺序阶段、独占所有权。指令和约定不是并发控制。

**Why:** 对共享状态的并发写入会造成竞态，这种竞态是间歇性的、难以复现，且调试成本很高。

**Pattern:**

1. **识别共享的可变状态**（双方都读写同一个文件、双方都 push 同一个分支、双方都定义并消费同一套 API）。
2. **默认做法：消除共享的写入目标。** 问：这些 actor 是需要同一个规范对象，还是各自在发布独立的事实？给每个 actor 各自独占的文件、key、分支或状态目录，只在读取与汇报的边界上合并。两个 worker 各把自己的 `lastX` 字段写进同一个 `state.json`，那仍然是共享修改；`indexer-state.json` + `metrics-state.json` 则不是。
3. **只有当「单一共享写入目标」是真正的不变量时，才在结构上串行化访问**（lockfile、顺序阶段、单一写者 actor，或原子 compare-and-swap）。把「我们需要一把锁」当作需要核查的设计坏味，而不是默认答案。
