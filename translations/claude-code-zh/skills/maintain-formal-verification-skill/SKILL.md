---
name: maintain-formal-verification-skill
description: "在 code 改变之后，把某个项目的 formal verification 重新对齐到 code：找出触及已验证 code 的 commit，更新 model、harness 或 property 使其描述当下的 code，重跑，并说明每个 failure 是验证本身漂移了，还是 code 里有 bug。用于 /maintain-formal-verification-skill、\"is the model still true to the code\"，或在那些触及已验证 code 却没有重新核验的 merge 与重构之后。"
disable-model-invocation: true
---

# 维护一个 formal verification skill

在 Claude Code 中，遵循本 skill 之前，每个 session 先读一次 [Claude Code 适配说明](../../docs/harness/claude-code.md)。它把 pstack skill 里的 Cursor 名字映射到 Claude Code。

一个 formal check 证明的是它所描述之物的某个 property。当 code 变了而验证没变，这个 check 可以一直通过，而它描述的已是不复存在的 code。那种通过才是危险的情形，因为它看起来像一份 proof。这个 skill 是 verify skill 的维护 loop：针对 `/create-formal-verification-skill` 生成的那个，或任何对具名 code 跑 model checker、prover 或 code 级 verifier 的项目内 skill。项目内那个 skill 处理的是 agent 在使用它的同时所做的改动。这个 skill 处理那些绕过了它的改动：merge、未用该 skill 所做的编辑，以及跨许多 commit 累积起来的 drift。

## Outcomes

给每个 check 一个 outcome，并说明是哪个：

- **in sync**：自上次 sync 以来没有任何改动改变该 check 所描述的东西，且该 check 通过。
- **updated**：code 变了，验证现在描述的是新 code，且该 check 通过。
- **bug**：验证描述的是当前 code，而 code 破坏了该 property。这是关于 code 的 finding，不是 drift。
- **blocked**：该 check 无法被重新对齐，或跑不起来。确切说明原因。

一个 check 可以同时是 updated 和 bug：更新让验证重新描述了 code，然后 property 在它上面失败。

## Edit scope

只编辑验证：model、harness、property 文件和 verify skill 本身。一次运行中绝不编辑产品 code，除非 user 要求。当某个 property 在当前 code 上失败时，不要为了让其通过而弱化 property 或 model。上报这个 failure。

## Pass

1. **找出各个 check。** verify skill 没有固定名字，所以按它做什么来找：一个对具名 code 跑 model checker、prover 或其他 verifier 的项目内 skill。把你找到的每一个都读一遍，或读 user 点名的那个。对每个 check，收集 property、它覆盖的 code、bound 与 assumption、运行它的 command，以及最后一次确认它描述了该 code 时所在的 commit。如果没有 verify skill，就停下并指向 `/create-formal-verification-skill`。如果该 skill 没有记录 sync commit，就用最后一次改动验证文件的 commit，并说明你这么做。

2. **按原样跑一遍。** 在做任何改动之前，每个 check 先跑一次，并记录结果。这里通过并不说明 code 正确，它说明旧的描述仍然成立。这里失败可能是 drift，也可能是 bug。在第 5 步之前不要下判断。

3. **读对已覆盖 code 的每一处改动。** 从 sync commit 到当前 commit 对已覆盖文件做 diff，并读每一条 commit message。也要找出移动过的 code：一个已覆盖的 function 若被重命名、拆分或移到别的文件，仍是已覆盖的 code。还要找出触及某个 check 所守护状态的新 code，例如一个写入相同字段的新 function。对每处改动，判断它属于哪一种：
   - **No effect。** 该改动没有改变验证所描述的任何东西，例如格式、注释，或验证未覆盖的 code 路径。要对着 model 或 harness 核对，而不是对着 commit message。
   - **验证不再描述该 code。** 原本作为一个不可分割动作的一步现在成了两步、新增或删除了一个分支、某个检查移动了位置、某条新路径到达了被守护的状态，或某个值的范围变了。model 或 harness 必须改。
   - **承诺被有意改变了。** 该改动改变了 code 所承诺的内容，且改动中的证据表明这是有意的：doc comment、test、changelog 或 commit message。property 必须改，且你必须引用那份证据。
   - **承诺可能被破坏了。** code 变了，且没有任何证据表明承诺变了。随之而来的失败按 bug 候选处理。

4. **从 code 更新，而不是从结果更新。** 修改 model 或 harness，使每个改动过的部分重新指向 reviewer 能打开的 code，并让 code 里不可分割的一步在验证里仍是同一步。重跑之前先从 code 写好更新，不要按「怎样能让 check 通过」去塑造它。只有当承诺被有意改变时才改 property。写下旧的措辞、新的措辞和证据。除非改动使 bound 变错，否则保留它。如果你必须降低一个 bound，就在 report 里说明。

5. **重跑并逐个判断结果。**
   - **Pass：** 一个已丧失失败能力的描述也可能通过。按该 property 所防范的方式去破坏新 code，例如删掉一个新检查、或调换一个新步骤的顺序，确认该 check 能抓到它。然后撤掉这处破坏。
   - **Fail：** 把 counterexample 一步一步地放回真实 code 上重演。如果某一步在 code 里不可能发生，那是验证错了。修验证，并说明错在哪。如果每一步都可能发生，那就是 bug。点名引入它的 commit，用 code 自己的措辞把 counterexample 讲成一串步骤，并用一句话陈述危害。如果有一个针对真实 code 的廉价 test 或 reproduction 能显示该 bug，就把它作为证据加进 report。不要把它 commit 进产品 code。

6. **更新 verify skill。** 更新每个 check 覆盖的 code、command、bound、assumption，以及 sync commit。把 sync commit 设成你核对过的那个 commit。被 blocked 的 check 不要前移 sync commit，并在 report 里说明。然后像下一个 agent 那样把 verify skill 走一遍，确认它的步骤仍能跑。

## Report

对每个 check，告诉 user：

- outcome，以及你读过的那些 commit；
- 验证里改了什么、为什么，每处改动给一句简短理由：code 形状变了，还是承诺被有意改变了（附证据）；
- 重跑结果，以及你用来证明更新后的 check 仍能失败的那处破坏；
- 每个 bug，用平实的话：用 code 的措辞把 counterexample 讲成步骤、危害，以及引入它的 commit；
- 验证仍不覆盖什么，包括它本该覆盖却没有覆盖的新 code。

直截了当地说明哪些 failure 是验证的 drift、哪些是 code 的 bug。对于一个在你更新之前通过、更新之后失败的 check，要说明旧的通过是基于一份陈旧的描述。

把验证的更新放进它自己的一个 change 里，与任何产品 fix 分开。