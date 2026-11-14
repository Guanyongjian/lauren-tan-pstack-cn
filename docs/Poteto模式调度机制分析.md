# Poteto Mode 核心调度机制分析

> 研究对象：[上游 SKILL.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/SKILL.md)  
> 上游快照：cursor/plugins Git tree `24621dbcc59e205a7faadb0e06d540f91712b5cc`  
> 分析性质：基于该快照中的主 Skill 内容。Cursor 专属工具行为不等同于 Codex 能力。

## 1. 结论先行

Poteto Mode 不是一个“把任务分给多个 Agent”的简单提示词。它更像一个由主 Agent 执行的工作流控制器：

1. 根据用户目标识别任务类型。
2. 选择对应 Playbook，并把 Playbook 步骤作为待办清单。
3. 在任务开始阶段落实设计、数据结构和并行边界。
4. 根据任务难度和职责选择子 Agent 模型。
5. 主 Agent 保留计划、判断、代码审查和最终责任。
6. 每个阶段以真实证据验收。
7. 通过独立 PR、验证 Agent 和决策记录形成交付闭环。

它的核心不是“Agent 数量”，而是**任务路由 + 明确所有权 + 隔离并行 + 可验证交接 + 独立审查**。

## 2. 主 Skill 的结构

主文件包含以下几类规则。

| 部分 | 解决的问题 | 关键约束 |
|---|---|---|
| Non-negotiables | 什么情况下必须触发某项能力 | 任务类型、风险和操作表面触发具体 Skill / Playbook |
| Principles | 判断依据是什么 | 原则必须读取叶子 Skill，回复说明它改变了哪项决策 |
| Autonomy | Agent 能自主做到什么程度 | 可逆工作继续；不可逆高影响操作暂停 |
| Subagents | 如何委派任务 | 角色模型、后台运行、上下文传递、隔离和新 Agent 策略 |
| Writing the reply | 如何交付结果 | 短句、证据标注、面向使用者和维护者 |
| Comments | 如何写代码注释 | 只保留代码无法表达的非显然原因 |
| Playbooks | 如何选择执行流程 | 将任务分类到具体工作流，并逐项复制步骤 |

这说明主 Skill 本身不是某一个具体任务的完整执行脚本，而是“规则入口 + 路由表 + 运行时约束”。

## 3. 任务路由机制

上游通过任务意图把请求分配到不同流程：

| 任务意图 | 路由 | 产物 |
|---|---|---|
| 只读地询问机制、原因或方案是否可靠 | Investigation | 有证据的解释或建议，不修改代码 |
| 已报告的缺陷 | Bug fix | 复现、根因、最小修复和回归证据 |
| 已测得的性能问题 | Perf issue | 基线、瓶颈、优化和对比结果 |
| 持续优化一个指标 | Hillclimb | 假设循环、测量、决策日志、逐次提交 |
| 运行时泄漏、空转、抖动 | Runtime forensics | 基于现场仪表的诊断 |
| 已有 Profile / Trace 文件 | Trace forensics | 对捕获产物进行诊断 |
| 新增或修改行为 | Feature | 设计、实现、验证和 PR |
| 不改变行为的结构调整 | Refactoring | 行为保持的重构 |
| 用一次性原型回答设计问题 | Prototype | 可运行的草图或实验结果 |
| 像素级 UI 一致性 | Visual parity | 基线截图差异证据 |
| 编写或修改 SKILL.md | Authoring a skill | 经校验的 Skill 变更 |
| 验证 Prompt / Skill / 结构变更 | Eval | 盲测结果 |
| 推进 PR 到可合入 | Babysit | 冲突、Review、CI 清理 |
| 合入已验证的 PR 栈 | Shipping | 独立验证后的顺序合入 |
| 单个任务无人值守运行 | Autonomous run | 明确退出谓词和迭代决策轨迹 |
| 多日、多个 PR、长期协调项目 | Orchestrate | 常驻协调者管理多个 PR Owner |
| 独立 PR 队列并全自动合并 | Autopilot-full | 每 PR Owner + 独立验证 + 合并 |
| 独立 PR 队列但保留人工合并 | Autopilot-stack | 已验证 PR 栈，交由操作者合入 |
| 接续历史 Agent 的未完成工作 | Session pickup | 根据 Transcript / 分支恢复状态 |
| 暂停当前工作 | Pause safely | 安全检查点和恢复说明 |
| 多阶段或多 PR 的计划 | Multi-phase plan | 有依赖、验收和证据的执行计划 |
| 清理 Worktree / Simulator | Worktree cleanup | 安全回收资源 |

路由上的关键边界：

- Investigation 是只读调查，不应顺手变成代码修改。
- Autonomous run 是一个任务收敛到一个可检查谓词。
- Orchestrate 是长期项目管理，不是单次任务多开几个 Agent。
- Autopilot-full 和 Autopilot-stack 的区别是是否由系统自动合并。
- Babysit 负责 PR 达到 merge-ready；Shipping 负责验证后合入。
- Feature 和 Refactoring 的区别是是否改变外部行为。

## 4. Non-negotiables：路由之后仍然强制执行的规则

### 4.1 首条回复先复述目标

除完全明确的一行小修改外，Agent 首次回应要用自己的话说明：
- 用户希望得到什么；
- 正在解决什么问题；
- 若需要改代码，预计最小变更是什么。

同一目标还要写入子 Agent Brief、PR 的 Why 和最终报告。这样可以减少任务在多次委派后发生语义漂移。

### 4.2 先确定数据形状，再写逻辑

任何代码任务都要先说清楚数据形状，并用 Model the Domain 原则决定组织结构。例如：
- 状态复杂时用状态机，而不是散落的布尔值；
- 多处分支依赖相同形状时用表或 Registry；
- 有明确约束时用类型模型；
- 先明确哪些并发参与者共享状态。

### 4.3 跨函数边界先做架构探索

代码跨越函数边界时，主 Skill 要求先走 Architect，进行并行设计探索，再实施。这是为了避免把局部函数改动扩散成未经讨论的接口和依赖。

### 4.4 并行任务区分 Swarm 和 Arena

- Swarm：任务分片、覆盖矩阵、并行探索和独立验证。
- Arena：同一设计或代码任务的多个候选实现，选择基线后吸收其他方案优点。

二者不能互换。多个独立子系统要覆盖完整性，应该分片；一个问题存在多种实现路线，才适合竞争式尝试。

### 4.5 争议设计先 Interrogate

当方案存在争议时，先用多模型对抗式审查，再进入交付。它不是要求所有小改动都跑多模型评审，而是针对存在实质分歧的设计。

### 4.6 多步骤任务写 Throughput Checkpoint

Feature Playbook 要求明确：
- 阻塞性前置步骤；
- 独立工作流；
- 共享可变状态；
- 最小且安全的拆分方式。

即使某项不适用，也保留并写明 `n/a` 原因。这样可以审查“为什么并行”以及“为什么不并行”。

## 5. Subagent 管理机制

### 5.1 主 Agent 不把 Playbook 本身委派出去

上游明确区分：
- 接收用户请求的主 Agent：执行 Playbook、掌握全局和最终负责。
- `poteto-agent`：执行 Playbook 步骤中的代码编写、辅助调查等具体工作。
- how、why、arena、swarm、architect、interrogate、reflect 等路由技能：按自身规则使用多模型或不同 Subagent 类型。

这能避免“主 Agent 把工作流交给另一个 Agent，而自己只负责转述”的责任断裂。

### 5.2 默认后台运行

上游 Task 委派默认：
- 后台执行，避免一个前台调用阻塞主会话；
- 使用 Agent 模式；
- 传递文件路径指针，不把大段文件内容重复塞入上下文；
- 按角色指定模型；
- 根据任务难度调整推理级别和速度。

### 5.3 模型按职责配置

默认模型不是一个全局统一模型，而是按角色配置：
- 代码实现；
- 判断与文档；
- 最难的跨模块设计、并发和复杂算法；
- Swarm 验证。

模型配置由 `/setup-pstack` 写入规则文件。任务启动前，主 Agent 再根据任务难度调整推理等级和速度。遇到不支持的模型 ID 时，应按明确的回退规则处理，不能反复猜测模型名称。

### 5.4 默认使用全新的 Subagent

新任务、修复轮次、重试和后续队列项，原则上都启动新的 Subagent，并把原始 Brief、后续指令、前一轮报告和分支信息整理成完整上下文。

只有当后续工作确实依赖旧 Agent 独有的状态，例如本地未提交修改、正在运行的服务或模拟器，才复用原 Agent。

原因是中断后恢复可能丢失指令。重新创建并提供完整 Brief，比信任旧 Agent 的“我已完成”摘要更可靠。

### 5.5 主 Agent 对结果负责

主 Agent 必须自己审查 Diff 和产物，自己撰写总结，不能把 Subagent 的报告直接转发给用户。第二意见应使用不同模型回答同一个问题；模型间一致性可以提高判断信号强度，但仍不能替代证据。

## 6. 自主权限边界

上游规则是：
- 可逆工作和部分外部动作可以在授权范围内继续执行；
- Force push 到共享分支、部署、数据删除、客户消息等不可逆或高影响操作必须暂停；
- 用户明确授予“继续运行”等会话级权限后，减少对可逆步骤的反复询问；
- 即使全自动，也不能越过用户明确设置的门禁或 Always-pause 项。

迁移到我们的工作台时，不应原样照搬 Cursor 的授权假设。工作台要有独立的工具权限层，至少把文件写入、执行命令、Git commit、Git push、PR 创建、合并、部署分级。默认策略应比上游更保守，尤其是本地 WSL、企业代码仓库和生产环境。

## 7. 回复与注释规范

主 Skill 要求：
- 用短陈述句，一句表达一个意思；
- 不用长破折号；
- 不用冒号串联句子，列表引导除外；
- 简洁不能删掉取舍、风险和未决事项；
- 先说明用户和维护者能观察到什么变化，再讲实现；
- 每项结论都要在同一句给证据，或明确标注为推断/猜测；
- 不编造链接、引用或 Transcript；
- 注释只解释代码本身看不出的非显然原因，不写阶段播报。

## 8. 对 Codex 多模型工作台的架构映射

| P-Stack 概念 | 工作台建议组件 | 说明 |
|---|---|---|
| Poteto Mode | Orchestrator / Workflow Engine | 主会话做路由、状态管理和决策 |
| Playbook | Workflow Definition | 有版本的任务状态机或工作流定义 |
| Principle | Policy / Guardrail | 可检查的行为规则，不只是提示词 |
| Subagent role | Agent Role Registry | 定义职责、输入输出、工具权限 |
| Model role config | Model Registry + Router | 模型与角色解耦，按任务选择模型 |
| Throughput checkpoint | Task Decomposition Plan | 并行边界、依赖、共享资源和拆分理由 |
| Swarm | Fan-out / Map-Reduce | 分片执行、独立结果聚合 |
| Arena | Candidate Race / Judge | 同题多解、盲化评估和方案融合 |
| Interrogate | Adversarial Review | 多视角找反例和阻断性问题 |
| show-me-your-work | Decision Log / Audit Trail | 记录每轮决策、证据、状态 |
| Babysit | PR Watcher | 事件触发检查 Review、CI 和冲突 |
| Shipping | Merge Gate | 独立验证、按依赖顺序合入 |

### 8.1 推荐的任务状态

```text
INTAKE
  -> CLASSIFY
  -> INVESTIGATE
  -> DESIGN
  -> PLAN
  -> IMPLEMENT
  -> VERIFY
  -> REVIEW
  -> PR_READY
  -> MERGE_APPROVAL
  -> DONE
```

不是每个任务都走完全部状态。只读调查可以在 INVESTIGATE 后结束；小型明确修改可以跳过复杂设计；Bug Fix 必须有复现和根因证据；高风险合并必须进入审批门禁。

### 8.2 工作台最重要的设计原则

1. 工作流与模型解耦。更换 Kimi、DeepSeek 或 OpenAI 模型不应改变任务验收规则。
2. 任务与 Agent 生命周期解耦。任务状态不能只存在于某个 Agent 的上下文中。
3. 每个并行任务必须声明文件范围和输出产物。
4. 每个写入型 Agent 必须有唯一资源所有权，禁止多个 Agent 同时写同一 Worktree。
5. 验证 Agent 不应等同于实现 Agent。
6. 结果必须绑定 commit SHA、命令和证据，不能只绑定“Agent 说完成了”。
7. 模型不可用时按角色策略回退，不得静默降级到未经批准的模型。

## 9. 不应直接照搬的部分

| 上游设计 | 迁移限制 |
|---|---|
| Cursor Task 工具和 `poteto-agent` 类型 | Codex CLI 的 Agent/子任务接口不同，需要 Runtime Adapter |
| Cursor `/loop` | 需要工作台调度器、系统服务或 Automations 实现 |
| Cursor Projects / Cloud Agent | 本地 WSL 需要自己的任务持久化和隔离 Worktree |
| Cursor Control UI / CLI Skill | 需对接项目现有测试脚本、SSH、串口、Redfish、D-Bus 等控制接口 |
| 模型 Slug 与推理档位 | 不同提供方 API 参数不一致，必须通过能力映射层适配 |
| Cursor 用户规则文件 | 应转换为工作台自己的 Role / Workflow 配置 |

## 10. 待继续验证

- 逐篇分析 23 个 Playbook 的完整步骤和失败分支。
- 阅读 Architect、Swarm、Arena、Interrogate 的完整 Skill，确认它们与主 Skill 的接口。
- 分析 `check-plan.mjs`、`bootstrap.ts`、`watch-pr` 和 `worktree-audit.sh` 的真实实现。
- 建立 Codex Runtime Adapter 的能力差异矩阵。
