### Hillclimb

**你负责这个指标和实验的完整性。监督并 review。把尝试委派出去。** 用于对某一个可测量对象、朝着某个目标做持续迭代式改进。一次性的修复属于 Bug fix 或 Perf issue。这里讲的是 loop。

核心纪律：一次改动、一次测量，保留或 revert。绝不叠加未测试的改动，也绝不凭读 code 就声称有收益（**prove-it-works** 原则 skill）。

1. 选指标之前先把 workload 和 architecture 打底。在目标上跑 **how** skill，点名那些能左右结果的现实 workload 维度（数据规模、历史、state、并发），并选一个能复现 user 抱怨的 case。如果没有 case 能复现它，就去修 repro，而不是做 hillclimb。然后定下一个指标、哪个方向算更好，以及一个可检验的停止 predicate——把目标与尝试次数下限配在一起，这样早期侥幸的胜利无法提前结束运行（示例「至少比 baseline 好 50%，且至少 10 次迭代」就是这个形状）。user 给了数字就用他们的，否则双方先议定。
2. 搭测量 harness，证明它的灵敏度，然后冻结它（**build-the-lever** 原则 skill）。跑对比鲜明且贴近现实的 workload，确认目标 case 复现了症状、而更容易的 case 如预期般区分开来。如果 harness 区分不了它们，就去改 workload 或指标。冻结之前用 **benchmark-checklist** skill 给 harness 做体检，并让它打印 error 计数和已完成工作的计数。冻结之后，一条可重复的命令就产出该指标，采样足以穿过噪声（N 次取 median，而不是单次运行）。在任何改动之前，记录 baseline 指标和 regression gate（必须持续通过的那些 test）的一次绿色运行。
3. 通过 **show-me-your-work** skill 打开 decision log。一个 `decision.tsv`，每次尝试一行：id、hypothesis、change、before、after、delta、tests、verdict（kept 或 reverted）、note。每次尝试之前先读它。把它放在 tree 之外（gitignore）。
4. 把每个假设建立在 step 1 的架构 model 上，让它点名一个具体机制（"defer X off the boot path because it blocks first paint"），而不是「试试给什么东西加 memo」。对 perf 指标，按 Perf issue playbook（`playbooks/perf-issue.md`）step 2 里的 performance mantra 来排假设的顺序。只借用它们的顺序，不借用那一步的停止规则。
5. 循环，每次迭代一个假设：
   - 把改动交给一个用你所配置 hillclimb model（默认 `grok-4.7-xhigh-fast`）的 subagent，给出紧致的 scope。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。去监督并 review diff，而不是自己敲（**guard-the-context-window** 原则 skill）。当多个独立假设同时进行时，把它们 fan 给并行 subagent，各自在自己的 worktree 里（**separate-before-serializing-shared-state** 原则 skill）。
   - 用冻结的 harness 前后测量，并跑 regression gate。
   - 只有指标越过噪声且 gate 保持绿色时才接受。否则把改动完整 revert。一个「也许有用」的小调整不保留。
   - 每个被接受的 fix 一个 commit，只 stage 你改过的 file（`git add <files>`，绝不用 `-A`）。无论保留还是 revert，都记录那一行。
   每次迭代都以一次 check 结束，然后才开始下一次（**sequence-verifiable-units** 原则 skill）。如果运行是无人值守的，只借用 Autonomous run playbook（`playbooks/autonomous-run.md`）的唤醒机制，不借用它的停止规则。
6. 突破第一个平台期。卡住时，连续几次被拒后，就换类别、组合几个接近的尝试、重读 source，或试更激进的办法，然后才断定这座山已经爬完。正确性与简单性优先于那个数字。会破坏行为的收益要 revert，而保持住数字的简化要保留（**laziness-protocol** 原则 skill）。
7. 当 predicate 满足时停止，或当剩下的想法很边缘、不值其成本时停止。不要为了达标而放低 predicate，也不要在还有廉价未试假设时收手。如果卡住了，就把卡点摆出来而不是空转。
8. 运行 **Opening a PR**，被接受的 commit 按它们落地的顺序 stack 起来。

**Reply：** 指标与目标、baseline 到最终的百分比 delta、跑了多少次迭代（kept vs reverted）、每个被接受的 fix 一行、`decision.tsv` 的路径，以及如果再往前推你会试的下一个最好的想法。