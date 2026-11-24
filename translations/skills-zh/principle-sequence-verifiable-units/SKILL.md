---
name: principle-sequence-verifiable-units
description: "适用于多步骤工作（批量清扫、迁移、一连串相似改动）以及你如何堆叠 commit 和 PR。把工作拆成小的单元，每个单元都终结在一个可验证的状态，推进下一个之前先检查当前这个，并按顺序交付，让整个序列本身就能向 reviewer 证明自己。"
disable-model-invocation: true
---

# Sequence work into verifiable units（把工作编排成可验证单元）

把工作排成一串小单元，每个都终结在一个你可以检查的状态，当前单元没绿就不要往下走。

**Why:** 在造成它的那个单元上发现的断裂，定位成本很低。等到一整批之后才发现，断裂就已经被埋住，而且你已经在一个坏掉的基础上继续盖了。把这些单元编排成 reviewer 可以重放的交付序列，就把「相信我」变成「看着它先红、再绿」。

**Execution.（执行）** 在批量清扫、迁移或任何一连串相似改动中，每次改动都先验证再开始下一个。每个单元是一个 before/after 括号：已知良好的状态、一次改动、跑检查、然后继续。先 rebase 到干净的 trunk 上，好让每次检查都对着真实基线来测。当由 lever 来做改动时，每个单元的检查几乎免费，但照样要跑。

**Delivery.（交付）** 按能证明这项工作的顺序堆叠 commit 和 PR。典型形态是先写失败的测试，再把修复盖在上面。其他叙事顺序包括：重塑之前先做减法、处理之前先采集基线、feature 之前先铺 scaffold。每个 commit 都能自行落地，整个序列读起来就像一段论证。

这是 **prove-it-works** 原则 Skill 在编排上的补充：后者保证每次检查都是真的，**build-the-lever** 原则 Skill 则让每个单元的检查变得便宜。
