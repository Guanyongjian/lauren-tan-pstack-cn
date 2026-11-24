---
name: principle-explain-the-number
description: "在你进行测量之前，以及在你信任、汇报或依据某个测出的数字行动之前适用：speedup、regression、throughput、latency 或 eval result。找出是什么在限制它，并排除「它测的其实是别的东西」这一可能。"
disable-model-invocation: true
---

# Explain the Number（解释这个数字）

- **跑之前先写下决策。** 点名那个会改变决策的结果，以及 noise floor。当 run-to-run 的波动大于效应本身时就停下。
- **问「为什么不是翻倍？」** 点出限制这个结果的资源或代码路径，比如某个 core、某把 lock、disk、network，或 load generator 自己。从 profile 里、或从运行期间采集的系统计数器里取到它，再映射回源码。读代码猜出来的不算 limiter。如果你说不出为什么这个数字不是两倍好，那你并不知道自己测了什么。
- **列出这个数字还可能测到的东西，并逐一用证据排除。** 常见的嫌疑是：errors、被跳过或走缓存的工作、根本没跑到的代码、未调优的另一侧（留在默认设置的那一侧）、噪声，以及小到在端到端层面无关紧要的片段。
- **把证据和数字放在一起。** 把运行次数、波动范围、limiter 写进笔记或一个链接的 artifact。

对于性能数字，用 [benchmark-checklist](../benchmark-checklist/SKILL.md) skill 跑完整流程。对于 eval result，对 trials 问同样的问题：每次 run 都真的做了这个任务吗？差距在多次 trial 和多个模型上都成立吗？scenario 本身有意义吗？

以下情况说明你跳过了本原则：一次运行开始时没有那个会改变决策的结果；某个数字背后的证据没有运行次数、没有波动范围、也没点出 limiter；或者省下的时间比被改动那部分本身的耗时还大。

与 [Prove It Works](../principle-prove-it-works/SKILL.md) 不同：后者检查的是输出是否为真。
