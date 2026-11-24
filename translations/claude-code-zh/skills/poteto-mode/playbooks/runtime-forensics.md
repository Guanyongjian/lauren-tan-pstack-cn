### Runtime forensics

**你负责这份诊断。给活着的进程加 instrumentation，不要对着 source 空想。** deliverable 是一份有引用的诊断，不是 fix。

1. 通过 control skill 在对应 surface 上捕获 live signal：空转进程取 CPU profile，泄漏取 heap snapshot，视觉异常取 CDP trace。要真实 artifact，不是猜测。
2. 把 artifact 削减到确凿证据：hot path 上的那个 function、从泄漏对象到 GC root 的 retainer 链、没有输入却在触发的那个 loop。在 subagent 里解析大 artifact（**guard-the-context-window** 原则 skill），主线程只留削减后的 finding。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。
3. 相信之前先证明机制。通过对运行中进程的 CDP eval 注入 instrumentation，或不重载地热修 live code，以低成本确认假设。
4. 把 finding 映射回 source：file、symbol、分配或调度它的那一行。
5. throughput checkpoint 保持一行：`throughput checkpoint: n/a, read-only forensics`。

**Reply：** 捕获到的 signal、削减后的 finding、你如何证明该机制、source 位置、artifact 路径。除非被要求，否则不给 fix。原因查明后交回 Bug fix 或 Perf。