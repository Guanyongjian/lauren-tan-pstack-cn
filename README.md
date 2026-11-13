# Lauren Tan P-Stack 中文研究与实践

> 对 Lauren Tan（Poteto）在 Cursor Plugins 中发布的 P-Stack 进行中文研究、结构化解读与工程实践。目标是理解其 Agent 工作流设计，并提炼适用于 Codex、GPT、Kimi、DeepSeek 与软件工程项目的可复用方法。

## 项目状态

- [x] 确认上游仓库与目录：`cursor/plugins/pstack`
- [x] 记录研究基线与统计口径
- [x] 建立架构、协作、Eval、原则的首批研究文档
- [x] 完成 10 篇用户指南中文解读初版
- [x] 完成 Poteto Mode 主调度规则分析
- [x] 建立 23 个 Playbook 路由目录
- [x] 完成 23 个 Playbook 的逐篇文本研究
- [ ] 审计 Playbook 配套 References、Scripts、Harness 和 Tests
- [ ] 完成 61 个 Skill 的逐项分析
- [ ] 完成 24 条工程原则的逐项分析
- [ ] 分析脚本、测试语料、自动化和适配器
- [ ] 建立上游变更追踪流程

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
| [docs/architecture.md](docs/architecture.md) | P-Stack 总体架构与核心组件 |
| [docs/agent-collaboration.md](docs/agent-collaboration.md) | Poteto Mode、Arena、Swarm、Interrogate |
| [docs/poteto-mode-analysis.md](docs/poteto-mode-analysis.md) | 主调度规则、路由、Subagent、权限和 Codex 迁移 |
| [docs/playbook-catalog.md](docs/playbook-catalog.md) | 23 个 Playbook 目录与分析进度 |
| [docs/playbook-pr-lifecycle-and-quality.md](docs/playbook-pr-lifecycle-and-quality.md) | Babysit、Shipping、Refactoring、Perf issue、Hillclimb 深度分析 |
| [docs/eval-system.md](docs/eval-system.md) | Eval 盲测流程与评估方法 |
| [docs/engineering-principles.md](docs/engineering-principles.md) | 工程原则总览 |
| [docs/research-inventory.md](docs/research-inventory.md) | 文件清单、分类、统计口径和研究进度 |
| [UPSTREAM.md](UPSTREAM.md) | 上游来源、版本与版权说明 |
| [CHANGELOG.md](CHANGELOG.md) | 本项目研究进度与更新记录 |

## 研究口径

本项目区分四种内容：

1. **上游事实**：文件明确写出的行为、配置、步骤与约束。
2. **中文解读**：对设计意图、机制和利弊的解释。
3. **实践建议**：适配到其他 Agent 运行环境的建议，不代表上游原生支持。
4. **待验证事项**：需要实际运行、测试或进一步读取源码确认的结论。

不把目录名、宣传语或访谈摘要当成实现证据。涉及具体机制时尽量链接到对应上游文件。

## 核心研究问题

- 如何让一个主 Agent 根据任务选择稳定的工作流程？
- 如何划分同题竞争（Arena）与分工并行（Swarm）？
- 如何通过独立验证和盲测降低模型自评偏差？
- 如何将经验沉淀成 Skills、Playbooks、Principles，而不是堆叠临时提示词？
- 哪些方法能迁移到 Codex CLI、不同模型 API 和本地代码仓库？

## 贡献与纠错

欢迎提交 Issue 或 PR。请指出对应的上游文件、版本或行号，并区分原文事实、个人解释和实践建议。

## 免责声明

本项目是独立的中文研究与解读项目，不代表 Lauren Tan、Cursor 或其关联组织。上游项目及其文件版权、许可证以原仓库声明为准。本项目新增的中文分析内容不应被误认为上游官方文档。
