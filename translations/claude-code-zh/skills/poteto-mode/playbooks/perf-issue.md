### Perf issue

**你负责这套测量的叙事。规划、review、验证数字。** 每个 fix 都绑定一次测量，不要拿读 source 代替测量。

1. 通过对应的 control skill 捕获一份 baseline trace。用 **benchmark-checklist** skill 给这份 baseline 以及之后每一个数字做体检。
2. 用 `how` 为假设打底。没先跑过就不要声称某个 perf 上限。
   按顺序试这些 performance mantra，最便宜的在前：
   1. 不做它。结果没人用的工作直接停掉，而不是把它变便宜。
   2. 做它，但不要重复做。
   3. 少做一点。
   4. 晚点做。
   5. 趁他们没注意时做。
   6. 并发地做。
   7. 用更便宜的方式做。

   当较早的那条 mantra 已经达标，就停。
3. 依据 trace 规划 fix。如果它跨 function 边界，先 `architect`。把实现委派给一个用你所配置 perf-issue model 的 subagent（默认 `grok-4.7-xhigh-fast`）。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。review 这个 diff。捕获一份 post-fix trace。
   应用 **sequence-verifiable-units** 原则 skill，在尝试下一个之前先验证当前这次。
4. 解析并比较各个 artifact（JSON 转 sqlite，再 diff）。"Inconclusive" 或搞错 surface 都不算 pass。把它标出来。
5. 在 PR 里引用这次测量。
6. 运行 **Opening a PR**。

对于针对某个指标的持续改进、而非一次性修复，用 Hillclimb playbook（`playbooks/hillclimb.md`）。

**Reply：** baseline 数字、post-fix 数字、delta、artifact 路径。