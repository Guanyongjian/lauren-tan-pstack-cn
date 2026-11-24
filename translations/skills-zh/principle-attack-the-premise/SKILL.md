---
name: principle-attack-the-premise
description: "当两个或更多共享同一个 premise 的 fix 都卡在同一个 gate 上时适用。把这个 premise 写下来，直接测试它，然后再写下一个假设该 premise 的 fix。"
disable-model-invocation: true
---

# Attack the Premise（攻击前提）

当两个或更多共享同一个 premise 的 fix 都没通过同一个 gate 时，该怀疑的是 premise，而不是那些 fix。

**Why:** 每一个失败的 fix 都是对它背后那个信念的反证。在同一 premise 上做第三个 fix，等于把力气花在证据已经指出「原因不在这里」的地方。

**Pattern:**

- **把 premise 写下来。** premise 就是那个被所有失败 fix 共同假设的一句话。
- **在下一个 fix 之前先测 premise。** 找到一个观察：如果 premise 为假，这个观察应当呈现不同结果；然后把它做出来。看失败是如何分布的，而不只看失败有多大。按 [Build the Lever](../principle-build-the-lever/SKILL.md) 的要求，让这个检查可以重复运行。
- **跟着证据走。** 如果证据与 premise 矛盾，原因在别处。去找那些失败共同具备、而 premise 没有预测到的东西。如果证据印证了 premise，就按 [Fix Root Causes](../principle-fix-root-causes/SKILL.md) 继续问下一个「why」。之前那些 fix 可能只是在处理 consequence 而不是 cause。
- **消除条件，而不是补偿条件**，见 [Laziness Protocol](../principle-laziness-protocol/SKILL.md)。如果证据显示某一方总是落在输的那一侧，就改掉把它放到那里的东西。一个事后清理的机制会留下 cause，并给每次运行都增加开销。

**Stop:** 在 premise 被写下并测试之前，不要开始下一个 fix。

本原则与 [Redesign from First Principles](../principle-redesign-from-first-principles/SKILL.md) 不同：后者是围绕一个新需求重建设计；本原则质疑的是当前设计所假设的一个事实。
