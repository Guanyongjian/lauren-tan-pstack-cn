### Eval

**你负责实验设计。规划、盲测、运行、综合。**

**盲测的 Non-negotiables：**

- candidate 能看到的任何目录、file 或 prompt 里，都不得出现 `eval`、`test`、`judge`、`experiment`、`rubric`、`score`、`compare`、`benchmark`、`candidate` 或 `arena`。
- candidate 看到的 prompt 要像一条自然的 user 请求。陈述目标，而不是 meta。
- 不要有诱使它交底的线索。不要让 candidate 列出它用了哪些 skill、原则或 file。笼统地索要 design note，并从 code 形状而非 self-report 来给链式遵循打分。
- 净化目录名与 slug 名。用 user 可能自己会起的、像项目里原生那样的名字。
- 不要告诉 candidate 还存在别的 candidate。
- judge 可以知道自己正在评判，但只能按净化后的 label 看 output，绝不看 model 名。
- 比较两个变体时：由一个 judge 在一次 pass 里、用同一把尺子给两组打分，且不知道哪一组来自哪个变体。

**Steps：**

1. **Frame。** 陈述在测哪个变体、什么行为算成功。为 judge 写下 rubric（3-6 条具体标准）。对 candidate 保密。
2. **搭好净化环境。** 每个 candidate 一个工作目录，变体已就位。把自然任务本该有的 context 都种进去：一个项目骨架、candidate 自然会去读的那些 skill。
3. **写一条自然的 prompt。** 就是 user 会打出来的那种。不泄漏正在测什么。
4. **spawn N 个并行 candidate**，按 **arena** skill 的 Phase B 跑在不同 model 上。各自在自己的净化目录里工作。每条 prompt 都相同。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。
5. **spawn 一个盲测 judge**，按 **arena** skill 的 Phase C 跑在另一个 model family 上。judge 按净化后的 label 和 rubric 看 output，绝看不到 model 名。
6. **从 transcript 核对这条链，而不是看 self-report。** 读每个 candidate 在当前 workspace 的 `agent-transcripts/` 目录下的本地 transcript（system prompt 会点名该路径）。不要对 `~/.cursor/projects/*/` 做 glob。那会跨越 workspace 边界、读到无关项目的私有对话。看每个 candidate 实际打开了哪些 file。用它真正读过的 file 加上 code 的形状来给链式遵循打分，绝不用 candidate 自己的说法。
7. **自己把每个 candidate 的 output 从头到尾读一遍。** 与 judge 的 verdict 对照。分歧说明某个 model 有偏见，或 rubric 含糊。做综合。

**Reply：** 在测的变体、rubric、每个 candidate 的记录、judge 的 verdict、你的综合，以及关于是否要推广该变体的建议。