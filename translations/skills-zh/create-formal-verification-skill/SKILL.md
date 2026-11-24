---
name: create-formal-verification-skill
description: "生成一个项目内 skill，用任何语言、挑最合适的 verification 工具，对「一个 bug 代价最高、而 test 又最难触及」的 code 做形式化验证。用于 /create-formal-verification-skill、\"model-check this race\"、\"prove this invariant\"，或当 concurrency、retry、state machine、parser 或 unsafe code 需要的超出 test 所能给的时候。"
disable-model-invocation: true
---

# 创建一个形式化验证 skill

test 检查的是有人想到要写的那些 case。formal verification 检查某个陈述范围内的一切 case：model 中步骤的所有顺序、某个 bound 以内的所有输入，或所有输入。这个 skill 找出 repo 里这件事最要紧的地方，验证它的一个 property，并留下一个项目内 skill，让下一个 agent 能拿改动去对照那个 property 做检查。写那个 skill 时，要假设读者是一个 agent：冷启动、正在改动途中、从没见过你的工作。user 必须能信任结果、并能在不学那门验证语言的前提下据此行动。

## 从 code 里选 target

从 codebase 回答，只问 user 那些你观察不到的东西。如果 user 点名了某个区域或某个 bug，就从那里开始。

好的 target 是 code 所做出的一个承诺，一旦被打破就会伤害 user，而 test 又极少触及那个会打破它的 case。选 repo 里最强的这类 target，而不是最好验证的那个。

## 让问题来选工具

选那个以最低成本回答该问题的工具：model checker、proof assistant、SMT-backed verifier，或其他工具。事件是否可能以坏的顺序发生，通常适合用 model checker 在一个设计的精简 model 上验证，而 TLA+ 是任何语言下这件事的默认选择。code 本身是否对每个输入都表现正确（如 memory safety、overflow，或某个 data-structure invariant），通常适合用在 code 上运行的 verifier。如果没有任何 verifier 能跑这门语言，就说明这一点，并用生成的输入去测真实 code，而不是测一个手工做的 function model。一个必须在任意规模下都成立的 property，如果 bound 不够用，就可能需要一份 proof。优先选 repo 的开发者能自行安装并运行的工具，并告诉 user 你为什么选它。

## 什么叫做好

- **忠于 code。** model 或 proof 的每一部分都指向 reviewer 能打开的 code。verification 当作不可分割一步的东西，在 code 里就是不可分割的一步。名字取自这个 repo。
- **能失败。** 一个你从没见过失败的 check 什么也证明不了。让每个 property 在它所守护的 code 的一个坏变体上失败，例如删掉一个检查、或调换一个步骤的顺序。
- **发现就是发现。** 当现有 code 破坏了该 property 时，用 code 的语言把 counterexample 一并汇报。不要为了让它通过而弱化 property 或 model，也不要在 user 未要求时改动产品 code。
- **对 scope 诚实。** 说明验证了什么、在哪些 bound 和 assumption 之下、以及哪些没覆盖。一次 pass 覆盖的是 model 或那个 bound，不是整个系统。
- **不靠工具也读得懂。** 各用一句平实的话陈述 property 和它带来的伤害。用 code 的措辞、以一小串步骤的方式讲清一个 counterexample。
- **重跑便宜。** 一条命令、可复现的工具版本，以及短到让下一个 agent 愿意在每次相关改动上都跑的运行时间。
- **与 code 同步。** 记录每个 check 覆盖哪些文件和 function，以及你最后一次确认该验证确实描述了这些 code 时所在的 commit。该 commit 之后被覆盖的 code 若发生变化，下一个 agent 就能看出这份验证需要再看一眼。

## 生成 verify skill

写一个项目内 skill，frontmatter 点名这个区域并说明何时使用。没有 frontmatter，skill 就不会注册。仅凭这个 skill，下一个 agent 就必须能判断某次改动是否触及被验证的 code、跑起这个 check、分辨真正的 bug 与 modeling 错误，并在改动属于有意为之的情况下更新验证。把 coverage 记录和 sync commit 放进 skill 里，并告诉下一个 agent：只有在确认该验证描述的是新 commit 下的 code 之后，才能把 sync commit 前移。用这个 repo 真实的 command、path 和名词，不要留任何 placeholder。

如果这个 check 是一个 TLA+ model，就告诉下一个 agent 用 pstack 的 [`/statechart`](../statechart/SKILL.md) skill 来读每一个结果。它会把 checker 发现的每个 invariant violation 以最短路径、用平实的话展示出来。当 check 通过时，`/statechart` 会画一张图，展示系统如何在状态之间移动。按名字引用 `/statechart`。它的 command、option 和文件路径在不同 release 和机器之间会变，所以不要把它们任何一条复制进生成的 skill 或它的 script。

## 交接之前先证明它

像下一个 agent 那样，把一个会在真实 code 中打破该 property 的 scratch change 走一遍生成的 skill。它必须抓到这次破坏。然后撤掉这个 scratch change，确认 check 回到起点状态：通过，或只在你将要汇报的那些 finding 上失败。一个从未跑过的 verify skill 只是草稿。如果 skill 漏掉了破坏、或某个步骤跑不起来，就修 skill 或验证本身，而不是修那个 scratch change。

## 交接

告诉 user 你验证了什么、用了哪个工具及原因、bound 是什么、这个 check 用平实的话发现了什么、怎么跑它，以及它不覆盖什么。只有当你找到一个相近的 target 时才建议第二个。指引 user 去看 `/maintain-formal-verification-skill`，用于在那些没有重新跑过验证的改动之后，把验证重新对齐。