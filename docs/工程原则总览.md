# P-Stack 工程原则：研究总览

P-Stack 将原则作为独立 Skill 提供，并由 `poteto-mode` 在多步骤任务开始时读取原则索引，根据任务触发相关原则。原则名称可以作为简短指令，指向一套更完整的行为约束。

来源：[用户指南：Steer with principle names](https://github.com/cursor/plugins/blob/main/pstack/docs/guide/08-principles.md)。

## 1. 原则的作用

原则不是口号，也不应只是 README 中的一组标语。有效原则需要能改变 Agent 的具体决策，例如：
- 何时先删除再新增；
- 何时应该先建模数据结构；
- 何时必须隔离并发写入；
- 如何区分根因修复与症状补丁；
- 完成任务前应提供什么证据。

## 2. 研究时采用的分类框架

以下分类用于本项目整理，不代表上游的官方分类标题。

| 研究类别 | 关注点 | 代表性原则 |
|---|---|---|
| 简化与可读性 | 减少不必要抽象和读者负担 | Laziness Protocol、Subtract Before You Add、Minimize Reader Load |
| 基础设计 | 先确定领域模型与系统边界 | Foundational Thinking、Model the Domain、Boundary Discipline |
| 变更策略 | 让迁移和重构收敛到目标形态 | Outcome-Oriented Execution、Migrate Callers Then Delete Legacy APIs |
| 并发与可靠性 | 避免共享状态竞争，支持重试 | Separate Before Serializing Shared State、Make Operations Idempotent |
| 验证与调试 | 用运行证据证明行为、追踪根因 | Prove It Works、Fix Root Causes、Test Behavior Not Implementation |
| 探索与决策 | 在锁定方案前探索设计空间 | Exhaust the Design Space、Attack the Premise |
| 用户价值 | 从用户体验而非实现便利出发 | Experience First |

## 3. 如何应用到 BMC 开发

| BMC 场景 | 可采用的原则 | 实际检查问题 |
|---|---|---|
| Lua 模块重构 | Subtract Before You Add | 是否先清理无效状态和重复逻辑？ |
| D-Bus 接口设计 | Model the Domain、Boundary Discipline | 签名、类型和边界是否明确？ |
| 跨板 RPC 重试 | Make Operations Idempotent | 重试是否会造成重复写入或副作用？ |
| 多协程共享文件 | Separate Before Serializing Shared State | 是否先隔离写入者和文件状态？ |
| 故障定位 | Fix Root Causes | 是否追踪到第一个错误状态，而非只增加保护分支？ |
| 功能交付 | Prove It Works | 是否在真实设备或可复现环境验证？ |
| 测试设计 | Test Behavior, Not Implementation | 测试是否验证外部可观察行为？ |

## 4. 原则落地的规则

一个原则只有满足以下条件，才适合进入团队工作流：
1. 有明确触发条件；
2. 有可执行的行为要求；
3. 有违反时的反例；
4. 有可验证的检查方式；
5. 不与更高优先级的安全、产品或项目约束冲突。

## 5. 下一步逐项研究

当前已确认上游目录中有 24 个 `principle-*` Skill。后续应逐个读取原始文件，记录：
- 上游路径和版本；
- 原则原文的准确含义；
- 触发条件；
- 强制动作与禁止动作；
- 典型反例；
- BMC / Lua / Codex 实践映射；
- 可自动化检查的部分。

本页是总览，不替代 24 个原则文件的逐项分析。
