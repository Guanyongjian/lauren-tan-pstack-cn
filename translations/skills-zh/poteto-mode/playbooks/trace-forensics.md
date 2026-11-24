### Trace forensics

**你负责从 artifact 里得出诊断。**

与 **Runtime forensics** 不同，那个是给活着的进程加 instrumentation。这里捕获已经存在。artifact 是一份固定的数据集，读它，不要重跑它。工具保持通用：cpuprofile 和 `.json.gz` 用 DevTools 或 trace parser，spindump 用文本编辑器，heapsnapshot 用你手上的 heap 工具。

1. 识别格式，并用对的工具加载它。在 subagent 里解析大 artifact（**principle-guard-the-context-window** skill），主线程只留削减后的 finding。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。
2. 把原始 artifact 转换成可查询的形式。把 trace 或 heap snapshot 灌进 sqlite，一个 sample、frame 或 node 一行。先到达可查询的形状，再去读。
3. 缩小到原因。查出占用时间最多的 frame，并沿 call tree 走到 hot path。对泄漏，从泄漏对象沿 retainer 链追到 GC root。对 spindump，找出卡在 on-CPU 或阻塞的那个 thread 及其 wait reason。
4. 归因到 source。借 artifact 自带的 symbol 把 hot frame 映射到 file、symbol 和 line。一个没有 source 映射的 frame 还不能算诊断。把 symbol 解析出来，或者直说这个 artifact 没带它们。
5. 如果你有一对配对的 capture，就 diff 前后两个 artifact 来确认。否则，把这个 finding 标为该 artifact 所能支持的最强假设，而不是已确认的原因。
6. 交回一份带引用的诊断，除非被要求否则不给 fix。原因查明后路由到 Bug fix 或 Perf issue。throughput checkpoint 保持一行：`throughput checkpoint: n/a, read-only forensics`。

**Reply：** artifact 及其格式、削减后的 finding、source 位置、artifact 路径，以及是否有配对 capture 予以确认。