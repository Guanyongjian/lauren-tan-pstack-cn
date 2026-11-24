---
name: automate-me
description: "用于 \"automate me\"、\"create/update/refresh my -mode skill\"、\"turn/capture my preferences or working style into a skill\"，或希望 agent 遵循 user 的工作方式时。通过 create-skill + unslop 起草或修订一个个人 -mode skill，可选地从最近 transcript 中拉取新证据。"
disable-model-invocation: true
---

# Automate me

一条引导式的流程，把 user 的工作习惯变成一个 agent 会遵循的 skill。产出是一个为其量身定制的 `-mode` skill（例如 `jay-mode`、`priya-mode`）。

这个 skill 编排另外三个：一次 inline 的挖掘 pass（见第 1 步）、Cursor 内置的 `create-skill`（撰写），以及 **unslop** skill（prose 纪律）。它负责排序，不取代它们。

## Flow

### 0. 检查是否已有 skill

递归查找与 user handle 匹配的 `.cursor/skills/**/*-mode/SKILL.md` 和 `~/.cursor/skills/*-mode/SKILL.md`。mode skill 可以放在某个个人分类目录里（`.cursor/skills/<handle>/`），并不只在顶层。如果已存在一个，用 `AskQuestion` 确认意图（除非他们已说过 "update my skill" 之类的话）：

- 更新已有的 skill（重复运行的默认选项）
- 从头开始（罕见，做之前先问为什么）

update 模式会改变后续流程：

- 第 1 步只挖掘该 skill 最后一次被编辑以来的历史（`git log -1 --format=%cI <path>`）。
- 第 2 步问的是有哪些变化或缺失，而不是从零开始要采集什么。
- 第 4 步就地编辑已有文件。保留 user 未予否认的章节。用新证据修订章节。只有确实全新的规则才新增章节。

### 1. 挖掘他们的历史

在 fan out 之前定位当前 workspace 的 transcript。system prompt 会点名该 workspace 的 `agent-transcripts/` 目录。只用那个路径。不要对 `~/.cursor/projects/*/` 做 glob。那会跨越 workspace 边界，读到无关项目的私有对话。

在该范围内检视最近的 agent 对话以寻找反复出现的 pattern。把历史切成几片（例如最近 2-4 周，切成 3 片，让每片都有足够素材），跑多个并行 subagent。按 **poteto-mode** skill 的 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。每个切片挖掘 subagent 读取 parent 提供的 workspace 范围内路径下的 transcript，寻找下面的 signal，并返回一份简短的结构化清单，列出它看到的 pattern 及 evidence 指针。值得追的默认 signal：

- 回复偏好（长度、语气、格式、要求「说简单点」的纠正）
- 委派习惯（subagent、model、专门化 workflow、并行）
- 验证姿态（「done」意味着什么、unit test 与 live repro、reviewer）
- code 与 prose 纪律（风格、引用的原则、lint/format 工具）
- 流程约定（worktree、commit、PR、review/merge 工具）
- Meta 偏好（任务中途修改 skill、提议新 skill）

在把某个 signal 提升之前先跨切片交叉核对。在 2 片以上出现的 pattern 是高置信度。孤立的 signal 很弱，通常会被丢掉。

### 2. 直接问 user

挖掘会漏掉那些还没出现过的意图。用 `AskQuestion` 工具（结构化多选），而不是让 user 从零打字。

形态：一到两个问题，每个 4-6 个选项，分类问题用 `allow_multiple: true`。先问宽泛的（"Which areas matter most?"），再就选中的领域用具体选项追问。结构化几轮之后，用一句自由文本的 chat 提问兜住选项遗漏的东西。

不要一次抛出 20 个问题。

### 3. 聚类发现

把合并后的 signal 分组为若干章节。常见的有（只采用适用的）：

- **Response style**：长度、语气、格式。
- **Autonomy**：不问就做到什么程度、MCP 工具使用。
- **Understand first**：在界定或调查一次改动时该动用哪些 skill。
- **Subagents**：默认、并行度、model 与任务的搭配、专门化 workflow。
- **Prose / code discipline**：原则、lint 工具、style guide。
- **Review and verify**：repro 姿态、verification skill、live-testing 工具。
- **Process**：git worktree、commit、PR、review/merge 工具。
- **Skills**：skill 撰写习惯、先修 skill、提议新 skill。

**poteto-mode** skill 展示了形状。去读它以了解颗粒度。不要抄它的内容。user 的规则和 poteto-mode 的并不相同。

### 4. 起草 skill

用 Cursor 内置的 `create-skill` skill 来撰写这个 skill。放置位置：

- Path：保留已有 mode skill 的分类。对新的 mode，如果 repo 已为该 handle 建立了个人分类，就用 `.cursor/skills/<handle>/<handle>-mode/SKILL.md`。否则默认放到项目里的 `.cursor/skills/<handle>-mode/SKILL.md`（或 user 偏好个人 skill 时放到 `~/.cursor/skills/<handle>-mode/`）。
- Handle：user 的名字或选定的标识符。
- Frontmatter `description`：以他们的名字 + `/<handle>-mode` + "work in their style" 触发，而不是用 "write code"、"review PR" 这类泛化关键词。
- Frontmatter 格式：遵循 `create-skill` 的 YAML 规则。让 `description` 保持为一个 YAML scalar。当标点或折行需要时，用引号包住，或用 `description: >-` 加缩进的续行。
- Frontmatter 默认 `disable-model-invocation: true`。只有当 user 明确希望他们的 mode 在每一轮都生效时才免除。

### 5. 迭代 prose

对每一行都套用 **unslop** skill 和 `create-skill` 的写作指引。

把草稿给 user 看并听取反馈。预计要迭代多轮。毫不留情地删减。mode skill 不是手册。

### 6. 落地

在从 main 切出的 worktree 里工作。commit 并开 PR。不要直接 push 到 main。

## Guardrails

- **不要对单次对话过拟合。** 一个偏好只说过一次、另一次又被否认，那是噪声。要有多次实例才能固化。
- **不要耍聪明。** 复述其他 skill 的内容、造隐喻、为 agent 读者写「诗意」的 prose，都是只有成本没有收益。保持可执行。
- **引用，而不是内联。** user 所依赖的其他 skill 应以路径引用出现，而不是粘贴摘录。他们维护在任何地方的 principle 文档同理。
- **章节保持最少。** 只有当 user 在那里有具体的、非默认的规则时才加一个章节。"Communicate clearly" 不算一个章节。"Short paragraphs. Tables when comparing options. Bullets only when items are genuinely parallel." 才算。
- **称呼用通用说法。** 祈使句里用 "the user" 或 "the human"，不用作者的名字。
- **不要强求对称。** 如果 user 没有值得写下的流程规则，就整节跳过 Process。

## Evaluation

`-mode` skill 是主观产出。`create-skill` 那种 test/iterate benchmark loop 在这里没用。与 user 做感觉上的核对：读起来像他们吗？漏了什么吗？然后就 ship。

只有当该 skill 的触发准确率在实践中确实成为问题时，才跑 description 优化 loop。

## 何时不要用

- user 想要一个 task 专属的 skill（而不是工作习惯）：单用 `create-skill` 即可，不需要挖掘。
- user 想固化某个很窄的 workflow（例如 "how I write commit messages"）。那是一个普通 skill，不是 mode skill。