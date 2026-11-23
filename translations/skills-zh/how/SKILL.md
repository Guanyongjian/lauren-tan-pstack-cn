---
name: how
description: "用于「how does X work」、改动之前的 code walkthrough，以及 placement / ownership / layering 问题（「where should this live」「which package owns this」「is this the right layer」）。解释 subsystem architecture、runtime flow、onboarding 用的 mental model。动机相关的问题用 why。"
disable-model-invocation: true
---

# How

探索 codebase，回答「how does X work?」这类问题。产出的 architectural explanation 要达到「一个 senior engineer 刚 onboard 到这个 subsystem」的水平：足以建立可用的 mental model，但又不至于读起来像逐行注释的 source code。

每次 spawn 都是一个 Task subagent，`subagent_type: generalPurpose`，`readonly: true`。explorer 使用 `pstack-models.mdc` 规则里的 `how explorer` 行（默认 `grok-4.7-xhigh-fast`），每个 explainer 使用 `how explainer` 行（默认 `claude-opus-5-5-xhigh`）。把 `model` 设成该行的值；如果规则或该行缺失，就用默认值。当该值为 `auto` 或 `inherit-parent` 时，不要设 `model`。如果 Task tool 拒绝某个 slug，就用默认值并说明。如果它连默认值也拒绝，就从它的 error message 里取同一 family 最接近的有效 slug。按 **poteto-mode** skill 的 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。

## 1. 评估 complexity

如果 scope 含糊，先说明你的理解再去探索。user 可以纠正方向。

- **Simple**（单个 module、一个小 utility，或诸如「how does function X work」这样的窄问题）：不要 explorer。spawn 一个 explainer，让它一趟完成探索与解释，用 `references/explainer-prompt.md` 构造，但不含 explorer-findings 那一节。跳到第 4 步。
- **Complex**（跨多个 file 或 service 的 subsystem、横切多个模块的 feature、完整的 architectural overview）：进入第 2 步。

拿不准时，走 simple 路径。

## 2. 探索（仅 complex）

把问题拆成 2 到 4 个 angle，每个 angle 是 subsystem 一个不同的切片。在一条 message 里 spawn 全部 explorer，每个都带上 `references/explorer-prompt.md` 并填入它的 angle。

## 3. 综合（仅 complex）

等所有 explorer 返回后，spawn 一个 explainer，带上 `references/explainer-prompt.md` 以及每个 explorer 的 findings。

## 4. 呈现

呈现 explainer 的 output。为清晰起见做轻度编辑、或补上对话里的 context，都没问题。不要实质性地重写它。

## Output format

解释使用 `references/explainer-prompt.md` 中定义的 section，不适用的可以省略：Overview、Key Concepts、How It Works、Where Things Live、Gotchas。
