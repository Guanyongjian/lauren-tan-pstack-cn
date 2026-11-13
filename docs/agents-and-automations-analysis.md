# P-Stack Agents 与 Automations 研究

> 上游快照：cursor/plugins Git tree 24621dbcc59e205a7faadb0e06d540f91712b5cc
> 文件范围：2 个 Agent 定义，以及 Benny 自动化包下的 12 个文件。

## 1. Agent 与 Skill 的区别

Skill 定义可复用工作方法；Agent 定义一个被调度的执行角色。Playbook 负责任务生命周期。三者不能混为一谈：
- Skill：如何做某类工作。
- Agent：谁以什么权限和身份做工作。
- Playbook：整个任务按什么阶段推进、何时验收。
- Automation：由什么外部事件触发长期工作流。

## 2. poteto-agent：受控的代码执行委派者

上游：[poteto-agent.md](https://github.com/cursor/plugins/blob/main/pstack/agents/poteto-agent.md)

它是 Poteto Mode 中用于代码编写和辅助任务的后台 Subagent，不是 /poteto-mode 的主执行者。

关键约束：
- 每个新任务启动一个新的 poteto-agent。
- 只有主 Skill Subagents 部分明确允许时才恢复旧 Agent。
- 在任何工作前，必须完整读取 Poteto Mode Skill，包括内嵌 Principles 索引。
- 若找不到唯一正确的 Skill 安装副本，必须停止并向 Parent 报告。
- 应用原则时要定位到具体的 leaf principle Skill，而不是只记住总览。

设计意义：委派者不是通用聊天机器人。它先加载统一规则，确保每个 Worker 在相同工作契约下运行。工作台应为 Worker Brief 注入项目级规则、任务 Playbook 和所需原则，并记录实际加载版本。

## 3. comment-sicko：注释审查专用 Agent

上游：[comment-sicko.md](https://github.com/cursor/plugins/blob/main/pstack/agents/comment-sicko.md)

它以极端严格的方式审查注释和代码抑制项，主要找叙述性注释、Banner、被注释掉的旧代码、为自有代码异常写的长篇辩护、不必要的 workaround 注释，以及 ESLint / TypeScript 等 Suppression。

允许保留的例外包括法律许可头、公开 API 契约、外部依赖 / 平台 / 协议强制产生的非显然行为，以及特定格式化指令。外部行为的保留必须能被证明；自有代码的意外行为应通过重命名、抽取、类型或架构变得清晰，而不是靠注释解释。

Agent 只报告，不直接改应用代码。上层 No Comments Skill 负责审查其报告、决定接受哪些 Finding、执行根因修改，并提出将真实约束编码成类型 / 测试 / Lint 的方案。

设计意义：专项 Agent 应输出范围清晰的报告，而不是获得无限修改权。激进审查角色与实际修改角色分离，降低误删和越权风险。

## 4. Benny：事件驱动的 Slack 问题处理自动化

上游：[Benny 目录](https://github.com/cursor/plugins/tree/main/pstack/automations/benny)

Benny 是一个 Dormant Automation Pack，包含两条协作自动化：
1. Triage issue reports：分类 Slack 报告、追踪责任层、查重并在原 Thread 回复。
2. Reproduce and fix issues：等待可信 Triage Marker，复现真实 UI 问题，验证已有修复，必要时尝试有限修复并创建 Draft PR。

它不是普通 Slash Skill。安装流程会把整个目录合并到目标仓库的 .cursor/automations/benny/，并在项目设置中启用 P-Stack 作为共享依赖。

### 4.1 Triage 工作流

上游：[triage-issue-reports/SKILL.md](https://github.com/cursor/plugins/blob/main/pstack/automations/benny/skills/triage-issue-reports/SKILL.md)

主要流程：
1. 从 Trigger 校验源 Slack Channel，并冻结 Channel ID 和根 Thread Timestamp。
2. 读取完整 Thread 和附件，抽取版本、环境、预期行为、实际行为、频率、错误和已有修复链接。
3. 用 How / Why 做有限源码和历史追踪，判断症状所属层，避免把表面症状路由给错误团队。
4. 分类为 Bug、Performance、Feature Request、Question / Feedback 或 Reroute。
5. 根据 Routing Map 找 Owner；没有明确匹配时不猜测。
6. 通过 Tracker Adapter 查重。只有明确新 Bug 才创建 Ticket。
7. 在原 Thread 发一条实质性 Verdict，结尾带唯一可信 Marker。

关键安全规则：只能在原 Thread 回复，不能在源 Channel 发 Root Message、不能 DM、不能广播。每次外发前重新确认父 Thread 仍存在且坐标匹配。Coordinator 是唯一 Slack 写入者；子 Agent 只读、只返回分析。不能创建无法回链到源 Thread 的 Ticket。缺少配置、权限或上下文时 Fail Closed，宁可不发消息、不建单。

### 4.2 Reproduce and fix 工作流

上游：[reproduce-and-fix-issues/SKILL.md](https://github.com/cursor/plugins/blob/main/pstack/automations/benny/skills/reproduce-and-fix-issues/SKILL.md)

主要流程：
1. 冻结并验证原始 Thread 坐标。
2. 等待指定 Triage 身份发出的可信 Marker，只接受 Bug / Performance。
3. 如果有人明确接手修复，立即停止，避免抢工作。
4. 如果已有 PR 或合入 Commit 可能修复问题，切换到 Verify Existing Fix，不覆盖原作者工作。
5. 读取项目 Control Adapter 和 Feature Map。
6. 必须通过真实 UI 两次复现精确症状；状态读取只能辅助确认，不能人为注入故障。
7. 没有确认复现就不能写修复。
8. 确认后做一次有边界的根因修复，廉价测试路径使用 TDD，并做 Blast Radius / Smoke 验证。
9. 只有 Before / After 证据通过才可创建 Draft PR。
10. 证据、截图、录像和日志不得进入源代码仓库；不得合并或部署。

额外安全规则：子 Agent 不得获得 Slack Token 或任何 Slack 写入工具。如果无法证明 Worker 环境不含 Slack 凭据，则由 Coordinator 自己修改代码。每次向源 Thread 发消息前必须重新检查原始 Parent。操作状态 Thread 若启用，必须使用独立坐标，不能与源 Thread 混淆。

### 4.3 Setup 与外部配置

上游：[setup-benny/SKILL.md](https://github.com/cursor/plugins/blob/main/pstack/automations/benny/skills/setup-benny/SKILL.md)

安装器要求：合并完整 Automation Pack，保留目标仓库只存在的文件；对同路径冲突先看 Diff，不覆盖用户改动；在目标仓库 .cursor/settings.json 启用 P-Stack 共享 Skill；用户自己的 Routing Map、Feature Map、Secret 和配置放在 Pack 目录之外；从目标仓库启动新 Agent，验证项目级 Skill 依赖确实加载；只有用户明确要求时才创建或更新 Automation；Secrets 不能放进 Prompt、插件文件或提交到仓库。

配置模板：[configuration.example.yaml](https://github.com/cursor/plugins/blob/main/pstack/automations/benny/templates/configuration.example.yaml)

配置项覆盖 Slack Channel / Triage Identity、Repository、Tracker、Routing、Control Adapter、Feature Map、Verdict Marker、Status、预算和模型选择。

### 4.4 Benny 的架构特征

事件处理链：

Slack event → immutable source coordinates → trusted triage identity → classification and routing → tracker dedupe / ticket → real UI reproduction → ownership and existing-fix gate → bounded code change → before/after evidence → draft PR

它最重要的不是自动修 Bug，而是多个失败关闭的门：身份不可信，不执行；Thread 坐标不确定，不写入；责任人已接手，不竞争；已有 PR，不覆盖；无复现，不修复；无 Before / After 证据，不开 PR；没有明确授权，不合并、不部署。

## 5. 对本地多模型工作台的迁移

### 5.1 Agent 权限模型

| 角色 | 允许 | 默认禁止 |
|---|---|---|
| Coordinator | 读取状态、分配任务、汇总、向用户汇报 | 直接并发改写多个 Worker 的文件 |
| Code Owner | 写自己 Worktree、提交、按授权创建 PR | 改其他 Owner 的分支 |
| Read-only Investigator | 读代码、日志、历史并给出证据 | 修改代码、外发消息 |
| Verifier | 在隔离环境执行测试、记录证据 | 修改被测代码 |
| External-action Agent | 执行明确授权的外部动作 | 超出授权范围的消息、合并、部署 |

### 5.2 事件坐标和外部副作用

Benny 的 Immutable Thread Coordinates 可推广为通用事件模型：source_system、source_object_id、source_thread_id、event_id、actor_identity、received_at、idempotency_key。外部写入前必须重新确认目标对象仍存在、仍归属原事件，并使用幂等键避免重复创建 Ticket / PR / 消息。

### 5.3 失败关闭与人工授权

将操作分级：只读默认允许；本地可逆写入在 Worktree / Scratch 中默认允许；远端写入按插件权限和任务授权；不可逆操作（删除、合并、部署、发外部消息）明确授权后才允许。

### 5.4 与 BMC 开发流程结合

Benny 的先复现、再修复、再验证可以应用到 BMC 现场问题：从问题单 / 日志 / 设备版本建立不可变问题上下文；由一个 Agent 负责问题单归因，另一个独立 Agent 做代码审查；先在目标设备或可复现环境证明问题；复现失败时不直接写修复；修复后在同一设备版本、同一操作路径验证；保存命令、日志、总线读回、Redfish 响应和版本信息；PR 默认由人决定是否合并。

## 6. 文件盘点

| 文件 | 用途 |
|---|---|
| benny/README.md | Pack 安装和使用说明 |
| benny/FOR_AGENTS.md | 安装入口和合并要求 |
| skills/setup-benny/SKILL.md | 配置、依赖和 Automation 建立流程 |
| skills/triage-issue-reports/SKILL.md | Triage 操作契约 |
| skills/triage-issue-reports/references/routing.example.md | 路由示例 |
| skills/reproduce-and-fix-issues/SKILL.md | 复现与修复操作契约 |
| skills/reproduce-and-fix-issues/references/control-adapter.md | 控制适配器契约 |
| skills/reproduce-and-fix-issues/references/feature-map.example.md | 功能地图示例 |
| skills/reproduce-and-fix-issues/references/verify-existing-fix.md | 已有修复验证流程 |
| templates/configuration.example.yaml | 外部配置样例 |
| templates/reproduce-automation-prompt.md | Repro Automation 提示模板 |
| templates/triage-automation-prompt.md | Triage Automation 提示模板 |

## 7. 研究边界

本轮已阅读两个 Agent 定义、Benny 的入口说明、两个主要操作 Skill、Setup Skill、配置模板和 Automation Prompt 模板。Control Adapter、Feature Map、Routing Example、Verify Existing Fix 等引用文件仍需继续逐一读取并核验细节。本文不将这些主文件描述等同于已运行验证。