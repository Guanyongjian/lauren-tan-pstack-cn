---
name: triage-issue-reports
description: Triage Slack issue reports with one thread-only verdict, evidence review, cause-aware routing, tracker dedupe, and fail-closed ticket creation. Use only from the configured Benny triage automation.
disable-model-invocation: true
---

# Triage issue reports

对一份 Slack report 做分类，并在它的 source thread 里发一条有用的 verdict。只有当它确实是一个清晰的、新的 bug 时才创建 tracker issue。不要在这里复现或修复它。

加载由 automation 提供的外部 Benny 配置。如果配置缺失、格式错误或不完整，就停下，既不发布也不写入 tracker。

## Hard safety rules

- source channel 和 root thread 坐标是不可变的。
- 绝不在 source channel 里发 root message。
- 绝不发到别的 channel、广播回复、发 DM，或另起一个新 thread。
- 在任何 tracker 写入之前、以及在发布 verdict 之前的那一刻，都要对 source parent 做 preflight。
- 如果 parent 缺失、已被删除、无法访问或不确定，就停下，不做任何写入。
- 只发布一条实质性的 verdict。不要叙述进度。
- coordinator 是唯一的 Slack 发帖者。
- 被委派的 worker 只返回 finding。它们必须是 read-only 的，且不得获得 Slack 凭据或写动作。
- 每一份 child prompt 都必须禁止 `SendSlackMessage`、`PostToSlack`、`chat.postMessage` 以及一切其他 Slack 写入。
- 如果 worker 隔离无法强制这些限制，就在 coordinator 里完成这项工作。
- 绝不创建无法链回 source thread 的 issue。
- 宁可不要 ticket，也不要一个猜测出来的或重复的 ticket。
- 对 source 坐标应用 pstack 的 `principle-separate-before-serializing-shared-state`。
- 对最终的 verdict 应用 pstack 的 `principle-minimize-reader-load` 与 `unslop` skill。

## 1. Freeze source coordinates

在列出工作清单或委派之前：

1. 从 trigger 里读 `source_channel_id`。
2. 要求它等于配置好的 source channel。
3. 当 `trigger.thread_ts` 存在时，把 `SOURCE_THREAD_TS` 设为它。否则用 `trigger.ts`。
4. 要求 `SOURCE_THREAD_TS` 非空。
5. 把 `SOURCE_CHANNEL_ID` 和 `SOURCE_THREAD_TS` 存为不可变的值。
6. 读该 thread，并核实它的 root 恰好是那些坐标。
7. 取一个稳定的 source permalink。

之后每一次 source 读取与发布都必须使用这些存下来的值。绝不要用某个 reply 的时间戳或 operations-thread 的时间戳去替换它们。

## 2. Read the whole report

在决定之前，读 root 和当前的 reply。

捕获：

- 报告者的措辞
- 产品版本、app build、environment 与平台（若有）
- 预期行为
- 观察到的行为
- 频率与触发条件
- 错误文本或 stack signature
- 已有的 issue、commit 或 pull request 链接
- 任何明确指出已经有人在修的陈述

检查每一份相关的附件。

- 以完整可用的分辨率读 screenshot。
- 审视 video，找那个区分正确与坏掉行为的状态转换。
- 读 log、trace 和 crash 文本，找具体 signature。
- 如果媒体需要专家 review，就用一个 read-only 的 media worker，并问一个范围很窄的问题。该 worker 只返回 finding。
- 如果某份附件读不了，就在 verdict 里说明。不要编造它展示了什么。

在向报告者索取更多信息之前，先用 thread 里已有的证据。

## 3. Trace cause before routing

在选择 owner 或目的地之前，做一次有界的 source 与历史检索。用 pstack 的 `how` skill 追从所报告动作到所观察结果的路径。当 report 看起来像回归或触及防御性 code 时，用 `why`。

1. 找出从所报告动作到所观察结果的、可能的 code 路径。
2. 判断可见的 symptom 属于那条 code 路径，还是属于它下方的某个依赖。
3. 当 report 看起来像回归时，检查最近的改动。
4. 检查是否已有某个已 merge 的 commit 或打开的 pull request 在处理同一个 symptom。
5. 把已确认的事实与假设分开。

这一趟不需要完整的根因。它必须强到足以避免把一个可见 symptom 路由给错误的 owner。

如果 repository 读不了，就不要猜 code owner。继续用一个保守的分类，并说明原因追溯不可用。

## 4. Classify

只选一个类别。

### Bug

某处违反了预期行为。示例包括错误输出、坏掉的 state、报错、crash、hang、静默 no-op，或回归。

### Performance

report 描述可测量的缓慢、过量内存、耗电、jank 或其他资源问题。把它当作 bug 处理，但要保留 measurement 与 profile。

### Feature request

当前行为看起来是有意的，而报告者想要另一种行为或交互形式。

### Question or feedback

report 询问某事如何工作、在不涉及具体缺陷的前提下表达偏好，或给出一般性反馈。

### Reroute

原因追溯显示另一个配置好的目的地拥有这个 issue。

当 bug 与 feature 的界线不清楚时，不要 file。这条唯一的 verdict 可以问一个聚焦的问题，并使用 `other` 标记。

## 5. Apply configured routing

从 `routing.map_path` 读可选的 routing map。

- 按已确认的 product area、code path 或 error signature 匹配。
- 当原因追溯指向别处时，单凭一个可见的 symptom 不够。
- 如果没有 route 匹配，就说明 owner 不明确。不要猜。
- 不要跨频道发帖。在 source thread 里告诉报告者该把 issue 带到哪里。

owner ping 默认关闭。只有当下面几条全部成立时才允许 ping：

1. routing map 明确点名该 owner。
2. 配置允许那种 ping 类型。
3. 该条目是一个需要 owner 输入的 feature request，或近期历史以很强的证据指出一位可能的回归作者。
4. 该 owner 不是一个宽泛的 on-call group。

其他任何情形都不 ping。

## 6. Use the issue-tracker adapter

tracker 是一个 adapter，而不是某个必须指定的供应商。Linear adapter 是一个有效的例子。GitHub Issues adapter 或另一个 tracker 也可以实现同一份 contract。

配置好的 adapter 必须提供：

- 按文本、state、label、source URL 和日期范围检索 issue
- 读单个 issue 及其链接
- 以 title、body、status、label 和 source URL 创建 issue
- 更新已有 issue 且不替换无关 field
- 添加 source 链接与 recurrence note
- 如果 Slack 交接失败，取消、关闭或删除本次运行创建的 issue

如果某项必需操作不可用，就对该写入 fail closed。

在运行时解析配置好的 team、project、status 和 label。不要臆造 ID、创建 label、指派 owner，或设置优先级，除非配置明确要求。

## 7. Dedupe

永远先检查这个 source permalink 是否已经链到某个 tracker issue 或某条先前的 triage 回复。如果是，就不要发布或创建重复项。

对 bug 和 performance 的 report，用下列条件检索 tracker：

- 确切的错误或 crash signature
- product area
- 触发条件
- symptom
- 版本或日期窗口
- 疑似回归的 commit
- source permalink

选定一种结果：

- Confident duplicate：signature 相同，或 area、触发条件与 symptom 相同，或有已确认的共同成因。
- Possibly related：共同成因说得通但未被证明。
- Weak resemblance：相似性很表面。
- No match。

对 confident duplicate，把 source permalink 和一句简短的 recurrence note 更新到已有 issue 上。除非配置要求，否则不要重开、改 label 或重新指派。

对可能的匹配，在 verdict 里以「不确定」的方式给出链接，不创建任何东西。

一个长期关闭的 issue 是一条回归线索，并不自动等于一个仍然存活的重复项。

## 8. Decide whether to create

只有当下面全部成立时才创建：

1. 分类是 bug 或 performance。
2. 行为明确是坏的。
3. 该 issue 仍然存活，或尚不知道已修复。
4. dedupe 没有找到 confident 或 plausible 的存活匹配。
5. source parent 与 permalink 通过了 preflight。
6. tracker 目标 field 已解析出来。
7. 如果 verdict 发布失败，adapter 能够补偿。

绝不为 feature request、question、feedback 条目、reroute、可能的重复项、confident duplicate，或已修复的 issue 创建。

新 issue 必须自足：

- 平实的标题，点明 area 与 symptom
- 报告者的引文
- 预期与观察到的行为
- 版本与环境，或 `unknown`
- 触发条件与频率
- source thread 的 permalink
- 简短的原因追溯 finding，其中的假设要标为假设
- 在被支持时，内嵌 screenshot 或代表性的 video 帧
- 指向其余 artifact 的链接
- 配置好的 intake status 与 label

不要把猜测的根因写进标题。

## 9. Post one verdict

再做一次新的 source-parent preflight。然后用 `channel=SOURCE_CHANNEL_ID` 和 `thread_ts=SOURCE_THREAD_TS` 只发布一条回复。

绝不要在 `thread_ts` 为空的情况下调用 source-channel 的发布动作。

让回复保持简短：

- 以结果开头。
- 有 tracker issue 时，链接已有的或新建的那个。
- 必要时提一句 reroute 或一个缺失的事实。
- 至多包含一次被允许的 owner ping。
- 以恰好一行 marker 结尾。

Marker contract：

```text
[benny:bug]
[benny:bug] tracker=https://tracker.example/issue/123
[benny:performance]
[benny:performance] tracker=https://tracker.example/issue/123
[benny:other]
```

只使用配置好的 marker 字符串。只有当 marker 来自配置好的 triage 身份、且在这个 source thread 里时，repro automation 才信任它。

发布之后，读同一个 source thread，并核实该 verdict 出现在 `SOURCE_THREAD_TS` 之下。如果没有，绝不要在 root 上重试。

如果本次运行创建了一个 tracker issue 而 verdict 没有落地，就用 adapter 的补偿动作。核实该 issue 已被取消、关闭或删除。如果补偿无法核实，只在 automation 的运行 output 里报告这次失败。

## 10. Watch one follow-up window

在配置好的 follow-up 窗口内盯住 source thread，然后停下。

- 只回答直接发给 triage 身份的提问。
- 在安全时，对 tracker issue 做一处具体的更正。
- 不要在同一次运行里发出第二个 marker。
- 不要参与人的协调和闲谈。
- 如果有人要求该 automation 停止，就提前停下。

不要把窗口延长超过一次。一份新的 report 应当开启一次新的运行。