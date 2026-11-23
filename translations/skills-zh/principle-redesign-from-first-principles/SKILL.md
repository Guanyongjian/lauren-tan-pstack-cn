---
name: principle-redesign-from-first-principles
description: "把一个新需求整合进已有设计时适用。"
disable-model-invocation: true
---

# Redesign From First Principles（从第一性原理重新设计）

整合一项改动时，不要把它硬接到已有设计上。要把它当成从第一天起就是基础假设，按此重新设计。

- 读完所有受影响的文件，理解当前设计
- 问：「如果我们带着这个新需求从零开始写，会怎么造？」
- 把改动贯穿到每一处引用：类型、文档、示例、rationale 章节
- 先想清楚整个重设计，再增量交付

这是在把改动整合进已有设计时保住 option value 的方法。
