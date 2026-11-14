# 第 6 章：验证结果并交付 Pull Request

> 上游来源：[docs/guide/06-verify-and-ship.md](https://github.com/cursor/plugins/blob/main/pstack/docs/guide/06-verify-and-ship.md)

“编译通过”不等于已经证明功能正确。Prove It Works 原则要求 Agent 在报告成功前检查真实产物；使用者要做的是让“真实产物”变得可检查。

验证通常是 Agent 工作中最慢的环节，因为它经常依赖人工。让 Agent 具备可执行的验证能力，才能避免并行 Agent 只增加待人工检查的工作量。

## 1. 在任务开始时定义完成条件

例如：

```text
/poteto-mode add json output to this command. text output stays byte-identical, the json parses, both run against the sample project. show me the evidence.
```

这条任务明确了三项可检查条件，而不是只给出“做得更好”这种主观目标。Agent 的最终回复应包含实际执行的命令和输出。如果某项检查无法运行，应明确报告“无法得出结论（inconclusive）”。没有证据却给出肯定结论，是风险信号。

不同变更应匹配不同验证方式：

- CLI 变更：运行真实命令。
- UI 变更：在运行中的应用里走完变更后的用户流程；像素级一致性要求则使用 Visual Parity Playbook，对冻结的基线截图做差异比较。
- 解析器或迁移：回放保存的输入。
- 性能变更：比较优化前后的性能 Profile。
- 存储变更：读取回写入的值，确认实际持久化结果。

应要求 Agent 提供可以独立检查的证据产物，例如先失败后通过的测试、前后对比视频、Trace 或截图。如果修复已经合入，也应在主分支上重新执行相同检查。

对于不完全信任的小型 Diff，可以使用 `/blast-radius` 分析潜在影响。它尝试找出使变更安全的关键事实，并通过运行代码验证，而不是只用文字论证。

## 2. 使用 /benchmark-checklist 审核测量结果

前后对比数字很容易被错误测量。热缓存、两侧构建配置不同，或者实际工作没有发生在计时区间内，都可能制造看似可信的性能提升。

运行：

```text
/benchmark-checklist vet the export speedup before it goes in the pr
```

该 Skill 会围绕七个问题收集运行证据：

1. 是什么限制了这个数值？为什么结果不是它的两倍？
2. 各测试对象是否都以生产环境相同的调优方式运行？
3. 结果是否违反物理限制，例如磁盘带宽或 CPU 核数？
4. 是否发生错误，或返回了错误结果？
5. 交替运行能否复现结果？中位数和波动范围是多少？
6. 端到端性能是否真的改善了用户等待的路径？
7. 被测工作是否确实发生在计时区间内？

结论包括更快、更慢、没有可测量差异或无法得出结论，并附运行次数、范围和瓶颈。如果无法确定限制因素，或者某一侧没有按正常配置运行，就应报告 inconclusive。

Perf Issue 和 Hillclimb Playbook 已经会在内部调用该检查。其他场景下，如果某个数字看起来过于漂亮，也可以手动执行。它对应 Explain the Number 原则。

## 3. 为项目创建验证 Skill

Agent 必须有脚本化方式操作真实应用。若项目没有现成能力，可以执行：

```text
/create-verification-skill
```

该 Skill 会从代码仓库中调查，而不是先向用户索要一堆信息。它需要确认：

- 用户实际接触的界面是什么：Web、CLI/TUI、桌面应用、API、移动应用或库。
- 本地如何启动应用，包括端口、环境变量、种子数据和认证。
- Agent 如何驱动应用：优先使用已有 Playwright/Cypress 测试、PTY 工具、HTTP 接口或调试端口；否则再选择通用方案。
- 可以捕获哪些证据：截图、终端记录、响应体、日志、退出码或数据库状态。
- 是否支持并行启动两个独立实例，避免破坏用户正在使用的实例。

生成目录为：

```text
.cursor/skills/verify-<app>/
```

其中应包含准确的 Launch、Doctor、Drive、Evidence、Cleanup 步骤；如果生成了辅助脚本，还应记录 Helpers。它还会创建 features/ 功能地图，索引应用功能及每个功能的验证证据。

交付前，生成器必须完整执行一次验证 Skill：启动、Doctor 检查、驱动一个功能、采集证据、清理，并确认清理后证据仍然存在。若该过程失败，不应使用生成结果。

后续任务可以明确要求：

```text
/poteto-mode build the bulk-archive action. use /verify-<app> to verify your changes and show me a video and screenshots as proof.
```

验证 Skill 应作为项目基础设施提交到仓库，让每个人和每个 Agent 使用同一套方式验证应用。

## 4. 保持验证 Skill 与应用同步

应用持续变化，功能地图可能过时。上游建议至少每天运行一次：

```text
/maintain-verification-skill
```

维护流程会并行安排只读代码检查，再进行真实运行验证。最终只有三种结果：

- `clean`：覆盖完整，无需修改。
- `changed`：产生一个仅修改验证 Skill 目录的修正 PR。
- `blocked`：说明阻塞原因。

它不修改产品代码。如果真实验证发现产品回归，应报告回归，而不是通过修改文档掩盖问题。

## 5. 对关键性质建立形式化验证

普通验证 Skill 证明的是实际驱动过的路径。但有些 Bug 发生在很少被测试触达的路径，例如两个重试重叠、锁在写入中途过期、状态变化乱序。

对于此类风险，可以运行：

```text
/create-formal-verification-skill
```

它会从代码中选择一个重要性质，例如“任务不能同时运行两次”，并选择适合的工具：

- 事件顺序、状态机和并发交错：可以对小型模型使用模型检查器，TLA+ 是上游给出的默认选择。
- 任意输入下的代码行为：使用能够针对实际代码运行的验证器。
- 如果语言没有可用验证器，应明确说明，并尽可能对真实代码生成输入测试，而不是只验证一个手写的替代模型。

验证器必须展示该性质在一个故意破坏的代码变体上失败。一个从未展示过失败的检查，无法证明自己真的能发现问题。

形式化验证结果有明确边界：通过只代表指定模型或界限内的性质成立，不代表整个系统绝对正确。后续代码变更可能使验证与代码脱节，因此还要运行 `/maintain-formal-verification-skill` 更新并复核。

## 6. 用 Statechart 展示行为

```text
/statechart what the user sees when they edit a note offline
```

Statechart Skill 根据 TLA+ 模型生成 Mermaid 状态图，让产品或设计人员能用熟悉的业务语言理解行为。规则（例如“离线时绝不能显示 Synced”）成为不变量。图中标记违反规则的状态，报告给出最短反例路径。

交付前还要在真实代码中复现每条 Bug 路径，避免把模型错误当成产品 Bug。

## 7. 创建 PR

```text
/poteto-mode open the pr. small ordered commits, evidence in the description.
```

Opening a PR Playbook 从 Worktree 开始，将工作整理为小而有序的 Commit，清理 Diff 和文字说明，最后返回 PR 链接。上游偏好多个窄 PR，而不是一个庞大的 PR；后续工作可以建立在前一个 PR 上。

## 8. 使用 Babysit 将 PR 推进到可合入状态

PR 创建后可能遇到冲突、Review 意见和 CI 失败。Babysit Playbook 按顺序处理：

1. 合并冲突；
2. Review 线程；
3. CI 检查。

已知修复尽量批量提交，避免每修一个问题就触发一轮 CI。它还会审慎区分真实问题和噪声：真实问题需要修复，噪声则应在讨论线程中提供反证。

```text
/poteto-mode babysit this pr. get it green.
```

Babysit 的终点是 PR 达到可合入状态，不会替用户做最终合并决定。

## 9. 使用 Shipping 合入变更栈

```text
/poteto-mode land the stack.
```

Shipping 会在合入前独立验证每个 PR。验证某项变更的 Agent 不应是编写该变更的 Agent。随后从底部开始，逐个合入连续且已验证的 PR；遇到第一个不满足条件的 PR 就停止。

一个上层 PR 即使自身验证通过，如果其依赖的下层 PR 尚未验证，也不能越过依赖直接合入。

## 本章解读：BMC 项目落地

对于 openUBMC，建议把验证证据分为四类：

1. **静态证据**：代码检查、接口签名、资源树定义、配置 Schema。
2. **单元证据**：Lua 单元测试、异常路径、边界输入。
3. **集成证据**：D-Bus 调用、跨板 RPC、服务启动与重试。
4. **设备证据**：真实 BMC 上的状态变化、日志、持久化结果和故障恢复。

不能把编译成功或 Mock 返回成功当作设备行为已经验证。每项结论都应记录执行环境、版本、命令、输出和未覆盖范围。
