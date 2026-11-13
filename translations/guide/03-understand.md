# 第 3 章：修改代码前先理解代码

> 来源：[上游 03-understand.md](https://github.com/cursor/plugins/blob/main/pstack/docs/guide/03-understand.md)。

在不了解代码的情况下修改代码，很容易引入隐蔽回归。对 Agent 来说也是如此。Agent 通常有两类失败方式：误解了用户想要什么，或者没有足够的系统上下文，无法正确完成工作。上一章讨论提示词如何减少第一类问题，本章关注第二类问题。

P-Stack 提供四种理解代码的入口：

- `/how`：解释代码当前是怎样工作的。
- `/why`：追溯代码为什么被设计成现在这样。
- `/teach`：把 How 与 Why 结合成循序渐进的解释。
- `/recall`：重建你自己最近围绕某个主题形成的上下文。

这些能力还会要求 Agent 用可以检查的语言解释自己的判断。这样，即使 Agent 对代码的了解可能比你更多，你仍能监督它的工作。

## 1. 从只读调查开始

当根因不明确时，先要求调查结论，而不是直接要求修复：

```text
/poteto-mode investigate why background jobs time out every few hours. give me what we know, what data you used, and your best hypotheses. don't change any code yet.
```

“暂时不要修改代码”会把任务路由到 Investigation Playbook。该流程使用 `/how` 理解当前行为；如果问题涉及设计动机，再使用 `/why`。最终返回带来源的解释。

如果需要在多个选项中做选择，应提供包含权衡因素的对比表。要求说明“使用了哪些数据”，则有助于把直接证据与猜测分开。当调查结果指向某个修复方向时，应把修复作为一个新任务启动。

## 2. 使用 /how 追踪当前行为

示例：

```text
/how do we dedupe notifications? is there an n+1 when we look up subscribers?
```

提出真正想弄清楚的问题即可。`/how` 会阅读代码，并以资深工程师带新人熟悉子系统的方式解释，包括：
- 运行时调用流程；
- 关键数据类型；
- 不直观的实现细节。

对于大型子系统，它会先并行启动 2–4 个只读探索 Agent；对于范围较窄的问题，则直接阅读和解释。

## 3. 使用 /why 追溯设计历史

示例：

```text
/why was the retry limit set to five? does the reason still hold?
```

`/why` 从版本控制历史开始，再并行查询当前 MCP 能提供的证据类别，例如 Issue Tracker、长文档、团队聊天、可观测性数据、错误追踪和分析数据。

报告应引用证据，区分直接证据与推断。当历史记录不足时，应使用“看起来可能是”等审慎措辞。即使查询没有结果，也应报告空结果，因为“没有留下设计原因记录”本身也是调查结论。

`/how` 和 `/why` 可以组合使用。如果怀疑历史背景解释了当前代码形态，可以要求先 Why、再 How。

## 4. 使用 /teach 真正理解实现

示例：

```text
/teach me how this PR changes retries. convince me it fixes the cause and not the symptom.
```

当普通摘要不够时，`/teach` 会组合 `/how` 和 `/why`（小范围变更可能只运行其中一个），逐步组织成通俗解释，并可通过图示建立理解。

“说服我它修复的是根因而不是症状”这种要求很有价值：它迫使解释形成可检验的论证，而不是单纯带你浏览代码。

它也可以用来审查 Agent 自己的设计选择：

```text
/teach me why you implemented it this way and not with a queue. what did you trade off, and why?
```

要求 Agent 教会你，也会促使它先阅读代码、用证据支撑主张，而不是自信地给出结论后直接结束。

## 5. 使用 /recall 恢复自己的历史上下文

示例：

```text
/recall catch me up on the export work from last week
```

`/recall` 会检索你近期的对话以及共享记录（Issue、既往修复、仍在出现的错误等），形成当前状态和下一步工作的简报。

旧对话中包含新 Agent 不具备的背景，因此重新开始一个旧主题时，可以先恢复上下文，再提供新的输入：

```text
/recall my work on the virtualized list from yesterday, then read this bug report.
```

如果要恢复某一个特定会话，则应使用 Session Pickup Playbook，而不是 `/recall`。

## 6. 使用 Session Pickup 接管之前的工作

当另一个 Agent（或你自己上周）留下了尚未完成的分支时：

```text
/poteto-mode take over this branch. read the decision log, figure out what's done, and continue from there. don't redo finished work.
```

Session Pickup Playbook 将之前的工作轨迹视为重要依据。它会重建分支状态和决策，指出恢复位置，并根据原始目标重新验证继承来的结论，而不是从头重复所有工作。

## 常见陷阱

不要认为“Agent 反正会读代码”，就跳过这些理解步骤。Agent 如果没有先建立行为模型就开始修改，往往会在第一个看似合理的位置修复症状。先运行 `/how`，通常比后续处理第二个 Bug 更省成本。

---

## 本章解读：对 BMC 故障定位的映射

建议把调查过程拆成三种不同问题：

1. **How：当前实际发生了什么？** 例如从 NTP 导入入口追踪到跨板 RPC、接收端方法和持久化调用。
2. **Why：为什么系统设计成这样？** 例如重试次数、同步阻塞、文件锁和启动依赖的历史原因。
3. **Teach：证据是否足以证明我们的解释？** 要求 Agent 解释关键状态变化、异常路径和反例。

历史上下文恢复与代码调查也应分开：Recall 恢复“之前做过什么”，How 解释“现在代码怎样运行”，Why 解释“当时为什么这样设计”。三者不能互相替代。
