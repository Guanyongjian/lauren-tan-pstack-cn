### Bug fix

**你负责这个 task。规划、review、验证。** 把调查和修复委派给 subagent，你仍在主导位置。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。

要讲科学。每一行 ship 出去的 code 都能追溯到 runtime 证据。那些「也许有用」的双保险是假设，不是 fix。它不 ship。当证据否定了某个假设时，把它所促成的改动 revert 掉。只 ship 证据所能支持的最小改动，不多做。

1. 自己通过 control skill 在对应的 surface 上复现它（见 Non-negotiables），即使某份 debug 或 instrumentation 协议说要请 user 来复现。只有在说得出具体理由、说明 control surface 到不了目标时，才去问 user，而且要先把能驱动的部分驱动到极限之后才问。如果它无法直接复现，就合成触发条件、收紧条件，或加 instrumentation 直到它能触发。
2. 二分查找原因。列出候选假设，再逐个排除直到只剩一个。用 `how` 在受影响的 subsystem 上、以及 **why** skill 查回归历史，来为这些假设提供线索。每一轮都选那个能砍掉最多剩余问题空间的分割，取得 runtime 证据，然后排除。program state 不清楚时，加 instrumentation 或 logging，在 code 运行时读它。不要猜。冗长或顽固的追查用 Cursor 的 `/loop` command 来驱动。在 step 3 的 architect/interrogate 展开之前，先用 runtime 证据确认存活下来的那个*机制*。
3. 规划 fix。如果它跨 function 边界，先 `architect`。把实现连同明确的 scope 委派给一个用你所配置 bug-fix model（默认 `grok-4.7-xhigh-fast`）的 subagent。
4. 在同一个 surface 上验证。原来的 repro 现在通过。"Inconclusive" 或搞错 surface 都不算 pass。把它标出来。unit test 展示的是分支行为，不是 bug 已不存在。
5. 安排 commit 的顺序，让失败的 repro 在 git 历史里先于 fix 落地。当这个 bug 有廉价的本地 test 路径时，见 **tdd** skill 关于 failing-test-first 节奏的说明。当 test 会变得昂贵、偏集成或含义不清时，跳过它。
   这就是 **sequence-verifiable-units** 原则 skill 的典范形态：失败的 test 在前，fix 叠在其上。
6. 运行 **Opening a PR**。

**Reply：** 什么坏了、根因、fix、你如何验证。把失败转通过的 repro output 原样粘上。