---
name: correct
description: "找出 agent 在这个 repo 里反复犯的 mistake，并让每一个都不可能再犯。先试 architecture，再试 type，再试一个 error message 里直接点名 fix 的 lint，再试 test，最后才写 doc。每个 check 都要证明它能在一个真实的历史 mistake 上失败。operator 每次纠正你，就重复一遍这件事。用于 /correct。"
disable-model-invocation: true
---

# Correct

operator 一直在为同样的 mistake 反复纠正这个 repo 里的 agent。改造 repo，让下一个 agent 犯不了这些错。

假定每个 contributor 都是一个 agent：它只看得到自己打开的 file、复制最近的例子、走能编译通过的最短路径。把 repo 设计成「从单个 file 看是对的改动，对整个 repo 也是对的」。

## 找出 mistake class

首先，读最近的 commit、revert、review comment、agent instruction file，以及解释 workaround 的 comment。把 mistake 归类。一个 class 出现两次才算成立。

## 在能生效的最高层次上修掉每个 class

1. **用 architecture 消灭它。** 让每一片 state 只有一个 owner，每项 task 只有一条被支持的做法。把内部实现藏起来，让错误的 import 直接失败。用单一 source of truth 取代手工同步的 list。删掉 agent 会去复制的旧做法和 dead code。
2. **用 type 强制它，让坏 state 写不出来。** 如果坏 code 仍能通过编译，就加一个 lint 或 CI check，让它的 error 直接点名该用哪个 file、type 或 function。如果这个 pattern 已经很普遍，就只在改动增加了更多时失败。
3. **测 behavior。** 任何 test，如果它检查的 behavior 坏掉时仍然通过，或只有 internal 变化时就失败，那就修掉或删掉它。
4. **最后才写 doc 或 agent rule，且只针对 judgment call。** agent 跳过它们时什么都不会失败。

## 修，并证明

然后现在就修掉最频繁的几个 class，每个 class 一个 commit。证明每个新 check 都能在一个真实的历史 mistake 上失败。本地和 CI 跑同一条命令。exception 写在出问题的那一行，附上理由、过期日期和人的批准。

## 维护 rule 表

最后，在 agent instruction file 里维护一张表，把每条 rule 与强制它的东西配对。当 operator 纠正你时，修掉 mistake 并加上 rule。如果 rule 早就存在、却没有任何东西强制它，那就是重复犯，要在同一次改动里按最高层次修掉。一旦某个 mistake 不可能再发生，就把对应的 rule 删掉。

**Reply：** 每个 class 给出它的 evidence、你选的层次，以及为什么更高层次做不到。
