### Refactoring

**你负责这个 contract。structure 变，行为不变。** 与 Feature 不同，它新增行为；与 Bug fix 不同，它纠正行为。

如果清理过程中暴露出一个缺失的 feature 或一个真实的 bug，就把它拆出去，先针对已 pin 的 contract ship 这次结构性改动。重写是允许的，但要点名它并路由到 Feature。大型或横切多处的结构性工作属于 **figure-it-out** skill。这个 playbook 处理的是聚焦到中等规模的改动。

1. 先 pin 住行为 contract。在受影响的 subsystem 上跑 **how** skill 弄清 contract，然后写一个 characterization test、snapshot 或等价性 harness，在任何 structure 移动之前捕获当前行为。如果该区域没有覆盖，就在动 structure 之前先写好这个 pin。type check 和 lint 不算 pin。
2. 按 **principle-model-the-domain** 点名 code 缺失的那个 structure。当形状已经清晰且局部时，无聊的 code 就留着。重塑应当删掉分支或非法状态，而不是增加间接层。
3. 点名目标形状。说明如果今天来构建，module layout、type 和 call graph 应该是什么样（**principle-foundational-thinking**、**principle-redesign-from-first-principles**）。如果目标跨 function 边界，在动手之前跑 **architect** skill 对该形状做并行 design 探索。
4. 先减后加。在引入新形状之前删掉死代码、合并单调用者的 wrapper、去掉冗余 validator、移除孤儿引用（**principle-subtract-before-you-add**）。只 ship 能到达目标形状的最小改动（**principle-laziness-protocol**）。那些「也许有用」的投机性清理要 revert。
5. 以小步、保持行为的方式移动，每一步都让 pin 保持绿色。对于 API 重塑，在同一波里迁移每个 caller 并删除旧 API（**principle-migrate-callers-then-delete-legacy-apis**）。不要兼容 shim，不要新旧并行的双路径。每个 rename 都对着实际 file 抽查。rename 会悄无声息地漏掉字符串、prose 和反向引用中的用法。把机械性编辑委派给一个用你所配置 refactoring model（默认 `grok-4.7-xhigh-fast`）的 subagent，给出明确 scope（file 路径、要移动的名字、要保持的行为）。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。
6. 在真实 artifact 上证明行为未变，而不是「它能编译」（**principle-prove-it-works**）。对较大的重塑，跑一次等价性检查：一个 diff 新旧 output 的 script、一份对着新 code 回放的已录 baseline，或一次通过相关 control skill 在对应 surface 上的 smoke run。
7. 确认这次改动值得保留。成功的衡量是 reader load 下降（**principle-minimize-reader-load**）。如果这个 diff 没有在某处降低 reader load，就 revert 它。
8. rebase 成小的有序 commit。一个减法 commit，然后是重塑，然后是任何后续清理。用 **sequence-verifiable-units** 原则 skill 来塑造它们，使每个保持行为的切片都在下一个之前保持绿色。运行 **Opening a PR**。

**Reply：** 变了什么 structure、你用它对照的 pin、等价性证明、reader load 的变化、什么 ship 了、什么被 revert 了。不含新行为。