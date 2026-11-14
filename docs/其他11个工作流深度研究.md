# Playbook 深度研究（三）：剩余 11 个流程

> 上游快照：`cursor/plugins` Git tree `24621dbcc59e205a7faadb0e06d540f91712b5cc`  
> 本文覆盖此前未深读的 11 个 Playbook。中文内容为分析解读，非逐字翻译。

## 1. Autopilot-stack：自动开发和验证，但不合并

上游：[autopilot-stack.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/autopilot-stack.md)

它直接复用 Autopilot-full 的完整流程，但将终点从“已合并”改为“当前 Head 已验证且 CI 绿色”。随后把 PR 交给操作者，交接之后任何人都不得 Push，除非操作者明确允许。

堆叠 PR 的处理规则：
- 只有确实依赖另一个 PR 时才建立 Stack。
- Stack 根节点 Rebase 到 trunk；子 PR Rebase 到父 PR 的分支。
- 下层 PR Head 更新后，上层 PR 需要重新 Stack。
- 如果 Restack 后某个 PR 的 `git patch-id` 未变化，原验证结论可继续有效。
- 最终逐个列出 PR 和验证结果，而不是汇报合并结果。

**设计意义：** 这是非常适合本地工作台的默认自动化级别。Agent 可以完成编码、CI 和独立验证，但把不可逆的合并决策留给人。比一开始开放 Autopilot-full 更稳妥。

## 2. Runtime forensics：对正在运行的进程做现场取证

上游：[runtime-forensics.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/runtime-forensics.md)

核心原则：诊断必须基于正在运行的真实进程信号，不能只读源码推测。交付物是有证据引用的诊断，不是修复。

流程：
1. 在匹配的真实操作面采集信号：CPU Profile、Heap Snapshot、CDP Trace 等。
2. 将大型产物交给子 Agent 解析，主 Agent 只保留压缩后的关键发现。
3. 用运行时注入或热修方式低成本验证机制，例如 CDP eval 或不重载的 Live Hotfix。
4. 将运行时发现映射回源码文件、符号和分配/调度位置。
5. 将 Throughput Checkpoint 明确标为只读取证。

**边界：** 原因确认后交给 Bug Fix 或 Perf Issue；没有用户授权，不顺手修改产品代码。

**迁移建议：** BMC 场景可以映射为现场 CPU/内存/线程/DBus/系统日志/Trace 采集，要求报告包含设备版本、采集命令、时间范围、原始产物、关键证据和源码位置。不要把离线日志推断冒充现场取证。

## 3. Trace forensics：分析已有捕获文件

上游：[trace-forensics.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/trace-forensics.md)

与 Runtime forensics 的区别：现场取证会操作活进程；Trace forensics 的输入已经是固定捕获文件，应该分析它，不要重新运行覆盖原始证据。

流程：
1. 识别格式，选择对应解析器。
2. 大文件先转换为可查询结构，例如 SQLite，每个 Sample、Frame 或 Node 一行。
3. 查询热点调用栈；内存泄漏沿 Retainer Chain 追到 GC Root；Spindump 查找持续占用 CPU 或阻塞的线程及等待原因。
4. 将热点帧映射到源码文件、符号和行号。没有符号映射就不能声称完成归因。
5. 有前后配对捕获时做 Diff；没有配对捕获，只能称为“当前证据支持的最强假设”，不能声称已确认因果。
6. 输出诊断和产物路径，不直接修复。

**迁移建议：** 建立统一 Artifact Adapter，记录文件 Hash、格式、采集工具版本、符号文件版本和解析脚本版本。分析过程不覆盖原始文件。

## 4. Prototype：用一次性原型帮助做设计决策

上游：[prototype.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/prototype.md)

Prototype 的产物不是可交付代码，而是一个设计决策。它刻意反转常规工程要求：速度优先、不做生产级抽象、不写测试、不做过度规划。严谨性集中在“是否用最低成本回答了正确的问题”。

流程：
1. 明确原型要帮助决定什么：布局、交互、密度、行为、时序或技术路线。没有明确决策问题就不该做原型，应转 Feature。
2. 方向开放时先收集参考案例，整理设计方向供选择；方向已确定则跳过。
3. 在独立 Scratch 目录做一次性实现，不能混入生产源码。
4. 比较多个方案时用同一 Switcher 切换，标注每个变体。
5. 在真实匹配界面观察、截图或测量。这里“观察结果”就是验证，不强求传统断言测试。
6. 提交备选方案、证据、权衡和建议，之后由 Feature / Architect 做正式实现。

**迁移建议：** 可用于 BMC Web UI 原型、Lua 模块接口方案、配置同步时序实验等。原型代码必须标记为 Throwaway，避免误合入生产。

## 5. Visual parity：像素级视觉等价

上游：[visual-parity.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/visual-parity.md)

核心原则：基线就是规格，不能为了让 Diff 通过而修改基线或测试工具。

流程：
1. 在迁移前建立视觉回归 Harness，覆盖组件状态；需要双实现对照时同时保存目标截图。
2. 明确禁止修改 Harness、篡改 Baseline、重构组件以迎合 Diff。
3. 一次迁移一个组件；不同组件可在独立 Worktree 并行，共享基础组件先迁移。
4. 在匹配真实界面截图并做图像 Diff；非零 Diff 即失败，定位像素变化并循环处理到零。
5. 每个组件或安全批次独立开 PR。

**迁移建议：** 适用于 Web 管理界面升级、前端框架迁移和 Redfish Web 页面视觉一致性；不适合直接套用到没有稳定渲染环境的纯 BMC 后台服务。

## 6. Eval：对模型、Skill 或 Prompt 做盲测

上游：[eval.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/eval.md)

Eval 最重要的是避免候选知道自己正在参加评测，防止它针对评测目标表演。

### 盲测约束

- 候选可见的目录、文件、提示词中不能出现 eval/test/judge/rubric/score/benchmark/candidate/arena 等泄漏评测意图的词。
- 候选提示词应像真实用户请求，只描述目标。
- 不要求候选自述使用了哪些 Skill 或原则；应从实际打开的文件和代码结构判断。
- 候选不知道还有其他候选。
- Judge 可以知道自己在评测，但只能看到匿名标签，不能看到模型名称。
- 比较多个版本时，一个 Judge 在同一轮、同一评分尺度上评估全部结果。

### 执行步骤

1. 明确被测变体和成功行为，给 Judge 准备 3–6 个具体评分标准，候选不可见。
2. 为每个候选准备隔离且已脱敏的工作目录，布置自然任务需要的上下文。
3. 编写一个自然用户提示。
4. 在不同模型上并行运行候选，使用同一提示和独立目录。
5. 使用不同模型家族的一个盲化 Judge 评分。
6. 从真实 Transcript 核验候选到底读了哪些文件、做了什么，不采信自我报告。
7. 主 Agent 阅读所有候选结果，对照 Judge 判断偏差，综合给出是否推广的建议。

**迁移建议：** 用于比较 Codex / Kimi / DeepSeek 的编码质量、不同系统提示、Skill 版本和调度策略。要固定任务集、环境、预算、模型版本、温度/采样参数和工具权限；否则实验不可比。评测日志应保存脱敏后的任务、输出、Judge 理由和复核结果。

## 7. Authoring a skill：Skill 创作与维护

上游：[authoring-a-skill.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/authoring-a-skill.md)

流程：
1. 使用专门的 Skill 创建工具，不从空白开始随意堆提示词。
2. 校验 Frontmatter 是否包含 name 和 description。
3. 检查引用文件存在、跨 Skill 链接可解析。
4. 结构性规则应有测试用例；纯主观语气类内容可跳过机械测试。
5. 进入 Opening a PR。

内容原则：
- 不确定是否需要的内容优先删除。
- 只保留会改变决策的文字。
- 规则直接写要做什么；仅在规则容易误解时解释原因。
- 把稳定知识写进类型、README、配置等结构性来源。
- Skill 之间按路径委托，不重复复制同一流程。
- 若某个工作流反复出现但没有被捕获，应考虑新建 Skill。

**迁移建议：** 我们的工作台应把 Skill 当成有版本、有依赖、有校验、有测试的可维护资产，而不是随手拼接的 Prompt 文件。

## 8. Opening a PR：统一的 PR 创建规范

上游：[opening-a-pr.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/opening-a-pr.md)

这是其他 Playbook 最终都会调用的交付流程。

### Worktree 与提交

- 从 main 的 Git Worktree 工作，避免多个任务污染同一工作目录。
- 多个 Task 在同一分支上执行时，各自独立 Worktree，或在执行前重置到指定分支。
- Commit 应及时创建，最终整理成小而有序、可独立合入的提交。
- 能归属刚创建的 Commit 就 Amend；可独立交付的内容新建 Commit。

### PR 标题和描述

标题遵循 Conventional Commits：`type(scope): subject`，简短、祈使、无句号。

描述按审查者一分钟读完的 Briefing 编写，核心部分包括：
- Why：为什么做；
- What changed：改了什么；
- Scope：覆盖与明确不覆盖的范围；
- Tradeoffs：真正需要审查者知道的取舍；
- Blast Radius：影响范围和风险；
- Verification：真实运行路径和结果。

PR 描述不应变成实验日志或文件清单；完整证据可放在单独产物中链接。

### Forge 与堆栈

- 第一次 PR 操作前确定 Forge，并保持同一 Forge 完成创建、编辑、查看、检查和合并。
- 若运行环境有内置 PR 工具，创建、编辑、Retarget 和 Ready 操作必须使用该工具。
- 优先多个窄 PR，而不是一个巨型 PR。
- 只有有真实依赖时才堆叠 PR；根 PR 面向 trunk，子 PR 面向父分支。
- PR 默认以 Ready 状态创建，而不是 Draft。
- 创建 PR 不等于开始 Babysit；先完成整阶段或整栈，再按用户要求 Babysit。

**迁移建议：** 将 PR 描述生成、提交拆分、依赖图和 Forge 选择做成结构化服务，避免完全依赖 Agent 临时记忆。

## 9. Pause safely：安全暂停

上游：[pause-safely.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/pause-safely.md)

只有用户明确要求暂停才进入此流程。“继续做”“我去睡觉了继续做”“不要停”等不应误判为暂停。

步骤：
1. 停在安全边界：完成当前原子步骤或撤销未完成步骤，启动新的工作前先暂停，并取消嵌套子 Agent。
2. 暂停不应引入不可逆操作，不为暂停额外创建 PR 或 Push。
3. 将未提交改动作为一个清晰的 WIP Commit 保存；若工作树本身损坏，在 Commit Body 中明确说明。
4. 写独立 Resume Note，记录目标、当前进度、已验证内容、状态、下一步、关键文件和陷阱；已有决策轨迹则引用，不重复抄写。

**迁移建议：** 任务持久化必须包括运行状态、当前步骤、Worktree、分支、未提交变更摘要、子 Agent 状态和恢复入口。暂停不应等同于杀进程。

## 10. Session pickup：接手前序 Agent 的工作

上游：[session-pickup.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/session-pickup.md)

流程：
1. 找到上一轮的权威记录：当前工作区 Transcript、云端 Agent URL 或已 Push 分支。先读元数据概览和最后消息，再回看决策节点；不能跨工作区扫描私人会话。
2. 重建实际状态：分支、Worktree、已合入内容、Git Diff、未完成 Todo 和已作出的决策。
3. 比较已完成与待完成事项，明确恢复点，不重复已经完成的排查和工作。
4. 将剩余工作重新路由到匹配的 Playbook。Pickup 只负责交接，不接管后续执行流程。
5. 在真实产物上验证继承的关键结论，不能把前一 Agent 的自我报告当作证据。

**迁移建议：** 工作台需要统一 Task ID、会话摘要、事件日志、Git 状态和 Artifact 索引。恢复时先还原状态，再决定是否需要重跑测试；不要仅靠一段自动摘要继续写代码。

## 11. Worktree cleanup：清理工作区和模拟器

上游：[worktree-cleanup.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/worktree-cleanup.md)

这是具有删除用户数据风险的流程，清理分类只是建议，不等于授权。

流程：
1. 记录磁盘空间，运行 Worktree Audit 脚本。审计依据 Git Worktree 实际列表，不凭目录命名猜测；按大小、年龄、合并状态、未提交改动、PR 状态和最近会话分类。
2. 结合用户 Pin 的会话和活跃会话核对候选 Worktree。Pinned 集合优先于自动审计的 safe 分类。
3. 对不确定或最近使用过的 Worktree，读取会话记录，判断是否仍被后台 Agent、Arena 或复现任务使用。
4. 对含未提交改动的 Worktree，先展示 Diff 并取得决定；不能因为它被标为旧目录就删除。未跟踪临时文件应明确列出。
5. 仅删除已确认安全的 Worktree，随后 prune 并复查磁盘空间。
6. 模拟器、构建缓存和包缓存也应逐类确认；用户要求保留的缓存不能清理。

**迁移建议：** 工作台清理操作默认 Dry-run，输出路径、大小、最后活动、Git 状态、关联任务和风险。删除必须二次确认；WIP、活跃任务和被 Pin 的工作区不可自动删除。

## 12. 23 个 Playbook 的研究完成状态

结合前两篇专题文档，本轮 11 个 Playbook 已补齐。23 个 Playbook 的目录级和逐篇深读工作至此完成：

- Feature
- Investigation
- Bug fix
- Refactoring
- Prototype
- Perf issue
- Hillclimb
- Runtime forensics
- Trace forensics
- Eval
- Visual parity
- Babysit
- Shipping
- Opening a PR
- Autonomous run
- Pause safely
- Session pickup
- Orchestrate
- Autopilot-full
- Autopilot-stack
- Multi-phase plan
- Authoring a skill
- Worktree cleanup

这表示 Playbook 文本研究已覆盖，不代表所有上游脚本和工具实现均已审计。后续仍需对相关 Skills、References、Scripts 和 Tests 做代码级核验。
