---
name: reproduce-and-fix-issues
description: Reproduce triaged Slack bugs through a configured app-control adapter, verify existing fixes, and open a bounded draft pull request only after before-and-after proof. Use only from the configured Benny repro automation.
disable-model-invocation: true
---

# Reproduce and fix issues

在 source thread 里等待一个可信的 triage 标记。通过目标 app 的真实 UI 复现那个确切的 symptom。已有修复时去核实它。只有 repro 确认之后，才尝试一个有界的修复。

加载由 automation 提供的外部 Benny 配置。如果 config、required actions、control adapter 或填好的 feature map 缺失，就 fail closed。

## Hard safety rules

- 在做任何工作之前先冻结 source channel 与 root thread 坐标。
- 绝不在 source channel 里发 root message。
- 每一次 source-thread 发帖之前都对 source parent 做 preflight。
- coordinator 是唯一的 Slack 发帖者。
- 被委派的分析 worker 是 read-only 的，只返回 finding 或 media note。
- 修复阶段的 code worker 只有在它的 environment 可证明地排除了 Slack 凭据和一切 Slack 写动作时才可编辑。否则由 coordinator 编辑。
- 每一份 child prompt 都必须明确禁止 `SendSlackMessage`、`PostToSlack`、`chat.postMessage` 以及一切其他 Slack 写入。
- 绝不把 Slack token、发帖指令、用于发帖的 source 坐标，或对外上报的许可交给任何一个 child。
- 如果某个 child 需要 Slack 写权限才能运行，就不要启动它。
- utility bot 是证据来源。除非有人明确把修复委派给了它们，否则它们不拥有这次修复。
- 那个确切的区分性 symptom 必须通过真实 UI 交互出现两次。
- state 检查可以确认某个观察。它不得注入或强制造出该 symptom。
- 没有确认的 repro，就没有由你撰写的修复。
- 已有的 pull request 或 commit 会把这次运行切到 verify mode。不要在它们之上另写。
- 使用 `github.com` 的 pull request 链接。
- 让抓取物、录制、log 和 token 都留在 source control 之外。
- 对被委派的分析使用 pstack 的 `principle-guard-the-context-window`。
- 在 repro、fix 与 verification 全程应用 pstack 的 `principle-sequence-verifiable-units`、`principle-fix-root-causes` 和 `principle-prove-it-works`。

## 1. Freeze source coordinates

在列出工作清单或委派之前：

1. 要求 trigger 的 channel 等于配置好的 source channel。
2. 当 `trigger.thread_ts` 存在时，把 `SOURCE_THREAD_TS` 设为它。否则用 `trigger.ts`。
3. 要求 `SOURCE_THREAD_TS` 非空。
4. 把 `SOURCE_CHANNEL_ID` 和 `SOURCE_THREAD_TS` 存为不可变的值。
5. 读 source thread，并核实它的 root 恰好是那些坐标。
6. 取 source permalink。

绝不要用 reply 时间戳、operations 时间戳或 status-message 时间戳去替换这些值。

在每一次 source-channel 发帖之前：

1. 按不可变坐标读该 thread。
2. 确认 parent 存在、未被删除，且仍属于 source channel。
3. 只用 `channel=SOURCE_CHANNEL_ID` 和 `thread_ts=SOURCE_THREAD_TS` 发送。
4. 再读一遍该 thread，核实新 message 是一条 reply。

如果任何一项检查失败，就什么都不发。绝不在 root 上或回退 channel 里重试。

## 2. Wait for the triage contract

在配置好的 verdict 预算内盯住 source thread。等待期间保持沉默。

只有当下面全部成立时才接受一条 verdict：

- 它的作者匹配 `slack.triage_identity_user_id`。
- 它是 `SOURCE_THREAD_TS` 之下的一条 reply。
- 它恰好包含一个配置好的 marker。

公开的 marker 形式：

```text
[benny:bug]
[benny:bug] tracker=https://tracker.example/issue/123
[benny:performance]
[benny:performance] tracker=https://tracker.example/issue/123
[benny:other]
```

只有当标记是 `bug` 或 `performance` 时才继续。捕获那个可选的 tracker URL。对于 `other`、没有 verdict、作者不可信、marker 冲突或超时，都静默停下。

这个 marker 取代了私有 bot 身份和自由形式的 verdict 匹配。

## 3. Apply ownership and fix-artifact gates

在开始工作之前立刻重读该 thread。

### Someone is explicitly fixing it

当某人明确认领这次修复、给出具体的实现计划，或要求另一个 agent 去 implement、patch、fix 或开 pull request 时，停下。

不要把下面这些当作修复归属：

- 某个 bot 汇总了证据。
- 某个工具去查了 log 或 ticket。
- 某人要求某个 bot 去 diagnose、explain、inspect 或 reproduce。
- 某个 bot 发了一个成因假设，但并未同意去实现它。

判断被请求的那个动作，而不是 bot 的存在与否。

### A fix artifact already exists

如果某个打开的 pull request 或已 merge 的 commit 看起来很可能修好这份 report，就切到 `references/verify-existing-fix.md`。

artifact 可能来自 thread、tracker issue、repository 历史或 pull request 检索。没有 commit 或 pull request 的声称不是 fix artifact。

如果某人拥有这项工作但还没产出 artifact，就停下。不要和他抢。

## 4. Open an optional operations thread

如果配置了 `slack.operations_channel_id`，coordinator 可以在那里创建一条 root 状态 message。这是 repro workflow 里唯一被允许的 root 发帖。

把它的坐标存为 `OPERATIONS_CHANNEL_ID` 和 `OPERATIONS_THREAD_TS`。绝不要把它们与 source 坐标混淆。

使用配置好的朴素 Unicode 状态字符串。状态文字要短：

- Reproducing
- Could not reproduce
- Blocked
- Reproduced
- Verifying existing fix
- Attempting bounded fix
- Draft pull request opened
- Fix did not land

优先用配置好的 Cursor Slack action。只有当 user 为某项范围很窄的缺失能力（例如编辑这一条 status message）配置了 `BENNY_SLACK_BOT_TOKEN` 时才使用它。绝不把该 token 暴露给 worker。

如果没有配置 operations channel，就把详细状态留在 automation 的运行 output 里。不要用一条 source-channel 的 root message 来替代。

## 5. Load and check the control adapter

读 `references/control-adapter.md` 与 `control.feature_map_path` 上填好的 map，然后调用 `control.skill_name` 所指名的 skill。

找出与所报告 user 路径匹配的 feature-map 章节。驱动 app 之前先读它。如果没有章节覆盖该 feature，就把这次运行标为 blocked，而不是臆造一条路径或 selector。

要求全部七项能力：

1. 启动配置好的目标 app 与 test environment。
2. 导航到被映射的 feature 并演练它记录在案的 state。
3. 用点击、输入、按键、滚动、拖拽、调整大小或导航来驱动真实 UI。
4. 检查 state 且不改变它。
5. 抓取 screenshot。
6. 开始并停止一段屏幕录制。
7. 清理进程、session、profile 和临时数据。

如果 adapter 缺失或任何必需能力缺失，就把 operations status 标为 blocked 并停下。不要把 screenshot、unit test、state 改动或读 source 假装成一次 UI repro。

## 6. Study the report

读完整的 source thread，以及（若存在）tracker issue。

收集：

- 确切的动作路径
- 预期行为
- 观察到的行为
- 两者分叉处的那个区分性 state
- 频率
- 版本、environment 与平台
- 附件与错误 signature
- 候选 code 区域

查看 screenshot 与 video。在有帮助时，为 code 历史、test 想法、blast-radius 映射和 media review 使用 read-only 的并行 worker。每个 worker 拿到一个窄问题，以及那条 Slack 写入禁令。

用 pstack 的 `how` skill 在 repository 里追这条动作路径。用 `why` 查回归历史与防御性 code。提出互相竞争的成因假设，并找出能区分它们的证据。

## 7. Reproduce

通过 control adapter 启动目标 app。

在动作之前，确认正确的 app、workspace、account、data set 和 feature state。使用稳定的 app marker。不要只依赖窗口顺序或一个熟悉的标题。

通过真实 UI 动作驱动所报告的路径。

在称其为已复现之前：

1. 说出正确的最终 state。
2. 说出坏掉的最终 state。
3. 到达两者分叉的那个点。
4. 观察到那个坏掉的 state。
5. 重置足够的 state，使第二次尝试独立。
6. 重复同一条路径，并再次观察到同一个坏掉的 state。
7. 尽可能交叉核对一个真实的 state 值。

一个预期之中的对话框、加载 state 或 setup 步骤都不是这个 bug。抓取那个能区分正确与坏掉行为的最终 state。

使用配置好的 repro 预算。如果 symptom 在预算内没有复现，就报一个干净的 `Could not reproduce` 结果。如果 environment 无法提供某项必需能力，就报 `Blocked` 并说明缺了什么。

## 8. Capture and review evidence

对一次成功的 repro：

- 录下穿过该 symptom 的完整路径。
- 抓取坏掉的最终 state 的 screenshot。
- 存一条简短 note，含确切步骤与观察到的 state。
- 把 artifact 放在配置好的临时 artifact 目录里。

让一个 read-only 的 media reviewer 回答一个问题：这份证据是否可见地展示了那个区分性的坏掉 state？

如果答案是「否」或「不确定」，repro 就未确认。去抓更好的证据，或用 `Could not reproduce`。

只有在配置了 operations thread 时才把详细证据发在那里。source 那边的更新保持简洁。

## 9. Report the repro outcome

先更新 operations status。

对于 `Could not reproduce` 或 `Blocked`，在 source thread 里什么都不发。结果由 operations thread 或运行 output 承载。

对已确认的 repro，跑一次 source preflight，并发至多一条未经提示的 source 回复：

- 说明该 issue 已复现。
- 有 operations 证据 thread 时链接它。
- 至多包含三条简短的 finding。
- 有 tracker issue 时链接它。
- 默认不要 ping owner。

只有当配置好的 Slack action 会把附件留在同一个 source thread 内、且组织的保留策略允许时，才附带证据。

等待配置好的 rejection 窗口。如果有人表明 setup 或解读有误，就把这次 repro 更正一次。在窗口关闭且没有有效驳回之前，不要开始 fix 阶段。

## 10. Verify an existing fix

当存在 fix artifact 时，遵循 `references/verify-existing-fix.md`。

核实必须展示该 symptom 在 baseline 上出现、在打过补丁的 build 上不出现。两条路径各自都要用真实 UI 跑两次。

不要编辑已有的修复、另加一个竞争的 patch，或开一个替换用的 pull request。

## 11. Qualify a bounded fix

只有当下面全部成立时才尝试修复：

- 结果是一次干净的已确认 repro。
- media review 确认了那个坏掉的最终 state。
- 没有出现任何已有的 fix artifact。
- 在 rejection 窗口内没有人认领这次修复。
- runtime 证据指认出根因。
- 可能的改动落在配置好的 fix 预算与 repository scope 之内。
- control adapter 能同时跑 baseline 与打过补丁的 build。

如果任何条件不成立，就保留 repro 报告并停下，不开 pull request。

当 gate 通过时，把 operations status 更新为 `Attempting bounded fix`。

## 12. Root-cause and implement

coordinator 拥有每一次 Slack 发帖、最终的 diff review、commit 以及 pull request。

read-only worker 可以：

- 追 code 与历史
- 提出 test
- 映射 blast radius
- review 一个 diff
- review 媒体

它们不编辑、不跑外部写入、不发 status，也不拥有这次修复。

在这个阶段，只有当 tool 隔离把 Slack 凭据和一切 Slack 写动作从该 worker 身上移除时，才可以委派一处范围很紧的 code 编辑。它的 prompt 仍必须带上那条明确的 Slack 写入禁令。coordinator 来 review 这处编辑，并运行或核实所需的 test。如果 tool 隔离不确定，就把这处编辑留在 coordinator 里。

用 runtime 证据确认那个机制。编辑之前先排除互相竞争的假设。

以最小的正当改动修复根因。

- 当存在廉价的本地 test 目标时，调用 pstack 的 `tdd` skill，并在修复之前先写失败的 test。
- 当该路径昂贵、不清楚或偏集成时，说明为何跳过 TDD。
- 把无关的清理挡在外面。
- 如果改动增长到超出配置好的 effort 或 risk 预算，就停下。

## 13. Prove the fix

保留原始的 baseline 证据。

在打过补丁的 build 上：

1. 跑同一条真实 UI 路径。
2. 重复两次。
3. 展示那个坏掉的 state 已消失。
4. 展示预期 state 出现在原处。
5. 抓取 after 的 recording 与 screenshot。
6. 交叉核对与 baseline 所用相同的真实 state 值。

一次编译、unit test、code review 或看似合理的 diff 都不是 after 证据。

先跑聚焦的 test，然后对改动行为周边的 blast radius 做 smoke。覆盖该改动可能影响的邻近 state、输入、权限、平台和失败路径。如果仍留有回归，就停下，不开 pull request。

## 14. Open a draft pull request

只有在前后对照的证明之后：

- review 最终 diff，看有无无关改动与密钥。
- 跑该 repository 要求的检查。
- 当 repository workflow 允许时，创建小的、有序的 commit。
- 开一个 draft pull request。绝不要从这个 workflow merge 或 deploy。
- 用该 tracker 支持的 pull request 语法链接配置好的 tracker issue。
- 使用配置好的公开 URL 形式，通常是 `https://github.com/{owner}/{repo}/pull/{number}`。
- 包含 repro 步骤、根因、test 结果、前后对照的证据，以及 blast-radius 检查。
- 把 pull request 的文本和所有 Slack 更新都过一遍 pstack 的 `unslop` skill。

如果 pull request 创建失败，不要声称成功。把 commit 或 branch 状态留在运行 output 里，并把 operations status 标为 `Fix did not land`。

成功时，把 operations status 标为 `Draft pull request opened`，并在 operations thread 里发一条带该 pull request 链接的简明回复。不要另建第二个 source-channel root，也不要有未经提示的 source 回复。

## 15. Follow-ups and cleanup

在配置好的 operations thread 里盯一个 follow-up 窗口。

- 用已经收集到的证据回答一个直接提问。
- 当某处具体的更正使 setup 失效时，做那一处更正并重跑一次 repro。
- 不要参与人的协调和闲谈。
- 被要求停时就停下。

永远调用 control adapter 的 cleanup 能力。只在配置好的保留策略允许的时长内保留 artifact。