### Pause safely

**你负责干净地停下。留下一个冷启动 agent 能续上的 checkpoint。** 这只在显式要求时执行。遇到 "keep going"、"going to bed, keep going" 或 "don't stop"，不要 pause。

1. 在一个安全的边界停下。完成当前这个原子步骤，或从中退出。不要开始任何新东西，并取消任何嵌套的 subagent。
2. 为了 pause 不要采取任何不可逆动作。不开 PR、不 push，除非你本来就已经有一个在外面。
3. 让工作变得持久。把未提交的编辑作为一个清晰的 `wip:` commit 提交到当前 branch，免得丢失。如果 tree 是坏的，就在 commit body 里用一行说明。
4. 在 context 之外写 resume note。记录 intent、你正在做什么、进展与已验证的部分、当前状态、下一步、关键 file，以及 gotcha。对 compaction 触发器，把它写到一个 file 里，如 `/tmp/<slug>-resume.md`。如果已存在 show-me-your-work trail，就指向它，不要重复。

**Reply：** 你在 loop 中的位置、哪些在磁盘上、哪些还只在脑子里（给路径，不要贴 diff）、你做的 commit 以及 tree 是否干净，以及 resume 时的第一个动作。这是一次 pause，不是最终 report。