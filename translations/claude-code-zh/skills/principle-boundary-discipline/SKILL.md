---
name: principle-boundary-discipline
description: "在接 validation、error handling 或 framework adapter 时适用。把 guard 集中在 system boundary（CLI、config、network、external API）上；信任内部类型，业务逻辑放在纯函数里。"
disable-model-invocation: true
---

# Boundary Discipline（边界纪律）

把 validation、type narrowing 和 error handling 放在 system boundary 上。无条件信任内部代码。业务逻辑住在纯函数里。shell 要薄，且是机械的。

**Why:** 分散的 validation 既吵又冗余，还会给人虚假的安全感。把逻辑挡在 framework 接线之外，才能脱离 framework 测试它。

**The pattern:**

- **在 boundary 上**（CLI args、config files、external APIs、network protocols）：validate、返回 error、防御式处理。
- **系统内部：** 使用 typed data、向上传播 error、不重复校验。信任类型。
- **跨越 boundary 时。** 暴露 domain 概念，而不是 boundary 私有的表示。通用机制留在内部，专用 policy 放在边缘。

**Applications:**

Validation 与 error handling：

- 在 parse 阶段（boundary 处）校验 config，而不是在业务逻辑里
- 在 boundary 处把原始数据 parse 成 domain types
- 不要把 transport、storage、framework 或 wire types 经 public surface 再导出
- boundary 已经校验过，就不要在调用链深处重复做 nil check

代码组织：

- 业务逻辑放在无 framework 依赖的纯函数里
- parse 函数：从原始 bytes 到 typed state 的纯转换
- prompt 构造：structured state 进，string 出
- scoring 与 assessment：从 state 到 result 的纯转换

**The tests:**

- 「这份数据此刻正在跨越 system boundary 吗？」如果不是，validation 就是冗余的。
- 「这能不能做成一个纯函数，让 shell 直接调用？」如果能，就抽出去。
