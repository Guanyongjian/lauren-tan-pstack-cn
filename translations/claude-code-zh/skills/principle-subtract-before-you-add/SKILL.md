---
name: principle-subtract-before-you-add
description: "在安排 addition、refactor 或 rewrite 时适用。先删掉 dead code、冗余 validator 和 stub reference，再在更简单的基础上施工。"
disable-model-invocation: true
---

# Subtract Before You Add（先减后加）

演进一个系统时，先削 complexity，再往上盖。默认选择做减法。

把 simplification 当成持续投入。交出去的设计要比你接手时**更简单、更强，而对外的 surface 不变或更小**。

- 先编排删除，再编排构建
- 先砍到不能再砍，再打磨质量（先拿到最小值，再投入品质）
- 按**实际观测到的 usage** 设计，不为臆想的 edge case 设计
- spec 没有要求的 validator、parser、guard，一个都不要加
- 简化 prompt（删掉冗余 instruction、砍掉过度 template）
- 一个 reference 若没有新内容，直接删掉，不要留个 stub
