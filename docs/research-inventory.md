# P-Stack 文件盘点与研究计划

## 1. 统计基线

初始统计基于上游仓库某一 commit 的递归 Git tree，研究目录为 `pstack/`。

- 初始 Git tree：`6e359ce0aba9e927914d8a940510aa2ef66a8f23`
- 初始插件版本字段：`0.15.36`
- 文件总数：573
- Skill 主文件（`SKILL.md`）：本轮固定快照 58（34 个通用 Skill + 24 个 Principle Skill）；早期 61 为不同快照，不能混用
- Playbook：23
- 独立 Principle Skill：24
- Guide Markdown：11
- Agent 定义：2
- Automation 文件：12
- 脚本相关路径文件：424
- 测试语料相关路径文件：356

分类存在包含关系，不能将各行简单相加。以上为历史快照，不代表上游当前状态。

### Poteto Mode 后续复核快照

- Git tree：`24621dbcc59e205a7faadb0e06d540f91712b5cc`
- Poteto Mode 主 Skill：1
- Playbook：23

本轮未重新统计整个 P-Stack 文件总量。

## 2. 逐项进度

| 研究对象 | 数量 | 状态 |
|---|---:|---|
| Guide | 10 篇用户指南 | 中文解读初版已完成，需持续校对 |
| Skills | 58 | 路径盘点完成；24 条原则逐项分析；34 个通用 Skill 已建立分类表，引用资源和实现审计继续进行 |
| Playbooks | 23 | 23/23 已逐篇完成文本研究；配套脚本与测试待代码级审计 |
| Principles | 24 | 24/24 主文件逐项研究完成，引用资源待交叉核验 |
| Agents | 2 | 已确认文件清单，待逐篇深读 |
| Automations | 12 | 已确认文件清单，待逐篇深读 |
| Scripts / test corpus | 424 / 356 | 待按调用链和测试用途分析 |

### 已深读的 Playbook（23）

- Feature
- Investigation
- Bug fix
- Autonomous run
- Orchestrate
- Autopilot-full
- Multi-phase plan
- Babysit
- Shipping
- Refactoring
- Perf issue
- Hillclimb
- Runtime forensics
- Trace forensics
- Prototype
- Visual parity
- Eval
- Authoring a skill
- Opening a PR
- Autopilot-stack
- Pause safely
- Session pickup
- Worktree cleanup

23 个 Playbook 的文本分析已完成。配套 References、Scripts、Harness、Tests 尚未完成代码级审计。

## 3. 研究完成定义

一个文件只有在以下内容齐备时才标记为“已分析”：

- 上游路径和对应版本；
- 主要目的与适用场景；
- 输入、输出和依赖；
- 执行步骤或关键实现；
- 风险、限制和失败路径；
- 对 Codex / 多模型工作台的迁移价值；
- 必要的验证或待确认问题。

仅列出文件名或生成一句摘要，不算完成。

## 4. 推荐研究顺序

1. 剩余 Playbook：补齐端到端工作流。
2. Arena、Swarm、Interrogate、Architect：理解协作原语。
3. Eval、Verification、TDD：理解质量闭环。
4. Principles：理解底层工程判断。
5. 其他 Skills、Agents、Automations：补齐工具箱。
6. Scripts、测试语料和适配器：核对实现细节。

## 5. 文件索引

- [上游 P-Stack 目录](https://github.com/cursor/plugins/tree/main/pstack)
- [上游 Skills](https://github.com/cursor/plugins/tree/main/pstack/skills)
- [上游 Guide](https://github.com/cursor/plugins/tree/main/pstack/docs/guide)
- [上游 Agents](https://github.com/cursor/plugins/tree/main/pstack/agents)
- [上游 Automations](https://github.com/cursor/plugins/tree/main/pstack/automations)
