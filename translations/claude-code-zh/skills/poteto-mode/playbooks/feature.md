### Feature

**你负责 design。规划、review、验证。** 把实现委派出去。你仍在主导位置。

1. 用 `how` 扫一遍受影响的 subsystem。
2. 用 `architect` 做并行的 design 探索。
3. 把 throughput checkpoint 写成四个 todo 项。确实不适用的维度（单 file、无 fan-out）保留其条目并写 `n/a: <reason>`，而不是删掉：
   - **Blocking first steps。** gate 在 fan-out 之前跑。
   - **Independent workstreams。** 不相交的 file、service 或 layer 可并行。共享写入则串行。
   - **Shared mutable state。** 默认拆分目标（**separate-before-serializing-shared-state** 原则 skill）。只为真正的不变量才串行。
   - **Smallest safe decomposition。** 若一个 worker 最优，说明为什么。
4. 把写 code 委派给一个用你所配置 feature model（默认 `grok-4.7-xhigh-fast`）的 subagent，并给出明确的 scope（file 路径；按 **principle-model-the-domain** 命名的 data shape 及其组织 structure——用 state machine 取代散落的 boolean、用 table/registry 取代分支、用 typed model 取代重复的形状假设，这些都要在 delegate 写 logic 之前选定；以及成功标准）。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。当实现容许多种有效形状（error handling、abstraction layer、test 结构）时，改经 **arena** skill 委派，让 runner 把备选摆出来、由 cross-judge 守住这个选择。这是强制要求：没有「跳过并说明理由」的例外，Laziness Protocol 也不能覆盖它（收益是 review 的分离，不是省下的行数）。一个被禁止 spawn 的 subagent 通过亲自拥有 diff、并保持同样的 review 分离来满足这一点。不要出现等待嵌套 agent 的 "standing by" 回复。comment 按 **Comments**。改动要精准，对来自上游的 file 要对照 source 重新打底。把共享 primitive 的改进移植给所有消费方并逐一验证。多 commit。
5. 在对应的 surface 上验证。"Inconclusive" 或搞错 surface 都不算 pass。把它标出来。
6. rebase 成小的、有序的 commit。follow-up 则 stack 起来。
   用 **sequence-verifiable-units** 原则 skill，构建、验证并 commit 每个小 unit，然后才做下一个。
7. 如果 design 有争议，ship 之前先 `interrogate`。
8. 运行 **Opening a PR**。

与 code 耦合的工作（单个 feature、单次 migration）交给单一 owner，checkpoint 内联在其中。那个 owner 在阻塞性 phase 之后自行 fan out。父层 fan-out 用于产出独立 artifact 的切片（audit、跨 subsystem 的调查、互相竞争的 experiment）。在 phase 边界重写 checkpoint。spawn 一个全新的 owner，而不是串联 interrupt。

**Reply：** 你构建了什么、你选了什么及为什么、throughput checkpoint、未决事项。design 备选用表格。