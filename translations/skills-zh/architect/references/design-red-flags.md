# Design red flags

综合之前，先对每个 candidate 过一遍筛。一条 red flag 就是修订或否决该 shape 的理由。

## Shallow module

shallow module 暴露一大片 interface，却几乎不隐藏任何复杂度。衡量深度，要看公共表面背后隐藏的能力与策略，相对这个表面本身的大小。优先选那种界面简单、背后有实质行为的做法。

不要把 deep module 和深调用链混为一谈。深调用链把理解打散到各层。deep module 把能力汇聚在一个 interface 之后。

留意这些迹象：

- 调用方得协调好几个 method 才能完成一次操作。
- 公共 option 暴露了内部阶段或实现选择。
- 学会这个 interface 并不能让调用方免于去学实现。

## Information leakage

information leakage 让多个 module 依赖同一个内部决定。某个表示、策略或协议细节出现在不止一处，于是改动它就得协调着改。

把传输类型或 wire 类型公开 re-export 就是泄漏。在 interface 背后把外部数据 parse 成 domain 类型。让 storage schema、framework 对象和协议细节保持私有。

## Temporal decomposition

temporal decomposition 按执行顺序来组织 module，而不是按它们所拥有的知识。把 load、validate、transform、save 拆成几个阶段，往往会在多个边界上重复同一个表示及其不变量。

围绕领域知识与归属来归组 code。在不同时刻运行的 method，只要守护的是同一批决定，依然可以属于同一个 module。

## Pass-through method

pass-through method 把同样的 argument 原样转给另一个 shape 相同 method。它只加了一层，却不隐藏任何复杂度。

删掉它，或者把职责移到那个能完成该操作的 module 上去。只有当转发边界增添了策略、适配，或是另一种明确的抽象时，才保留它。

## Split ownership

不止一个 module 写同一份 state，或各自留一份副本。编辑其中一个写入方的 agent 看不到其他写入方，于是它们的规则会逐渐分叉。

每一份 state 只给一个 owner。其他 module 要么读它，要么请 owner 去改它。

## Two ways to do one task

设计支持不止一种做法来完成同一件事。agent 会复制它最先找到的那一种，于是每一种做法都在不断获得调用方。

只留一种。把调用方从其余做法上迁走，并在同一次改动里把它们删掉。

## Importable internals

调用方能够 import 某个 module 的 internal。agent 会走那条能编译通过的最短路径，于是直接把它们 import 进来，它们就此成了 interface 的一部分。

让 internal 从 module 外部不可达，使来自外部的 import 直接构建失败。

## Hand-synced list

两处或更多地方列出同一批条目，新增一个条目就得逐一编辑每一处列表。看到其中一份列表的 agent 只会更新那一份。

只保留一份列表，其余都从它派生。如果某份列表无法派生，就让列表不一致时构建失败。