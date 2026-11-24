---
name: benchmark-checklist
description: "在你汇报或据此行动之前，先对一次 perf 测量做体检（limiter、tuning、limits、errors、repeatability、relevance，以及那项工作到底有没有真的发生）。在你跑 benchmark，或汇报自己测到的 speedup 或 regression 时使用。"
disable-model-invocation: true
---

# Benchmark checklist

当你产出一个性能数字时用它：一个 PR 的 before/after、一个 regression claim、一个 hillclimb harness，或一次库/配置的选择。每个问题都用一次 run 里的证据来回答，而不是对 code 的猜测。

如果 user 只是要一个快速量级估计，一次 run 就够了。但仍要检查第 4、7 题，并说明这只是单次 run。除非那次 run 看起来有问题，其余可以跳过。在多个 option 之间做选择，永远不能只靠一个量级估计。

## 跑任何东西之前

- 把预期要下的 claim 写下来，用你准备 ship 出去的措辞（"export is 30% faster at p50 on the 60k-row dataset"）。下面的问题就是用来检验这句话的。
- 读测量脚本。记下它计时什么、统计什么、忽略什么。
- 用 `uptime` 查 load average，用 `nproc` 查核数。如果机器忙，搞清楚在跑什么。如果你停不掉它，就让两边交错跑，使二者面对相同的噪声，并在 report 里说明这一点。

## 各问题

1. **为什么没有快一倍？** 点名 limiter。在一个你不汇报的 run 里做 profile，因为 profiler 和 tracer 会拖慢工作。用逐进程的 CPU（`top`、`pidstat`）、runtime profiler（`node --cpu-prof`、`py-spy`、`perf`）、I/O wait，以及 syscall 计数（Linux 上是 `strace -c`），再把 hot spot 对应回 source。也要盯着 load generator：如果它先饱和了，你测的是 load generator。如果某个 change 没有推动这个数字，limiter 就解释了原因，所以在判定这个 change 无用之前先把它找出来。
2. **它调优了吗？** 让每一侧都按 production 的方式跑：release build、production 的 flag 和 env、batching 与 transaction 设置、connection pool、cache 的冷热程度与 production 看到的一致，以及相同的版本和数据。如果某一侧跑在默认值上，你比较的是配置，不是实现。如果 limiter 其实是个设置（每行一次 commit、debug build、缺一个 index），那说明这一侧没调优。把它调优、重新测量，再去选赢家。如果你没法调优，就不要用那次 run 选赢家。当 user 是在选择要采纳什么时，把 claim 收窄成「按今天 ship 的 code」并不能解决这个问题，因为他们采纳的是那个选项，不是今天的设置。
3. **它撞到 limits 了吗？** 做算术。把每秒字节数与磁盘、网络带宽比；把每秒操作数乘以单次操作成本，再与你的核数比；把省下的时间与所改动部分原本占用的时间比。拿掉一个只占整轮 10% 的部分，最多只能让整轮快大约 11%。一个越过 limit 的结果，测到的是别的东西，例如 cache、no-op 或 bug。
4. **它报错了吗？** 统计 failure 和非成功响应，并检查输出是否正确，而不只是存在。拒绝往往很快，而 timeout 和 retry 很慢。如果脚本不统计 error，就把这个计数加上。
5. **它能复现吗？** 每一侧至少跑 5 次，交替进行（A、B、A、B 如此往复），这样 warmup、lazy initialization、cache 和 drift 都不会偏袒任何一侧。汇报 median 和 range。小于 run 之间波动的差距不算可测量的差异。当结论很接近时，用 rank-sum test 或 harness 自带的统计。
6. **它重要吗？** 任何 micro 结果旁边，都要测一条 user 真正等待的 end-to-end path，用真实的数据规模和并发，并把 micro 结果作为整体的占比来汇报。一个只占一次 request 1% 的 helper，无论它变得多快，最多也只能让这个 request 快 1%。
7. **它到底发生了吗？** 确认工作确实在计时区间内跑过：request 到达了 server、row 被写入、byte 被读取，且 code 使用了那个结果。lazy code（没人 iterate 的 generator、没人 await 的 promise、JIT 可以丢弃的结果）和 timeout 会为从未发生的工作给出数字。

## Report

- 先给 verdict：faster、slower、no measurable difference，或 inconclusive。
- 给出数字及其单位、run 次数、range，以及 limiter。例如 "p50 41 ms → 33 ms, median of 7 runs per side, range 32 to 35 ms after, bound by JSON parsing on one core."
- 当你声称有差异却点不出 limiter、当某一侧未调优、或当你无法检查第 4、7 题时，把 verdict 判为 inconclusive。点明这个 gap。
- 按 **Opening a PR** playbook，PR body 只保留一个主数字。把 run、range 和 limiter 的证据放进一个链接的 artifact 或 notes 文件。

## 其他 perf 材料

- 在 **Perf issue** playbook 据此做计划之前，先给它的 baseline 做体检，之后每一个数字也要体检。
- 在 **Hillclimb** playbook 的 harness 被冻结之前给它做体检。冻结之后的 harness 会打印 error 与 work 计数，于是每次 keep-or-revert 都免费地检查了第 4、7 题。