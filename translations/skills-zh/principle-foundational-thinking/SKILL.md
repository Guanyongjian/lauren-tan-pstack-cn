---
name: principle-foundational-thinking
description: "写 logic 之前适用：选择核心 type 和 data structure、安排 scaffold 与 feature 的先后、想清楚 concurrent actor 共享了什么。把 data structure 选对，下游 code 就会变得显然。"
disable-model-invocation: true
---

# Foundational Thinking（基础思维）

**Structural decision** 保护 option value。**Code-level decision** 保护 simplicity。

**Data structure 先行。** 先定对 data shape，再写 logic。早点定义 core type，trace 每一种 access pattern，选择与主导 path 匹配的结构。

在 code 层面，DRY 的是 structure，不是每一行。type 和 data model 应当 converge。三句相似的 statement 仍然胜过一个过早的 abstraction。宁可 explicit，不要 clever。测 behavior 和 edge case，不数 line count。

**Concurrency corollary。** 在让多个 actor 共享 state 之前，先问「如果另一个 actor 同时修改它，会发生什么？」如果不是「什么都不会」，就 isolate。

**Scaffold first。** 如果某样东西对后面每个 phase 都有帮助，就先做它。问「后面每个 phase 是否会因为它已存在而受益？」CI、linting、test infrastructure 和 shared type 都是 scaffold。按 option value 排序：setup 在 feature 之前，test 在 fix 之前。commit 要小、要 single-purpose。

每一次 increment 都应当落地一个自洽的 abstraction，或加深一个已有的 abstraction。不要把新 capability 以 special-case coordination 的形式散布到各个 caller。

subtraction 在 scaffolding 之前。先删 dead code，再打地基。
