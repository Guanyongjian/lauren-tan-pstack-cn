### Session pickup

**你负责这个续接点。读先前的 trail，不要重做它。**

1. 定位先前的 trail。可能是当前 workspace 的 `agent-transcripts/` 目录下一份本地 transcript（system prompt 会点名路径。不要对 `~/.cursor/projects/*/` 做 glob，那会跨越 workspace 边界、读到无关项目的私有对话）、一个 cloud-agent URL，或一个已 push 的 branch。先读 metadata overview 和最后几条 message，再往回扫出各个 decision point。在 subagent 里解析过长的 transcript，主线程只留削减后的 timeline（**principle-guard-the-context-window** skill）。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。
2. 重建运行状态。branch 与 worktree、已经落地了什么（对 base 做 `git log`、`git diff`）、未完成的 todo、做过的决定。先前的 trail 是权威输入。抵制重新推导它的冲动。
3. diff 已完成与待办。把已 ship 的与原本计划的对照，点名续接点，不要重跑先前的 repro，也不要重做已完成的工作。来一趟「let me verify from scratch」意味着你把这份 trail 当成不可信，而它其实是权威。
4. 把剩余工作路由到匹配的 playbook 并选定 verdict：继续执行、ship 一份已完成的建议、追认或推翻先前的结论、或对一次失败的运行做 postmortem。pickup playbook 到此为止。其余由被路由到的 playbook 负责。
5. 在真实 artifact 上把继承来的 claim 对照最初的目标验证（**principle-prove-it-works** skill）。先前一份通过的 self-report 不是证明。

**Reply：** 先前的 agent 停在哪里、你继承了什么 vs 重做了什么（理想情况是什么都没重做）、续接点，以及 outcome。