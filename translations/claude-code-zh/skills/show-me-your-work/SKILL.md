---
name: show-me-your-work
description: "为长时间运行或无人值守的工作保留一条可审阅的 decision trail：一个 TSV log，每个 decision 一行（what、why、evidence、result）。默认只放本地；当 reviewer 需要这条 trail 才能信任结果时再 commit 它。用于 /show-me-your-work、autonomous 或多 phase 运行，或那种 human 走开一阵回来才 review 的工作。"
disable-model-invocation: true
---

# Show me your work

在 Claude Code 中，遵循本 skill 之前，每个 session 先读一次 [Claude Code 适配说明](../../docs/harness/claude-code.md)。它把 pstack skill 里的 Cursor 名字映射到 Claude Code。

只维护一份 canonical log。

## 格式

单个 TSV 文件，每个 decision 一行。单元格保持单行。evidence 是一个指针，不是一段 prose。

复制 `references/decision-log-template.tsv`（表头行）来开始一份干净的 log。列：

- **ts。** ISO8601 时间戳。
- **phase。** phase 或 workstream。
- **decision。** 选了什么或做了什么，一行。
- **why。** 用平实的话说理由。如果是某个原则驱动了它，就平实地讲出来，不要用术语标签。
- **evidence。** 一个能证明它的链接或路径：commit SHA、PR 编号、`file:line`，或某个 artifact、trace、screenshot 的路径。绝不要一段话。
- **result。** 结果或 predicate 状态：`tests green`、`reverted`、`pixel-diff 0`、`INCONCLUSIVE`、`open`。

一个示例，措辞平实，让 reviewer 一眼读懂。

```
ts	phase	decision	why	evidence	result
2026-05-24T09:02:00Z	frame	counted the work first, about 100 components and roughly 75 hours	wanted to know the size before starting a long run	commit 3a9f1c2	found 5 things to sort out before starting
2026-05-24T09:40:00Z	harness	took screenshots of the old version before changing anything	so we can compare old against new and catch any visual change	scripts/snapshot.sh, baseline/	saved 120 reference screenshots
2026-05-24T11:15:00Z	widget	moved the widget styles over without changing how it looks	keep the change small and the result identical	commit 7c21e0a, pixel-diff 0	looks identical, tests pass
2026-05-24T12:30:00Z	widget	threw out a helper's work because its screenshots were blank	checked the real files instead of trusting its summary	worktree reset	reverted, tightened the instructions for next time
```

## 记录一行

每条记录都按你会告诉同事「你做了什么」的方式写。平实的词、具体的动作，不要 AI 腔或抽象术语（**unslop** skill 同样适用于 log 文本）。

用 helper `scripts/log.sh <logfile> <phase> <decision> <why> <evidence> <result>`。它会盖上 `ts`、首次使用时写入表头、剥掉多余的 tab/换行，并给任何以 `=`、`+`、`-` 或 `@` 开头的单元格加一个单引号前缀。直接用 `printf` 追加一行也可以，但单元格若来自生成内容或 user 提供的文本，同样要留意这几个字节。

记录 decision point 和 checkpoint，而不是每一个动作：选定的一个分叉、完成的一个 unit 及其验证结果、一次 pivot 或 revert 及其触发原因、浮现的一个 blocker、修好的一个 gate。对 loop 运行，每次迭代一行。琐碎和显而易见的跳过。

一次 run 是一个 agent conversation，包括它后续的 turn 以及任何对它的 summary。一次 pickup、一个替换 agent、或一个新 chat，都开启新的 run。当一次 run 往一份已有行的 log 里追加时，它的第一行 phase 是 `start`；在另一个 run 的 `start` 行之后，它的第一行也同样是 `start`。所以一次在后续 turn 回到某份 log 的 run，要先把这份 log 的最后几行读一遍，看看此后是否有别的 run 写过。一个 `start` 行要点名它之前那些非本 run 所写行的 `ts` 区间，其 evidence 要点名本 run，例如它的 agent id。phase `start` 不用于其他任何情形。

## 它放在哪里

默认情况下这份 log 是一个工作产物，不 commit。放在 work dir 下的 `decisions.tsv`，或当有多项工作同时进行时放在 `.audit/<task-slug>.tsv`，并把它排除在 git 之外。

只有当工作足够有分量、reviewer 需要这条 trail 才敢信任结果时，才 commit 它。

## 规则

- Append-only。一次错误判断用一个新行来取代它。绝不编辑或删除历史。
- 优先用由已 commit 的 script 产出的 evidence，而不是手工的一次性产物（**encode-lessons-in-structure** 原则 skill）。

## 拿 log 对照 transcript 审计

在 run 结束时、交回之前，检查这份 log 说的是不是真话。读本次 run 在当前 workspace 的 `agent-transcripts/` 目录下的 transcript（system prompt 会点明路径）。不要对 `~/.cursor/projects/*/` 做 glob。那会读到无关的私有对话。把本次 run 的各行与实际发生的事逐一对上。它们的每一段都始于本次 run 的某个 `start` 行，或（若本次 run 创建了这份 log）始于第一行，并结束于另一个 run 的下一个 `start` 行：

- 检查每一行都对应一个真实的 decision 或 action。
- 检查每一行的 evidence 都能解析、且确实显示了该行声称的内容。
- 一个塑造了工作却未被记录的分叉、pivot 或放弃的方案，是一个 gap。把它补上。

修正 log，而不是修正故事。审计绝不编辑或删除一行，哪怕是编造出来的行。当某行既不对应真实 decision 也不对应真实 action，或其 claim 或 evidence 有误时，追加一行来取代它，写明实际发生了什么，并给出一个能解析的指针。这个审计不检查本次 run 各段之外的行。如果本次 run 自己的工作暴露出其中某一行有误，就把它当作任何错误判断一样取代掉。

## 对 trail 做跨 model review

交回之前，在一个与完成这项工作的 model 不同的 family 上 spawn 一个 subagent。self-review 不能替代它。该 subagent 读审计 trail 和本次 run 的 transcript，然后标出 user 应当留意的点。不是重做这项工作，而是扫描出次优或有风险之处。按 **poteto-mode** skill 的 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。

- 记录时 evidence 薄弱或缺失的 decision。
- 在 transcript 中被跳过、或声称做了却没有证据的验证步骤。
- 事后看有风险的选择（过早、scope 蔓延、遮掩症状）。
- user 随手一瞟容易漏掉的 gap。

任何产出了 trail 的 run，其每一条 reply 都以一个 "Attention" 一节收尾。第一行单独写 reviewer 的 model（`reviewed by <model>`），然后逐条列出 flag，指向具体的行或时刻。"No flags" 是有效值。model 名不是。

## 审阅这份 trail

从上到下读，顺着 evidence 指针走，抽查。GitHub 会把 commit 过的 TSV 渲染成表格。`column -s$'\t' -t decisions.tsv` 可在终端里渲染它。

## 与其他 skill 的组合

其他 skill 把它们的审计 trail 路由到这里，而不是另造一套。按名字引用它，让它拥有这个格式。不要复述这些列。