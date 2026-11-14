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

**研究边界：** 静态文本与源码研究已覆盖主要资产；测试执行、外部服务端到端验证和 Codex 工作台程序实现仍是后续工程工作。详见[研究完成报告](docs/研究完成报告.md)。

## 中文指南

- [指南索引](translations/guide/指南目录.md)
- [01 安装与配置](translations/guide/01-安装与配置.md)
- [02 Poteto Mode 路由任务](translations/guide/02-Poteto模式任务路由.md)
- [03 理解代码](translations/guide/03-代码理解.md)
- [04 设计](translations/guide/04-架构设计.md)
- [05 实现与清理](translations/guide/05-功能实现与代码清理.md)
- [06 验证与交付](translations/guide/06-验证与交付.md)
- [07 自主运行](translations/guide/07-自主运行与自动化.md)
- [08 工程原则](translations/guide/08-工程原则.md)
- [09 定制工作流](translations/guide/09-定制工作流.md)
- [10 配方与陷阱](translations/guide/10-实践配方与常见陷阱.md)

## 建议阅读顺序

建议按“先建立整体认识，再理解调度与协作，最后研究工程化和迁移”的顺序阅读。不要一开始就从 58 个 Skill 或脚本目录逐个啃，先抓住 P-Stack 的主干。

### 第一阶段：建立整体认识

1. [P-Stack 总体架构](docs/P-Stack总体架构分析.md)：先理解 P-Stack 是什么、由哪些部分组成，以及它不是什么。
2. [指南目录](translations/guide/指南目录.md)：了解 10 篇用户指南的全貌。
3. [01 安装与配置](translations/guide/01-安装与配置.md)：了解模型、工具和运行环境的基本配置。
4. [02 Poteto Mode 路由任务](translations/guide/02-Poteto模式任务路由.md)：理解主 Agent 如何识别任务并选择工作流。

### 第二阶段：理解核心工作方式

5. [Poteto Mode 调度机制](docs/Poteto模式调度机制分析.md)：重点理解任务分类、Playbook 路由、Todo 约束、角色分工和权限边界。
6. [23 个工作流目录](docs/工作流目录与初步分析.md)：先建立 23 个 Playbook 的全景认识。
7. [核心 Agent 协作机制](docs/智能体协作深度研究.md)：重点理解 Architect、Arena、Swarm、Interrogate 的区别与配合。
8. [Agent 协作机制总览](docs/智能体协作机制总览.md)：回顾主 Agent、Worker、Reviewer、Verifier 等角色如何协作。
9. [Skill 目录与研究状态](docs/技能目录与研究状态.md)：理解 Skill 与 Playbook、Agent 的职责边界。

### 第三阶段：深入质量控制与工程实践

10. [PR 生命周期与质量改进](docs/PR生命周期与质量改进研究.md)：理解 Babysit、Shipping、Refactoring、性能优化和 PR 验证。
11. [其他 11 个工作流深度分析](docs/其他11个工作流深度研究.md)：补齐自主运行、排障、原型、评测和清理等工作流。
12. [24 条工程原则深度研究](docs/工程原则深度研究.md)：理解 P-Stack 如何把工程经验变成可执行约束。
13. [Eval 模型盲测流程](docs/模型评测系统.md)：理解如何客观比较不同模型或提示词的效果。
14. [元工作流与学习闭环](docs/元工作流与学习闭环.md)：理解如何从经验中持续改进 Skills 和工作流。

### 第四阶段：研究实现细节并迁移到自己的工作台

15. [Agent 与自动化研究](docs/智能体与自动化研究.md)：研究 Agent 定义、自动化任务及其边界。
16. [脚本与测试框架研究](docs/脚本与测试框架研究.md)：了解状态机、脚本、测试语料和运行支撑。
17. [Reference 与多平台适配研究](docs/参考资料与多平台适配研究.md)：理解上游参考资料及 Claude Code Harness 的适配方式。
18. [Codex 多模型工作台架构](docs/Codex多模型工作台架构设计.md)：把前面的机制映射到 Codex、GPT、Kimi、DeepSeek 等多模型工作台。
19. [全量研究完成报告](docs/研究完成报告.md) 与 [研究文件清单](docs/研究文件清单.md)：最后核对研究覆盖范围、未完成验证和后续工程任务。

### 如果时间有限，先读这 6 篇

**总体架构 → Poteto Mode 调度机制 → 23 个工作流目录 → 核心 Agent 协作机制 → PR 生命周期与质量改进 → Codex 多模型工作台架构。**

这条最短路径能先回答六个关键问题：P-Stack 是什么、谁负责调度、任务如何分类、多个 Agent 如何协作、结果如何验收，以及怎样迁移到自己的工作台。

---

## 研究文档

| 路径 | 内容 |
|---|---|
| [P-Stack 总体架构](docs/P-Stack总体架构分析.md) | P-Stack 总体架构 |
| [Poteto Mode 调度机制](docs/Poteto模式调度机制分析.md) | 主调度规则、任务路由、Subagent 和权限 |
| [23 个工作流目录](docs/工作流目录与初步分析.md) | 23 个 Playbook 目录与研究状态 |
| [PR 生命周期与质量改进](docs/PR生命周期与质量改进研究.md) | Babysit、Shipping、Refactoring、性能优化 |
| [其他 11 个工作流深度分析](docs/其他11个工作流深度研究.md) | 剩余 11 个 Playbook 深度分析 |
| [Skill 目录与研究状态](docs/技能目录与研究状态.md) | 58 个 Skill 全量目录、分类和状态 |
| [24 条工程原则深度研究](docs/工程原则深度研究.md) | 24 条工程原则逐项研究 |
| [核心 Agent 协作机制](docs/智能体协作深度研究.md) | Architect、Arena、Swarm、Interrogate、How、Why |
| [Agent 与自动化研究](docs/智能体与自动化研究.md) | Agent 定义与 Benny 自动化 |
| [脚本与测试框架研究](docs/脚本与测试框架研究.md) | Watcher、Statechart、脚本和测试资产 |
| [Reference 与多平台适配研究](docs/参考资料与多平台适配研究.md) | 30 个 Reference 与 Claude Code Harness |
| [元工作流与学习闭环](docs/元工作流与学习闭环.md) | Figure It Out、Setup、Reflect、Correct、Automate Me |
| [Eval 模型盲测流程](docs/模型评测系统.md) | Eval 盲测流程 |
| [Agent 协作机制总览](docs/智能体协作机制总览.md) | Agent 协作机制初步总览 |
| [工程原则总览](docs/工程原则总览.md) | 工程原则总览 |
| [研究文件清单](docs/研究文件清单.md) | 文件盘点、统计口径和进度 |
| [Codex 多模型工作台架构](docs/Codex多模型工作台架构设计.md) | 基于 P-Stack 的 Codex 多模型工作台目标架构 |
| [全量研究完成报告](docs/研究完成报告.md) | 研究覆盖、结论、未完成运行验证和验收门禁 |

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
