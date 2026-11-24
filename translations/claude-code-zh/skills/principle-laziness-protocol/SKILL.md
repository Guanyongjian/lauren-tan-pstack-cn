---
name: principle-laziness-protocol
description: "在 refactor、评估 diff 大小，或想加 abstraction、layer、signal threading 时适用。倾向删除，倾向用能解决问题的最小 change。"
disable-model-invocation: true
---

# Laziness Protocol（惰性协议）

- **把 decision 收敛到一处。** 不要在多个地方重复同一个 choice。把它放在唯一的 source of truth 后面，把 result 作为简单 flag 传出去。
- **把 diff 压到最小。** 用能解决问题的最小 change。更少的行胜过「elegant」的 boilerplate。
