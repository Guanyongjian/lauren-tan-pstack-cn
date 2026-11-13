# P-Stack 到 Codex 多模型工作台：目标架构设计

> 本文是基于 P-Stack 研究形成的二次设计，不是 Lauren Tan 或 Cursor 的上游方案。
> 目标：在本地 WSL 环境运行一个工作台，统一管理 Codex、Kimi、DeepSeek 等模型的任务、会话、Worktree、验证和证据。

## 1. 设计结论

建议采用 **Local-first Control Plane + Provider / Runtime Adapters + Isolated Agent Workers**。

- 控制面运行在用户自己的 WSL 环境中，拥有任务状态、文件、Git 和工作区。
- 模型调用可以走远端 API，但代码、工作区、日志和任务状态默认留在本地。
- Web UI 只负责观察和操作；真正的任务状态由本地服务持久化，不放在浏览器内存。
- Codex CLI 与 OpenAI 官方模型配置保持原样；Kimi / DeepSeek 使用独立 Provider Profile 或独立 CODEX_HOME，避免覆盖既有登录状态和会话。
- P-Stack 的 Markdown Skill / Playbook 是流程知识源，工作台需要执行引擎、权限层和工具 Adapter 才能真正运行。

## 2. 总体结构

```text
Windows Browser / Desktop
          | localhost
          v
Local Workbench UI
          | REST / WebSocket
          v
Control Plane (WSL)
  | Task DB / Event Log / Approval Policy
  | Workflow Engine (Playbooks)
  | Role Router / Model Registry
  | Agent Runtime Manager
  | Evidence Store
  | Tool Adapters
  |
  +--> Codex CLI Runtime (existing CODEX_HOME profiles)
  +--> Kimi Provider Adapter (Volcano Ark API)
  +--> DeepSeek Provider Adapter
  +--> Other OpenAI-compatible APIs
  |
  +--> Git / Worktree / Build / Test / SSH / Logs / PR
          |
          v
Isolated Worktrees + Artifacts + Verification Records
```

远端只承担模型推理和必要的代码托管服务。工作台本身不需要部署到公网，也不需要把整个仓库同步到一个远端 Agent 平台。

## 3. 核心模块

### 3.1 Control Plane

负责创建任务、状态转换、调度 Worker、权限检查、持久化和用户通知。主 Agent 可以规划和审查，但不能越过工具权限直接执行高风险动作。

### 3.2 Workflow Engine

将 23 个 Playbook 映射为可执行状态机，而不是 23 份孤立 Prompt。每个 Playbook 定义：
- Trigger / Preconditions；
- 阶段与步骤；
- 所需角色和工具能力；
- 每一步输入 / 输出；
- 验收谓词和证据要求；
- 失败、重试、暂停和恢复规则；
- 需要人工批准的操作。

例如 Bug Fix 的状态流：

```text
INTAKE -> RESTATE -> REPRODUCE -> ROOT_CAUSE
       -> DESIGN -> IMPLEMENT -> VERIFY
       -> REVIEW -> PR_READY -> HUMAN_MERGE
```

每个状态迁移必须保存事件和证据。不能因为模型回复“完成”就自动推进。

### 3.3 Model Registry / Role Router

角色和模型分离。建议先定义稳定角色：

| 角色 | 职责 | 常见模型选择策略 |
|---|---|---|
| Planner / Architect | 需求建模、数据形状、接口和方案 | 高推理能力模型 |
| Coder / Worker | 在限定 Worktree 和文件范围内实现 | 性价比与代码能力优先 |
| Investigator | 只读调查代码、日志、历史和数据 | 长上下文、工具调用稳定 |
| Reviewer / Adversary | 独立找缺陷，禁止修改被测代码 | 尽量不同模型家族 |
| Judge | 盲化比较候选方案 | 与候选模型家族隔离 |
| Verifier | 运行测试 / 真实产品验证，产出证据 | 工具可靠性优先，不以写代码能力为准 |
| Coordinator | 汇总结果、管理状态和用户授权 | 稳定遵循规则的模型 |

Role Router 根据 Provider 能力、上下文长度、工具权限、成本预算、Reasoning Budget 和任务类型选模型。模型选择必须可审计，不能悄悄自动切换后仍报告原模型。

### 3.4 Provider / Runtime Adapters

需要区分两种接入方式：
- **CLI Runtime Adapter**：启动和管理本地 Codex CLI 子进程，支持独立配置目录、会话恢复、工作目录和输出采集。
- **API Provider Adapter**：直接调用兼容的模型 API，负责鉴权、模型名、请求格式、流式响应、工具调用和错误重试。

不要把“火山方舟 API 可调用”误认为“它自动继承 Codex CLI 的会话、工具和沙箱能力”。若 Kimi 通过 API 接入，工作台必须自己管理对话状态、工具执行和结果回传；若通过 Codex 自定义 Provider 接入，则还需遵守 Codex 当前支持的 Provider 配置语义。

### 3.5 Agent Runtime Manager

每个 Agent Run 都是一个独立执行实例，至少记录：
- task_id / run_id / parent_run_id；
- role / provider / model / reasoning_budget；
- worktree_path / branch / base_sha；
- writable_paths / tool_permissions；
- prompt_version / skill_versions / playbook_version；
- start / end / status / exit_reason；
- stdout / stderr / transcript / artifacts。

同一 PR 的写入权只归属一个 Owner。其他 Agent 只读审查或在独立 Worktree 中做实验，避免共享文件竞争。

### 3.6 Evidence Store

验证结果不是一句 PASS，而是一个绑定代码版本的证据对象：

| 字段 | 含义 |
|---|---|
| artifact_id | 证据唯一 ID |
| task_id / pr_id | 关联任务和 PR |
| head_sha / patch_id | 验证代码版本和 Patch 身份 |
| verifier_run_id | 验证者身份 |
| provider / model | 验证者使用的模型 |
| environment | 构建、设备、镜像、配置、数据集 |
| command / procedure | 实际执行步骤 |
| result | PASS / PASS+NOTES / FAIL / INCONCLUSIVE |
| raw_outputs | 日志、截图、视频、Trace、报告路径 |
| created_at | 证据生成时间 |

代码 Patch 变化后，系统重新判断旧证据是否有效。对真实 UI、设备或运行时验证，不能只靠 Patch ID 推断行为仍然一致。

### 3.7 Policy / Approval Engine

按副作用风险分级：
- L0 只读：读取文件、日志、Git 历史、PR 状态，默认允许。
- L1 本地可逆：新建 Worktree、改本地文件、运行测试，任务范围内允许。
- L2 远端可逆写入：创建 Draft PR、回复 Review Thread、更新 Issue，需要明确任务授权。
- L3 不可逆或外部影响：合并、部署、删除数据、发送外部消息、修改生产设备，必须单独授权。

默认不给 Worker 合并、部署、删除和外部消息权限。用户明确授权一个动作，不代表授权整个后续链条。

## 4. 持久化数据模型

建议第一版使用 SQLite，文件和大体量产物放本地 Artifact Store。

| 实体 | 核心字段 |
|---|---|
| Project | repo_url, root_path, default_branch, toolchain |
| Task | goal, done_predicate, status, priority, owner, created_at |
| WorkflowRun | playbook, version, current_step, state, checkpoint |
| AgentRun | role, provider, model, parent_run, worktree, status |
| Worktree | path, branch, base_sha, dirty_state, owner_run |
| Artifact | type, path, sha256, task_id, run_id, commit_sha |
| Verification | head_sha, patch_id, verifier, environment, verdict |
| Approval | action, scope, requested_by, approved_by, expires_at |
| Event | event_type, payload, actor, timestamp, idempotency_key |
| ModelProfile | provider, model, endpoint, auth_ref, capabilities |

事件日志采用追加式设计；任务当前状态可以由事件重建。所有写操作使用幂等键，避免断线恢复后重复创建 PR / Ticket / 评论。

## 5. Worktree 和 Git 所有权

每个写入型 Worker 使用独立 Worktree：

```text
repo/
  main worktree (read-only coordinator by default)
  .worktrees/task-101-owner/
  .worktrees/task-101-reviewer/
  .worktrees/task-102-worker-a/
  .worktrees/task-102-worker-b/
```

实际路径可使用 git worktree list 管理，不靠目录名推断。每个 PR 一个 Owner，Owner 负责提交和分支操作；Verifier 对固定 SHA 只读验证；Coordinator 只协调，不代替 Owner 修改同一分支。

## 6. UI 形态

第一版推荐本地 Web UI，而不是桌面 Electron：
- WSL 中运行 API Server 和 Worker Manager；
- Windows 浏览器访问 localhost；
- 通过 WebSocket 推送任务状态和 Agent 日志；
- UI 展示 Task Board、Agent Runs、Worktree、Evidence、Approval 和 Cost；
- 所有数据落在 WSL 本地 SQLite / 文件目录。

这样本地部署、升级和调试都简单。后续如果需要桌面通知、全局快捷键或系统托盘，再加 Desktop Shell，不应一开始把 UI 技术栈变成架构核心。

## 7. MVP 实施路线

### Phase 0：单 Agent 闭环

- 本地任务创建和持久化；
- Codex CLI Runtime Adapter；
- 单 Worktree；
- 任务状态、日志、Diff、测试证据；
- 用户手动批准 Commit / PR。

验收：从任务创建到代码修改、测试和报告全链路可恢复，关闭 UI 不丢状态。

### Phase 1：角色分工与独立验证

- Role Router；
- 独立 Coder / Reviewer / Verifier；
- 每个写入 Worker 独立 Worktree；
- Evidence 绑定 SHA / Patch ID；
- 权限策略和人工审批。

验收：一个 Agent 开发，另一个 Agent 不改代码地验证；发现问题后可回到 Owner 修复并重新验证。

### Phase 2：Arena / Swarm / Eval

- 同题候选隔离运行；
- 不同模型家族 Judge；
- 切片任务并行；
- 盲测任务集和统一评分；
- 结果合成与决策记录。

验收：能证明不同模型在相同任务和环境下的质量差异，而不是只比较主观印象。

### Phase 3：PR 生命周期

- Forge Adapter；
- PR Watcher；
- Babysit / Shipping 状态机；
- 仅 Autopilot-stack（不自动合并）作为初始自动化；
- 合并始终需要人工批准。

### Phase 4：BMC 工程适配

- 构建 / Conan / 编译日志 Adapter；
- 设备 SSH / Serial / DBus / Redfish / IPMI 控制 Adapter；
- 真实设备验证和证据采集；
- Lua / C 项目规范和测试模板；
- TLA+ 状态模型工具链。

## 8. 不应照搬的 P-Stack 设计

| P-Stack / Cursor 假设 | Codex 工作台处理方式 |
|---|---|
| Cursor Task / Agent | 由 Codex CLI 或 API Runtime Adapter 实现 |
| Cursor Cloud Agent | 本地 Git Worktree / 独立容器，必要时再接远端 Runner |
| Cursor Automations | 本地 Event Scheduler + Webhook / Poller |
| Bugbot | Forge Review Thread Adapter + 自己的审查策略 |
| Cursor MCP 工具 | 统一 Tool Registry，按实际连接器注册 |
| pstack-models.mdc | Provider Profile + Role Policy 配置 |
| Cursor Transcript 目录 | 自己的 Task / Run / Event 数据模型 |
| Cursor 内置 PR 工具 | GitHub / CodeHub / GitLab Forge Adapter |

不要把 P-Stack 的某个具体模型 Slug、CLI 命令或目录路径写死在工作流里。它们应该属于 Adapter / Profile 配置。

## 9. 关键非功能要求

- **安全：** API Key 不写入 Prompt、日志、Git、任务导出包；只保存 Secret Reference。
- **隔离：** Agent 只能访问其授权 Worktree 和路径；Reviewer 默认只读。
- **可恢复：** 进程崩溃后从持久化状态恢复，重复执行不会重复外部副作用。
- **可审计：** 每个结论可以追溯到模型、Prompt 版本、Git SHA、命令和原始证据。
- **成本可见：** 记录每个 Provider 的 Token、请求数、时延和费用估算。
- **可替换：** 更换模型不改变 Playbook 状态机；更换 UI 不改变任务执行层。
- **诚实降级：** 当前宿主不支持某项能力时，标记 SKIPPED / BLOCKED，不伪造 PASS。

## 10. 最终建议

先把单 Agent 的任务闭环和持久化做正确，再扩大并行。第一版不需要 10 个 Agent，也不需要全自动合并。最有价值的早期成果是：一个需求能被主 Agent 正确理解、在隔离 Worktree 中完成、由另一个模型独立验证、证据绑定具体 Patch，并能在中断后恢复。