# 改代码之前先理解代码

去编辑你并不理解的代码，就是微妙的回归被交付出去的方式，这对 agent 和对你自己一样成立。agent 通常以两种方式之一失败。它们误读了你想要的，或者它们没有把活干对的上下文。[一段 prompt 里放什么](./02-poteto-mode.md#what-goes-in-a-prompt)处理第一种。本页处理第二种。

pstack 给你四条进入的路。`/how` 解释这段 code 现在做什么。`/why` 挖出它为什么长成这个形状。`/teach` 把两者织成一份解释。`/recall` 重建你自己关于某个主题的近期上下文。每一个也都会让 agent 用它自己能核对的措辞解释自己。这就是你监督一个可能比你更懂这段 code 的 agent 的办法。

![一名侦探拿着放大镜研究一份机器蓝图，机器人在一旁取来卷宗；她身后的证据板在 /how 与 /why 之下把线索连了起来。](./images/understanding.jpg)

## 从一次 read-only 的调查开始

当成因不明时，要 finding，不要修复：

```text
/poteto-mode investigate why background jobs time out every few hours. give me what we know, what data you used, and your best hypotheses. don't change any code yet.
```

「don't change any code yet」把这句路由到 [Investigation playbook](../../skills/poteto-mode/playbooks/investigation.md)。它运行 `/how`，对动机类的问题再加上 `/why`，然后交回一份带引用的解释。面对几个选项之间的取舍，它交回一份带 trade-offs 表的推荐。要求「what data you used」会迫使 agent 把证据与猜测分开。当 finding 指向某个修复时，把这个修复当成一个新 task 开始。

## 用 `/how` 追踪行为

```text
/how do we dedupe notifications? is there an n+1 when we look up subscribers?
```

就问你自己真正有的那个问题。[`/how`](../../skills/how/SKILL.md)读 code，并以一位资深工程师把你带上手这个子系统的层次来回答，包含运行时流程、关键类型，以及那些不显然的部分。对一个大的子系统，它先派两到四个 read-only explorer。对一个窄问题，它就直接读并解释。

## 用 `/why` 挖出历史

```text
/why was the retry limit set to five? does the reason still hold?
```

[`/why`](../../skills/why/SKILL.md)从 source control 起步，然后并行查询你的 MCP 所暴露出的每一个证据类别，例如 issue tracker、长文文档、团队 chat、observability、错误追踪和 analytics。报告会引用一切，把直接证据与推断分开，并在记录单薄时说「似乎是」。空结果也会被报出来，因为「没人写下为什么」本身就是一个答案。

两者天然可组合。当你怀疑历史能解释这团乱时，`do why first then how` 是一段好 prompt。

## 用 `/teach` 真正理解它

```text
/teach me how this PR changes retries. convince me it fixes the cause and not the symptom.
```

[`/teach`](../../skills/teach/SKILL.md)是给摘要不够用的场合用的。它运行 `/how` 和 `/why`——对小改动也许只跑其中一个——并把 finding 织成一份平实的解释，一张图一张图地搭起来。「convince me」这个框架值得反复用。它把解释变成一场你能检验的论证，而不是一次参观。

它对 agent 自己的选择同样管用：

```text
/teach me why you implemented it this way and not with a queue. what did you trade off, and why?
```

教对你和对 agent 的帮助一样多。一个不得不解释自己工作的 agent，必须去读 code 并为每一条主张配证据，而不是自信地说一句就往前走。

## 用 `/recall` 重建你自己的上下文

```text
/recall catch me up on the export work from last week
```

[`/recall`](../../skills/recall/SKILL.md)挖掘你自己近期的 chat 加共享记录（issue、先前的修复、仍在触发的 error），交回一份简报告知事情到哪一步了、接下来是什么。你旧的 chat 里存着一个新 agent 所欠缺的上下文，所以在一个旧主题上开始新工作时，先把它载入，再交接新的输入：

```text
/recall my work on the virtualized list from yesterday, then read this bug report.
```

如果你想恢复某一个特定的 chat，那是下面的 Session pickup playbook，不是 `/recall`。

## 用 Session pickup 接管先前的工作

当另一个 agent（或者上周的你自己）把一个 branch 留在半路：

```text
/poteto-mode take over this branch. read the decision log, figure out what's done, and continue from there. don't redo finished work.
```

[Session pickup playbook](../../skills/poteto-mode/playbooks/session-pickup.md)把先前的轨迹当作权威。它重建该 branch 的状态与各项决定，指出接手的点，并对继承来的主张拿原始目标去核实，而不是从头重新推导一切。

**陷阱：** 不要因为「反正 agent 会读 code」就跳过本页的这些 skill。一个没有可追溯模型就开始编辑的 agent，往往在第一个看似合理的地方修掉 symptom。先跑 `/how`，比后来那个 bug 便宜。

下一节：[设计这次改动](./04-design.md)。