---
name: principle-redesign-from-first-principles
description: "把一个 new requirement 整合进已有 design 时适用。"
disable-model-invocation: true
---

# Redesign From First Principles（从第一性原理重新设计）

整合一项 change 时，不要把它 bolt 到已有 design 上。要把它当成从第一天起就是 foundational assumption，按此重设计。

- 读完所有受影响的 file，理解当前 design
- 问：「如果我们带着这个 new requirement 从零开始写，会怎么造？」
- 把 change 贯穿到每一处 reference：types、docs、examples、rationale 章节
- 先想清楚整个 redesign，再增量交付

这是在把 change 整合进已有 design 时保住 option value 的方法。
