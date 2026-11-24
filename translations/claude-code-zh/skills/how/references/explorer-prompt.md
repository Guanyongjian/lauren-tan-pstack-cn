# Explorer Prompt Template

用这个模板构建每个 explorer subagent 的 prompt。填入占位符。

---

其他 explorer 正在并行调查同一 subsystem 的不同切片。不要试图覆盖所有内容。专注于分配给你的角度并深入调查。

## Question

> {QUESTION}

## Your Exploration Angle

{EXPLORATION_ANGLE}

## Output

### Components Found
关键的 type、service、class 和 abstraction。每一项都给出：name、file path，以及一句话说明它做什么。

### Flow
逐步描述 execution flow。每一步都说明：运行哪个 function/method，它位于哪个 file，它做什么，接下来调用什么。包括在步骤之间流动的 data。

### Files Read
列出探索期间阅读的每一个 file，方便 explainer 引用。

### Boundaries
这个 subsystem 与 codebase 其他部分的连接位置。输入和输出。

### Non-Obvious Things
任何令人意外、有历史原因或容易出错的内容。那些看起来应该按一种方式工作、实际却按另一种方式工作的内容。

### Open Questions
任何你无法完整追踪或理解的内容。如实说明缺口。
