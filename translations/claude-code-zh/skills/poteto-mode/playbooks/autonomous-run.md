### Autonomous run

**你负责退出条件。先定义 done，然后不停顿地朝它推进。**

1. 在第一次迭代之前，把退出条件陈述成一个可检验的 predicate（tests green、repro fixed、all N PRs merged、pixel-diff zero）。
2. 用 Cursor 的 `/loop` command 选定唤醒机制（这是内置功能，不是 pstack skill）。有事件可等（CI、一次 merge、某 ref 推进）就配一个 watcher subagent，在事件发生时唤醒你，并以一个长周期的时间心跳作为兜底。没有事件就用固定间隔的心跳，间隔按「结果多久后值得再查一次」来定。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。
3. 每次迭代都做证据所能支持的最小改动，对着 predicate 验证，有推进就 commit，没帮助的改动就丢弃。那些「也许有用」的双保险要 revert，不要留着碰运气。
   通过 **sequence-verifiable-units** 原则 skill 编排工作，在下一个之前先验证当前这个，而不是把 check 攒到最后。
4. 运行途中发现的、有助于达成目标的都属于你。坏掉的 skill、相关 bug、flake 的验证器、review 噪声、工具故障、被孤儿化的 follow-up，以及可修的 drift，都由你自己经 poteto-mode 处理。把计划外的修复放进它自己的 PR。不要为 reversible 的工作把人搁着，也不要用 `AskQuestion`。只上报不可逆动作、真正属于产品或偏好且任何实验都无法定夺的取舍，或真正的死路。保持 predicate 为主线，每做完一次旁支修复就回到它。
5. 每次迭代都通过 **show-me-your-work** skill 打 checkpoint，一行记录改了什么、predicate 是否推进。
6. predicate 满足时就停。平台期不是停止条件，所以要继续走并换做法去突破它。真正的死路就上报，而不是空转，也绝不为了宣布胜利而放低 predicate。

**Reply：** 退出条件、跑了几次迭代、什么落地了、什么被丢弃、最终的 predicate 状态。