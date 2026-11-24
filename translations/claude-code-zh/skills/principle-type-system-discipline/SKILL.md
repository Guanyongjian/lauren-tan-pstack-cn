---
name: principle-type-system-discipline
description: "在设计 type、评审 function signature，或用任何 statically-typed language 写 code 时适用。让 illegal state 无法表示，给语义化 primitive 打上 brand，在 boundary parse external data，穷尽 variant，从权威 schema derive。"
disable-model-invocation: true
---

# Type System Discipline（类型系统纪律）

让 compiler 拒绝 impossible state、mismatched primitive 和未处理的 variant。优先把 error 和 special case 定义到不存在，而不是不断增补 handler。TypeScript 语法见 `typescript-best-practices` skill。

- **给语义化 primitive 打 brand。** `UserId` 和 `OrderId` 底层都是 string，但不应可以互换。给各自独立的 type，比如 TypeScript 里的 branded intersection，或其他语言里的 newtype。创建时 validate 一次，下游信任 type。如果两个 argument 共享同一个 primitive type 但含义不同，就给它们打 brand。
- **External data 在被 parse 之前都是 untyped。** RPC payload、JSON、IPC message、CLI args、config file、environment variable、database row。在每个 boundary 上都要有一个 parse function，把 unstructured input 变成 typed model。**boundary-discipline** 原则 Skill 说明了该把 validation 放在哪里。
- **从权威 schema derive type。** 当某个 protocol buffer、OpenAPI spec、GraphQL schema、database migration、design-token file 或其他 file 拥有某个 shape 时，从它 derive，而不是手写一份平行 type。见 **encode-lessons-in-structure** 原则 Skill。
