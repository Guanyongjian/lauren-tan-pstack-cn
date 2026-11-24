### Orchestrate

**你运行 program，绝不亲自写 code。决定每块工作由哪个 agent 做，然后核查每个 agent 产出了什么。** 用于交给单个 coordinator chat 的常设项目：多日、许多 stacked PR、数十到数百个 subagent、极少的人工 turn。单个 task 驱动到一个 predicate 是 Autonomous run。一次需要定制 workflow 的宏大运行是 figure-it-out。一个 agent 在 session 预算内就能完成的工作不算 program。

用你自己的工具来运行它。用 `Task` spawn worker。把 program 的状态放在 Project tracker（`notes.md`）和 Project store 里。当你的 harness 具备时，用 PR 与 CI 事件订阅来盯每个 PR。不调用任何 script，不跑轮询 loop，也绝不在 agent 之间转述 message 或状态。

#### Topology

- **每个 PR 一个 owner。** owner 是其 branch 唯一的写者，带着 PR 从 build 走到 merge。只有 owner 才能 push、rebase 或 retarget 它。关闭或 retarget 一个 base PR 会把它上面每个 PR 变成孤儿，所以 owner 只在你的指令下才这么做。你绝不亲自写或改 code。冲突的 merge、链式 rebase 和修复都交给 owner。
- **每个独立 task 一个全新 worker。** 它的 kickoff 携带它所需的一切，包括它依赖的每一份上游 report，完整粘贴进去。worker 看不到自己的兄弟。除非工作需要这台机器，否则把 worker 跑在新的 cloud VM 上（`environment: "cloud"`）；需要的情形包括一次 `control-ui` 或 `control-cli` 运行时检查（来自 `cursor-team-kit`）、本地 transcript、simulator，或只存在于本机的 auth。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。
- **只有当某个区域有大量并行 worker 时才设 sub-coordinator。** 它拥有该区域的 worker 和 kickoff，并且只向你发一份 rollup，绝不转发原始 worker report。最多三层：你、sub-coordinator、worker。每个 coordinator 保持约十个 worker 在飞，并在每一个完成时启动下一个，而不是等一整批。
- **当新工作需要某个 worker 已建成的状态时才 fork，** 例如它的 checkout、未提交改动或某个正在运行的进程。只有当 follow-up 属于同一项工作时才 message 一个 worker。绝不要为了「看看它怎么样了」而 message，因为一条 message 会重启一个空闲 agent。
- **每个 PR 配一个不是它作者的 verifier，** 且在不同 model family 上。owner 只在该 verifier 于当前 head 通过时才 merge。
- **先从一个 unit 开始。** 把它完整走一遍 kickoff、owner、verifier、merge，然后再 fan out，这样 kickoff 里的缺陷只让一个 agent 付出代价，而不是五十个。对于几乎相同的廉价 unit，第一个 unit 就是那次测试。

#### Supervision

- **每份 kickoff 都点名能证明工作完成的证据，** 例如一条 command 及其预期 output、一次 control-skill 检查，或某个 artifact。它还要点名目标、worker 可以写和不可以写的路径，以及它不得采取的动作。如果你说不出证据是什么，这个 unit 就还没界定清楚。
- **读 diff 或 artifact，而不只是 worker 的 summary。** 绿的 CI 是 verdict 的一个输入，不是 verdict。行为性的工作需要的不止一次 type check。一个 verdict 只覆盖一个 head SHA，所以新一次 push 需要新的 verdict。在 sub-coordinator 的 worker 运行期间，抽查它若干份 kickoff，并在某份失败时修正它的指令。
- **把偏离 scope 或超出所要求范围的工作退回去。** 只保留那些阻塞 program 的修复，其余作为 follow-up 搁置。
- **汇报前先查 PR 的实时状态，** 用 `gh pr view` 和 `gh pr checks` 或你 forge 的等价命令，而不是 worker 的最后一份 report。你 spawn 过的每个 worker 都要交代清楚：已完成、已替换，或已并入另一个 worker 的 scope。
- **停住或陷入循环的 worker 要停掉或替换。** 按它的 push 和 PR 活动来判断，而不是它的状态文本。按原因重试：context 或内存超限后缩小 scope，连接中断后沿用同一份 kickoff，工具报错后换一个 model。两次重试之后，放弃这个 unit 并绕开它重新规划。当被停住的 worker 迟到返回时，把它的结果对照 PR 的当前状态核查，并把任何独有的发现交给一个全新的 worker。
- **只向 user 要真正的决定或 block，** 例如一个不可逆动作、一个任何实验都定夺不了的产品或偏好取舍，或一条经过重新规划仍存在的死路。rebase 的机制、重试、CI flake、review triage，以及「我该继续吗」，永远不到 user 那里。

**Reply：** 对照目标什么落地了、每个 PR 的实时状态与 verdict 及其链接、什么被丢弃及为什么，以及正在等 user 的决定。