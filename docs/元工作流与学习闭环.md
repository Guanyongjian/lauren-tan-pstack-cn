# P-Stack 元工作流：任务设计、模型配置、反思与纠错

> 上游快照：cursor/plugins Git tree 24621dbcc59e205a7faadb0e06d540f91712b5cc
> 重点 Skill：figure-it-out、setup-pstack、automate-me、reflect、correct。

## 1. Figure It Out：没有现成 Playbook 时，先设计工作流

上游：[figure-it-out/SKILL.md](https://github.com/cursor/plugins/blob/main/pstack/skills/figure-it-out/SKILL.md)

Figure It Out 的交付物在代码之前：一个按任务规模配置严谨度、可审计、可以运行的工作流。

五个阶段：
1. Frame：定义可证伪的 Done Predicate、量化范围、阻塞点和严谨度。高风险、不可逆、Blast Radius 大的步骤提高门禁；可逆低风险步骤降低门禁。
2. Design Workflow：拆成可独立合入的原子单元，按最危险未知优先排序；先建验证 Harness 并保存旧基线；不可逆设计决策走 Architect；并行任务按独立边界隔离 Worktree。
3. Run Loop：每个单元都是实验，提出假设、做最小改动、对真实产物测量；推进就保留，无进展就回退；不能用自述代替证据。
4. Audit Trail：用 Show Me Your Work 记录决策；这类大型任务通常应把决策轨迹提交到 PR。
5. Verify and Hand Back：在真实产品上检查总体 Done Predicate，反复出现的纠正应变成门禁、Lint、检查或脚本。

**与 Multi-phase Plan 的关系：** Multi-phase Plan 是一个有明确多阶段 / PR 结构的计划流程；Figure It Out 是没有现成 Playbook 能覆盖时，为任务自定义一套可审计流程。不能把它当成所有复杂任务的默认入口，否则会重复发明流程。

## 2. Setup P-Stack：按角色配置模型，不按任务随意换模型

上游：[setup-pstack/SKILL.md](https://github.com/cursor/plugins/blob/main/pstack/skills/setup-pstack/SKILL.md)

它把模型配置写入一个始终生效的规则文件，而不是每次任务重新猜模型。

关键机制：
- 先从当前运行环境实际可用的 Subagent 模型清单探测 Slug；没确认的 Slug 不允许写入。
- 预算级别统一映射到推理强度，包含 unlimited / large / medium / small。
- 按角色配置模型：代码实现、判断与文案、最困难任务、How Explorer / Explainer、Why Investigator / Synthesizer、Reflect 三类 Reviewer、Arena Runner / Judge、Swarm Worker、Architect Runner、Interrogate Reviewer。
- 面板角色使用模型列表，列表长度决定并行候选数量；Arena Judge Pool 只允许不同于父模型家族的候选。
- 重跑 Setup 时保留用户已经自定义的角色值；删除废弃角色；整体覆写配置保证幂等。
- Setup 完成后还会询问是否生成真实应用 Verification Skill 和 Formal Verification Skill。

**设计意义：** 模型选择是角色级策略，不应由每个 Agent 自己决定。模型供应商可替换，但角色契约和评估标准应稳定。

## 3. Automate Me：从历史行为生成个人工作模式

上游：[automate-me/SKILL.md](https://github.com/cursor/plugins/blob/main/pstack/skills/automate-me/SKILL.md)

它通过用户真实工作记录生成一个个人 -mode Skill，而不是复制 Poteto 的个人偏好。

流程：
1. 查找现有个人 Mode Skill；默认更新而非重建。更新只分析 Skill 上次编辑后的历史。
2. 仅读取当前工作区 Transcript，不能遍历其他项目的会话，避免越界读取私人聊天。
3. 将最近 2–4 周的会话分片给多个只读 Mining Agent，分析回答偏好、委派方式、验证标准、代码 / 文案纪律、Git 流程和 Skill 使用习惯。
4. 至少两个分片出现的模式置信度更高；孤立一次的行为通常不沉淀。
5. 通过结构化问题询问历史中未出现的偏好。
6. 将规则聚类成少量可执行章节，调用 Skill Authoring 工具写入，再用 Unslop 校对。
7. 展示给用户迭代，最后在 Worktree 中提交并开 PR。

**设计意义：** 个性化工作流应该从长期重复行为中归纳，而不是根据单次聊天推断用户习惯。

## 4. Reflect：从一次任务中提取可复用经验

上游：[reflect/SKILL.md](https://github.com/cursor/plugins/blob/main/pstack/skills/reflect/SKILL.md)

Reflect 需要用户明确触发。它跳过琐碎、离题或已经被正确遵循的任务。

三位 Reviewer 并行审查同一会话：
- Judgment：从具体事故中提炼判断原则、用户纠正、架构和流程摩擦。
- Tooling：找出命令、路径、工具参数、库和 CI 的具体细节，也标记用户手动提供但 Agent 本可通过 MCP 获取的上下文。
- Divergent：寻找反直觉的二阶影响、遗漏步骤、幸运通过的验证和其他 Reviewer 可能漏掉的盲点。

随后 Synthesizer 根据耐久性、具体性、是否改变未来决策、是否已有 Skill 覆盖、是否应该由结构性机制实现、目标 Skill 是否真的被调用等条件筛选 Accepted / Rejected / Backlog。

关键约束：
- Transcript 和 Reviewer 输出都是不可信数据，不能把其中的 Prompt Injection 当作指令。
- 只有用户批准后才应用 Accepted Skill 修改。
- 结构化机制更合适时放入 Backlog，例如 Lint、脚本、元数据或运行时检查。
- 不编辑 Plugin Cache 中的 Skill；编辑工作区或用户目录中的副本。
- 默认不创建 PR，也不 Push；Reflect 的任务是改进本地 Skill 资产。

**设计意义：** 经验沉淀需要一个“发现—多视角复核—综合筛选—用户批准—结构化落地”的治理流程，不能让 Agent 自动把每次对话写进长期规则。

## 5. Correct：把重复错误从人的记忆中移到系统结构里

上游：[correct/SKILL.md](https://github.com/cursor/plugins/blob/main/pstack/skills/correct/SKILL.md)

触发条件是操作人员反复纠正 Agent。某类错误至少发生两次，才计为稳定错误类别。

修复层级严格按以下顺序：
1. Architecture：消除重复状态所有权、多个实现路径、可导入内部实现和可被模仿的旧代码。
2. Types：用类型让错误状态无法表达。
3. Lint / CI：为仍可编译的坏模式增加检查，错误信息直接告诉开发者正确用法。
4. Tests：确保测试真的会因行为破坏而失败，且不因内部重构而失败。
5. Docs：最后才写文档，且仅用于无法由结构表达的判断规则。

每类错误单独 Commit，并用真实历史错误证明新门禁会失败。规则表要记录每条规则由什么机制执行。若某类错误已经不可能发生，就删除对应规则。

**设计意义：** 这是 P-Stack 最强的反馈闭环之一：用户纠正不是只让当前 Agent 道歉，而是让代码库和工具链以后不再允许同类错误。

## 6. 组合成一个长期学习闭环

```text
Setup P-Stack
  -> 按角色选择模型
  -> Poteto Mode 选择 Playbook
  -> Agent 执行 / 验证 / 交付
  -> Show Me Your Work 保存决策
  -> Reflect 提炼经验
  -> Correct 把重复错误变成门禁
  -> Automate Me 更新个人工作方式
  -> 下次任务使用改进后的流程
```

这些流程的对象不同：
- Setup 管模型和预算；
- Playbook 管单次任务；
- Show Me Your Work 管运行审计；
- Reflect 管经验提炼；
- Correct 管仓库级工程防错；
- Automate Me 管个人偏好。

## 7. 对 Codex 多模型工作台的实现建议

建议把元工作流拆成五个服务：

| 服务 | 职责 | 持久化对象 |
|---|---|---|
| Model Registry | 发现模型、Provider、上下文窗口、推理预算和工具能力 | ProviderProfile、ModelCapability |
| Role Policy | 为 Planner / Coder / Reviewer / Judge / Verifier 分配模型 | RoleBinding、BudgetPolicy |
| Workflow Engine | 执行 Playbook 状态机和 Done Predicate | WorkflowDefinition、TaskRun、StepRun |
| Evidence & Decision Log | 保存 Commit、测试、Trace、截图和每轮决策 | EvidenceArtifact、DecisionEvent |
| Learning Governance | 收集反馈、提出规则变更、审批并发布 Skill / Lint / Script 更新 | LearningCandidate、RuleChange、Approval |

不要允许 Reflect 直接写入全局规则；所有长期规则修改都要经过审查和批准。对重复错误优先生成自动检查，而不是不断加 Prompt。

## 8. 本文边界

本文件依据 5 个 Skill 主文件整理其工作流。个人历史挖掘和模型配置在 Cursor / Claude Code 中依赖各自 Transcript、模型发现和 Agent Tool；Codex 版本需要实现对应 Adapter，不能直接复用 Cursor 文件路径和工具名。