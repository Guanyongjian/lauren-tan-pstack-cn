---
name: maintain-verification-skill
description: "周期性跑一遍，让某个项目的 verification skill 和 feature map 保持诚实：每个 feature 一个并行 source reader，用同一个 live session 驱动每个 feature，最多一个 PR 的已证明 correction。用于 /maintain-verification-skill 或 \"audit the verify skill\"。"
disable-model-invocation: true
---

# 维护一个 verification skill

app 一变，feature map 就开始腐烂。这个 skill 是 `/create-verification-skill` 生成的 skill（或任何带 feature map 的项目内 verification skill）的维护 loop。rigor 的单位是 feature，不是每一句话：从 source 覆盖每个 feature 文件、live 演练每个 feature，同时不必把每条 bullet 都过一遍终端。

## Outcomes

选一个，并说明选了哪个：

- **clean** — 每个 feature 都得到了 source 覆盖和 live 覆盖；没有值得 ship 的东西。不建 branch，不开 PR。
- **changed** — 一个 PR ship 出已证明的 doc、harness 或 map correction。
- **blocked** — 覆盖没能完成，或某个已证明的 fix 无法安全 ship。确切说明被什么卡住。

## Edit scope

只编辑 verification skill 自己的目录（它的 SKILL.md、features/，以及它拥有的任何 harness script）。一次运行中绝不编辑产品 code：map 描述了、但 app 已不再具备的 behavior，要么是 doc drift（修 map），要么是 product regression（上报它，不要在 doc 里遮掩）。

## Pass

0. **定位 target。** 找到要维护的 verification skill：那个项目内的、body 里有 launch/drive 各节且有 feature map 的 skill（通常是 `.cursor/skills/verify-*/`）。有多个候选就问是哪一个；一个都没有就停下，并指向 `/create-verification-skill`，而不是自己臆造一个 target。

1. **Index 卫生。** 读 feature map 的 README 并 glob 它的同目录文件。修正缺失、多余、重复或失效的条目。轻量处理；不要生成 inventory。

2. **Source wave。** 每个 feature 文件一个 read-only subagent，并发启动。每个都从 source 解释「这个面向 user 的 feature 是怎么工作的？」，标注可能的 doc drift 并附引用，并返回一份简洁的 live-verification recipe。子 agent 绝不驱动 app，也绝不编辑文件。返回形状：feature summary / source entry point / 可能的 drift 或无 / 一份 recipe。

3. **Reconcile。** 每个 feature 文件都要有一份返回的 summary。把重叠的 recipe 合并成尽可能少的 app state。抽查被引用的 drift；对干净的 claim 不要重新证明。扫一遍最近的 churn，找出 map 里缺失的面向 user 的 surface——在判定缺失之前，要求有具体的 source path。

4. **Live pass。** 即使 source 看起来干净也必须做。coordinator 负责全部驱动；遵循 verification skill 自己的 launch model——server 和 UI 用一个长期存活的实例串行驱动，短命的 CLI 则每次驱动用一个全新的隔离 session（由该 skill 的 Launch 一节决定，不是由这一节决定）。每个 feature 至少演练一次，并在整个 pass 期间守住三条 invariant，无论出什么 failure：(1) 绝不驱动一个自上次出现意外行为以来还没做过 health check 的实例——首次驱动前 doctor，在 session 作为单位的场景下每个新 session 都要 doctor，任何失败的驱动之后再次 doctor，而对于 doctor 看不到的 failure（健康进程上一个卡死的 UI state），就 reset 到已知状态或重新启动，而不是寄希望于它自己好；(2) 到目前为止采集的证据要在每一次 cleanup 中存活，在它被点名的位置做检查，而不是假定它在；(3) 一次驱动所启动的任何东西，都不能在该驱动失去用处之后继续存活——失败迭代的残留要清理，无论 session 是卡住、已退出还是共享的（共享实例就清理残留，而不是清理实例）。由 skill drift 引起的 doctor failure 就是 drift：在 edit scope 下修掉并重试一次——重启该 fix 使之失效的东西，仅此而已——然后才能把这次 pass 判为 `blocked`。一个到不了的 feature，只有在给出具体前置条件（auth、entitlement、OS、外部 state）和尝试过的路径时才算 `verified-unreachable`；如果 map 漏了这个前置条件，那也是 drift。triage 中产生的任何 harness fix，都要在 ship 之前重新 live 驱动一遍。最终 teardown 发生在本次运行最后一次驱动之后——包括那些重新证明——这样任何东西都不会活得比这次运行更久（证据按该 skill 的规定保留）。

5. **Triage。** 面向 user 的描述错误或缺失 → doc drift，修掉。harness 驱动不了但实际可用的 behavior → harness gap，修掉；harness fix 遵循与生成时相同的 helper 规则（script 可执行，调用方式写在 skill body 里）。确实是坏了的 app behavior → product gap；记录给 user，不要放进这个 PR。

6. **Ship 或停。** 对 changed：一个 PR 的已证明 correction，先重读每个改动的文件。对 clean 或 blocked：不开 PR，如实汇报 outcome 和 coverage。

把简洁的运行记录（覆盖了哪些 feature、到不了的前置条件、确认的 drift、outcome）放在一个 scratch 位置；不要 commit 它们。