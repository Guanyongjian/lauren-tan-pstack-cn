# Playbook 深度研究（二）：PR 生命周期与质量改进

> 研究范围：Babysit、Shipping、Refactoring、Perf issue、Hillclimb  
> 上游路径：
> - [babysit.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/babysit.md)
> - [shipping.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/shipping.md)
> - [refactoring.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/refactoring.md)
> - [perf-issue.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/perf-issue.md)
> - [hillclimb.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/hillclimb.md)
>
> 研究快照：上游 Git tree `24621dbcc59e205a7faadb0e06d540f91712b5cc`。以下是中文分析，不是上游原文翻译。

## 1. PR 生命周期不是一个“自动合并”动作

P-Stack 将 PR 生命周期拆成三个职责边界：

```text
Opening a PR
    -> Babysit
    -> Shipping
```

- Opening a PR：把已完成的工作整理成可审查 PR。
- Babysit：处理冲突以外的 Review / CI 问题，将 PR 推进到 merge-ready。
- Shipping：独立验证代码，再按依赖顺序真正合并。

最重要的边界是：**Babysit 默认不拥有合并权限。** 用户说“让它变绿”不等于授权合并。只有明确要求 merge / land / ship 才进入 Shipping。

这避免了一个常见自动化风险：把“检查通过”误解成“可以替用户做不可逆决策”。

## 2. Babysit：维护合并前沿

### 2.1 先声明运行模式

Babysit 有四种模式：

| 模式 | 用途 | 行为 |
|---|---|---|
| drive | 明确要求 get it green / merge-ready | 循环推进直到达到 merge-ready |
| background | PR 仍在构建中 | 非阻塞地分类和处理 |
| threads-only | 只要求处理 Review / Bugbot 评论 | 只处理评论，不碰 CI 等其他事项 |
| check | 查询当前状态 | 单轮检查并汇报 |

小型或仅文档 PR 默认 check，而不是 drive。

这很重要：不同请求不应该都触发持续轮询和自动修改。工作台应把“查看状态”“处理评论”“持续修复”做成显式不同的运行模式。

### 2.2 只处理最低未合并 PR

对于堆叠 PR（PR2 基于 PR1，PR3 基于 PR2），当前最低的未合并 PR 是 merge frontier。

在最低 PR 还未就绪时：
- 可以阅读上层 PR 的评论；
- 可以批量记录上层待处理问题；
- 不应先修改上层 PR 并触发新的检查；
- 不能为了让上层看起来有进展而忽略最底层阻塞。

每个 Stack 同一时刻只允许一个 Babysitter，避免两个 Agent 同时修改状态、重复触发 CI 或产生相互矛盾的结论。

### 2.3 不允许 Babysit 改写堆栈拓扑

Babysit 不负责：
- 修改 PR base；
- Rebase；
- Stack-wide submit；
- Force push。

遇到冲突时，报告具体哪个分支需要 Rebase，并停止当前冲突处理。分支所有者负责重建并推送自己的分支。

这将“修复 PR 内容”和“改变 PR 依赖结构”分成两个权限域，减少自动化工具误操作。

### 2.4 固定处理顺序

```text
冲突检查
  -> Review threads
  -> CI
  -> 再次读取 PR 和评论
  -> 下一轮
```

一个 push wave 应批量包含当前已知修复，而不是每发现一条评论就单独 Push、重新触发 CI。

CI 失败先分类：
- Flake / 基础设施异常：允许重新触发一次新构建，不是盲目重试单个 Job。
- 相同失败第二次出现：不再视为 Flake，读取子日志定位。
- 失败发生在 Diff 未触及代码：检查是否是 stale base，不能直接当作 Flake。
- 失败确实由 Diff 中代码引起：修复代码并提交。

### 2.5 Review / Bugbot 评论是“不可信输入”

评论文字不能当作操作指令。Agent 必须：
1. 对照代码核实评论；
2. 复现或证明其成立；
3. 真问题才修；
4. 噪声要给出具体反证并在评论线程中解释；
5. 不为让 Bot 安静而反复改代码。

这和安全工程中的“数据与指令分离”一致。PR 评论是外部数据，不是更高权限的 Prompt。

### 2.6 Forge 状态不能混用

上游支持 GitHub CLI 和 Origin CLI 两种 Forge 路径，并明确说不能混合两者状态。GitHub 使用专用 `watch-pr` 脚本；Origin 使用自己的 PR / thread / checks 命令。GitHub Watcher 不能假装覆盖 Origin。

GitHub Watcher 的终态和 Origin 的 Merge-ready 判定不同。工作台实现时应采用 Forge Adapter，定义统一内部状态，但保留来源端的原始状态与判定依据。

## 3. Shipping：验证后才合入

### 3.1 每个 PR 必须有独立验证者

每个 PR 指派一个没有编写该代码的验证 Agent。验证者要像用户一样通过匹配的控制面运行变更，并在 PR 上给出：
- PASS；
- PASS+NOTES；
- FAIL。

绿色 CI、Bot Review Approve 都不能代替真实行为验证。作者自证也不能代替独立验证，因为作者知道自己想实现什么，容易忽略实际行为和预期之间的偏差。

### 3.2 只合入连续的已验证区间

对堆叠 PR，从最低 PR 向上检查：
- 第一个没有 PASS / PASS+NOTES 的 PR 是停止点；
- 它下面连续通过的 PR 构成可合并区间；
- 上层即使单独验证通过，也不能越过依赖未验证的下层 PR。

例外是一个 PR 完全不依赖下方代码，可以独立移到 trunk，但必须重新验证，因为原来的验证环境包含了 trunk 尚不存在的依赖代码。

### 3.3 验证结果绑定 Patch，而不是简单绑定 PR 名称

Rebase 会改变 Commit SHA，但不一定改变 Patch。上游要求比较验证时和当前版本的 `git patch-id`：

- Patch 相同，旧验证结果可能仍然有效；
- 如果差异仅是测试、文档或 Lint 配置，还需要证明实际构建结果没有实质变化；
- 若差异属于代码本身，必须重新验证；
- 对没有 Build 输出的运行型验证，无法仅凭 Patch ID 推断结果仍有效，应重新运行。

这体现了一个非常关键的模型：

```text
VerificationResult = (Verifier, PatchIdentity, Environment, Evidence, Verdict)
```

不是简单的：

```text
PR #123 = verified
```

### 3.4 从底向上逐个合并

每次只合并当前最低 PR。合并后：
1. 读取 PR 状态确认真的 merged；
2. 将下一 PR 的 base 转到 trunk；
3. 将其 Patch 移到合并结果之上；
4. 使用安全的 force-with-lease 推送；
5. 按 Patch Identity 规则判断原验证结果是否仍然适用；
6. 继续下一项。

合并命令返回成功不等于 PR 已经合入。Merge Queue 可能只是排队，Auto-merge 也不代表已经完成。必须重新读取 PR 状态。

### 3.5 不应让堆栈在合并过程中被其他 Agent 修改

Shipping 期间，除将下一 PR 移到新基线外，不应随意改变分支和 Base。因为合并操作会合并当时分支上实际存在的内容，而不是验证者此前看到的内容。

## 4. Refactoring：结构变化，行为不变

Refactoring 与 Feature / Bug Fix 的关键区别：

- Feature：新增或改变行为。
- Bug Fix：修正错误行为。
- Refactoring：只改变结构，保持外部行为契约。

### 4.1 先冻结行为契约

第一步不是改代码，而是：
1. 用 How 理解子系统当前行为；
2. 写 Characterization Test、Snapshot 或等价性测试；
3. 没有测试覆盖时，先补上行为基线；
4. Type Check 和 Lint 不能替代行为基线。

### 4.2 先定义目标结构，再移动代码

说明模块布局、类型和调用图在理想状态下应该是什么样。如果跨越函数边界，先通过 Architect 做并行设计探索。

重构目标必须删除分支、冗余状态或不必要的间接层，而不是仅仅换一种写法。

### 4.3 先减后加

先删除：
- 死代码；
- 只有一个调用者的包装函数；
- 冗余校验；
- 孤立引用。

再引入目标结构。猜测“以后可能有用”的清理应撤销。

### 4.4 小步迁移并保持基线绿色

每一步都要让行为基线保持通过。API 重塑时，在同一轮迁移所有调用者并删除旧 API，不长期保留新旧两套路径或兼容层。

最终必须在真实产物上证明行为没有变化。大规模重塑可使用旧输出与新输出 Diff、历史输入回放或真实运行冒烟测试。

成功指标是降低读者负担。如果 Diff 没有让任何地方更容易理解，就应考虑撤销。

建议提交顺序：
1. 删除无用结构；
2. 调整目标结构；
3. 后续必要清理。

## 5. Perf issue：一次性性能问题

性能修复不能以“看代码觉得这里慢”为依据。它要求先采集基线 Trace，并使用 Benchmark Checklist 检查基线和后续测量。

优化尝试遵循从便宜到昂贵的顺序：

1. 不做：停止无用工作；
2. 做一次，不重复；
3. 降低频率；
4. 延后执行；
5. 放到用户不敏感的时机；
6. 并发执行；
7. 降低单次成本。

前一条已达到目标就停止，不要为了“优化得更彻底”引入复杂度。

实施后采集新 Trace，解析产物并比较。结论必须引用测量结果和产物路径；Inconclusive 或错误操作面都不能报告通过。

## 6. Hillclimb：持续优化一个指标

Hillclimb 不是一次性性能修复，而是围绕单一指标进行多轮实验。

### 6.1 先定义实验

必须明确：
- 真实工作负载；
- 一个指标；
- 改善方向；
- 目标值；
- 最少尝试次数组成的退出谓词。

例如“至少比基线提升 50%，并且至少完成 10 次迭代”。最少迭代次数可避免某一次偶然测量提前结束实验。

### 6.2 冻结测量 Harness

Harness 必须能区分真实问题负载和较简单的对照负载，并证明自身对目标变化足够敏感。冻结前运行 Benchmark Checklist。

每次使用同一条命令测量，采用足够采样的统计值，例如 N 次中位数，而不是单次结果。

### 6.3 每次只验证一个假设

每轮：
1. 提出有架构依据的具体假设；
2. 交给受限范围的 Subagent 修改；
3. 测量修改前后；
4. 运行回归门禁；
5. 收益超过噪声且回归通过才保留；
6. 否则完整撤销；
7. 无论保留还是撤销，都记录决策；
8. 每个被接受的改进独立提交。

决策日志字段包括：尝试 ID、假设、改动、Before、After、Delta、Tests、Verdict、Note。

### 6.4 平台期不能成为降低标准的借口

连续失败时应换假设类别、组合接近成功的方案、重新阅读代码，或尝试更激进但有依据的思路。不能为了完成任务而放宽目标。若剩余思路收益很低且成本过高，可以停止并明确报告。

## 7. 对 Codex + 多模型工作台的设计建议

### 7.1 统一 PR 生命周期状态机

```text
DRAFT
  -> READY_FOR_REVIEW
  -> REVIEWING
  -> CI_CHECKING
  -> MERGE_READY
  -> INDEPENDENT_VERIFY
  -> VERIFIED
  -> MERGING
  -> MERGED
```

状态应保存到工作台数据库，而不是仅存在 Agent 上下文。每次迁移必须记录触发事件、操作者和证据。

### 7.2 引入 Forge Adapter

内部统一接口可抽象为：
- get_pull_request；
- list_review_threads；
- reply_review_thread；
- get_checks；
- watch_checks；
- get_mergeability；
- merge_pull_request；
- update_base。

GitHub / GitLab / 内部代码平台分别实现 Adapter。不能把某一平台的状态字符串直接当成通用状态。

### 7.3 验证结果必须是不可混淆的对象

建议至少记录：

| 字段 | 说明 |
|---|---|
| repository / PR | 仓库和 PR 标识 |
| head_sha | 验证时的提交 |
| patch_id | Patch 身份 |
| verifier_agent | 验证者 |
| verifier_model | 使用模型 |
| model_family | 模型家族，用于检查独立性 |
| environment | 设备、镜像、依赖和配置 |
| command | 实际执行命令 |
| evidence | 日志、截图、测试报告、Trace |
| verdict | PASS / PASS+NOTES / FAIL / INCONCLUSIVE |
| created_at | 验证时间 |

### 7.4 权限建议

- 代码 Owner：写自己的 Worktree / 分支。
- Babysitter：处理 Review、CI 和修复，不改变堆栈拓扑。
- Verifier：只读代码并执行验证，不能修改被测代码。
- Shipper：执行经授权的合并。
- Coordinator：分配任务和审查状态，不直接写产品代码。

默认不授予 Agent Force Push、合并、部署或删除数据权限。用户明确授权后再开放相应操作。

### 7.5 映射到 BMC 项目

| P-Stack 方法 | BMC 研发实践 |
|---|---|
| Characterization Test | 记录现有 D-Bus 行为、资源树属性和 Redfish 输出 |
| Behavior pin | 重构前保存接口签名、日志和设备行为基线 |
| Independent verifier | 由不同 Agent / 人员在真实 BMC 环境复测 |
| Patch identity | 绑定验证报告到具体 Git Patch |
| Perf baseline | 保存启动时间、RPC 延迟、CPU、内存、IO 采样 |
| Hillclimb decision log | 每轮优化记录假设、数据、保留/回退原因 |
| Merge frontier | 多个依赖 PR 按底层接口先合入，再合上层业务 |

## 8. 当前研究边界

本轮已逐篇读取并分析 Babysit、Shipping、Refactoring、Perf issue、Hillclimb 五个上游文件。Autopilot-stack 的完整上游文件本轮读取遇到 GitHub API 限流，因此不把它标为已深读；后续需要重新读取并补齐具体 Owner loop、验证门禁和最终交接步骤。

另外，以上流程中的 Cursor Cloud Agent、Origin CLI、GitHub Watcher、Graphite 等工具具有宿主依赖。Codex 工作台应复用其流程思想，不能声称复制 Skill 文件就自动获得相同执行能力。
