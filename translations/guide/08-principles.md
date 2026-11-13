# 第 8 章：用原则名称引导 Agent

> 上游来源：[docs/guide/08-principles.md](https://github.com/cursor/plugins/blob/main/pstack/docs/guide/08-principles.md)

P-Stack 提供 24 条独立的工程原则 Skill。Poteto Mode 会在多步骤任务开始时读取原则索引，根据任务触发相关原则，并在回复中说明应用了哪些原则以及它们改变了什么决策。

用户不必每次重新解释整套要求，只需使用原则名称。原则名称指向 Agent 已经读取的完整规则，因此一句简短指令就可能比一大段临时提示词更准确。

## 1. 用原则名称纠偏

例如，Agent 准备在现有三个 Adapter 上再增加一个 Adapter：

```text
use subtract before you add. delete the obsolete adapters first, then design what's left.
```

Agent 只凭编译成功就宣称任务完成：

```text
apply prove it works. run the real import flow and show me the written records.
```

多个并行尝试准备写入同一个分支：

```text
separate before serializing shared state. give each attempt its own worktree, no locks.
```

原则引用必须落实到具体决策。Agent 应说明该原则改变了哪项决定；如果只报出原则名称，却没有任何决策变化，说明它可能只是复述了规则。

## 2. 24 条原则概览

以下名称保留英文，便于和上游 Skill 对照。

### 核心设计与简化

| 原则 | 中文理解 |
|---|---|
| Laziness Protocol | 惰性协议：优先删除和最小改动，不为不存在的问题增加抽象。 |
| Foundational Thinking | 基础性思考：先确定核心数据结构，再编写逻辑。 |
| Redesign from First Principles | 从第一性原理重新设计：把新需求视为系统从一开始就存在的基础条件。 |
| Attack the Premise | 质疑共同前提：多个修复失败时，先验证它们共同依赖的假设。 |
| Subtract Before You Add | 先减后加：先清除无用结构，再建立新方案。 |
| Minimize Reader Load | 降低读者负担：减少层级、隐藏状态和无意义包装。 |
| Outcome-Oriented Execution | 面向结果执行：重写和迁移应收敛到目标架构，不长期保留临时兼容状态。 |
| Experience First | 体验优先：从用户结果而不是实现便利做取舍。 |
| Exhaust the Design Space | 穷尽设计空间：缺少先例时，先制作多个结构不同的原型再决定。 |
| Build the Lever | 构建杠杆：重复工作应沉淀为脚本、生成器或工具，让审查者能重跑。 |

### 架构与状态管理

| 原则 | 中文理解 |
|---|---|
| Model the Domain | 建模领域：用状态机、类型、表或注册表表达领域规则，避免条件散落。 |
| Boundary Discipline | 边界纪律：在系统边界校验输入，内部信任已经建立的类型约束。 |
| Type System Discipline | 类型系统纪律：让非法状态尽可能无法表达。 |
| Make Operations Idempotent | 操作幂等：面对崩溃和重试，操作应收敛到相同终态。 |
| Migrate Callers Then Delete Legacy APIs | 迁移调用方后删除旧 API：尽可能在同一轮完成调用方迁移与旧接口清理。 |
| Separate Before Serializing Shared State | 先隔离，再串行化共享状态：优先消除并发写入共享状态，再考虑锁和协调。 |

### 验证与调试

| 原则 | 中文理解 |
|---|---|
| Prove It Works | 证明它有效：检查真实产物，不用代理指标代替真实行为。 |
| Fix Root Causes | 修复根因：从症状追到系统最早出错的位置。 |
| Sequence Work into Verifiable Units | 将工作拆成可验证单元：每个小阶段完成后先验证，再进入下一阶段。 |
| Test Behavior, Not Implementation | 测试行为而非实现：断言用户可观察的行为，不绑定内部实现细节。 |
| Explain the Number | 解释数字：报告性能数据前，说明限制因素并排除测量错误。 |

### 委派与上下文管理

| 原则 | 中文理解 |
|---|---|
| Guard the Context Window | 保护上下文窗口：将批量阅读委派出去，把精炼结论留在主会话。 |
| Never Block on the Human | 不要无谓等待人：可逆且已授权的工作先推进，再呈现结果。 |

### 元原则

| 原则 | 中文理解 |
|---|---|
| Encode Lessons in Structure | 将经验编码进结构：把反复出现的建议变成 Lint、检查或脚本。 |

## 3. 不要把原则当成口号

一个原则要真正落地，至少应具备：
- 明确的触发场景；
- 可执行的动作；
- 应避免的行为；
- 能识别违反原则的反例；
- 可检查的结果。

后续逐项研究 24 个 Principle Skill 时，应补充每条原则的原始定义、触发条件、执行约束、反例和验证方式。本章只是总览，不替代逐文件分析。

## 本章解读：BMC 开发中的原则映射

- Lua 重构：先减后加，优先删除死代码和重复状态。
- D-Bus 接口：领域建模、边界纪律，明确签名、类型和输入约束。
- 跨板 RPC：操作幂等，明确超时、重试和重复请求的副作用。
- 多协程文件访问：先隔离共享状态，再决定是否需要文件锁。
- 故障定位：修复根因，避免只加保护分支掩盖错误状态。
- 功能交付：证明有效，在真实设备或可复现集成环境验证。
- 测试设计：验证外部可观察行为，不绑定内部函数调用次数等实现细节。
