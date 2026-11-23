---
name: reflect
description: "Spawn 三个并行的 review subagent 处理当前 transcript，提炼 learning，并把每一条路由到某个已有 skill 上的具体 edit。用于 user 说 reflect 时。"
disable-model-invocation: true
---

# Reflect

从当前对话里挖掘可长期保留的 learning，再把这些 learning 路由到 skill edit。

当 user 说 "reflect" 或 "/reflect" 时调用。当对话 trivial、跑题，或已被 parent 正确遵循的某个现有 skill 覆盖时跳过。一次性的东西不是 learning。

## 1. 定位当前 transcript

在 fan out 之前，先去 system prompt 指定的 `agent-transcripts/` 目录找到本次对话的 transcript。不要对 `~/.cursor/projects/*/` 做 glob。那会跨越 workspace 边界，读到无关项目的私有对话。

```bash
ls -t <agent-transcripts>/*.jsonl <agent-transcripts>/*/*.jsonl <agent-transcripts>/*/subagents/*.jsonl 2>/dev/null | head -10
```

这覆盖了旧式的扁平布局（`<id>.jsonl`）、当前的嵌套布局（`<id>/<id>.jsonl`），以及 subagent 布局（`<parent>/subagents/<child>.jsonl`）。对每个候选文件，读它的第一行 JSONL。取那个 `message.content[0].text` 中包含本次对话首条 user prompt 的文件。如果都不匹配，改传一份精简的 session digest。

## 2. 并行 spawn 三个 reviewer

一条 message，三个 `Task` call，`subagent_type: generalPurpose`，agent mode（`readonly: false`）。reviewer 需要 MCP access 才能查 transcript 引用的 ticket、chat thread 和 observability trace，而 readonly 会剥掉 MCP。

每个 reviewer 和 synthesizer 都会点出 `pstack-models.mdc` 规则里的一个 role 行以及一个 default。把 `model` 设成该行的值；如果规则或该行缺失，就用 default。当该值为 `auto` 或 `inherit-parent` 时不要设 `model`。如果 Task tool 拒绝某个 slug，就用 default 并说明。如果它连 default 也拒绝，就从它的 error message 里取同一 family 最接近的有效 slug。按 **poteto-mode** skill 的 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。

| Lens | Role line | Default `model` | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `claude-opus-5-5-xhigh` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `grok-4.7-xhigh-fast` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `claude-opus-5-5-xhigh` | `references/divergent-reviewer.md` |

把每个 template 原样传入，并在标注处替换为 transcript path 或 digest。reviewer 在 `Task` response body 里返回 finding。

## 3. 综合

一次 `Task` call，`subagent_type: generalPurpose`，`model` 取自 `reflect judgment, divergent, synthesizer` 行（默认 `claude-opus-5-5-xhigh`），agent mode（`readonly: false`）。它会通过 MCP 抽查 citation，而 readonly 会剥掉 MCP。原样传入 `references/synthesizer.md`，并在标注处内联每个 reviewer 的完整 output。它返回一份 Accepted / Rejected / Backlog 清单。

## 4. 结构性强制检查

任何 Accepted 项，如果用 lint rule、script、metadata flag 或 runtime check 能更可靠地强制，就移到 Backlog。见 **encode-lessons-in-structure** 原则 skill。

## 5. 应用

呈现 synthesizer 完整的 Accepted / Rejected / Backlog output，并在应用任何 Accepted edit 之前等待明确批准。user 挑选子集，也可能改变路由。skill 改动会影响 org 里每一个未来的 agent。不要自动应用。

把每个 Backlog 项直接提交到你团队的 devex 或 backlog tracker，无需等待。只有 Accepted 清单需要批准。

绝不要编辑 `plugins/cache/` 下的 skill。批准之前，先展示它的目的地：`.cursor/skills/<skill>/` 或 `~/.cursor/skills/<skill>/`。批准之后，把 skill 目录复制到那里，并编辑副本。绝不要开 PR 或 push。

严格按每个已批准行的 Routing 执行：

- Trivial 的现有 skill edit（一行 bullet、收紧一句、修正一个过时事实）：由 parent 直接做。
- 实质性的现有 skill edit（新增一节、新增 pattern 表、超过约 10 行）：交给 Cursor 内置的 `create-skill` skill，并跑它的 draft / test / iterate 循环。
- `tune description: <skill path>`（skill 存在，但该触发时没触发）：交给 `create-skill`，跑它的 description 优化循环。
- `new skill via create-skill: <kebab-name>`：把创建交给 `create-skill`。不要临时臆造 shape。

如果你的环境带有 SKILL.md validator，在宣布完成前对每个被触碰的 skill 跑一遍。

## 6. 向 user 汇报

短清单，不要开场白：

- 已应用的 edit：`<skill path>`。改了什么，每项一行。
- 新建的 skill：`<skill path>`。每项一行（罕见）。
- 已提交到 devex tracker 的 Backlog：`<issue title>`（`<tags>`）。每项一行。
- 已丢弃：每个被驳回的 finding 一行，附 synthesizer 给出的理由。
