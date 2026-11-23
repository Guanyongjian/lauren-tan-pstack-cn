---
name: tdd
description: "仅在 user 明确要求 TDD、failing test 或 regression test 时使用；或当该 bug 有显而易见的廉价 local test target 时。如果 test path 不清楚、昂贵、integration 负担重，或未被要求，就跳过。"
disable-model-invocation: true
---

# TDD Bug Fix

当修 bug 的 test path 清晰且廉价时，先让 broken behavior 变成可执行的，再去改 production code。目标是写出一个聚焦的 regression test：修之前失败，修之后通过。

不切实际时不要硬加 test。如果可用的 test 需要大范围 harness setup、脆弱的 mock、缓慢的 end-to-end infrastructure、只在 production 才有的 state、含糊的复现步骤，或大量无关 fixture churn，就跳过新增 test，改用最接近的有效 verification。

## Workflow

1. **理解 bug。** 确定 intended behavior、current behavior、受影响 path，以及最小可观察的 reproduction。
2. **选最窄的可执行检查。** 优先用该 codepath 已经在用的 unit、component、integration 或 regression test。如果没有显而易见的可行 test path，不要仅为走完流程而从零造一个。
3. **先写 failing test。** 加上最小的、能捕获该 bug 的聚焦 test。test 应当编码 intended behavior，而不是镜像当前 implementation。
4. **修之前先跑新 test。** 确认它因预期原因失败。如果它通过，或因无关原因失败，先修正 test 或 reproduction，再动 implementation。
5. **修 bug。** 做出满足 intended behavior 的最小 production change，同时保持周边 contract 不变。
6. **重跑 regression test。** 确认 test 现在通过。

## 如果 failing test 不切实际

改用最接近的可执行 regression check：一个定向 script、手工复现命令、browser automation、snapshot 比对、log 断言，或聚焦的 integration check。

宁可没有新 test，也不要坏 test。坏 test 是指：主要在测 mock、编码当前 implementation detail、依赖 timing 或无关 global state、为一个小 fix 需要昂贵 infrastructure，或在证明 fix 之后马上就会被删掉。

## Guardrails

- 不要仅为迁就错误 implementation 而改 test。
- 除非 expected behavior 确实变了且理由清楚，否则不要弱化已有 assertion。
- 让 regression test 聚焦在这个 bug 上。避免大范围 fixture churn 或无关的 coverage 扩张。
- 如果 bug 是 flaky 的，尽量让 test 确定化，并记录被锁定的 signal。
- 如果 bug 揭示了一整类故障，先落地聚焦的 regression path，再考虑补充同族的 coverage。

## Final Response

汇报 evidence，而不只是 outcome：

- 点名 failing-before 的 test 或可执行检查，以及它产生的失败。
- 点名 passing-after 的 test run，以及所做的周边 verification。
- 如果无法展示 failing-before 的 evidence，说明原因，并描述改用的最接近的 regression check。
