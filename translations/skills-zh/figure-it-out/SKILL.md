---
name: figure-it-out
description: "当没有更窄的 playbook 适用时，设计一套可审计的 playbook：大型 migration、野心很大的多部分 change，或那种 human 走开一阵回来还要 review 的工作。把 rigor 与 task 匹配，跑一个 hypothesis loop，并记录 decision。用于 /figure-it-out 或 'figure it out'。"
disable-model-invocation: true
---

# Figure it out

当 task 与任何 playbook 都不匹配时，就设计一套。在写任何 code 之前，deliverable 就是 workflow 本身：一串 phase，把 rigor 与 task 匹配、跑科学方法，并留下一条 human 事后能审计的 decision trail。

## Start

打开一个 todolist，第一项是读 **poteto-mode** skill 的 Principles 一节。然后把下面的 phase 作为 todo 加进去。

## Phase A: Frame

先 grounding，再 commit。在你能陈述出以下内容之前，不要开始执行：

- definition of done，写成一个可证伪的 predicate（**prove-it-works** 原则 skill）。
- scope，量化：粗略的 unit 数与工作量，加上 grounding 暴露出的 blocker。
- rigor level，偏高一档。one-way door 和 blast radius 大的多给一些。可逆、低风险的步骤少给一些。rigor 指的是 gate 和 artifact，不是「更努力一点」。

在投入一次长时间运行之前，先呈现 framing 和 tradeoff。可逆的工作直接推进（**never-block-on-the-human** 原则 skill），但一次数小时的运行值得一个 checkpoint。

## Phase B: 设计 workflow

拆成原子的、可独立落地的 unit。按「风险未知最高的先来」排序。scaffold 和 verification 在 feature 之前（**foundational-thinking** 原则 skill）。

- 在工作之前先把 verification harness 建好，baseline 从改动前的状态采集，这样 check 读起来就是「旧值 vs 新值」。
- 对于 one-way-door 的 design decision，跑 **architect** skill（它会跑 **arena**）。对于 shape 已经具体化的机械性工作则跳过。在一个已定案的设计上再跑一次 arena 是 over-engineering（**laziness-protocol** 原则 skill）。
- 决定哪些部分要 fan out。只在接缝处并行，并给每个 worker 自己的 worktree 或 branch（**separate-before-serializing-shared-state** 原则 skill）。不要过度 fan out。按 **poteto-mode** skill 的 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。
- 把设计好的 phase 清单写下来。这份清单就是 human 要 review 的东西。

然后执行这个设计。把它的步骤作为具体条目加到 todolist 里 Phase C 与 Phase D 条目之间。每一步都在 Phase C 的 loop 纪律下运行，并把 Phase D 的 log 贯穿其间——每落地一步就写一行，而不是把整条 trail 留到最后。

## Phase C: 跑 loop

每个 unit 都是一次 experiment。陈述 hypothesis，做最小的 change，对着真实 artifact 按 predicate 测量，有推进就保留，没推进就 revert。应用 **sequence-verifiable-units** 原则 skill，在开始下一个 unit 之前先验证当前这个，而不是把 check 攒到最后一起做。

- 通过检视 artifact 来验证，绝不靠 self-report。当某样东西通过得过于容易时，先怀疑 observation method，再怀疑系统。
- 把委派出去的工作配上一个 judge。如果 worker 钻了 gate 的空子，就 reset 并加固 contract。如果 gate 本身错了，就单独用一个 change 修 gate，而不是绕开它。
- verdict 只有三种：VERIFIED、NOT VERIFIED、INCONCLUSIVE。Inconclusive 不算 pass。不要藏起负面结果。

## Phase D: 保留审计 trail

通过 **show-me-your-work** skill 记录这次运行。figure-it-out 的工作通常足够有分量，可以把 trail commit 下来，让 reviewer 在 PR 里读到。trail 加上 diff，正是让 human 回来时能信任这项工作的东西。

## Phase E: 验证并交回

对照 Phase A 的 predicate，在真实产品上检查整体，而不只是查 harness。把任何反复出现的 correction 固化成 gate、lint rule、check 或 script（**encode-lessons-in-structure** 原则 skill）。

**Reply：** 你设计出的 playbook、rigor level 及其理由、decision-trail 的路径、哪些已按 predicate 验证过，以及哪些仍然 open。