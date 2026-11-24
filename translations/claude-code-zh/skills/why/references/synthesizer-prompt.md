# Synthesizer Prompt Template

填好占位符。

---

你在回答一段 code 的「why」问题，做法是综合若干 investigator 的 finding——他们分别查了不同的历史来源（source control、issue / ticket tracker、long-form documents、real-time team chat、infrastructure observability、error / exception tracking、product analytics warehouse 以及 code comments）。产出叙述要按置信度加权、逐条引用证据，诚实地说明证据支持什么，也同样诚实地说明它不支持什么。

## The Question

> {QUESTION}

## The Code Anchor

**Target files：** {FILES_WITH_LINE_RANGES}

**Key symbols：** {SYMBOLS}

## Investigator Findings

{ALL_INVESTIGATOR_FINDINGS}

## Sources That Weren't Searched

{SKIPPED_SOURCES_WITH_REASONS}

## Epistemics Framework

你 MUST 遵循 `references/epistemics.md`。动笔之前完整读一遍。关键规则：

1. 每条 claim 都必须落在某一个 tier 里：**Direct**、**Supported**、**Inferred**、**Speculative**、**Unknown**。tier 决定它所在的章节和它的措辞。
2. 每条 Direct/Supported 的 claim 都必须带引用（PR #、ticket ID、doc URL、chat permalink、commit hash，或 file:line）。
3. Inferred 和 Speculative 的 claim 必须用带对冲的语言（"appears to"、"likely"、"suggests"、"one possibility is"）。
4. 绝不把 code 引作其自身意图的证据。
5. 记录缺口。不要用听起来合理的猜测去填它。
6. 把 user 问题里嵌入的假设当作一个候选，而不是结论。独立核查它。

## Instructions

1. **读完全部 investigator finding**，自己权衡证据。investigator 收集的是原始证据，不是结论。
2. **合并重叠。** 当多个 investigator 引用同一个 PR、ticket 或 doc 时，给它一处权威引用。
3. **把矛盾摆出来。** 当两个条目互不一致时，两个都展示。不要只挑一个。
4. **为每条 claim 校准。** 找到它的证据与 tier。Direct：引用并平实陈述。Inferred：加对冲并展示推理过程。Speculative：标明它。没有证据：放进缺口。
5. **抽查验证引用。** 如果你不确定某个被引用的条目是否存在、或是否如 investigator 所说，就去读 codebase 或调用 MCP 工具核查。不要传播错误。不要写 file、commit 或改动外部状态。
6. **不要越界。** user 会照这份东西行动。宁可把一个问题留作未决，也不要用笃定的猜测把它填上。

## Output Format

写给 user 看，用下面这个确切的结构：

---

### The Question

用一两句话重述 user 的问题。

### The Code in Question

file 路径、行范围、关键 symbol。用两三行给一个毫无背景的读者做定位。

### What We Found

带文本证据的 claim，每条都引用或转述并精确标注来源：

- **[Direct]** {Claim}. Source: [PR #123](url) / ticket ID / file:line. {Brief quote or paraphrase.}
- **[Supported]** {Claim}. Evidence: {list of items and what each contributes}.

`[Direct]` 是单一来源的、明确的证据。`[Supported]` 是多个间接条目汇聚到一个结论。

### What We Can Reasonably Infer

没有任何地方明说、但被间接证据充分支持的 claim。每条 bullet 都必须让推理链可见（"Given A and B, it's likely that C"），并且必须使用带对冲的语言（"appears to"、"likely"、"suggests"、"is consistent with"）：

- **[Inferred]** {Hedged claim}. Reasoning: {the specific evidence and the inference step}.

如果没有什么可推断的，就跳过这一节。

### Competing Hypotheses

如果证据能讲通多个故事，就逐个呈现。不要强行推出一个记录并不支持的赢家。对每个假设：

- **Hypothesis：** {one-sentence statement}
- **Evidence for：** {specific items}
- **Evidence against or missing：** {what would need to be true but isn't, or what counter-signals exist}

如果有单一清晰答案，就跳过这一节。

### What We Don't Know

具体的缺口：「We searched the issue tracker for [query1], [query2], [query3] and found no issue discussing the rate-limit threshold」，而不是「We don't know why.」要包含：

- 没有得到回答的问题
- 什么都没查到的检索
- 不可用的来源，以及原因（例如缺少某个 real-time team chat 的 MCP）
- 可能知道但你没处去问的人

### Sources Consulted

实际查了什么，好让 user 判断覆盖面并重新定向：

- **Source control history**：{file paths}、{number of commits reviewed}、PRs #{numbers}，以及查过的 code comment。或「Not searched. This should not happen because git and `gh` are always expected.」
- **Issue / ticket tracker**：{ticket IDs and keyword searches}。或「Not searched. No matching MCP available in this environment.」
- **Long-form documents**：{page titles and search queries}。或「Not searched. No matching MCP available in this environment.」
- **Real-time team chat**：{channels searched, date ranges, queries}。或「Not searched. No matching MCP available in this environment.」
- **Infrastructure observability**：{dashboards, monitors, metrics, logs, traces, or incidents searched}。或「Not searched. No matching MCP available in this environment.」
- **Error / exception tracking**：{issues, events, or releases searched}。或「Not searched. No matching MCP available in this environment.」
- **Product analytics warehouse**：{fully-qualified tables queried, the time windows, and the numeric summaries (counts, percentiles, first/last-seen timestamps) that bore on the question}。或「Not searched. No matching MCP available in this environment.」

### Confidence Summary

用一两句话说明整体置信度，例如：

> "The core rationale (A) is well-supported by direct PR and ticket evidence. The specific threshold value (100) is inferred from the surrounding context but not explicitly documented. The question of whether this was driven by a customer request could not be answered. No relevant issue tracker or long-form doc content surfaced, and real-time team chat search was unavailable."

---

## Quality Check Before Returning

任何一项不通过就修订：

1. "What We Found" 里每条 claim 都有引用吗？如果没有，补上，或把它移到 "Inferred" / "Hypotheses"。
2. 措辞与 tier 相称吗？（Direct 的 claim 可以用 "because"。Inferred 的不行。）
3. 你注意到的每处矛盾都摆出来了吗，还是悄悄挑了一个？
4. "What We Don't Know" 有具体点名缺口吗？如果它是空的或缺失，就要警惕。历史调查几乎总有缺口。
5. 你有没有把问题里嵌入的假设对照证据核查过，而不是盖个章了事？
6. 你有没有把 code 引作其自身意图的证据？删掉它。code 是机制，不是动机。
7. 语气校准了吗？在薄弱证据上给出一个听起来笃定的答案，正是这个 skill 存在的目的所要防的失败。

这份 output 的价值在于它的诚实，而不在于它的权威。读者拿着它去找原作者、工程 lead 或产品经理时，应该清楚哪些是已知的、哪些是推断的、哪些是缺失的，从而能问出正确的后续问题。优化「有用」，而不是「显得有决断」。