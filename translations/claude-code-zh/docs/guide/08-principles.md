# 用原则的名字来掌舵

pstack 把 24 条原则作为独立的 skill 随附。`/poteto-mode` 在每个多步 task 的开头读它们的索引，应用这个 task 所触发的那几条，并在 reply 里点名每一条被应用的原则，连同它所改变的那个决定。

你不去调用原则。你用它们的名字来掌舵。每一个名字都指向一条 agent 已经读过的完整规则，所以一个短语比一整段指令更精确地把工作拨过去。

## 实践中的掌舵

假设 agent 正要把一个新的 adapter 硬接到三个现成的上面：

```text
use subtract before you add. delete the obsolete adapters first, then design what's left.
```

假设它因为 build 通过就宣称成功：

```text
apply prove it works. run the real import flow and show me the written records.
```

假设两个并行尝试即将写同一个 branch：

```text
separate before serializing shared state. give each attempt its own worktree, no locks.
```

每个短语都能落地，是因为它背后的规则很具体。agent 还得在 reply 里说清这条规则改变了哪个决定。一条背后没有决定的原则引用，意味着 agent 点出了规则却没有应用它。

## 24 条，简述

core 原则决定要建多少，以及何时重新思考设计：

- [Laziness Protocol](../../skills/principle-laziness-protocol/SKILL.md)偏好删除，以及能解决问题的最小改动。
- [Foundational Thinking](../../skills/principle-foundational-thinking/SKILL.md)在写逻辑之前先选好核心数据结构。
- [Redesign from First Principles](../../skills/principle-redesign-from-first-principles/SKILL.md)把一个新需求整合得像它从第一天起就在那里一样。
- [Attack the Premise](../../skills/principle-attack-the-premise/SKILL.md)把两个或更多失败修复所共享的那个前提写下来，并在下一个修复之前直接检验它。
- [Subtract Before You Add](../../skills/principle-subtract-before-you-add/SKILL.md)在往上搭建之前先移除死重。
- [Minimize Reader Load](../../skills/principle-minimize-reader-load/SKILL.md)合并读者不得不在脑子里扛着的层次与隐藏 state。
- [Outcome-Oriented Execution](../../skills/principle-outcome-oriented-execution/SKILL.md)让重写向目标设计收敛，而不是保留一次性的兼容状态。
- [Experience First](../../skills/principle-experience-first/SKILL.md)宁选 user 的结果，而不是实现的便利。
- [Exhaust the Design Space](../../skills/principle-exhaust-the-design-space/SKILL.md)在没有先例时建两到三个互相竞争的原型。
- [Build the Lever](../../skills/principle-build-the-lever/SKILL.md)造出那个完成或证明这项工作的 script，好让 reviewer 能重跑它。当一个 agent 反复手工做同一件事时，让它写出它希望自己拥有的那个工具或 skill。如果一个 script 能每次都同样地做完某一步，就用这个 script，把 agent 留给那些需要判断的地方。

architecture 原则决定 state、校验和兼容性各自住在哪里：

- [Model the Domain](../../skills/principle-model-the-domain/SKILL.md)把重复的规则编码进一个结构，而不是散落各处的条件判断。
- [Boundary Discipline](../../skills/principle-boundary-discipline/SKILL.md)在边界处校验，并信任内部类型。
- [Type System Discipline](../../skills/principle-type-system-discipline/SKILL.md)让非法状态无法表示。
- [Make Operations Idempotent](../../skills/principle-make-operations-idempotent/SKILL.md)让重试收敛到同一个最终 state。
- [Migrate Callers Then Delete Legacy APIs](../../skills/principle-migrate-callers-then-delete-legacy-apis/SKILL.md)在同一波里迁移并删除。
- [Separate Before Serializing Shared State](../../skills/principle-separate-before-serializing-shared-state/SKILL.md)在加协调之前先移除共享。

verification 原则定义什么才算证据：

- [Prove It Works](../../skills/principle-prove-it-works/SKILL.md)验证真实的 artifact，而不是代理指标。
- [Fix Root Causes](../../skills/principle-fix-root-causes/SKILL.md)在改 code 之前先复现并追到根因。
- [Sequence Work into Verifiable Units](../../skills/principle-sequence-verifiable-units/SKILL.md)让每个小单元都在开始下一个之前以一个检查收尾。
- [Test Behavior, Not Implementation](../../skills/principle-test-behavior-not-implementation/SKILL.md)断言 code 的使用者能观察到的东西，这样当该行为坏掉时 test 会失败，而当内部实现变化时它仍能存活。
- [Explain the Number](../../skills/principle-explain-the-number/SKILL.md)在任何人信任或报告一个测量出来的数字之前，点名是什么限制了它，并排除它测到的是别的东西。[`/benchmark-checklist`](../../skills/benchmark-checklist/SKILL.md)把它变成七个你从真实运行里回答的问题。

delegation 原则让并行的工作保持清醒：

- [Guard the Context Window](../../skills/principle-guard-the-context-window/SKILL.md)把批量阅读路由给 subagent，把 finding 留在主 chat 里。
- [Never Block on the Human](../../skills/principle-never-block-on-the-human/SKILL.md)在可逆的工作上继续推进并呈现结果。

还有一条 meta 原则：

- [Encode Lessons in Structure](../../skills/principle-encode-lessons-in-structure/SKILL.md)把你已经重复过两遍的建议变成一条 lint、检查或 script。[`/correct`](../../skills/correct/SKILL.md)把它应用到一整个 repo，见[变成你自己的](./09-make-it-yours.md#fix-the-environment-with-correct)。

不要背这份清单。现在扫一遍，然后当你撞见 agent 在干某件这里的一个名字本可以拦住的事时，再回来查。词汇就是这样扎下根的。

下一节：[变成你自己的](./09-make-it-yours.md)。