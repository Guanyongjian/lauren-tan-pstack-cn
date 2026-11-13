# P-Stack 全量研究阶段性完成报告

> 上游仓库：cursor/plugins
> 研究基线 Git tree：24621dbcc59e205a7faadb0e06d540f91712b5cc
> 研究范围：pstack/ 全目录及 harness/pstack/claude-code 生成适配树。
> 本报告区分静态源码研究、文件盘点和实际运行验证，不把未执行的测试写成已通过。

## 1. 研究覆盖清单

| 研究对象 | 固定快照数量 | 研究状态 |
|---|---:|---|
| P-Stack 全部文件 | 573 | 已完成目录和类型盘点 |
| Guides | 10 篇用户指南 | 已有中文解读初版 |
| Playbooks | 23 | 23/23 主文件逐篇研究完成 |
| Skills | 58 个 SKILL.md | 58/58 路径盘点和主文件初读；24 条原则逐项深读，核心协作 / 验证 / 元工作流专题完成 |
| Principle Skills | 24 | 24/24 逐项研究 |
| References | 30 | 30/30 路径盘点并按所属 Skill 研究 |
| Agents | 2 | 2/2 主文件研究完成 |
| Benny Automation Pack | 12 | 12/12 文件研究完成 |
| TypeScript | 51 | 51 个源文件和测试文件已阅读 / 审查 |
| MJS | 10 | 10 个脚本和 View 模块已盘点 / 阅读 |
| Shell | 2 | 2/2 脚本阅读 |
| Java | 1 | TLC 配置 Oracle 阅读 |
| Statechart Corpus | 33 个案例目录 / 356 个文件 | 38 个 TLA+ 文件做了顶层模型扫描；测试夹具与黄金输出已分类，未逐行翻译所有生成输出 |
| Claude Code Harness | 560 个文件 | Adapter 与生成器逻辑已研究；未在本环境实际安装 / 运行生成检查 |

早期统计曾记录 61 个 Skill 主文件。本轮固定快照中实际找到 58 个（34 个通用 Skill + 24 个原则 Skill），因此本报告统一采用本轮 Git tree 的可复核统计。

## 2. 已形成的研究文档

| 文档 | 研究主题 |
|---|---|
| architecture.md | P-Stack 架构总览 |
| agent-collaboration.md | Agent 协作原语初步研究 |
| poteto-mode-analysis.md | 主调度、路由、权限和 Subagent |
| playbook-catalog.md | 23 个 Playbook 总目录和完成状态 |
| playbook-pr-lifecycle-and-quality.md | Babysit、Shipping、Refactoring、Perf issue、Hillclimb |
| playbook-remaining-11-analysis.md | 剩余 11 个 Playbook |
| skills-catalog.md | 58 个 Skill 目录、分类和研究状态 |
| engineering-principles-deep-dive.md | 24 条工程原则逐项研究 |
| agent-collaboration-deep-dive.md | Architect、Arena、Swarm、Interrogate、How、Why |
| agents-and-automations-analysis.md | 两个 Agent 和 Benny 事件驱动自动化 |
| scripts-and-test-harness-analysis.md | Watcher、计划检查、Worktree、Statechart、Corpus |
| references-and-harness-portability.md | 30 个 Reference 与 Claude Code Harness |
| meta-skills-and-learning-loop.md | Figure It Out、Setup、Reflect、Correct、Automate Me |
| codex-multimodel-workbench-architecture.md | P-Stack 到本地 Codex 多模型工作台的架构转化 |

## 3. 关键研究结论

### 3.1 P-Stack 是工作流系统，不是 Prompt 集合

Skill 提供可复用方法；Playbook 提供任务状态和验收流程；Agent 定义执行角色和权限；Principle 提供触发式工程约束；References / Scripts / Tests 把部分约束变成可执行机制；Harness Adapter 将宿主专有能力映射到另一运行时。

### 3.2 并行必须以隔离和所有权为前提

一个写入型任务一个 Owner；不同 Worker 使用独立 Worktree；Coordinator 负责调度和汇总；Verifier 独立且只读；Judge 盲化；多个 Agent 不共享可变文件或分支。

### 3.3 验证结论必须绑定具体代码和环境

PASS 不是一句文本，而是包含 Head SHA / Patch ID、验证者、模型、环境、命令和原始证据的对象。CI 绿色不等于用户路径已验证；作者自证不等于独立验证；Inconclusive 不是 Pass。

### 3.4 自动化应分级授权

默认自动执行只读和本地可逆工作；远端写入需要任务授权；合并、部署、删除和外部消息等不可逆操作需要单独授权。Autopilot-stack 是比 Autopilot-full 更适合先落地的安全起点。

### 3.5 经验沉淀应优先结构化

重复纠正应优先变成架构、类型、Lint、测试或脚本。Reflect 提炼候选经验，但需要用户批准；Correct 以真实历史错误验证新门禁。

### 3.6 多宿主迁移需要 Adapter 和 Generator

Claude Code Harness 不是手工复制的一套文件，而是由源目录和生成器产生，并通过 CI 防止漂移。Codex 应有自己的 Capability Registry / Adapter / Generator，不能直接照搬 Cursor 或 Claude 的工具名和会话路径。

## 4. 尚未完成的验证工作

以下工作属于运行验证或逐项产物审计，不影响本轮对流程文本和主要代码架构的静态研究结论，但完成前不能声称整个上游工程已被端到端复现：

1. 在匹配的 Node / Bun / Java / TLC 环境执行所有上游测试套件。
2. 运行 Claude Code Harness 生成器的 --check，确认生成树和源目录无漂移。
3. 将 33 个 Statechart Corpus 案例逐个运行 TLC，核对全部 Chart / Report / Exit 黄金输出。
4. 对 356 个 Corpus 文件做机器化差异、引用和一致性检查，而不是逐一人工翻译生成输出。
5. 在真实 GitHub / Origin 环境验证 PR Watcher；在真实 Slack / Tracker / Control Adapter 环境验证 Benny 自动化。
6. 对 34 个通用 Skill 的所有引用路径、子模板、安装器和外部依赖做完整闭包检查。
7. 实际实现并验证 Codex Adapter。当前仓库只有目标架构设计，尚未包含工作台程序代码。

## 5. 推荐的最终验收门禁

- 文档链接检查：本仓库所有相对链接可解析。
- 上游链接检查：每个研究专题都指向对应上游文件和固定快照。
- Skill 闭包检查：所有引用文件存在，名称和 Frontmatter 合法。
- Script 测试：TypeScript 严格类型检查、Bun / Node 测试通过。
- Statechart：TLC Corpus Golden、Fuzz、Differential、Renderer 全通过。
- Harness：生成器 --check 通过，源树和生成树无漂移。
- Automation：使用测试 Slack / Tracker / App 环境验证失败关闭、幂等和权限边界。
- Codex Adapter：至少完成单 Agent 闭环、独立 Worktree、独立验证、恢复和权限审批。

## 6. 研究声明

本仓库是对公开 P-Stack 项目的独立中文研究与工程迁移设计，不代表 Lauren Tan 或 Cursor。上游文本研究、静态源码审阅和实际运行验证是不同层次。本报告只对已经执行的研究动作作出结论；未运行的测试、未连接的服务和未实现的 Adapter 均明确保留为待验证事项。