# References 全量盘点与 Claude Code Harness 迁移研究

> 上游快照：cursor/plugins Git tree 24621dbcc59e205a7faadb0e06d540f91712b5cc
> 参考文件：30 个 references 文件；Harness：harness/pstack/claude-code。

## 1. 30 个 Reference 文件的职责

### Architect（3）

- design-red-flags.md：设计候选的淘汰规则，包括浅模块、信息泄漏、按时间拆模块、透传方法、多写者、重复任务入口、可导入内部实现和手工同步列表。
- rationale-template.md：要求先写调用者使用方式，再推导类型与模块形状；必须写综合决策、接受的权衡、替代方案和开放风险。
- runner-prompt.md：给每个独立设计候选使用统一契约，要求不同模型各自提出完整设计，不要提前收敛到安全的中间方案。

**结论：** Architect 的设计评审标准具体到可观察的结构坏味道，不是泛泛的 SOLID 检查。调用者体验先于类型草图，是其重要设计顺序。

### Create Verification Skill（3）

- feature-map-example/README.md：定义真实应用的验证环境、隔离数据目录、健康检查、证据留存和 Feature Map 格式。
- create-note.md：示范如何通过 UI 和 CLI 创建数据，并从第二个用户可见视图确认持久化。
- search.md：示范搜索入口、标题 / 正文命中、空结果、清除查询和 CLI 一致性。

Feature Map 的核心是从用户 POV 描述行为，不写内部实现细节；每个 Feature 都要列出所有入口、精确操作命令、可观察结果和陷阱。验证实例必须是本次 Run 启动并健康检查过的实例，避免驱动其他人正在使用的环境。

### How（2）

- explorer-prompt.md：每个只读 Explorer 负责一个独立切面，返回组件、调用流程、读取文件、系统边界、非显然行为和未解问题。
- explainer-prompt.md：主 Explainer 汇总多个 Explorer 的结果，自己复核矛盾，按 Overview / Key Concepts / How It Works / Where Things Live / Gotchas 输出。

这让并行调查变成可合并的结构化数据，而不是多个 Agent 各自写一篇重叠文章。

### Poteto Help（2）

- prompting.md：用户提示只需说目标、完成检查、需要展示的证据、已有上下文和真实约束；不要把执行步骤写死，因为 Playbook 负责步骤。
- recipes.md：按理解、构建、设计计划、审查交付、离开与恢复给出可复用提示词。

其核心是把用户 Prompt 从“操作说明书”变成“目标 + 可检查完成条件 + 证据要求”。

### Poteto Mode（1）

- bugbot-triage.md：将 Bugbot 评论分成 fix / dismiss / ask；学习到的跳过模式必须有置信度、适用条件、禁止跳过条件、示例和来源。高风险安全 / 隐私 / 数据问题不能因重复噪声而自动忽略。

### Reflect（4）

- divergent-reviewer.md：寻找反直觉、二阶影响、遗漏的验证和未发生但本应发生的步骤。
- judgment-reviewer.md：从会话错误、用户纠正、工作偏好和反复手工步骤中提炼可泛化原则。
- tooling-reviewer.md：挖掘命令、工具参数、库行为、CI 入口、路径约定和 Agent 本可自行查询却让用户手工提供的上下文。
- synthesizer.md：对三类 Reviewer 的发现做耐久性、具体性、决策影响、已有覆盖、结构化机制可替代性和 Skill 使用范围审查；只有用户批准后才应用 Accepted 修改。

Reflect 不是自动把对话复制进 Skill。它先多视角提取候选，再去重、验证、路由、拒绝低价值或已覆盖建议，并要求用户批准。

### Show Me Your Work（1）

- decision-log-template.tsv：单行 TSV，字段为时间、阶段、决策、理由、证据和结果。配套 log.sh 对换行和表格公式注入做了处理。

### Statechart（1）

- render.md：要求 Mermaid 产物用指定渲染器输出 SVG，并通过 CSS 标记违规状态、最短 Bug Path 和循环状态。渲染器参数需要放大默认限制以支持较大图。

### TypeScript Best Practices（1）

- patterns.md：提供 Branded Types、判别联合、构造性类型、NonEmpty、时间范围建模、边界验证和简单全类型等代码示例。

### Why（12）

- epistemics.md：把历史动机证据分为 Direct、Supported、Inferred、Speculative、Unknown 五级，明确每级的措辞和引用要求。
- investigator-prompt.md：每个调查者只负责一种证据来源，记录搜索词、完整阅读引用内容、原文摘录和未查到的内容；禁止跨来源追踪造成重复工作。
- source-playbook.md：定义代码历史、Issue Tracker、长文档、团队聊天、可观测性、错误追踪、产品分析等证据类别。
- synthesizer-prompt.md：合并各类来源证据，检查冲突、校验引用、区分事实和推断，并明确未搜索的来源。
- sources/code-archaeology.md：Git Log、Pickaxe、Blame、Commit Diff、ADR、测试和共变文件的调查方法。
- sources/linear.md：Issue 描述、评论、父子任务、项目文档、标签、重复链和过期票据检查。
- sources/notion.md：PRD、RFC、ADR、会议记录、父子页面和文档版本核对。
- sources/slack.md：按作者、PR URL、错误字符串和时间范围检索，必须读取 Thread，并注明保留期限和私信不可见等缺口。
- sources/datadog.md：从 Service、Dashboard、Monitor、Metric、Logs、APM、Incident 还原运行时背景。
- sources/sentry.md：按异常、Release、First Seen / Last Seen、事件栈和标签定位错误历史；AI 分析仅作为假设来源。
- sources/databricks.md：用产品分析和仓库事件数据解释功能使用、阈值和实验背景；查询前先探测 Schema，并限制时间窗口。
- sources/incident-postmortem.md：当目标代码涉及 Retry、Timeout、Rate Limit、OOM、Feature Flag 等防御逻辑时，额外追查事故记录。

Why 的关键贡献是认识论纪律：代码能证明现在做什么，不能单独证明作者当时为什么这么做。没有证据也是有效结论。

## 2. Claude Code Harness：P-Stack 如何跨宿主迁移

上游：[Claude Code Harness Adapter](https://github.com/cursor/plugins/blob/main/pstack/docs/harness/claude-code.md)；[Harness 生成器](https://github.com/cursor/plugins/blob/main/scripts/generate-pstack-harness-trees.mjs)。

### 2.1 不是简单复制目录

插件元数据版本为 0.15.36，许可证 MIT。Cursor 使用 pstack/ 原目录；Claude Code 使用 harness/pstack/claude-code/ 生成树。固定快照中，源 pstack 有 573 个文件，生成 Harness 总计 560 个文件（其中 559 个在 claude-code 子目录，另有 Harness README）。差异主要是 Cursor 专属 Automations（12 个文件）和 Logo 资源（1 个文件），另加生成 README。

README 明确要求修改源目录后运行根目录脚本生成 Harness；不能手工改生成副本。CI 使用 --check 比较文件内容和可执行权限，发现漂移就失败。

### 2.2 Generator 做了什么

generate-pstack-harness-trees.mjs：
1. 扫描 Skills，识别哪些文件引用 Cursor 专有工具 / 字段 / 路径 / 模型名。
2. 检查每个 Skill 的 frontmatter name 必须与目录名一致，且符合 Agent Skills 命名限制。
3. 检查 Harness Adapter 是否覆盖每一种被使用的 Cursor 专有术语。
4. 将所有 Skills、Agents、Guide、Adapter、README 和 License 复制到生成目录。
5. 对需要迁移的 Skill，在 H1 后自动插入“先阅读 Claude Code Adapter”的说明。
6. 改写相对链接：Harness 内存在的文件保留相对链接；未被打包的源文件转成 GitHub 链接。
7. 检查生成目录内部是否存在断链。
8. --check 模式比对磁盘文件内容与 executable bit，保证生成树与源一致。

这是一个真正的适配编译器：源工作流保持一套，生成器依据使用到的 Cursor 能力，把它转换成 Claude Code 版本。

### 2.3 工具映射

| Cursor | Claude Code |
|---|---|
| Task | Agent |
| AskQuestion | AskUserQuestion；非交互模式改用普通文本提问 |
| Todo List | TodoWrite；没有时由主 Agent 在回复中维护 |
| 运行其他 Skill | Read 对应 SKILL.md 后遵循 |
| Grep / Glob | Bash + rg |
| poteto-agent / comment-sicko | pstack:poteto-agent / pstack:comment-sicko |
| readonly Worker | Explore Agent，并在 Brief 明确禁止写文件，之后检查 git status |
| cloud Worktree | Agent isolation: worktree |
| Cursor 模型规则 | ~/.claude/rules/pstack-models.md |
| Cursor Transcript | ~/.claude/projects/<slug>/<session>.jsonl |

Claude Code 的 Agent 模型参数只接受特定 model 名和 effort；非 Claude 模型 Slug 不能照搬，需回退当前会话模型并明确说明。Fast 后缀也不能机械保留。

### 2.4 Cursor-only 功能处理

Claude Code 没有 Cursor Automations、Bugbot 自动化、Cursor Cloud Agent 和内置 PR 工具。适配器规定：需要 Cursor 专属功能时写一行 Skipped 说明后继续；如果后续步骤需要被跳过步骤产生的 URL / Key，则保留占位符并说明。GitHub PR 本身仍可通过 gh 等 Forge CLI 完成，所以不应把“没有内置 PR 工具”误解为“不能操作 PR”。

### 2.5 对 Codex 工作台的启示

Claude Code Harness 是 Codex 适配最值得参考的部分，但不能直接把它当作 Codex Adapter。Codex 需要自己的能力映射表和生成器：
- Skill 调用：Codex CLI 的提示 / 文件读取 / 配置机制，而不是假定存在 Cursor Slash Skill。
- Subagent：根据 Codex 当前可用的多 Agent 能力和隔离机制实现；没有等价能力时要显式降级。
- Model：将 provider + model + reasoning budget 映射为统一 Role 配置；火山方舟 Kimi、DeepSeek 和 OpenAI 模型的 API 参数分别适配。
- Tools：把 Git、Shell、测试、PR、文件和联网能力作为工具接口，而不是写死 Cursor Task / MCP 名称。
- Transcript：为 Codex 会话和任务建立统一 Task ID / Session ID 索引，不直接套用 Cursor 或 Claude 路径。
- Cursor-only Automation：在 Codex 工作台中重建事件调度、条件触发、状态持久化和人工确认，不是简单复制 Benny 提示词。

建议把 P-Stack 作为工作流源语言，Codex Adapter 作为独立运行时。Playbook 定义阶段和证据，Adapter 负责模型、工具、上下文、权限和文件路径转换。

## 3. 本轮结论

1. P-Stack 已经展示出多宿主设计：同一工作流源，使用显式 Adapter 映射宿主工具和能力。
2. 生成 Harness 不是第二套手工维护代码，而是由源目录自动生成并通过 CI 防漂移。
3. 不支持的宿主能力必须显式跳过或降级，不能假装成功。
4. Why 的证据分级、Reflect 的多视角评审和 Architect 的统一 Runner Prompt，说明 Skill 资产不仅是说明文字，也包含可复用的子 Agent 协议。
5. 对 Codex 最重要的工程任务，是实现一套自己的 Adapter / Generator / Capability Registry，而不是复制 P-Stack 的 Cursor 语法。

## 4. 仍需验证

- 本轮未在 Claude Code 中实际安装插件并运行所有流程；只审阅 Adapter 和生成器源码。
- 本轮未运行 generate-pstack-harness-trees.mjs --check；源文件和生成文件的一致性结论来自脚本实现审阅，不是本地执行结果。
- Codex 适配能力需根据实际 Codex CLI 版本和配置验证，不能直接假设 Agent / Worktree / Hooks / MCP 的功能与 Cursor 或 Claude Code 完全相同。