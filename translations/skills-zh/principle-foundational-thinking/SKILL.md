---
name: principle-foundational-thinking
description: "写逻辑之前适用：选择核心类型和数据结构、安排 scaffold 与 feature 的先后、想清楚并发方共享了什么。把数据结构选对，下游代码就会变得显然。"
disable-model-invocation: true
---

# Foundational Thinking（基础思维）

**结构性决策**保护 option value。**代码层决策**保护简单性。

**数据结构先行。** 先定对数据形状，再写逻辑。早点定义核心类型，追踪每一种访问模式，选择与主流路径匹配的结构。

在代码层面，DRY 的是结构，不是每一行。类型和数据模型应当收敛。三句相似的语句仍然胜过一个过早的抽象。宁可显式，不要聪明。测行为和边界情况，不数行数。

**并发推论。** 在让多个 actor 共享状态之前，先问「如果另一个 actor 同时修改它，会发生什么？」如果不是「什么都不会」，就隔离。

**先铺 scaffold。** 如果某样东西对后面每个阶段都有帮助，就先做它。问「后面每个阶段是否会因为它已存在而受益？」CI、linting、test infrastructure 和共享类型都是 scaffold。按 option value 排序：setup 在 feature 之前，test 在 fix 之前。commit 要小、要单一目的。

每一次增量都应当落地一个自洽的抽象，或加深一个已有的抽象。不要把新能力以特例协调的形式散布到各个调用方。

减法在脚手架之前。先删死代码，再打地基。
