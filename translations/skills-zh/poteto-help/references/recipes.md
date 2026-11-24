# 值得复制的 prompt

替换为真实的路径、skill 和完成检查。非正式措辞即可。

## 理解

- `/poteto-mode 阅读 <thread>。用你自己的话，以平实的英文重述根本问题。`
- `/in-your-own-words <long or messy ask>`
- `/sharpen <the prompt you're about to send>`
- `/poteto-mode 调查 <symptom> 的原因。告诉我已知信息、使用的数据以及最可能的假设。先不要改任何 code。`
- `用 /how 理解 <subsystem>，再用 /why 查明它最近为什么出问题。`
- `/recall 我上周关于 <topic> 的工作，然后阅读 <issue>。`
- `/teach 我为什么这样实现，而不是 <other way>？做了什么权衡？`
- `/poteto-mode 接管这个 branch。阅读 decision log，找出已完成的工作并继续。不要重做已完成的工作。`

## 构建

- 缺陷：`/poteto-mode <symptom>。先复现，再修复并验证。`
- 应用缺陷：`/poteto-mode 用 /verify-<app> 复现这个问题。如果 main 上也能复现，就修复它，并用视频向我证明。`
- 有低成本 test 的缺陷：`/poteto-mode 先复现 <bug>。如果有低成本的 test path，就用 /tdd。然后修复并重跑。`
- 功能：`/poteto-mode 添加 <behavior>。<current output> 必须保持逐字节一致。两者都要验证。`
- 重构：`/poteto-mode 把 <code> 移到一个 module 中，行为零变化。先记录当前输出，并证明修改后它仍未变化。`
- 性能：`/poteto-mode <operation> 耗时 <time>（在 <fixture> 上）。追踪它，修复测量到的原因，并向我展示前后对比。`

## 设计与计划

- `/poteto-mode 为 <feature> 制作几个方案原型。截图或录视频供我比较。`
- `/poteto-mode 我们需要 <feature>。先用 /architect 设计，并用原型回答未决问题。继续之前让我审查。`
- `/poteto-mode 先写一份教程，说明我会如何使用 <new package>。然后用 /teach 解释它为什么胜过当前方案。`
- `让 /arena 对这个 thread 和我们的方法给出第二意见。`
- `/poteto-mode 把这个设计转成计划。PR 要小且可验证，每个都有自己的验证步骤。`
- `/poteto-mode 计划把 <library> 迁移到 <target>。PR 要小且可验证。结果必须与原始版本完全一致，包括 bug。`

## 审查与交付

- `/interrogate 审查整个 branch，但保持怀疑态度。先不要改任何东西。除非是真实 bug 或 regression，否则不要挑细枝末节。` 也要阅读 Dropped 列表。
- `/create-formal-verification-skill 证明 <property> 在 <module> 中成立，即使 <steps> 交错执行或重试。` 此后对该 code 做 merge 或 refactor 后：`/maintain-formal-verification-skill`。
- `/swarm 按各自的 check script 检查 <dir> 下的每个 package。每个 package 一个 worker。汇总一份 report。`
- `/poteto-mode 创建 PR。commit 要小且有序，description 中附上证据。`
- `/poteto-mode 跟进这个 PR，直到检查全绿。` 只查状态时：`/poteto-mode 检查 PR <number>。还有未解决的事项吗？`
- `/poteto-mode 落地整个 stack。`

## 离开与回来

- `/poteto-mode 我要去睡了。目标是 <goal>；在基于 <base> 的新 worktree 中工作。完成意味着 <checks>。保留 decision log。commit 前不要问我。用 /loop 直到完成。如果几小时后确实卡住，就停止并写明原因。`
- `/show-me-your-work 让我了解你昨晚做了什么。` 先阅读其中的 Attention 一节。
- `/ketchup` 让你了解自你上一条消息以来这个 chat 的进展，并列出每一个等待你处理的 call。
- `/poteto-mode 对这个 queue 启用 full autopilot。每一项都相互独立。`
- `/poteto-mode autopilot 这些改动，但不要 merge。我会 land 它们。`
- `/reflect 记录我们学到的东西，让下一次 run 不再重蹈覆辙。` 只批准会改变未来决策的 edit。
- `/bro` 用平实的话重述上一条回复。
