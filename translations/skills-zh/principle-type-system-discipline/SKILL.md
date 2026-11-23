---
name: principle-type-system-discipline
description: "在设计类型、评审函数签名，或用任何静态类型语言写代码时适用。让非法状态无法表示，给语义化基础类型打上 brand，在边界解析外部数据，穷尽 variant，从权威 schema 派生。"
disable-model-invocation: true
---

# Type System Discipline（类型系统纪律）

让编译器拒绝不可能的状态、错配的基础类型和未处理的 variant。优先把错误和特殊情况定义到不存在，而不是不断增补 handler。TypeScript 语法见 `typescript-best-practices` skill。

- **给语义化基础类型打 brand。** `UserId` 和 `OrderId` 底层都是 string，但不应可以互换。给各自独立的类型，比如 TypeScript 里的 branded intersection，或其他语言里的 newtype。创建时校验一次，下游信任类型。如果两个参数共享同一个基础类型但含义不同，就给它们打 brand。
- **外部数据在被 parse 之前都是无类型的。** RPC payload、JSON、IPC message、CLI args、config files、环境变量、数据库行。在每个边界上都要有一个 parse 函数，把非结构化输入变成带类型的模型。**boundary-discipline** 原则 Skill 说明了该把校验放在哪里。
- **从权威 schema 派生类型。** 当某个 protocol buffer、OpenAPI spec、GraphQL schema、数据库迁移、design-token 文件或其他文件拥有某个形状时，从它派生，而不是手写一份平行类型。见 **encode-lessons-in-structure** 原则 Skill。
