# P-Stack Scripts、Harness 与测试资产研究

> 上游快照：cursor/plugins Git tree 24621dbcc59e205a7faadb0e06d540f91712b5cc
> 目录范围：pstack/ 下 573 个文件。本文聚焦可执行工具、测试框架和模型检查语料，不逐一复述所有生成输出。

## 1. 文件统计与分类

| 资产类型 | 数量 | 说明 |
|---|---:|---|
| 全部文件 | 573 | P-Stack 固定快照 |
| Markdown | 169 | Skills、Playbooks、Guides、References 和说明 |
| TypeScript | 51 | Watcher、Statechart、测试及工具实现 |
| MJS | 10 | Node 脚本和验证工具 |
| Shell | 2 | Worktree Audit、Decision Log |
| TLA+ | 39 | Statechart 模型规格 |
| TLC Config | 34 | 模型检查配置 |
| Mermaid | 36 | 状态图结果或测试快照 |
| Graphviz DOT | 33 | 状态图结构结果 |
| TLC 输出 .out | 134 | 参考输出和反例记录 |
| Exit 结果 | 44 | 进程退出码参考结果 |
| 其他 | 其余 | 图片、配置、锁文件、Java Oracle 等 |

脚本路径统计为 424 个，测试相关路径匹配为 380 个，Statechart Corpus 目录下有 356 个文件。这里的测试相关匹配包含模型输入和已生成输出，不能把 380 理解为 380 条独立测试用例，也不能把不同扩展名数量相加当作唯一测试数量。

## 2. Poteto Mode 工具链

上游目录：[poteto-mode/scripts](https://github.com/cursor/plugins/tree/main/pstack/skills/poteto-mode/scripts)

### 2.1 watch-pr：PR 状态观察器

核心文件：
- watch-pr/cli.ts：CLI 参数、单 PR / 连接 Stack / 固定 Queue 模式、轮询和输出入口。
- watch-pr/github.ts：通过 GitHub CLI / GraphQL 获取 PR、Review Thread、Checks、Commit Rollup。
- watch-pr/policy.ts：状态快照、阻塞分类、Queue 推进和终态判定。
- watch-pr/types.ts：严格状态模型和判别联合。
- watch-pr/render.ts：JSON 与人类可读 Markdown 输出。
- watch-pr/*test.ts：参数、API 解析、策略和状态机测试。

它不是简单的 gh pr checks 循环。CLI 有三种范围：单 PR、连接的 PR Stack、冻结顺序的 Queued Stack。支持 status-only 单次检查、JSON / NDJSON、pretty 输出、轮询间隔、全 Stack 扫描间隔、超时和连续查询错误预算。

状态读取包括 PR 本身、Review Threads、CI Check 和 GitHub Mergeability。Check 获取有快速路径和 GraphQL Rollup 回退；快速路径不可用或为空时再走 GraphQL 分页。对已合并 PR 会提前返回，不再查询 Review / CI。

类型系统把 PR 状态建模为 Merged、Closed、Open；Open 再带有 CI Clean / Pending / Failing / GitHub Rejected 等判别状态。READY 结果需要携带正向证据：合并状态清晰、无未解决 Review Thread、CI 通过、PR 非 Draft 且没有 Changes Requested。类型编译测试还用 @ts-expect-error 验证不可能状态不能构造。

策略测试覆盖 readiness truth table、GitHub BLOCKED 与 Commit Rollup 的组合、Checks 快速路径和回退、GraphQL 分页、已合并短路、Stack 阻塞优先级和 Queue 行为。CLI 测试覆盖参数错误、冻结 PR 顺序、JSON / Pretty 输出和退出码。

**设计价值：** 把“是否可合入”从散落的字符串判断变成带证据的状态模型。上层 Agent 消费 Verdict，而不是自己拼凑 GitHub API 返回值。

**迁移建议：** 本地工作台应抽象 Forge Adapter，并保留来源平台原始事实。GitHub、内部 CodeHub 或 GitLab 的状态映射必须独立测试；不要把某个平台的 BLOCKED / CLEAN 字符串直接当作通用语义。

### 2.2 check-plan：计划结构检查器

上游：[check-plan.mjs](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/scripts/check-plan.mjs)

它读取计划 Markdown，检查必需章节、顺序、PR 分块、验证门禁和文案约束。检查内容包括：
- 是否存在 How to read this、Program checklist、Close the program 等章节；
- Program Checklist 是否按规定顺序包含关键阶段；
- 每个 PR 是否有依赖、文件、构建、可见结果、单元 / 现场 / 性能验证、Review Gate 和 Merge 等分块；
- 每个验证框是否明确证据；
- 计划文本是否违反长破折号、弯引号、中句冒号等写作规则；
- Markdown Fence 的开闭是否正确，代码块内部内容不应误判成正文。

check-plan.test.ts 使用临时文件调用真实 CLI，覆盖普通和缩进代码围栏、多级反引号、波浪围栏、错误闭合、非法 Info String、代码 Span 标点和未闭合 Span 等情况。

**设计价值：** 计划不是只靠 Agent 自觉遵守的 Prompt。关键结构由可重复执行的 Linter 强制校验。这个思路与 Encode Lessons in Structure 一致。

### 2.3 worktree-audit.sh：清理审计，不直接删除

上游：[worktree-audit.sh](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/scripts/worktree-audit.sh)

脚本读取 Git 自己报告的 Worktree 列表，而不是猜测目录路径。对每个候选目录检查：大小、最近 Commit 时间、相对指定 Base 是否已合并、Tracked WIP、未跟踪 Scratch、远端 Push 状态、PR 状态和最近关联会话。它支持 Origin CLI，不能用时回退到 gh，并支持显式指定 PR Base。

输出是排序后的审计表和建议 Bucket。脚本只读，不执行删除。Playbook 进一步要求把 Bucket 与用户 Pin 的会话、活跃 Agent 和 Worktree 关联起来，确认 WIP 后再执行删除。

**风险与迁移：** Transcript 关联和目录状态可能过期；自动 Bucket 不能被当作删除授权。工作台应默认 Dry-run，删除前显示路径、大小、Git 状态、任务占用和未提交内容，并要求人工确认。

### 2.4 show-me-your-work/log.sh：追加式决策日志

上游：[log.sh](https://github.com/cursor/plugins/blob/main/pstack/skills/show-me-your-work/scripts/log.sh)

脚本要求六个参数，按 TSV 追加时间、阶段、决策、理由、证据和结果。它只使用追加写入，自动创建父目录；将字段中的 Tab / 换行 / CR 转为空格，确保每条记录只有一行；若单元格以 =、+、-、@ 开头，则加单引号，防止 CSV / Spreadsheet Formula Injection。

**设计价值：** 这是一个很小但成熟的审计工具。工作台可以借鉴追加式事件日志、单行字段约束和公式注入防护。

## 3. Statechart：形式化模型检查工具

上游：[statechart Skill](https://github.com/cursor/plugins/blob/main/pstack/skills/statechart/SKILL.md)；[实现目录](https://github.com/cursor/plugins/tree/main/pstack/skills/statechart/scripts)

Statechart 是 P-Stack 中代码量和测试资产最集中的工具之一。它把 TLA+ / TLC 模型检查结果转成可读的状态图和报告。

### 3.1 执行管线

大致执行过程：

1. CLI 解析 TLA+ Spec、CFG、View 和输出目录。
2. 检查输出目录必须是新建或空目录，避免覆盖已有证据。
3. 启动隔离 Worker 执行 TLC，并处理 SIGINT / SIGTERM。
4. 解析 TLC 消息、状态、属性和反例路径。
5. 将原始模型结果转换为内部 IR。
6. 通过 Reachability、Label、Regions、Loop Check 等 Pass 处理状态图。
7. 生成 Mermaid Chart、Markdown Report、原始 TLC 输出和各规则反例输出。
8. 若被中断或工具失败，不把不完整结果伪装成成功。

### 3.2 用户自定义视图

View 模块可以将模型变量映射为用户理解的状态名称，也可以定义动作箭头标签、并行区域、分组颜色和图标题。字符串表示扁平状态，数组表示父子状态，对象表示并行 Region。

图表默认控制在约 20 条箭头的可读范围；超过 500 个状态时只画通向违规规则的路径，若没有违规则可能不输出完整图。规则不能为了通过而被削弱；模型约束和状态上限必须在报告中说明。

### 3.3 测试设计

Statechart 测试不仅测函数：
- Corpus Test 将模型输入交给 TLC，再比较生成的 Chart / Report 与已提交的基线产物。
- CLI Test 验证真实命令行执行、启动器路径、输出文件和失败行为。
- Config Fuzz Test 使用固定随机种子生成 4000 个配置样本，并与 TLC 的解析结果 Oracle 比较。
- Java ConfigOracle 用 TLC 自己的解析行为作对照，避免测试只验证实现者自己的假设。
- 多个 TLA+ Corpus 覆盖死锁、Invariant、Action、State、View、Symmetry、Region、路径等模型情况。

statechart/scripts/package.json 使用 Node 测试运行器和 fast-check；Poteto Mode 工具包使用 Bun Test，并对 Watcher TypeScript 执行 strict Type Check。

**设计价值：** 它把模型检查工具自身也作为工程产品对待：有输入规范、隔离执行、错误码、反例、黄金样例、Fuzz 和可重复输出。

**迁移建议：** 对 BMC 的 IPMBETH、跨板 RPC、配置同步、状态迁移等有并发和时序风险的功能，可以用小型 TLA+ 模型表达不变量和动作顺序，再把反例转换为真实设备复现或自动化测试。模型通过只证明模型范围和假设，不等于整个 BMC 产品已经正确。

## 4. 代码实现审计得到的共性

1. **状态先建模：** Watcher 用判别联合表达 CI / PR 状态；Statechart 用 IR 表达模型结果。
2. **输入边界校验：** CLI 参数、PR 编号、配置文件和外部输出先解析，再进入内部逻辑。
3. **失败关闭：** 检查信息无法获取时，不能将其当作通过；工具被中断时不写成功报告。
4. **证据保留：** 原始日志、模型输出、反例和报告都可以定位和复核。
5. **可重复验证：** Golden Corpus、固定种子 Fuzz、TS 类型负例和 CLI 集成测试共同约束行为。
6. **副作用分级：** Worktree Audit 只审计，清理由更高层流程确认；Watcher 只观察，不合并。

## 5. 对本地工作台的实现优先级

| 优先级 | 能力 | 原因 |
|---|---|---|
| P0 | 任务状态机与证据对象 | 没有状态和证据，Agent 结果无法审计 |
| P0 | Git Worktree Audit / 独立工作区 | 多 Agent 并行的基础安全边界 |
| P0 | 追加式 Decision Log | 长任务中断和恢复所需 |
| P1 | PR Watcher + Forge Adapter | 自动推进检查，但不越权合并 |
| P1 | Plan Linter | 防止计划遗漏验证门禁 |
| P2 | Verification Skill 生成器 | 将真实产品验证自动化 |
| P2 | Statechart / TLA+ 集成 | 处理高风险并发和状态协议 |

## 6. 研究边界

本轮审计了主要脚本入口、状态模型、关键策略和代表性测试。尚未逐行审阅全部 424 个脚本路径，也未在本地安装 TLC / Bun 并执行完整上游测试套件。356 个 Corpus 文件中有大量黄金输出和模型样本，后续应按测试族继续抽样并核对覆盖矩阵。本文不声称上游工具已在本环境重新运行通过。