---
name: principle-laziness-protocol
description: "在重构、评估 diff 大小，或想加抽象、加层、加 signal threading 时适用。倾向删除，倾向用能解决问题的最小改动。"
disable-model-invocation: true
---

# Laziness Protocol（惰性协议）

- **把决策收敛到一处。** 不要在多个地方重复同一个选择。把它放在唯一的事实来源后面，把结果作为简单 flag 传出去。
- **把 diff 压到最小。** 用能解决问题的最小改动。更少的行胜过「优雅」的样板代码。
