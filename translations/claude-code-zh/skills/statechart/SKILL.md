---
name: statechart
description: "检查一个在状态之间移动的系统的 TLA+ model，例如一个产品流程、一个协议或一个服务，并用 Mermaid statechart 把它画出来。report 给出到达每个破坏规则状态的最短路径。用于 /statechart，或把 bug 展示为穿过状态的路径。"
disable-model-invocation: true
---

# Statechart

chart 展示一个系统如何在状态之间移动，用的是读图之人的措辞。这个人，也就是 reader，来判断行为是否正确。

## Run

在 repo 之外的一个 scratch 目录里工作。写一份 TLA+ spec 及其 config。然后运行：

```sh
<skill dir>/scripts/statechart SPEC.tla [--config FILE] [--view FILE] [--out DIR]
```

`scripts/statechart.ts` 是 TypeScript，所以要用一个能执行 TypeScript 的 runtime 来跑它。

首次运行会用 mise 安装 TLC 和 Java，需要网络。

## 写 spec

- 把 reader 认可的每条规则写成一个 INVARIANT。规则可以关于一个 screen、一个结果、一个存储值或一条 message。如果 model 里没有对应某条规则的 variable，就加上这个 variable。绝不为了让它成立而弱化规则。
- 把 `Next` 写成各 action 的 disjunction，例如 `YouPressPlay \/ YouPressStop`。若不这样写，TLC 会把每一步都命名为 `Next`。
- 一个没有出边的状态会破坏 `NoDeadlock`，即使它是一个正确的终态也不例外。当某个 INVARIANT 或 PROPERTY 已经占用了这个名字时，规则名是 `CHECK_DEADLOCK`。在 `Next` 里加一个只在终态为真、且不改变任何东西的 action，例如 `Done == phase \in {"paid", "failed"} /\ UNCHANGED vars`，并在 `step()` 里给它一个 label。

## 选 chart

需要判断力的工作由你来做：每个状态和箭头的文字、phase 及其颜色、标题，以及给 reader 的 report。把你的工作放进一个 view module，用 `--view` 传进去。

为呈现 reader 的措辞，view 导出 `state(vars)`。`state()` 返回的值决定形态：

- 返回字符串就是一张扁平 chart：`export const state = (v) => (v.paid ? "Paid" : "Paying");`
- 返回数组就会产生 parent 状态：`export const state = (v) => v.main.split(".");`
- 返回 object 就为每个 key 产生一个平行区域：`export const state = (v) => ({ Playback: v.playback, Volume: v.volume });`

给每个状态标注 reader 看得见或在意的内容，例如 "Paying" 或 "Lease held, write pending"。label 里不要出现 variable 名。在 `vars` 里，TLA+ 的 sequence 是一个 key 从 1 开始的 object，所以 `v.pc[1]` 就是 `pc[1]`。set 是一个 array。

view 还可以导出 `step(action, from, to)`。它拿到 TLC 的 action 名以及该步前后的值，返回箭头的 label。每个 step label 都按 user 看到它发生的样子来写，例如 "you press play" 或 "the connect fails"。不要点出 code 或 TLA+ action 的名字。在 chart 中结局相同的两个 action 使用同一个 label，让它们共用一条箭头。

当某一步只在某些条件下才会发生时，在它的 label 末尾用方括号写明该条件，用 reader 的措辞，例如 `you press play [while the file loads]`。在 regions chart 中，command 会把条件按其他区域 label 的措辞写在箭头上的那些区域旁，例如 `[when Offline]`。你的方括号会取代它，于是同一状态引出的两条箭头可能看起来一样。所以在 regions chart 中，不要为另一区域上的条件写方括号。当某个没有 label 展示的值决定了某一步的去向时，在 label 里点明其结果，例如 "the roster read fails"。

view 还可以导出这些：

- `group(vars)` 返回某个 phase 的名字。每个 chart 状态取其 group 的颜色。当一个 chart 状态背后的多个 model 状态属于不同 group 时，该状态没有颜色。
- `colors` 给每个 group 名一个颜色 class。
- `title` 是一个在 chart 顶部显示的字符串。

command 对每个 model 状态最多调用一次 `state()` 和 `group()`，对每个 step 最多调用一次 `step()`。chart 和 report 都使用这些答案。所以让每个 function 只依赖它的参数。

chart 不绘制停留在同一个 label 内的 step。当 reader 必须看到这样的 step 时，就拆分 label。

瞄准大约 20 条箭头或更少，因为更拥挤的 chart 很难读。先从 `state()` 返回更粗的 label。把行为相同的值归到一个 label，并省去 reader 不需要的细节，例如一个在途调用，其返回不改变任何东西。保留 bug 路径上的每个状态，也保留每个标记。当一次合并把一个 `breaks` 状态变成 `mayBreak` 时，它就掩盖了规则在哪里被破坏。不要合并破坏不同规则的两个状态，因为那样 reader 就看不出哪条规则在哪里被破坏。如果 chart 仍然太挤，就对 reader 不需要的 step 从 `step()` 返回 `null`，例如每个状态都有的 reset，或箭头与其他箭头重复的 step。隐藏 step 时遵守这些规则：

- 保持每个 chart 状态都能从某个起始状态经箭头到达。
- 每个在 model 中有出边的 chart 状态，至少保留一条出边。
- 一条箭头的所有 step 要么全隐藏，要么全不隐藏。只隐藏一部分时，它的条件会变窄。
- 在交接说明中写明 chart 隐藏了哪些 step。

## 读 report

- 在 chart 中，破坏某条规则的状态带 `breaks` class。当它背后的 model 状态只有一部分破坏该规则时，带 `mayBreak` class。Legend 点明每个标记对应的规则。当两条规则同时被破坏时，它在一个标记上列出两者，所以在交接说明中要讲清哪个状态破坏哪条规则。在 regions chart 中，当一个状态参与的每一种区域状态组合都可能破坏规则时，该状态就带标记。当某个组合可能破坏规则、而它没有任何状态带标记时，该组合中的每个状态都带标记。
- TLC 会越过破坏规则的那个状态，所以 chart 展示的是 bug 之后的状态。
- 因为 TLC 会越过 bug，一个对其状态不设限的 model 可能无休止地跑下去。把常量取小，或加一个 CONSTRAINT。
- 有了 VIEW 或 SYMMETRY，TLC 会把它视为相同的状态算作一个，chart 也只画那一个。某条箭头可能指向它，而不是该步实际到达的状态，report 会说明这一点。
- TLC 会检查越过 CONSTRAINT 或 ACTION_CONSTRAINT 之后每个状态里的规则，但不会展开该状态，也不对它做 deadlock 检查。当 TLC 为某条规则找到的最短路径终止于这样一个状态时，chart 会画出该状态，report 给出那条路径。chart 不画边界之外的其他状态。这种状态里的 deadlock 不会显示出来。TLC 也会检查被 ACTION_CONSTRAINT 排除的每一步之后的规则，即使它通过另一条路径到达了下一个状态。当 TLC 为某条规则找到的最短路径以这样一个 step 结尾时，chart 会画出该 step。
- command 按原样的 config、用单个 worker 检查规则。当某条规则被破坏时，command 移除该规则并重跑 TLC，直到没有规则被破坏。首次破坏之后，每次运行在 100,000 个不同状态处停止，以免大 model 无休止地跑。当一次运行触及该上限或因错误停止时，report 会在 "Rules not checked" 下列出它没有检查的规则，chart 也不标记它们。未被检查的规则可能成立也可能被破坏。要检查它，就从 config 里移除被破坏的规则，或把 model 做小。这个上限会引入一个改变 TLC variable 顺序的 module，所以对某个 property，TLC 可能找到一个与不用该上限时不同的 counterexample。
- `tlc.out` 是 TLC 按原样 config 打印的内容。当 chart 没有展示某条被破坏规则对应的 bug 路径时，`tlc-RULE.out` 是 TLC 为找到它的那次运行所打印的内容。当 TLC 重复它的第一条 warning 时，plain TLC 会打印两次，但 `tlc.out` 只显示一次，因为 TLC 把第二份排除在 command 读取的 output 之外。这只在 Java 以 `-XX:+UseParallelGC` 运行时发生，否则 TLC 的第一条 warning 就是它建议传入该 flag，而它只打印一次。

## 展示 chart

把 `chart.mmd` 以 `mermaid` 代码块的形式展示给 user。chart 有 500 个状态的预算，按 TLC 在原始 config 上计数。超出之后，chart 只画通向被破坏规则的路径；当没有规则被破坏时，command 不写 `chart.mmd`。它仍会检查每条规则，report 给出状态数和每条 bug 路径。要看完整图，把 model 做小。

用 Pele 渲染 chart。当 user 要一张图片，或 chart 大到无法当文本读时，遵循 `references/render.md`。除非 user 要求，否则不要换用别的 renderer。

## 交接

把每张 chart 及其 Mermaid 文本交给必须做判断的人。为每个 bug 加一行：该规则、reader 对这条规则的那句话，以及 report 为其编号的那条路径。说明 model 省去了什么。给出重新生成这些文件的 command，用一个新的 `--out` 目录。

当 model 描述的是 code 时，把每条 bug 路径对着真实 code 重放，作为一个 test 或一次 live repro，每个 action 一步。如果某个 bug 没有发生，就先认为 model 错了，直到你证明它没错。