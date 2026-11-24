---
name: setup-pstack
description: 配置 pstack 按 role 使用哪些 model、以及用什么 reasoning budget。探测你可用的 model，并写出一个 always-applied 规则，用来覆盖 skill 的默认值。用于 /setup-pstack、"configure pstack models"、"pstack budget"，或修改 pstack 的 model 选择。
---

# Setup pstack

写出 `~/.cursor/rules/pstack-models.mdc`，这是一个 always-applied 规则，按 role 设定 pstack 的 model。

## Steps

### 1. 探测可用 model

枚举你在这个 session 里能传给 `Task` subagent 的 model slug。这是可靠的来源。如果 Cursor 还暴露了 models API 或 CLI、能列出该 user 有权使用的 model，为了完整性优先用它。如果你探测不到任何东西，请 user 粘贴他们能访问的 slug。绝不要写一个你未确认可用的真实 slug。别名 `inherit-parent` 和 `auto` 始终有效，即使它们并非探测出来的 slug。

### 2. 载入当前状态

默认的 role 到 model 的映射，就是下面第 5 步所示的规则形状。如果 `~/.cursor/rules/pstack-models.mdc` 已存在，读它，并把它的 `# budget` 行和各 role 的值当作当前选择。否则从那些默认值起步。如果某一行的 role 不在第 5 步中，例如 `how critics`，那它来自一个已退役的 role。删掉它。

### 3. Budget、映射与确认

**(a) 询问 budget。** 优先用 AskQuestion，而不是自由文本。提供下面四个选项，用这些确切标签，并在规则记录了当前 budget 时点名它。没有规则时，说明 `large` 与 skill 默认值一致。

- `unlimited — max reasoning`
- `large — xhigh reasoning`
- `medium — high reasoning`
- `small — medium reasoning`

**(b) 应用它。** 从 skill 默认值构建工作表格，重跑时保留你按 family、列表或别名（`inherit-parent`、`auto`）改动过的任何 role。`unlimited`、`large`、`medium` 和 `small` 会把每个真实 slug（含 panel 条目）的 effort token 分别设为 `max`、`xhigh`、`high` 或 `medium`。effort token 是末尾那个 token，或在结尾 `fast` 之前的那个，阶梯为 `max` > `xhigh` > `high` > `medium` > `low`。如果结果不是已探测的 slug，就用同一 family 中已探测的、effort 不高于目标且最接近的那个 slug，否则把该 role 标为需要选择。`inherit-parent` 和 `auto` 不变。于是 `unlimited` 把 `claude-opus-5-5-xhigh` 变成 `claude-opus-5-5-max`。Grok 的 slug 最高只到 `xhigh`，所以在 `unlimited` 下 fallback 会把 Grok 定在 `xhigh`，并让 `grok-4.7-xhigh-fast` 保持原样。`large` 保持两个默认值不变。`small` 把它们变成 `claude-opus-5-5-medium` 和 `grok-4.7-medium-fast`。

**(c) 展示 role 并确认。** 展示每个 role 及其 model，把不在已探测集合中的真实 slug 标为需要选择。同时列出第 2 步删掉的每一行。询问是原样接受还是修改特定 role，选项给出已探测的 model 加上 `inherit-parent` 和 `auto`（两者同义：该 role 跑在 parent chat model 上，Auto 用户就是这样留在 Auto 上的）。优先用 AskQuestion，而不是自由文本。对 panel role（arena runners、architect runners、interrogate reviewers），值是一个列表，每个条目跑一个 subagent，别名条目也算，所以列表长度决定数量。`arena cross-judge pool` 也是一个列表，但 Arena 只跑一个 judge。它只尝试与 parent 不同 family 的值，按列表顺序，所以请按偏好排序。`inherit-parent` 或 `auto` 值永不作 judge。`swarm workers` 是每个 worker 的默认 model，除非某次 race 或比较按 arm 另行指定 model。

### 4. Validate

写入的每个真实 slug 都必须在已探测集合中。`inherit-parent` 和 `auto` 始终通过。如果选中的真实 slug 不可用，就停下并重新询问。

### 5. 写出规则

写出 `~/.cursor/rules/pstack-models.mdc`，带 `alwaysApply: true`、一行含所选标签及其目标 effort 的 `# budget`，以及每个 role 一行，使用与 poteto-mode 相同的标签。整份文件覆写，好让重跑保持幂等。形状：

```
---
description: pstack per-role model choices (overrides skill defaults)
alwaysApply: true
---
# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit Task `model`). Alias entries in a panel list still count toward its fan-out.
# budget: large (xhigh)
feature, refactoring: grok-4.7-xhigh-fast
bug-fix: grok-4.7-xhigh-fast
perf-issue: grok-4.7-xhigh-fast
hillclimb: grok-4.7-xhigh-fast
judgment and prose: claude-opus-5-5-xhigh
hardest tasks: claude-opus-5-5-xhigh
how explorer: grok-4.7-xhigh-fast
how explainer: claude-opus-5-5-xhigh
why investigators: grok-4.7-xhigh-fast
why synthesizer: claude-opus-5-5-xhigh
reflect tooling: grok-4.7-xhigh-fast
reflect judgment, divergent, synthesizer: claude-opus-5-5-xhigh
arena runners: claude-opus-5-5-xhigh, grok-4.7-xhigh-fast
arena cross-judge pool: claude-opus-5-5-xhigh, grok-4.7-xhigh-fast
swarm workers: grok-4.7-xhigh-fast
architect runners: claude-opus-5-5-xhigh, grok-4.7-xhigh-fast
interrogate reviewers: claude-opus-5-5-xhigh, grok-4.7-xhigh-fast
```

### 6. 确认

告诉 user 规则已写出，并对新 session 生效。重跑这个 skill 会更新它。

### 7. 提供一个 verification skill（可选）

检查该项目是否有办法驱动真实 app 作为证据（一个 `verify-*` skill，或已有的 harness）。如果没有，提供一次："want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." 若同意，调用 `/create-verification-skill`（在 pstack 安装处解析：workspace、user 或 plugin）。若不同意，就此作罢，不要推销。

### 8. 提供一个 formal verification skill（可选）

检查该项目是否已有 formal verification skill（一个对 code 跑 model checker、proof 或其他 verifier 的项目内 skill）。如果没有，提供一次："want a formal verification skill, so agents can prove a key property of your code holds in every case in scope, not only the cases tests reach? I can generate one with /create-formal-verification-skill." 若同意，调用 `/create-formal-verification-skill`（在 pstack 安装处解析：workspace、user 或 plugin）。若不同意，就此作罢，不要推销。