# 更新记录

## 2026-11-13

- 初始化公开研究仓库。
- 记录上游来源、初始文件统计和 Git tree 基线。
- 建立 P-Stack 架构、Agent 协作、Eval、工程原则和文件盘点文档。
- 完成 10 篇 P-Stack 用户指南中文解读初版。
- 重新读取上游递归 Git tree，确认 Poteto Mode 目录含 1 个主 Skill 和 23 个 Playbook。
- 新增 Poteto Mode 主调度机制分析，覆盖任务路由、Non-negotiables、Principles、Subagents、权限边界、回复规则和 Codex 迁移映射。
- 建立 23 个 Playbook 路由目录与初步分析。
- 深读 Feature、Investigation、Bug Fix、Autonomous Run、Orchestrate、Autopilot-full、Multi-phase Plan。
- 本轮新增深读 Babysit、Shipping、Refactoring、Perf issue、Hillclimb。
- 新增 PR 生命周期与质量改进专题，分析 merge frontier、独立验证、Patch identity、行为基线和持续性能实验。
- 通过上游 Git tree + blob 快照读取补齐 Autopilot-stack 及最后 10 个 Playbook，绕开 Contents API 限流。
- 新增剩余 11 个 Playbook 专题文档，覆盖 Autopilot-stack、Runtime forensics、Trace forensics、Prototype、Visual parity、Eval、Authoring a skill、Opening a PR、Pause safely、Session pickup、Worktree cleanup。
- 更新 Playbook 总表、README 和研究进度：23/23 个 Playbook 的文本研究完成；配套 Scripts、References、Harness、Tests 仍需代码级审计。

- 新增 24 条工程原则逐项研究，整理其触发条件、核心规则、组合关系及 BMC 落地映射。
- 新增核心 Agent 协作机制深度研究，覆盖 Architect、Arena、Swarm、Interrogate、How、Why、TDD 和验证思路。
- 对固定 Git tree 重新盘点 P-Stack Skills：当前快照为 58 个 SKILL.md，其中 34 个通用 Skill、24 个 Principle Skill；早期 61 个统计属于不同快照，已在清单中说明差异。
- 新增 Skills 全量目录与状态表。引用文件、脚本、测试及宿主适配器仍待审计。

- 新增 Agent 与 Automation 研究文档，分析 poteto-agent、comment-sicko、Benny Slack Triage / Repro 自动化、权限边界和失败关闭机制。

- 新增 Scripts 与 Test Harness 专题，审阅 watch-pr 状态机、check-plan 结构检查、worktree-audit 安全审计、TSV 决策日志和 Statechart/TLA+ 工具链。

- 新增 30 个 Reference 文件职责盘点及 Claude Code Harness 迁移分析，审阅 Adapter、自动生成脚本、工具映射、Cursor-only 能力降级和 Codex 迁移建议。

- 补齐 Benny 的 Control Adapter、Feature Map、Verify Existing Fix、Routing Map 四个引用文件，完成自动化包 12/12 文件文本研究。

- 新增元工作流研究，分析 Figure It Out、Setup P-Stack、Automate Me、Reflect、Correct 及其长期学习闭环。
