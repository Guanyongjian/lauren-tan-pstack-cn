# P-Stack 文件盘点与研究计划

## 1. 统计基线

本次初始统计基于上游仓库某一 commit 的递归 Git tree，研究目录为 `pstack/`。

- 初始 Git tree：`6e359ce0aba9e927914d8a940510aa2ef66a8f23`
- 初始插件版本字段：`0.15.36`
- 文件总数：573
- Skill 主文件（`SKILL.md`）：61
- Playbook：23
- 独立 Principle Skill：24
- Guide Markdown：11
- Agent 定义：2
- Automation 文件：12
- 脚本相关路径文件：424
- 测试语料相关路径文件：356

这些分类存在包含关系：测试语料文件包含在脚本相关路径统计中，不能将各行简单相加。上述数字是初始快照统计，不代表上游当前状态。

### Poteto Mode 后续复核快照

本轮重新读取上游递归 Git tree，得到：

- Git tree：`24621dbcc59e205a7faadb0e06d540f91712b5cc`
- Poteto Mode 主 Skill：1
- Playbook：23
- 配套引用、脚本和测试文件：另行纳入后续代码研究

本轮没有重新计算整个 P-Stack 的文件总量和各分类数量，因此初始统计仍只作为历史基线。

## 2. 研究分类

| 类别 | 研究方法 | 交付物 |
|---|---|---|
| README / 插件元数据 | 完整阅读 | 项目定位、安装方式、版本与许可说明 |
| Guide | 逐篇阅读 | 中文解读、术语、操作流程 |
| Skills | 逐个读取 SKILL.md 及引用文件 | 职责、触发条件、输入输出、边界 |
| Playbooks | 逐篇阅读 | 阶段、分支、验收和失败处理 |
| Principles | 逐篇阅读 | 触发条件、行为规则、反例 |
| Agents | 逐个阅读 | 角色约束、生命周期、权限 |
| Automations | 阅读配置与脚本 | 触发条件、调度与副作用 |
| Scripts / Tests | 按入口和调用关系分析 | 代码结构、测试覆盖、执行方式 |
| Assets | 检查用途和引用位置 | 图片与辅助资源索引 |
| Harness / Adapters | 对比不同宿主实现 | 能力差异与迁移边界 |

## 3. 逐项进度

| 研究对象 | 数量 | 状态 |
|---|---:|---|
| README / plugin metadata | 2 | 已初读 |
| Guide | 10 篇用户指南 | 中文解读初版已完成，需持续校对上游变更 |
| Skills | 61 | 已抽样，待全量分析 |
| Playbooks | 23 | 路由目录已完成；7 个深读，16 个待深读 |
| Principles | 24 | 已建立总览，待逐项分析 |
| Agents | 2 | 已抽样阅读 |
| Automations | 12 | 待分析 |
| Scripts / test corpus | 424 / 356 | 待按调用链和测试用途分析 |

### 已深读的 Playbook

- Feature
- Investigation
- Bug fix
- Autonomous run
- Orchestrate
- Autopilot-full
- Multi-phase plan

详细内容见 [Poteto Mode 核心分析](poteto-mode-analysis.md) 和 [Playbook 目录与初步分析](playbook-catalog.md)。

## 4. 完成定义

一个文件只有在以下内容齐备时才标记为“已分析”：

- 上游路径和对应版本；
- 主要目的与适用场景；
- 输入、输出和依赖；
- 执行步骤或关键实现；
- 风险、限制和失败路径；
- 对 Codex / 多模型工作台的迁移价值；
- 必要的验证或待确认问题。

仅列出文件名或生成一句摘要，不算完成。

## 5. 推荐研究顺序

1. Guide 全文：理解作者希望用户怎样使用 P-Stack。
2. Poteto Mode 与全部 Playbooks：理解调度和端到端流程。
3. Arena、Swarm、Interrogate、Architect：理解协作原语。
4. Eval、Verification、TDD：理解质量闭环。
5. Principles：理解底层工程判断。
6. 其他 Skills、Agents、Automations：补齐工具箱。
7. Scripts、测试语料和适配器：核对实现细节。

## 6. 文件索引

- [上游 P-Stack 目录](https://github.com/cursor/plugins/tree/main/pstack)
- [上游 Skills](https://github.com/cursor/plugins/tree/main/pstack/skills)
- [上游 Guide](https://github.com/cursor/plugins/tree/main/pstack/docs/guide)
- [上游 Agents](https://github.com/cursor/plugins/tree/main/pstack/agents)
- [上游 Automations](https://github.com/cursor/plugins/tree/main/pstack/automations)
