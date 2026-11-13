# Poteto Mode 23 个 Playbook 目录与初步分析

> 上游目录：[pstack/skills/poteto-mode/playbooks](https://github.com/cursor/plugins/tree/main/pstack/skills/poteto-mode/playbooks)  
> 路由定义：[Poteto Mode SKILL.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/SKILL.md)  
> 上游 Git tree：`24621dbcc59e205a7faadb0e06d540f91712b5cc`

## 1. Playbook 的职责

Playbook 是任务类型对应的可执行流程。主 Skill 负责判断“当前是什么任务”，Playbook 负责规定“这个任务应该按什么步骤执行、谁负责、怎样验收”。

主 Skill 要求将匹配 Playbook 的步骤原样放入 Todo，放在任务专属 Todo 之前。选择跳过的步骤也不能删除，应写明 `skip: <reason>`。大规模跨模块任务或无人值守任务即使表面符合 Feature，也可能转交 Figure It Out；长期项目则使用 Orchestrate。

## 2. 23 个 Playbook 分类

| 分组 | Playbook | 主要任务 | 交付物 / 关键门禁 |
|---|---|---|---|
| 需求与实现 | feature | 新增或修改行为 | 命名数据形状、Throughput Checkpoint、实现、真实验证、PR |
| 需求与实现 | bug-fix | 已报告缺陷 | 先复现、二分定位根因、最小修复、同表面回归 |
| 需求与实现 | refactoring | 不改变外部行为的结构调整 | 行为保持证据、范围控制、分阶段提交 |
| 需求与实现 | prototype | 用实验回答设计或经验问题 | 一次性原型、运行结果、截图或测量证据 |
| 调查与诊断 | investigation | 只读理解、原因和方案判断 | 有引用的解释或权衡建议，不改代码 |
| 调查与诊断 | perf-issue | 一次性性能问题 | 基线、瓶颈定位、优化和性能复测 |
| 调查与诊断 | hillclimb | 持续优化单一指标 | 假设、交替测量、决策日志、每次收益单独提交 |
| 调查与诊断 | runtime-forensics | 现场运行时异常 | 通过实时仪表和日志形成诊断，不以修复代码为默认交付 |
| 调查与诊断 | trace-forensics | 分析已有性能捕获文件 | 对 cpuprofile、trace、spindump、heap snapshot 等进行诊断 |
| 验证与评审 | eval | 比较 Skill、Prompt 或结构变更 | 候选盲测、统一 Judge、行为证据 |
| 验证与评审 | visual-parity | UI 像素级一致性 | 冻结基线、截图 Diff、真实界面驱动 |
| 验证与评审 | babysit | PR 达到可合入状态 | 冲突、Review、CI 按序清理，不负责最终合并 |
| 验证与评审 | shipping | 验证并合入 PR 栈 | 独立验证、连续依赖栈、从底向上合入 |
| 验证与评审 | opening-a-pr | 创建 PR | 小而有序的提交、清理 Diff、PR 描述和证据 |
| 自主运行 | autonomous-run | 一个任务持续运行到退出条件 | 可检查谓词、唤醒机制、每轮验证和决策轨迹 |
| 自主运行 | pause-safely | 暂停进行中的任务 | 安全结束当前步骤、WIP 检查点、恢复说明 |
| 自主运行 | session-pickup | 接手历史未完成任务 | 从 Transcript、云端任务 URL 或分支恢复状态 |
| 自主运行 | orchestrate | 多日、多 PR、长期项目 | 常驻协调者、PR Owner、独立验证者、项目状态记录 |
| 自主运行 | autopilot-full | 独立 PR 队列自动合入 | 每 PR Owner + 独立 Swarm 验证 + 合并门禁 |
| 自主运行 | autopilot-stack | 独立 PR 队列自动构建和验证，但不合入 | PR 栈和验证结论交给操作者 |
| 计划与治理 | multi-phase-plan | 多阶段或多 PR 的执行计划 | 依赖图、每 PR 证据、验证矩阵、执行授权门禁 |
| 计划与治理 | authoring-a-skill | 创建或修改 Skill | 使用 Skill 作者工具、校验 Frontmatter 和链接 |
| 资源清理 | worktree-cleanup | 清理 Git Worktree 和旧 Simulator | 识别安全清理对象并回收磁盘 |

上表的任务路由和分类依据主 Skill。具体执行步骤仍需逐篇阅读 Playbook，不能只根据文件名推断。

## 3. 已深读 Playbook

### 3.1 Feature

来源：[feature.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/feature.md)

核心思想是“主 Agent 负责设计、计划、审查和验证，委派实现，但始终保持主导”。

主要步骤：

1. 使用 how Skill 理解受影响子系统。
2. 使用 Architect 并行探索设计。
3. 建立 Throughput Checkpoint，明确阻塞步骤、独立工作流、共享可变状态和最小安全拆分。
4. 将代码实现委派给配置的 Feature 模型，并给出文件范围、命名数据形状、组织结构和成功标准。
5. 多种实现形态都合理时，使用 Arena，而不是让单个 Worker 自行选择。
6. 在匹配的真实表面验证。无法判断或验证了错误表面都不算通过。
7. Rebase 成小而有序的 Commit，必要时堆叠后续 PR。
8. 有争议的设计在交付前使用 Interrogate。
9. 进入 Opening a PR。

重要补充：一个功能或一次迁移等代码耦合任务，通常由一个 Owner 负责整体工作，再由该 Owner 在阻塞阶段之后内部并行。父级 Fan-out 更适合产生独立产物的审计、跨子系统调查和竞争实验。

**分析：** Feature 的并行不是先按文件数量切任务，而是先判断依赖、共享状态和交付物是否独立。它明确反对多个 Agent 同时修改同一共享资源。

### 3.2 Investigation

来源：[investigation.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/investigation.md)

核心思想是“主 Agent 自己负责答案，负责计划、路由和撰写”。

主要步骤：

1. 只读问题路由到 how；涉及设计动机时再使用 why。
2. Throughput Checkpoint 明确标记为只读调查，不进行代码 Fan-out。
3. 输出采用 Overview、Key Concepts、How It Works、Where Things Live、Gotchas 结构；方案比较则附权衡表。
4. 对最终文字执行 unslop。

它明确禁止调查阶段顺手开 PR、Babysit 或调用 Architect。若调查后确实要修改代码，应先交还结论，再重新路由到 Bug Fix 或 Feature。

**分析：** Investigation 是一个有边界的只读工作流，避免“解释问题”在没有用户授权时自动升级成“修改代码”。

### 3.3 Bug fix

来源：[bug-fix.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/bug-fix.md)

核心思想是“每一行修复代码都要有运行时证据支持”。

主要步骤：

1. Agent 自己在匹配的真实操作表面复现问题。只有明确说明控制面无法触达目标，并且已经尽可能尝试后，才向用户请求复现。
2. 对根因做二分式排查。提出候选假设，每轮选择能最大幅度缩小问题空间的切分，用运行时证据排除假设；必要时增加日志和仪表。
3. 在运行时证据确认机制后，再进入 Architect / Interrogate 或实现委派。
4. 在相同表面验证原始复现已通过。Inconclusive 和错误表面均不算通过。
5. 让失败复现先于修复进入 Git 历史。便宜的本地测试路径适合 TDD；昂贵或高度集成的场景不强行套用。
6. 使用 Opening a PR。

最终报告应说明故障现象、根因、修复和验证方式，并原样附上失败到通过的复现输出。

**分析：** 该流程反对“顺手加几个防御分支”。如果假设被证据否定，基于该假设增加的代码也应撤销。

### 3.4 Autonomous run

来源：[autonomous-run.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/autonomous-run.md)

核心思想是“主 Agent 对退出条件负责，持续推进直到条件满足”。

主要机制：

1. 在第一次迭代前定义可检查的退出谓词。
2. 选择唤醒方式。存在 CI、合并或分支推进等事件时用事件观察者，并以较长心跳兜底；没有事件时使用固定间隔心跳。
3. 每轮只做有证据支持的最小改动，验证谓词；有进展才提交，无收益则丢弃。
4. 任务过程中发现的相关问题由 Agent 在授权范围内处理，但独立修复应进入独立 PR。
5. 每轮通过 show-me-your-work 记录决策。
6. 只有谓词满足才结束。平台期不是结束条件，必须调整方法；真实死路应报告，不能放宽谓词制造成功。

**分析：** 自主运行必须围绕结果谓词，而不是围绕时长、轮数或“尽量多做一些”。

### 3.5 Orchestrate

来源：[orchestrate.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/orchestrate.md)

核心思想是“协调者管理项目，不亲自写项目代码”。

适用范围是多日、多 PR、几十到数百个子 Agent 的长期项目。一个会话预算内可完成的任务不应该升级成 Orchestrate。

关键拓扑：

- 每个 PR 一个 Owner，只有 Owner 能写对应分支、Push、Rebase 和修改目标分支。
- 每个独立任务使用新 Worker，启动 Brief 必须带齐依赖报告和上下文。
- 只有某个领域并行 Worker 很多时才增加 Sub-coordinator，最多三层。每个协调者约维持十个并行 Worker，并采用完成一个补充一个的滚动调度。
- 每个 PR 配置非作者的独立验证者，且验证模型家族不同。
- 先用一个任务完整走通启动、Owner、验证、合并，再扩大 Fan-out。
- Worker 的验收依据是实际 Push、PR 和产物，不是状态文字。
- Worker 卡住或循环时及时停止或替换。按失败原因调整重试；两次重试后仍失败，应重新规划。
- 只有不可逆操作、真实产品决策或无法绕过的死路才上报用户。

**分析：** 这是强所有权模型。协调者不写代码，Owner 独占 PR 分支，Verifier 独立验收，减少多人同时改一个对象造成的冲突和责任不清。

### 3.6 Autopilot-full

来源：[autopilot-full.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/autopilot-full.md)

核心思想是“Owner 负责 PR 生命周期，根协调者负责验证结论，未经独立验证的代码不能合并”。

关键机制：

- 一个 PR 对应一个 Owner，Owner 从开发到合并负责。
- 每个验证结论绑定具体 Patch；CI 绿色绑定具体 Head。
- 完整 Swarm 在 Code-ready Head 运行。只有新增行为、重设计或大 Diff 才重新跑完整 Swarm；小修复或 Rebase 可使用单个验证者。
- 先开 PR，让 CI 和自动化检查并行运行。
- Code-ready 前清理代码和注释，再 Rebase 到当前主干。
- Owner 自证、CI 和 Babysit 都完成后，报告 Merge-ready。
- 验证者独立于作者，覆盖真实行为和 Diff。
- 只阻断有证据的问题；基线分支已经存在的问题不应自动归咎于当前 PR。
- 绿色 CI 不能单独授权合并。

**分析：** 它把“代码版本”和“验证结论”绑定起来。PR 新 Push 后，旧验证结果不能无条件复用。这是工作台需要实现的核心审计能力之一。

## 4. 已识别但尚未逐篇深读的 Playbook

以下条目当前只完成路由级盘点，后续要读取完整文件并补齐步骤、异常分支和工具依赖。

| Playbook | 下一步重点 |
|---|---|
| runtime-forensics | 现场诊断工具、采样和结论边界 |
| trace-forensics | 捕获文件解析、热点归因和证据 |
| prototype | 实验如何回答经验问题，如何清理一次性产物 |
| visual-parity | 截图基线、像素 Diff 和误差阈值 |
| eval | 候选盲化、Judge、评分标准与防观察者效应 |
| authoring-a-skill | Skill 文件校验、链接检查和交付步骤 |
| opening-a-pr | Commit 整理、PR 描述和证据要求 |
| autopilot-stack | 不合并模式下的 PR 依赖与交接 |
| pause-safely | 当前步骤如何安全结束、保存检查点 |
| session-pickup | 从 Transcript、分支或云端会话恢复状态 |
| worktree-cleanup | 如何识别可安全清理的 Worktree 和 Simulator |

## 5. 第二批深读：PR 生命周期与质量改进

详细分析见 [Playbook 深度研究（二）：PR 生命周期与质量改进](playbook-pr-lifecycle-and-quality.md)。

本轮新增深读：

- **Babysit**：四种运行模式、merge frontier、单一 babysitter、禁止改写堆栈拓扑、冲突 / Review / CI 顺序、CI 分类、Bugbot 评论可信边界，以及 GitHub / Origin 状态隔离。
- **Shipping**：独立验证者、连续已验证区间、Patch identity、从底向上合并、合并后验证有效性检查。
- **Refactoring**：先冻结行为契约，再定义目标结构；先减后加；小步迁移；真实产物等价性验证。
- **Perf issue**：基线 Trace、Benchmark Checklist、由低成本到高成本的优化顺序、前后测量。
- **Hillclimb**：单指标目标、冻结 Harness、每轮单假设、保留或完整回退、决策日志和停止谓词。

### 已深读数量更新

当前已深读 12 个：Feature、Investigation、Bug fix、Autonomous run、Orchestrate、Autopilot-full、Multi-phase plan、Babysit、Shipping、Refactoring、Perf issue、Hillclimb。

仍待深读 11 个：Runtime forensics、Trace forensics、Prototype、Visual parity、Eval、Authoring a skill、Opening a PR、Autopilot-stack、Pause safely、Session pickup、Worktree cleanup。

## 6. 面向本地多模型工作台的总体判断

不建议将 23 个 Playbook 实现成 23 个互不相关的长提示词。更好的设计是：

- 统一任务状态机；
- 统一任务、Agent、Worktree、PR 和验证结果的数据模型；
- Playbook 只定义任务阶段、转移条件、角色和证据要求；
- 公共能力由工具层提供，例如 Git、测试、日志、PR、模型调用；
- 所有任务状态持久化，Agent 只作为执行者；
- 高风险操作由权限策略拦截。

建议优先实现 Feature、Bug Fix、Investigation、Refactoring 四条基础工作流，再实现 Swarm / Arena / 独立验证。Autopilot-full 和 Orchestrate 应在任务持久化、权限控制和审计能力成熟后再开放。

## 7. 本文的完成状态

- 已从上游主 Skill 确认 23 个 Playbook 的名称和任务路由。
- 已深读 Feature、Investigation、Bug Fix、Autonomous Run、Orchestrate、Autopilot-full、Multi-phase Plan、Babysit、Shipping、Refactoring、Perf issue、Hillclimb。
- 其余 11 个 Playbook 仍是目录级初步分析，不能视为逐篇完成。
- 后续更新应在每篇补充上游版本、执行步骤、分支条件、证据、失败路径和迁移建议。
