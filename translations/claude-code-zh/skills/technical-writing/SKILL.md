---
name: technical-writing
description: "分层的技术写作标准：Diátaxis 结构、Google developer style 句式、STE 指令规则、Global English 句法。用于 /technical-writing，或在写、评审 doc、RFC、readme、PR description 或 commit message 时。"
disable-model-invocation: true
---

# Technical writing

在 Claude Code 中，遵循本 skill 之前，每个 session 先读一次 [Claude Code 适配说明](../../docs/harness/claude-code.md)。它把 pstack skill 里的 Cursor 名字映射到 Claude Code。

写到让一个疲惫的工程师第一遍就能读懂。四层全部套用。

有三条规则凌驾于各层之上：

- **删掉每一个不起作用的词。** 如果删掉某个词句子依然成立，这个词就该删。"In order to" 就是 "to"。"It is important to note that" 什么也不是。
- **用短小、日常的词。** 用 "Use"，不用 "utilize"。用 "Help"，不用 "facilitate"。用 "Do"，不用 "perform"。一个长词必须用精确性来换取它的长度。
- **当某条规则让句子更糟时，换一种方式改这个句子，或者别动它。** 一个遵守了所有规则、读起来却像机器写的句子，已经失败了。

codebase 就是词表。写真实的 symbol、file、flag 或 command 名，而不要用同义词或对它的描述。

不要造术语。用开发者会当面说出口的词："move"、"delete"、"a budget that only decreases"，而不是 "evacuate"、"ratchet" 或 "endgame"。当 doc 首次说明其含义时，用一个有名字的 pattern 是可以的。把新发现的违规词及其替换词作为对 `unslop` 抽象隐喻规则的补充，连同 diff 一起提在你的 reply 里。不要编辑那个 skill。

## 变化节奏

一份 doc 可以遵守每一层，读起来仍然像机器写的：每个句子都截得很短、通篇没有观点、什么都说得笼统。

- 有意混合句子长短。短句落一个点。长句承载一个带条件或后果的事实。
- 一句一个想法，不等于一句一个长度。把承载两个想法的句子拆开。保留承载一个想法的长句。
- 在 mode 允许的地方要有一个观点。explanation 权衡取舍，所以说清你怎么看，而不是罗列利弊。reference 保持干涩。
- 具体胜过干瘪。不是 "schema changes can cause issues"，而是 "a column rename fails the build"。

## 先选 mode（Diátaxis）

一份 document，一个 mode。两个问题选定它：内容是服务于行动（doing）还是理解（thinking），以及它服务于学习还是工作？

- 行动 + 学习：**tutorial**。
- 行动 + 工作：**how-to**。
- 理解 + 工作：**reference**。
- 理解 + 学习：**explanation**。

把这个罗盘用在整份 document 上，或用在某一个句子上。

**Tutorial：在做中学。** 学习者能否成功是你的责任，不是他们的。开头就说学习者将做出什么，而不是他们将「学到」什么。每一步都产出可见的结果，早出现、常出现。告诉他们应该看到什么：预期的 output、prompt 的变化、那行 log。把解释压到一个从句加一个链接。保持具体。用「我们」来写，用命令式："First, do x. Now, do y."

**How-to：通往目标的步骤。** 解决一个人遇到的问题，而不是一台机器能执行的操作。假定对方有能力，跳过教学。只讲行动：不要跑题、不要背景、不要为完整而完整。那些改用链接。允许分叉和判断："If you want x, do y." 按 task 给指南命名："How to calibrate the radar array"，而不是 "Radar array calibration"。

**Reference：供查阅的事实。** 只描述。没有指令、没有说服、没有观点。干涩、完备、笃定。陈述事实、选项、限制和错误，不带任何对冲。镜像被描述之物的结构，好让 code 与 doc 能对照着导航。把材料放在读者预期的地方。尽可能从 code 生成。

**Explanation：理解与原因。** 一个边界清晰的主题，可以脱离产品单独阅读。每个标题都应能容忍前面隐含一个 "About..."。锚定在一个真实的 why 问题上。给出背景：design decision、历史、约束、备选。观点在这里允许，在别处不允许。

不要混用 mode：tutorial 里不要放 reference 表格，reference 里不要有 tutorial 式的搀扶，how-to 里不要论证。拆开并链接。

## 把句子写给读者（Google developer style）

- 用 "you" 对读者讲话，用现在时。只有确实稍后才发生的事才用 "will"。
- 说清谁做了什么："the compiler checks"，而不是 "is checked"。只有在施动者未知或无关紧要时，被动才没问题。
- 把指令写成命令："Click Submit."。平实地陈述事实。绝不用 "should be done"。
- 把条件放在指令之前："To delete the document, click Delete."
- 常见情形放在前面。例外放在后面。
- 听起来像一个懂行的朋友。不要行话、不要比喻、指令里不要 "please"，流程步骤里绝不用 "simply"、"easy" 或 "quickly"。如果它真的简单，读者就不会在这里了。
- 不要提前宣告（"we will soon support..."），也不要连续几句用同一个短语开头。
- 用能说明链接去向的词来链接：页面标题或一句简短描述。绝不用 "click here"。宁可在本页给一句上下文，也不要链出去。
- 标题承载观点，而不只是主题（"Pick the mode first"，而不是 "Modes"）。用 sentence case。task 类标题是不带动词的动词短语（"Create an instance"）。概念类标题是名词短语。每页一个 h1，不跳级。
- 序列用编号列表，其余用 bullet。用一句完整的话引出列表。各项保持平行结构。
- code 用 code 字体。UI 元素用粗体。使用 serial comma。删掉 "etc."，并在开头说明这个列表并不完整。

## 让每个陈述一次只承载一件事（STE 规则）

- 一句一条指令。其他地方一句一个想法。
- 把超过约 20 个词的指令、以及超过约 25 个词的其他句子拆开。
- 把 warning 或条件放在它所守护的步骤之前："If hot oil touches your skin, injuries can occur."
- 保留 "the" 和 "a"："Remove backup file" 有两种读法。"Remove the backup file" 只有一种。
- 给每个词一个含义、一个职责，然后保持不变。如果 "check" 意为 inspect，就不要再用它表示 restrain。
- 每个动作只选一个词并坚持用："start"，不要这里用 "start"、那里用 "initiate"。
- 把流程写成直接的命令，绝不写成叙述，也绝不用被动："Install the component"，而不是 "the component must be installed"。
- 尽量避免 "-ing" 形式的词。

## 不要让任何一个句子有两种读法（Global English）

- 把 "only" 和 "not" 这类词放在它们所修饰的词旁边："only fails on growth" 与 "fails only on growth" 意思不同。
- 拆开长名词串："the proto import budget check script" 改成 "the script that checks the proto-import budget"。
- 让每个 "it"、"they" 和 "this" 都明确指向一个东西。拿不准时重复名词。绝不用 "this" 或 "which" 指向整个从句。
- 不要省略动词："Phase 1 moves the converters and Phase 2 the runtime" 让 Phase 2 没了动词。给它补一个。
- 保留显示结构的小词，例如 "Ensure that the switch is off" 里的 "that"。绝不用清晰度去换字数。
- 当能避免误读时，在并列中重复冠词："the client and the host"，而不是 "the client and host"，因为它们是两个东西。
- 当一个句子可以有两种分组方式时，说明 "and" 或 "or" 连接的是哪些部分。"Both...and"、"either...or" 和 "if...then" 是免费消歧器。
- 用句号，不用分号。把 em dash 替换成一个新句子。
- 让括号里的文字成为一个完整的语法单位，或自成一句。绝不用 "(s)" 构成复数。
- 不要斜杠：写 "a, b, or both"，而不是 "a/b" 或 "and/or"。
- 在任何地方，每个东西只用一个名字。一份 doc 对同一个东西既说 "the gate"、又说 "the ratchet"、又说 "the budget check"，等于教了三样东西。没有变化的东西不要乱改。
- 跳过习语、口语、拉丁缩写和隐喻。

## 语态与 repo 细节

- 对本 skill 触及的每一份 doc 都套用 **unslop** skill。那个 skill 拥有 slop pattern 目录：AI 词汇、填充、对冲、格式 tell。
- PR description 和 commit message 也是写作。除 Diátaxis 之外的每一层都适用于它们。PR body 是一份 reviewer 一分钟内能读完的简报。不要粘贴 swarm log、SHA 列表或指标表。链接它们。
- 产品 UI 字符串不是文档。那些请用你产品的 copy 指南。
- code 片段用 tab 缩进。写真实路径。让每一处计数或 tree 相关的说法在落地它的那个 commit 上为真，并给出重新生成它的 command。

## 完整示例

Before：

> Configuration of the proto import ratchet budget script parameters is performed via budget.json. Note that it's important to remember that running with --write, which updates the committed budget to reflect the current count, should only be done when lowering it. If exceeded, CI fails.

After：

> `budget.mjs` reads the committed budget from `budget.json` and counts the files that import protos. If the count exceeds the budget, CI fails. Run `budget.mjs --write` only to lower the budget.