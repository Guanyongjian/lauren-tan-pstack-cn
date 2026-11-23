---
name: principle-migrate-callers-then-delete-legacy-apis
description: "在引入新 internal API、而旧调用方仍然存在时适用。在同一波里迁移调用方并删掉旧 API，而不是保留兼容层。"
disable-model-invocation: true
---

# Migrate Callers Then Delete Legacy APIs（先迁移调用方再删遗留 API）

- 更新测试，让它们断言新的 contract；删掉那些只保护重构前实现细节的测试

**When this applies:**

- 没有外部用户依赖向后兼容
- 项目能够承受协同的破坏性变更
- 新 API 属于一次简化或重构行动
