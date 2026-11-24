---
name: principle-model-the-domain
description: "在写 stateful logic 时适用，或当代码 branch 很多、跨 file 重复同一种 shape assumption 时适用。"
disable-model-invocation: true
---

# Model the Domain（对领域建模）

把真实的 domain 编码进一个 data structure，而不是把它散落在各个 conditional 里。与 domain 匹配的结构能让 invalid state 无法表示，并删掉 branch。在写代码时选它是便宜的；事后补救读起来像一次 refactor，于是被一拖再拖。

优先考虑：

- 用 state machine，而不是散落的 boolean、phase 或 lifecycle check。
- 用 typed model，而不是松散的 parameter 或反复出现的 shape assumption。
- 用 map、registry、lookup table 或 discriminated union，而不是散落各 file 的 branch。
- 用 reducer 或 command/event model，而不是临时起意的 state mutation。
- 用围绕单一体量的 domain knowledge 组织的 module，而不是按 load、validate、transform、save 这类顺序切分。execution order 不等于 ownership。
- 用一个小 module boundary 来收拢重复出现的 behavior、ownership 或 invariant。
- 在 access pattern 需要时，用 queue、cache、index、graph、tree 或 normalized collection。
- 任何其他合适的结构。当没有合适结构时，先把「代码绝不能允许什么」「data 如何被读取」想清楚，再去找恰好能编码这些的结构。

不要硬套 abstraction。如果当前 shape 已经清晰、局部、且不太可能增长，就选 boring code。对那些只增加 indirection、却不消除 branch、不消除重复 rule、不消除 invalid state、不降低 lifecycle risk 的 abstraction，保持怀疑。

你漏掉本原则的 signal 是：一个新 feature 只是把现有的 if/else 链又加长了一个 branch，或者多了一个必须与第一个保持同步的 boolean。temporal decomposition 是另一个 signal——以 phase 命名的 module 会把同一套 domain rule 在各个 step 里重复一遍。
