---
name: ketchup
description: "用平实的话和少量小图，把这个 chat 里自 user 上一条 message 以来发生的变化讲给 user 听。逐项列出所有在等 user 的事，并给足他们仅凭这条 reply 就能定夺所需的依据。用于 /ketchup。"
disable-model-invocation: true
---

# Ketchup

把这个 chat 里、自 user 在 `/ketchup` 之前写的那条 message 以来发生的变化讲给 user 听，并帮助他们理解每一处变化，而不只是它们现在到哪一步了。然后把每一件在等 user 定夺的事摆出来，让他们仅凭你的 reply 就能做出决定。notification 和 subagent 的 result 不算他们的 message。假定 user 只记得自己最后那条 message，之后的一概不记得。

用 [`/bro`](../bro/SKILL.md) 的口吻，而不是它的 task：平实的词、短句、不用术语，就像一个人给另一个人讲近况。说对 user 而言变了什么，而不是你如何做到的。说 "the tests pass"，不说 "CI is green"。省掉 hash、文件路径、命令、build 号以及 test 计数，除非 user 需要其中某项才能行动。用 user 认得的名字称呼每个 PR、branch 或 agent，而不是你自创的标签。如果某个事实需要背景才讲得通，就给出背景，或者干脆不讲这个事实。

## 收集发生了什么

这一轮保持 read-only。只用你已经有的东西做图：不要改动 code、不要启动 app 或 job、不要发布任何东西。汇总你自己自那条 message 以来的工作、subagent 的 report，以及这个 chat 里其他人的 message。核对这个 chat 触及的每个 PR、CI run 或 agent 的当前状态。把你准备展示的每个数字与它所依据的事实核对一遍，纠正过就在文中说明。

action item 是只有 user 才能做的决定或步骤，例如一个产品取舍、一次批准、一个不可逆的操作，或你没有的访问权限。把仍在等 user 的事都包含进来，即使它是在他们最后那条 message 之前提出的。你自己还能做的工作不算 action item。绝不要为了让 reply 有内容而编造一个决定。user 没有要求、工作也不需要的一个步骤不算 action item，除非它不可逆且在等 user：给它一行、不要配图。

一个决定可以涵盖多项，例如一组待 merge 的 PR 中的每一个。对每一项，收集它的链接、它对 user 改变了什么、你做出该选择所依据的证据、它的风险，以及你的选择。若某个决定所需的事实你不知道，就写 "unknown"。没有的链接就不写。

## 写 reply

把笔墨花在决定上，而不是故事上。「发生了什么」控制在 100 个词以内（不计图片），事情少时更短。对 user 而言什么都没改变的工作，省掉。每项约 30 个词。reply 随项数增长：两项时总计应远低于 150 词（不计图片），三十项时则远不止此。绝不要为了压字数而砍掉项或缩小项：不要用计数代替清单，也不要用链接代替某一项。链接可以增加深度，但仅凭 reply 本身就必须足以做出决定。

用一句简短的开场，点名什么在等 user，或说明没有。细节由 action item 给出。如果什么都没发生、也没有任何事在等 user，就说明这一点然后停。

然后展示发生了什么，先放图。把工作产出的 screenshot 和 video 内联嵌入，再放任何能说明某处变化的 diagram。然后用一条短 bullet 概括 user 提出的每件事：结果如何，以及它是 done、仍在运行、失败还是未检查。每一行都按你会当面说出口的方式写："Search was slow from a missing index"，而不是 "Search review: done" 或 "Slow search: missing index"。把途中发现并修掉的 bug 点名。每一行单独读时都必须成立。绝不把仍在等 user 的事标记为 done，也不要写进任何 action item 已说明的内容。在 summary 之下，最多给三行能改变 user 认知或行动的短句。然后用一行点明你自己还能做完的任何剩余工作。

接着列出 action item。提出那个由 user 掌握的决定，例如 merge、approve 或 pick，并给出你的选择。你愿意先做的步骤写进你的选择里。必须先发生的事、以及不可撤销的事，也写进去。给出每个决定所涉及的 PR、issue 或 agent 的编号或链接，选项之间的决定里也要给。

让形状贴合这个决定。关于单项的决定是一条 bullet：决定本身、你的选择、它对 user 改变了什么、你选择所依据的证据，以及它的风险，该项只点名一次。当多项共享同一个决定时，把这个决定和你的选择写一次，然后每项各自一条 bullet，风险最高的在前：它的链接与名称、它对 user 改变了什么、你选择所依据的证据，以及它的风险。只有当某项的选择与整体决定不同时，才点名该选择。即使风险很低，也要给出每项的风险，例如 "Low risk: only the colors change." 只有当等待的代价超出单纯延迟时才说明，例如一个 deadline 或数据丢失。

对于选项之间的决定，把工作权衡过的每个选项都给出，各自说明它给 user 带来什么、代价是什么，若存在当前状态也一并给出。这些代价就是该决定的风险，所以不要再单独加一行风险。当上面的 screenshot 已经展示了这些选项时，就在每个 screenshot 下方写它的收益与代价。

## Visuals

visual 是一张图：screenshot、video、Mermaid diagram、来自 `/visualize` 的 chart 或 diagram，或生成的 image。Markdown 表格不是 visual，即便带有 before/after 两列也不算。

当某样东西用图比用句子更容易 grasp 时，就画出来：一个 design 或 system 如何运作、一个带各 PR 状态的 PR stack 或依赖链、一次 fix 的 before/after，或并排的 option。绝不画 status list、action item 清单，或彼此毫无连接的方块。绝不重复同一个事实，无论在文字中还是在多个 visual 之间。

每张 visual 都要小到一眼能读懂：最多六个方块，每个方块最多八个词。label 用一个人会说的平实词，而不是 "Tests: pass" 这类标签。需要一句话才能说清的事实，应放进正文，或者哪里都不放。

当变化是可见的时，把 screenshot 和 video 内联嵌入，而不只是给链接。如果某个可见变化没有，就在它那条 summary 行标上 "No screenshot yet,"，并在那里说明屏幕上变了什么。用你手上的事实来画 diagram 和 chart：Mermaid diagram 表达事物如何连接，`/visualize` chart 表达数字。绝不编造数字，绝不绘制或生成一个你没有截到的屏幕。只链接确实存在的 artifact。