---
name: arena
description: "让 N 个并行 candidate 做同一个 task，选出一个 base，再把落选者最强的部分嫁接进去。用于 /arena、'arena this'、'throw it in the arena'，或当对一个非平凡 artifact 的第一次尝试会把错误的 shape 固化下来时。"
disable-model-invocation: true
---

# Arena

在 Claude Code 中，遵循本 skill 之前，每个 session 先读一次 [Claude Code 适配说明](../../docs/harness/claude-code.md)。它把 pstack skill 里的 Cursor 名字映射到 Claude Code。

在启动任何东西之前，打开一个 todolist，每个 phase 一条（Frame、Fan out、Cross-judge、Pick、Graft、Verify）。

## Phase A: Frame

每个 candidate 拿到相同的 prompt，所以 prompt 就是 contract。

1. 陈述每个 candidate 要产出的 artifact。
2. 推导 rubric，即 3-6 条具体、可打分、用于判断在**这个** task 上「成功是什么样」的标准。它是 Phase D 里 picker 的工具。candidate 只看得到 task。
3. 选 runner。用 `~/.cursor/rules/pstack-models.mdc` 里的 `arena runners` 行。如果规则或该行缺失，默认在 `claude-opus-5-5-xhigh` 和 `grok-4.7-xhigh-fast` 上各放一个。该行里 `auto` 或 `inherit-parent` 的条目意为 parent model，对它省略 `model`。如果 Task tool 拒绝某个已配置的条目，就让那个 seat 跑在它所属 family 的默认 model 上，并说明。family 按前缀划分：`claude-*`，以及带 `cursor-grok-*` 和 `composer-*` 的 `grok-*`。被拒绝的 `composer-*` 条目跑在 `grok-4.7-xhigh-fast` 上。如果该 family 没有默认值，或 Task tool 拒绝那个默认值，就从它的 error message 里取同一 family 最接近的有效 slug；若一个都没有，就丢掉这个 seat 并说明。如果丢掉的 seat 使 runner 少于两个，就继续加 runner 直到两个；若该行只有一个条目，则为一个。新增的 runner 跑在某个剩余 runner 的 model 上；若已无剩余，则不写 `model`，让它跑在 parent model 上，并说明。当 arena 覆盖多个设计方向时，spawn 更多 runner。当工作属于生成受限、而非判断敏感时，同一个 model 用 N 次。按 **poteto-mode** skill 的 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。
4. 按 **separate-before-serializing-shared-state** 原则 skill，给每个 candidate 自己的 output 位置（尽量用 git worktree，否则 `/tmp/arena-<slug>/candidate-<n>/`）。

## Phase B: Fan out

在一条 message 里 spawn 全部 N 个 subagent，带 `run_in_background: true`，每个都拿到 task、共享 grounding 的路径、它自己的 output 路径，以及这样的指示：产出 artifact，并附一份简短 rationale，点名它考虑过哪些备选、否决了什么。

如果某个 candidate 没有产出，就用 N-1 继续，并记录这次掉队。

## Phase C: Cross-judge

等 Phase B 的所有 candidate 完成后，从 `~/.cursor/rules/pstack-models.mdc` 里的 `arena cross-judge pool` 行中选一个 model。如果规则或该行缺失，就从 `claude-opus-5-5-xhigh` 和 `grok-4.7-xhigh-fast` 中选。spawn 一个 readonly judge subagent。judge 绝不来自 parent 的 family（family 的划分见 Phase A 第 3 步）。只尝试来自另一个 family 的条目，按 pool 顺序。`auto` 或 `inherit-parent` 条目就是 parent model，因此它绝不担任 judge。用默认 pool 时，Claude 作 parent 就得到 `grok-4.7-xhigh-fast`。来自任何其他 family 的 parent，先得到 `claude-opus-5-5-xhigh`。如果 Task tool 拒绝某个条目，就用 error message 里同一 model 在最近 level 或 speed 上的有效 slug；若一个都没有，就移到下一个条目。如果来自另一个 family 的条目一个都跑不起来，就按同样的方式尝试默认 pool 里来自另一个 family 的条目。如果那些也一个都跑不起来，就跳过 judge，在 Phase D 单独选 base，并说明这一点。如果你不知道 parent 的 model，就按 pool 顺序尝试 pool 里真实的 slug，并说明 family 检查没有执行。judge 看得到 rubric 和以路径标签标识的各个 candidate，逐条 criterion 打分，并推荐一个 base 附理由。它与你在 Phase D 的阅读并行进行。不要在 candidate 还在写的时候就 spawn 它。

## Phase D: 选一个 base

选之前要把每个 candidate 从头到尾读完。对着 rubric 逐条 criterion 打分，而不是凭整体感觉，并在 Phase C 跑过 cross-judge 时与它对照。在 base 上的一致证实了这个选择。分歧则意味着你们中有一方有偏见，或 rubric 含糊。决定之前把两份 rationale 都读一遍。

选那个未来的维护者最容易扩展、又不会破坏 invariant 的 base。当两者看起来打平时，按 Laziness Protocol 优先选边界更干净或 API 更小的那个。

## Phase E: Graft

把每个落选的 candidate 再走一遍，看有什么值得移植进 base，通常每个 candidate 一两点，而不是大部分。按 **redesign-from-first-principles** 原则 skill，手动把每一处 graft 折进去，使结果在一个 mental model 下保持自洽。不要机械粘贴。

如果各个 candidate 收敛到同一个 shape，那是强一致。记下它，直接 ship 这个共识 shape。不需要 graft。如果它们分歧极大，说明 Phase A 规格不足。重新 frame 并重跑，而不是把分歧平均掉。

## Phase F: Verify

按 **prove-it-works** 原则 skill，像对待任何其他 output 一样验证综合出来的 artifact。如果验证发现了 arena 漏掉的问题，要么 Phase A 错了（重新 frame 并重跑），要么某个 candidate 抓到了而你漏掉了 graft（回到 Phase E）。不要遮掩。

## Outputs

一个综合后的 artifact，旁边附一份简短的 synthesis note，点名 base 及理由、cross-judge 的 verdict 或 Phase C 跳过了 judge、每一处 graft 及其来源 candidate、被否决的东西及原因、任何收敛或掉队，以及验证结果。