---
name: architect
description: "在写 code 之前先勾画 type、signature 和 module structure，然后在整个 implementation 填充过程中保持在线。用于 /architect、'architect this'、'design this'，或那些直接跳到 code 会把错误 shape 固定下来的非平凡工作。"
disable-model-invocation: true
---

# Architect

用 `not implemented` 的 body 和 pseudocode，勾画 type、function signature、class shape 和 module boundary。在多个 model 视角之间做综合，然后对着选定的 sketch 填 code。

## Start

开始前打开一个 todolist，每个 phase 一条。

1. Ground
2. Sketch
3. Agree
4. Implement
5. Scrap

## Phase A: Ground the problem

为新 code 触及的每一个系统建立真实的 mental model。对相关 subsystem 跑 **how** skill。只是点出一个 file 的名字不叫 grounding。产出 `how` 规定的 architectural explanation。如果这个 design 重新定义了 ownership 或 layering，再对现有 shape 跑 **why** skill，好让那份 rationale 变成 constraint 而不是猜测。

只有当这项工作确实是 greenfield、周围没有任何需要集成的系统时，才跳过 Phase A。

## Phase B: Sketch

用 design-sketch task 和 Phase A 的 grounding artifact 跑 **arena** skill。把 `references/runner-prompt.md` 作为每个 runner 的 prompt 传入。

runner 取自 `pstack-models.mdc` 规则里的 `architect runners` 行，取代 `arena runners` 行。如果规则或该行缺失，就用 `claude-opus-5-5-xhigh` 和 `grok-4.7-xhigh-fast`。alias 与被拒绝的条目遵循 **arena** skill Phase A 里的 runner 规则。

Design it twice。在综合之前要求至少两个结构上不同的 candidate，即使第一个看起来已经够好。这是把 **exhaust-the-design-space** 原则 skill 具体化。要的是整体 shape 的备选，而不是同一个 shape 内部的点状修正。

综合之前，拿每个 candidate 对着 [`references/design-red-flags.md`](references/design-red-flags.md) 筛一遍。假定下一个 contributor 是一个 agent：它只看得到自己打开的 file、复制最近的例子、走能编译通过的最短路径。优先选那种「从单个 file 看是对的改动，对整个 repo 也是对的」的设计。

在 interface depth 上比较可行的 candidate。优先选把更多 complexity 藏在更小、更简单 public surface 后面的设计。一个 rich interface 可以通过集中能力、而不是把能力散到各层，来保持 call chain 短。

arena 返回一个综合好的 design package。它的 synthesis decision 填入 rationale 的 "Synthesis decision" 一节。

## Phase C: Agree（可选）

默认：带着综合后的 design 直接进入 implementation。没有 human checkpoint。

当 invoker 明确要求时才启用 checkpoint："/architect with checkpoint"、"stop and show me before implementing"，或类似说法。此时先把综合后的 design 呈现出来，停下来等待签字确认。

无论哪种情况，综合结果都可以作为独立 commit 先行落地，也就是 **foundational-thinking** 原则 skill 里的 "scaffold first" 模式。填充期间的 planned 且有 scope 的 breakage 是允许的，见 **outcome-oriented-execution** 原则 skill。若想在 implementation 之前对 design 施加对抗性压力，对综合后的 sketch 跑 **interrogate** skill。

如果 human 对 shape 提出反对（无论在 checkpoint 中还是事后），把它当作 Phase A 的 evidence。重新 ground，并在写更多 code 之前重跑 Phase B。

## Phase D: Implement against the sketch

把 `not implemented` 的 body 换成 code，把 pseudocode 换成 logic。综合后的 sketch 就是 contract。偏离它是需要上报的 signal，而不是可以默默吞掉的摩擦。如果某个 function 需要 sketch 没有预料到的 parameter，就问清楚：是 sketch 错了、requirement 漏了，还是 implementation 越界了。

## Phase E: Scrap when the architecture is wrong

如果 implementation 持续产生 sketch 吸收不了的摩擦，就把 sketch 扔掉。不要把 fix 硬装到错误的设计上，见 **redesign-from-first-principles** 和 **fix-root-causes** 原则 skill。

signal 是**模式**，不是单个实例。特征：

- 同一种 shape 的 workaround 在互不相关的 code 里反复出现。
- 多个互不相关的 edge case 都需要 special-case branch。
- type 需要逃生口（`any`、cast、实际使用时总会被赋值的 optional field）才能编译。
- 当 sketch 说 state 并不共享时，仍出现 "we need a lock" 的条件反射。
- caller 必须了解 abstraction 的内部规则才能用。
- 整个 implementation 里出现两处或更多彼此独立的、同一 shape 的 Phase D 偏离。

用判断力。几个 edge case 不足以判定一个 architecture 有罪。有些问题本身就是复杂的。data 里的 complexity 不等于 design 里的 complexity。

要推翻时：

1. 对已经建起来的东西重跑 **how** skill。
2. 按照 redesign-from-first-principles，把新 constraint 当成 day-one assumption 重新设计。
3. 按 **subtract-before-you-add** 原则 skill，先减后加。新 sketch 在长大之前应当比旧的那个更小。
4. 回到 Phase B，重跑 arena。

## Outputs

先写 caller 的 usage，再从中推导 type sketch。小改动就一个 file，包含新的 type 和 signature。较大的工作则给 module map 加 type definition。rationale 一同交付，按 `references/rationale-template.md` 成形，包含 usage sketch 和 synthesis decision。
