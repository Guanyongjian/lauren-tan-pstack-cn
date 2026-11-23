---
name: principle-boundary-discipline
description: "在接线校验、错误处理或框架适配层时适用。把守卫集中在系统边界（CLI、config、network、external API）；信任内部类型，业务逻辑放在纯函数里。"
disable-model-invocation: true
---

# Boundary Discipline（边界纪律）

把 validation、type narrowing 和 error handling 放在系统边界上。无条件信任内部代码。业务逻辑住在纯函数里。shell 要薄，且是机械的。

**Why:** 分散的 validation 既吵又冗余，还会给人虚假的安全感。把逻辑挡在框架接线之外，才能脱离框架测试它。

**The pattern:**

- **在边界上**（CLI args、config files、external APIs、network protocols）：validate、返回错误、防御式处理。
- **系统内部：** 使用带类型的数据、向上传播错误、不重复校验。信任类型。
- **跨越边界时。** 暴露领域概念，而不是边界私有的表示。通用机制留在内部，专用策略放在边缘。

**Applications:**

Validation 与 error handling：

- 在 parse 阶段（边界处）校验 config，而不是在业务逻辑里
- 在边界处把原始数据 parse 成 domain types
- 不要把 transport、storage、framework 或 wire types 经 public surface 再导出
- 边界已经校验过，就不要在调用链深处重复做 nil 检查

代码组织：

- 业务逻辑放在无框架依赖的纯函数里
- parse 函数：从原始 bytes 到 typed state 的纯转换
- prompt 构造：结构化 state 进，string 出
- scoring 与 assessment：从 state 到 result 的纯转换

**The tests:**

- 「这份数据此刻正在跨越系统边界吗？」如果不是，validation 就是冗余的。
- 「这能不能做成一个纯函数，让 shell 直接调用？」如果能，就抽出去。
