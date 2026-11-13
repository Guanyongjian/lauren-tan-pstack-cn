# Lauren Tan P-Stack 中文研究与实践

> 对 Lauren Tan（Poteto）在 Cursor Plugins 中发布的 P-Stack 进行中文研究、结构化解读与工程实践。目标是理解其 Agent 工作流设计，并提炼适用于 Codex、GPT、Kimi、DeepSeek 与软件工程项目的可复用方法。

## 项目状态

- [x] 确认上游仓库与目录：`cursor/plugins/pstack`
- [x] 固定研究快照：`24621dbcc59e205a7faadb0e06d540f91712b5cc`
- [x] 完成 10 篇用户指南中文解读初版
- [x] 完成 23 个 Playbook 逐篇文本研究
- [x] 完成 24 条工程原则逐项研究
- [x] 盘点 58 个 Skill 主文件，完成核心协作、验证和元工作流研究
- [x] 盘点并研究 30 个 Reference 文件
- [x] 完成 2 个 Agent 定义和 Benny 12 个 Automation 文件研究
- [x] 静态审阅 51 个 TypeScript、10 个 MJS、2 个 Shell 和 1 个 Java 文件
- [x] 研究 Claude Code Harness Adapter 和生成器
- [x] 形成 Codex 多模型工作台目标架构
- [ ] 在匹配环境执行完整上游测试套件
- [ ] 运行 Harness 生成器 `--check` 并验证生成树
- [ ] 在真实 GitHub / Slack / App 环境端到端验证
- [ ] 实现并验证 Codex Runtime / Provider Adapter

**研究边界：** 静态文本与源码研究已覆盖主要资产；测试执行、外部服务端到端验证和 Codex 工作台程序实现仍是后续工程工作。详见[研究完成报告](docs/research-completion-report.md)。

## 中文指南

- [指南索引](translations/guide/README.md)
- [01 安装与配置](translations/guide/01-setup.md)
- [02 Poteto Mode 路由任务](translations/guide/02-poteto-mode.md)
- [03 理解代码](translations/guide/03-understand.md)
- [04 设计](translations/guide/04-design.md)
- [05 实现与清理](translations/guide/05-build-and-clean.md)
- [06 验证与交付](translations/guide/06-verify-and-ship.md)
- [07 自主运行](translations/guide/07-overnight.md)
- [08 工程原则](translations/guide/08-principles.md)
- [09 定制工作流](translations/guide/09-make-it-yours.md)
- [10 配方与陷阱](translations/guide/10-recipes-and-pitfalls.md)

## 研究文档

| 路径 | 内容 |
|---|---|
| [architecture.md](docs/architecture.md) | P-Stack 总体架构 |
| [poteto-mode-analysis.md](docs/poteto-mode-analysis.md) | 主调度规则、任务路由、Subagent 和权限 |
| [playbook-catalog.md](docs/playbook-catalog.md) | 23 个 Playbook 目录与研究状态 |
| [playbook-pr-lifecycle-and-quality.md](docs/playbook-pr-lifecycle-and-quality.md) | Babysit、Shipping、Refactoring、性能优化 |
| [playbook-remaining-11-analysis.md](docs/playbook-remaining-11-analysis.md) | 剩余 11 个 Playbook 深度分析 |
| [skills-catalog.md](docs/skills-catalog.md) | 58 个 Skill 全量目录、分类和状态 |
| [engineering-principles-deep-dive.md](docs/engineering-principles-deep-dive.md) | 24 条工程原则逐项研究 |
| [agent-collaboration-deep-dive.md](docs/agent-collaboration-deep-dive.md) | Architect、Arena、Swarm、Interrogate、How、Why |
| [agents-and-automations-analysis.md](docs/agents-and-automations-analysis.md) | Agent 定义与 Benny 自动化 |
| [scripts-and-test-harness-analysis.md](docs/scripts-and-test-harness-analysis.md) | Watcher、Statechart、脚本和测试资产 |
| [references-and-harness-portability.md](docs/references-and-harness-portability.md) | 30 个 Reference 与 Claude Code Harness |
| [meta-skills-and-learning-loop.md](docs/meta-skills-and-learning-loop.md) | Figure It Out、Setup、Reflect、Correct、Automate Me |
| [eval-system.md](docs/eval-system.md) | Eval 盲测流程 |
| [agent-collaboration.md](docs/agent-collaboration.md) | Agent 协作机制初步总览 |
| [engineering-principles.md](docs/engineering-principles.md) | 工程原则总览 |
| [research-inventory.md](docs/research-inventory.md) | 文件盘点、统计口径和进度 |
| [codex-multimodel-workbench-architecture.md](docs/codex-multimodel-workbench-architecture.md) | 基于 P-Stack 的 Codex 多模型工作台目标架构 |
| [research-completion-report.md](docs/research-completion-report.md) | 研究覆盖、结论、未完成运行验证和验收门禁 |

## 研究口径

本项目区分四种内容：

1. **上游事实**：文件明确写出的行为、配置、步骤与约束。
2. **中文解读**：对设计意图、机制和利弊的解释。
3. **实践建议**：适配到其他 Agent 运行环境的建议，不代表上游原生支持。
4. **待验证事项**：需要实际运行、测试或进一步读取源码确认的结论。

不把目录名、宣传语或访谈摘要当成实现证据。涉及具体机制时尽量链接到对应上游文件。

## 核心研究问题

- 如何让主 Agent 根据任务选择稳定工作流？
- 如何划分同题竞争（Arena）与分工并行（Swarm）？
- 如何通过独立验证和盲测降低模型自评偏差？
- 如何将经验沉淀成 Skills、Playbooks、Principles 和自动化门禁？
- 哪些机制能迁移到 Codex CLI、不同模型 API 和本地代码仓库？

## 上游来源与许可

- 上游：[cursor/plugins/tree/main/pstack](https://github.com/cursor/plugins/tree/main/pstack)
- 上游版本字段：0.15.36（研究快照信息，非当前版本承诺）
- 本项目为独立中文研究与解读，不代表 Lauren Tan、Cursor 或其关联组织。
- 上游项目的版权和许可证以原仓库声明为准；本项目不将上游全部原文复制进公开仓库。

## 贡献与纠错

欢迎提交 Issue 或 PR。请指出对应的上游文件、版本或行号，并区分原文事实、个人解释和实践建议。
