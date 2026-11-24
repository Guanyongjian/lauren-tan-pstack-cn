---
name: principle-outcome-oriented-execution
description: "在有明确 phase boundary 的 planned rewrite 和 migration 期间适用。向 target architecture converge；不要为维持平滑的 intermediate state 而写一次性的 compatibility code。"
disable-model-invocation: true
---

# Outcome-Oriented Execution（结果导向执行）

优化朝向预期的、可验证的 end state，而不是维持平滑的 intermediate state。

**Why:** 让每个 intermediate step 都完全稳定，往往会制造出临时 compatibility code，而这些代码会变成长期 debt。向 target architecture converge，并在明确的 verification boundary 上证明正确性。

**Core rule:**

- end-state integrity 优先于 transitional stability
- intermediate breakage 是可以接受的，前提是它有计划、有范围、可回退

**Guardrails:**

- 用于有明确 phase boundary 的 planned rewrite 和 migration
- 声明哪些地方允许暂时的 breakage
- migration 期间，对正在改动的区域保留 high-signal check
- 计划完成时要求完整的 static 与 runtime verification
