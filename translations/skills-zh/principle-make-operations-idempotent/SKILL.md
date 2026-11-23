---
name: principle-make-operations-idempotent
description: "在设计 command、lifecycle step 或 processing loop 时适用，尤其是那些要在 crash、restart、retry 中运行的场景。无论此前是否只跑了一半，都要 converge 到同一个 end state。"
disable-model-invocation: true
---

# Make Operations Idempotent（让操作幂等）

把 operation 设计成：无论跑多少次、上次停在哪里，都能 converge 到正确 state。每个 state-mutating operation 都应当回答：「如果它跑两遍会怎样？如果上次跑到一半 crash 了会怎样？」

**Why:** command、lifecycle operation 和 processing loop 所处的环境里，crash、restart、retry 都是常态。如果残留的 partial state 会改变下一次 run 的 outcome，那么每次 restart 都会变成一次 debugging session。

**The idea:** 让每一步都从「当前存在的 state」推导出来，而不是从「上一次 run 打算做什么」推导。读当前 state，与 goal 比较，只应用差异。这样写出来的步骤可以安全重复，因为重复时会发现已经没有事情可做。

run 留下的任何东西——lock、temporary file、写了一半的 record、已被 claim 的 job——都必须能被下一次 run 识别为 stale。判断 stale 要依据「无论上次停在哪里都仍然成立」的证据，而不只是 common case 下的证据。一个下一次 run 无法判读的 marker，会把每次 crash 都变成 manual cleanup。例如：写入 temporary path 再 rename 到位，或按内容而非创建顺序比较 artifact。

**The test:**

1. 连续跑两遍会怎样？
2. 如果上一次 run 在每一个可能的时点 crash，会怎样？
3. 重新执行是否 converge 到同一个 end state？

如果任一答案是「取决于留下了什么 state」，这个 operation 就需要一个 reconciliation 步骤。
