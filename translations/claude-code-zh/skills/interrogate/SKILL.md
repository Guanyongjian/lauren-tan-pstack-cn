---
name: interrogate
description: "用于「interrogate」「adversarial review」「multi-model review」「challenge this」「stress test this code」「find blind spots」，或「tear this apart」。adversary 试图打破一个 change 或 design，只有靠一次 run 证明出来的 finding 才留下来。"
disable-model-invocation: true
---

# Interrogate

在 Claude Code 中，遵循本 skill 之前，每个 session 先读一次 [Claude Code 适配说明](../../docs/harness/claude-code.md)。它把 pstack skill 里的 Cursor 名字映射到 Claude Code。

adversary 试图打破一个 change 或一个 design。只有一次 run 证明了它，finding 才留下来。汇报 finding。不要应用 fix。

## Frame

scope 是 user 点名的东西。否则就是该 branch 相对于它与 base branch 的 merge base 的 diff，连同 working tree。用 **in-your-own-words** skill，从 user 的 message、commit 和 PR description 中把 intent 陈述出来。intent 不清楚时问 user。

## Fan out

跑 **arena** skill 的 Phase A 第 3、4 步和 Phase B，带四个 change。读取 `interrogate reviewers` 行，取代 `arena runners`。把 scope 里未提交的 change 复制进每个 worktree。把每个 adversary 都作为 `generalPurpose` spawn。取代 arena 的 task 和 rationale，给每个 adversary 传 scope、intent，以及这段 brief：

> 打破这个 change。每条 finding 都要用一次针对真实 code 的 run 来证明，例如一个 failing test、一个 repro script，或显示错误行为的 command output。对于 design 或 plan，跑一个 prototype 或探测当前 tree。把 repro 留在你自己的 worktree 里。每条 finding 汇报一个标题、确切的 command、它打印出的 output，以及 intent 所要求的 output。你没有跑过的东西不要写。那涵盖 style、naming、structure，以及那些需要未来某次改动才会构成问题的 risk。没有 finding 也是一个有效结果。

## Verify

按 arena Phase F 重跑每条 finding 的 command 来验证它。当 output 显示出该 failure、且该 failure 破坏了 intent 时，保留这条 finding。其余丢掉。共享同一 root cause 的 finding 合并。

跳过 arena 的 Phase C、D、E。adversary 找到的是不同的 failure，所以 verdict 保留每一条已验证的 finding，而不是某个 adversary 的一份清单。

## Output

- **Intent**：重述。
- **Findings**：对每条已验证的 finding，给出 command、它的 output、它如何破坏 intent，以及发现它的 adversary。一条都没留下来时说「no verified findings」。
- **Dropped**：对每个 adversary，给出被丢掉 finding 的数量和原因。