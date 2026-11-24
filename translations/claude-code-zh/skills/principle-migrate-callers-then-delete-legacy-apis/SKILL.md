---
name: principle-migrate-callers-then-delete-legacy-apis
description: "在引入新 internal API、而旧 caller 仍然存在时适用。在同一波里 migrate caller 并删掉旧 API，而不是保留 compatibility layer。"
disable-model-invocation: true
---

# Migrate Callers Then Delete Legacy APIs（先迁移调用方再删遗留 API）

- 更新 test，让它们断言新的 contract；删掉那些只保护重构前 implementation detail 的 test

**When this applies:**

- 没有 external user 依赖 backward compatibility
- 项目能够承受 coordinated breaking change
- 新 API 属于一次 simplification 或 refactor 行动
