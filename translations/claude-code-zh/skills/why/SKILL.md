---
name: why
description: "用于「why does X work this way」「why we picked Y」、design rationale、regression、postmortem，或有 data 支撑的 threshold。先发现可用的 MCP，再按每个 evidence category（source control、issue tracker、long-form docs、real-time chat、infrastructure observability、error tracking、product analytics warehouse）并行查询，然后给出一份带引用的、关于 decision 和 tradeoff 的解读。runtime behavior 用 how。"
disable-model-invocation: true
---

# Why

在 Claude Code 中，遵循本 skill 之前，每个 session 先读一次 [Claude Code 适配说明](../../docs/harness/claude-code.md)。它把 pstack skill 里的 Cursor 名字映射到 Claude Code。

调查 code 背后的动机与意图。配套的 `how` skill 回答 code 做了什么、如何运作；`why` 回答是什么力量塑造了它现在的样子。

下面每次 spawn 都会点出 `pstack-models.mdc` 规则里的一个 role 行以及一个 default。把 `model` 设成该行的值；如果规则或该行缺失，就用 default。当该值为 `auto` 或 `inherit-parent` 时不要设 `model`。如果 Task tool 拒绝某个 slug，就用 default 并说明。如果它连 default 也拒绝，就从它的 error message 里取同一 family 最接近的有效 slug。按 **poteto-mode** skill 的 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。

每次 spawn 都是 `generalPurpose` 配 `readonly: false`（agent mode）。**不要用 readonly/Ask mode。** 那会剥掉 MCP access，从而让由 MCP 支撑的 investigator 和 synthesizer 的 citation 抽查失效。investigator 本身仍然不应写任何东西。

## Operating Posture

以**谨慎、严谨、精确的 investigator** 身份工作。诚实区分你所知道的与你正在推断的。完整的 confidence framework 与措辞指南见 `references/epistemics.md`。synthesizer 必须遵循它。

## Step 1. 理解 target 与 question

**target** 通常是一段 code、一个 pattern、一个 feature，或一个具名 design decision。**question** 通常是 design rationale、tradeoff、促成某个设计的 edge case、外部 constraint、dead code，或一次跨较长时间的历史梳理。

如果 target 含糊（「why do we do it this way?」而所指不明），就依据对话 context（打开的 file、最近的编辑、cursor 位置、刚讨论过的内容）做最合理的判断。简短说明你的理解，让 user 能纠正，然后继续。

## Step 2. 建立 code anchor

在 spawn investigator 之前，先就地构建 seed context：file path 与 line range、关键 symbol（function、class、constant）、最近几个涉及 target 的 commit、merge commit 里的 PR 编号（subject line 中的 `(#1234)` 形式），以及任何关联的 ticket ID。运行 `git blame -L <start>,<end> <file>` 拿最后触碰的 commit，`git log --follow -p -- <file>` 拿穿越 rename 的完整历史与 patch，`git log --oneline -20 -- <file>` 拿最近 commit 并让 PR 编号可见，`git log -1 --format=%B <commit>` 提取 PR 编号。然后对任何实质性 commit 拉取 PR body 与讨论：`gh pr view <number> --json title,body,author,createdAt,mergedAt,labels,closingIssuesReferences,comments,reviews`。这个 anchor 会交给每个 investigator 和 synthesizer。

## Step 3. Spawn 并行 investigator

**默认做完整的并行调查。** 目标是完整的 coverage map，而不是最小的一份。把 null 结果也记录下来，不要跳过搜索。

### Discovery

spawn investigator 之前，先列出 Cursor 环境里可用的 MCP。有 available-tools map 就用它；否则检查 Cursor 暴露的 `mcps/` 目录里已启用的 MCP server。

把每个可用 MCP 映射到一个 evidence category：

1. Source control history
2. Issue / ticket tracker
3. Long-form documents
4. Real-time team chat
5. Infrastructure observability
6. Error / exception tracking
7. Product analytics warehouse

Source control 永远可用，通过 git 和 `gh`。其余六类，依据 MCP 名称、server instruction、tool 名称和 resource 描述来归类。如果一个 MCP 能同时对应多个 category，选与其主要证据相符的那一个。把含糊的情况记录在 coverage map 里。

每个有匹配 MCP 的 category spawn 一个 investigator，全部放在同一条 message 里以便并发执行，每个只负责一个 tool 或 MCP。不要让一个 agent 覆盖多个 MCP。`model` 用 `why investigators` 行，默认 `grok-4.7-xhigh-fast`。

每个 investigator 的 prompt 是填好的 `references/investigator-prompt.md`，再加上：

- 所选 MCP 对应的 category playbook `references/sources/<source>.md`，参照 `references/source-playbook.md` 中的示例改写
- `references/sources/incident-postmortem.md`，**如果目标代码看起来是防御性的**（null check、retry logic、timeout handling、rate limiting、feature flag、egress guard、OOM handler）
- code anchor 和 user 的原始问题

### Investigator 名单，每个可用 evidence category 一位

下列每个 category 都独特地适合浮现某一类「why」，写在「Best at」之后。用它来判断该期待什么样的结果、在某个 category 返回空时点名 gap，以及仅在极少数可证明无关的情况下，为跳过提供依据。

1. **Source control**（git history、用 `gh` 取 PR、code comment、test）。永远 spawn，这是唯一有保证的来源。最擅长*review 期间记录的 implementation-time rationale*。
2. **Issue / ticket tracker**（例如 Linear、Jira、GitHub Issues、Plane、Shortcut MCP）。最擅长*产品或业务侧的驱动因素*。当 why 属于工程之外时最强。
3. **Long-form documents**（例如 Notion、Confluence、Google Docs、Coda MCP）。最擅长*长篇 design rationale*，即在变成 code 之前就写下来的部分。
4. **Real-time team chat**（例如 Slack、Discord、Microsoft Teams、Mattermost MCP）。最擅长*从未落到文档里的实时讨论*。当 source control、ticket 和 doc 的书面记录都很薄时尤其重要。
5. **Infrastructure observability**（例如 Datadog、New Relic、Honeycomb、Grafana、Splunk MCP）。最擅长*促成这段 code 的基础设施与运行时现实*。当 target 是对某个 infra signal（timeout、retry、rate limit、circuit breaker）的响应时最强。
6. **Error / exception tracking**（例如 Sentry、Rollbar、Bugsnag、Airbrake MCP）。最擅长*促成防御性或纠正性代码的具体 exception 与 error trajectory*。对 catch block、null guard、type check、retry 等防御手段最强。
7. **Product analytics warehouse**（例如 Databricks、Snowflake、BigQuery、ClickHouse、dbt、Redshift MCP）。最擅长*塑造了这段 code 的产品与数据现实*。对 flag-gated code、experiment 驱动的发布、data migration，以及「这个数字是从哪来的」这类问题最强。

### 何时跳过某个 investigator

只有在给出**明确、书面的理由**时才跳过，该理由要写进最终的 Sources Consulted。有效理由有两种：

- **该 category 在本环境没有可用 MCP。** 把它标为 gap 而非选择：「Real-time team chat skipped. No matching MCP available, so the conversational record was not searchable.」
- **该来源可证明无关**，而不只是「大概无关」。门槛很高：「Error / exception tracking skipped. Target is a build-time script with no runtime code path.」

如果你的 scope 评估显示这是一个单 commit 的 trivial target、而 PR description 已包含完整答案，你可以在确认七个 category 的可用搜索都会冗余**之后**，直接就地作答。要明确这么说。这种情况应当罕见。

## Step 4. 综合

spawn 一个 synthesizer。`model` 用 `why synthesizer` 行，默认 `claude-opus-5-5-xhigh`。它拿到：

1. investigator 的 findings，包括任何 null 结果和任何带理由跳过的 category
2. code anchor
3. user 的原始问题
4. 来自 `references/epistemics.md` 的 epistemics framework
5. 来自 `references/synthesizer-prompt.md` 的 synthesizer prompt template

## Step 5. 呈现

把 synthesizer 的 output 呈现给 user。你可以为清晰起见做轻度编辑、或补充对话中的 context，但**不要重写 confidence 的措辞**。

## Output Format

结构采用 `references/synthesizer-prompt.md` 里的那套：The Question、The Code in Question、What We Found、What We Can Reasonably Infer、Competing Hypotheses、What We Don't Know、Sources Consulted、Confidence Summary。可按需调整，但要保持 confidence 的分层完整，并让 Sources Consulted 保持每个 investigator 一行，包括那些返回空或跳过的，并写明理由。

在 Sources Consulted 之后，如果 user 的 `why` 问题是要改动这段 code 的前奏，就把 lineage findings 转成用于规划改动的 Preserve / Change / Avoid / Risk 约束集。

## 要避免的常见 failure mode

- **Recency bias**。假定最近的 commit 就是权威。当前的形态往往是许多更早决策层层累积的结果。往前追。
