# 核心 Agent 协作 Skills 深度研究

> 上游快照：`cursor/plugins` Git tree `24621dbcc59e205a7faadb0e06d540f91712b5cc`  
> 重点文件：[Architect](https://github.com/cursor/plugins/blob/main/pstack/skills/architect/SKILL.md)、[Arena](https://github.com/cursor/plugins/blob/main/pstack/skills/arena/SKILL.md)、[Swarm](https://github.com/cursor/plugins/blob/main/pstack/skills/swarm/SKILL.md)、[Interrogate](https://github.com/cursor/plugins/blob/main/pstack/skills/interrogate/SKILL.md)、[How](https://github.com/cursor/plugins/blob/main/pstack/skills/how/SKILL.md)、[Why](https://github.com/cursor/plugins/blob/main/pstack/skills/why/SKILL.md)。

## 1. Arena：同一任务多方案竞争

Arena 的目的不是简单并行，而是让多个候选在相同任务约束下独立产出，再用统一标准选出最强基线，并从失败候选中提取可用部分。

六个阶段：
1. Frame：明确候选产物、3–6 个可评分标准和模型阵容。
2. Fan out：同一提示并行执行，每个候选拥有独立 Worktree / 输出目录。
3. Cross-judge：候选完成后，启动不同模型家族的只读 Judge；Judge 只看到匿名标签和评分标准。
4. Pick：主 Agent 逐一完整阅读候选，按每项标准打分，与 Judge 结论对照。
5. Graft：从落选方案中提取少量有价值设计，手工整合进基线；不能机械拼贴。
6. Verify：验证最终合成产物。若发现问题，回到重新定义问题或补充整合。

关键规则：
- 所有候选收到同一个 Prompt，它就是实验契约。
- 每个候选有独立写入目录。
- 不能在候选还在写时启动 Judge。
- Judge 与主 Agent 意见不一致时，必须检查评分标准是否含糊或存在偏见。
- 如果候选差异巨大，说明任务框定不足，应重新 Frame，而不是平均不同设计。

**Arena 的交付物**是一个合成产物，加上基线选择理由、Judge 结论、Graft 来源、被拒方案和验证结果。

## 2. Swarm：分工并行或同题竞争的通用执行框架

Swarm 的目标是并行覆盖任务，而不是挑一个最佳候选。它支持三种形状：
- Slice：按独立范围切分任务；
- Race：多个 Worker 对相同任务竞争；
- Mixed：先分工再竞争，或反之。

四个阶段：
1. Frame：定义可检查的完成谓词和需要返回的产物；声明 Slice / Race / Mixed。Race 必须事先选定 first pass、rank all 或 best-of。
2. Fan out：所有 Worker 在一次调度中启动，每个 Worker Brief 自包含，写任务使用独立输出位置。
3. Aggregate：检查每个 Worker 的终态报告；缺少指定 SHA 或测量方法的结果不能算通过，最多补跑一次，第二次仍缺失则记 Gap。
4. Report：输出一个合并报告，包含结果表、问题、缺失覆盖和采用的竞赛规则。

Worker 报告状态必须是 PASS、ISSUES 或 BLOCKED，并附证据。验证和测量任务要指定准确 SHA、测量方法、样本数、样本定义和顺序。

**与 Arena 的区别：** Arena 是选出最佳候选并合成；Swarm 是确保所有切片完成或明确记录缺口。不要把所有并行任务都称为 Arena。

## 3. Architect：先定数据形状，再实现

Architect 的五阶段是 Ground、Sketch、Agree、Implement、Scrap。

### Ground
先理解所有受影响子系统。通过 How 建立运行和架构模型；若重定义所有权或分层，再用 Why 研究现有设计动机。仅命名文件不算完成理解。

### Sketch
使用 Arena 产生至少两个结构上不同的候选设计。候选必须是整体形状差异，不是同一方案里的局部修补。用 Design Red Flags 检查候选，并比较接口深度：优先能用更小公共表面隐藏更多复杂度的方案。

设计草图包括类型、函数签名、模块边界和伪代码；调用方使用方式先写，再从调用方式推导类型。

### Agree
默认不需要人为确认，综合设计后直接实现。只有用户明确要求 checkpoint 时才停下来等待签字。需要对抗式压力测试时，可对综合草图运行 Interrogate。

### Implement
草图是实现契约。若实现需要草图未包含的参数或逃生通道，应判断是草图错误、需求遗漏还是实现越界，而不是静默偏离。

### Scrap
若实现持续产生相同形态的绕行方案、特殊分支、类型逃生口或调用者必须理解内部规则，说明架构可能错了。重新理解当前系统、重新设计，并从更小的草图重新开始。

**关键洞察：** Architect 不是“先写一份设计文档”，而是让设计草图成为实现过程中的约束，并允许证据推翻它。

## 4. Interrogate：多模型对抗审查，不负责修复

Interrogate 的目标是找出变更或设计中的可证实缺陷。它不会自动应用修复。

- 范围由用户指定；否则使用当前分支相对基线的 Diff。
- 先用用户目标、Commit 和 PR 描述重述真实意图。
- 默认四个对抗者，各自使用独立 Worktree，包含未提交变更。
- 每个对抗者必须针对真实代码执行失败测试、复现脚本或命令；没有运行的猜测不得作为 Finding。
- 主 Agent 重新执行每条 Finding 的命令，只有确实违背目标的结果保留。
- 不做 Arena 的候选评比和 Graft；所有已验证 Finding 都应保留。
- 最终列出 Intent、Verified Findings、Dropped Findings。没有已验证问题也是合法结果。

**安全意义：** 多模型意见只是线索，运行证据才是缺陷成立的依据。

## 5. How：理解系统如何工作

How 用于代码走读、子系统架构、运行流程、模块归属和分层问题。

- 简单问题：一个 Explainer 一次完成探索和解释。
- 复杂问题：拆成 2–4 个互相独立的调查角度，多个只读 Explorer 并行，之后由一个 Explainer 综合。
- 输出围绕 Overview、Key Concepts、How It Works、Where Things Live、Gotchas。
- Explorer 只读；主 Agent 不应将源代码扫描结果直接堆成注释式长文。

## 6. Why：追溯设计动机和历史约束

Why 与 How 不同：How 解释代码当前做什么；Why 解释为何形成现在的形状。

它先建立代码锚点：路径、行范围、关键符号、Git Blame、历史提交、PR、Issue ID。然后按可用证据源并行调查：
1. Source control；
2. Issue tracker；
3. Long-form docs；
4. Team chat；
5. Infrastructure observability；
6. Error tracking；
7. Product analytics。

每类证据源要么实际调查，要么明确说明缺少对应 MCP 或为何与目标无关。不能把“没有找到”说成“从未存在”。

最后综合时区分事实、合理推断、竞争假设、未知项和置信度。若调查服务于后续改动，应整理 Preserve / Change / Avoid / Risk 约束。

## 7. 这些协作原语如何组合

| 需求 | 推荐原语 | 输出 |
|---|---|---|
| 我不知道系统怎么工作 | How | 架构与运行解释 |
| 我不知道为什么这样设计 | Why | 有出处的决策历史与约束 |
| 我需要先选架构 | Architect | 类型 / 接口草图与综合决策 |
| 有多种合理实现 | Arena | 最佳基线 + Graft + 验证 |
| 工作可以独立切分 | Swarm | 分片结果与覆盖报告 |
| 我想找设计或代码漏洞 | Interrogate | 经运行复核的 Finding |
| 我要评估不同 Prompt / Skill / 模型 | Eval | 盲测结果与推广建议 |

## 8. 对 Codex + Kimi + DeepSeek 工作台的设计

### 8.1 角色与模型分离

不要把角色写死为某个模型：
- Planner / Architect：负责问题建模与设计草图；
- Worker：负责具体实现；
- Reviewer / Adversary：负责独立找问题；
- Judge：负责盲化评分；
- Coordinator：负责调度和证据汇总。

模型供应商只是角色的可配置执行后端。每次执行要保存 model id、provider、API 参数、工具权限和上下文快照。

### 8.2 隔离是并行前提

每个写入型 Worker 使用独立 Git Worktree；每个候选独立输出目录；测量任务锁定 Commit SHA；禁止多个 Agent 同时写一个状态文件。协调者只汇总，不代替 Owner 修改工作区。

### 8.3 统一任务契约

建议每个 Agent Brief 结构化为：
- Goal；
- Scope / Non-goals；
- Input artifact / exact SHA；
- Writable paths；
- Constraints；
- Verification command；
- Expected output schema；
- Deadline / retry policy；
- Stop predicate。

### 8.4 统一结果协议

Worker 的结果至少有：
- status: PASS / ISSUES / BLOCKED；
- summary；
- changed files；
- exact commit SHA；
- commands executed；
- stdout/stderr artifact paths；
- tests and evidence；
- unresolved risks；
- next action.

没有证据的 PASS 应降级为 UNKNOWN / INCONCLUSIVE。

### 8.5 独立性不只是模型名称不同

如果作者和 Reviewer 使用相同模型家族、同一上下文和相同工具观察路径，独立性有限。工作台应记录模型家族、上下文来源、是否看过作者解释、是否修改过产物等因素。不同模型不能自动保证无偏，但能提供不同视角。

## 9. 研究边界

本轮依据上述 Skills 主文件研究核心协作协议。Architect、Arena、How、Why 等引用的 Runner Prompt、Design Red Flags、Rationale Template、Epistemics、Source Playbooks 和脚本仍需逐项读取；本文不声称已经完成全部引用资源的实现审计。
