---
name: principle-prove-it-works
description: "task 做完、宣布 done 之前适用。对着真实的 artifact 验证（跑一遍 feature、读真实的 value、看真实的 diff），而不是对着 proxy、self-report 或「it compiles」。"
disable-model-invocation: true
---

# Prove It Works（证明它真的能用）

在 Claude Code 中，遵循本 skill 之前，每个 session 先读一次 [Claude Code 适配说明](../../docs/harness/claude-code.md)。它把 pstack skill 里的 Cursor 名字映射到 Claude Code。

每个 task 产出都要直接检查 **real thing** 来验证。不要从 proxy、self-report 或「it compiles」上做推断。

**Why:** 未经验证的 work，correctness 未知。间接验证（file mtime、output 是否新鲜、agent 的 self-report、cached screenshot）看起来比直接观测便宜；但基于错误推断去行动，代价远高于直接查源头。

检查 real thing，不要查 proxy：

- 直接检查 process 是否活着，不要绕经 derived state 去推断
- 读真实的 value，不要读 cache 或 derived 表示
- verification 失败时，先怀疑 observation method，再怀疑系统

## 能写成 script 就写成 script

最强的 proof，是一个可以反复跑出同一结果的 deterministic script，而不是一次肉眼确认。把 script 写出来、跑一遍，并把 output 留成 artifact——reviewer 可以自己重跑，而不必信你的口头保证。

artifact 要让人类看得见。只有在大型或复杂的活儿（比如一次大 port 或 migration，需要日后可审计的 trail）才 commit 进仓库（见 **show-me-your-work** skill）。
