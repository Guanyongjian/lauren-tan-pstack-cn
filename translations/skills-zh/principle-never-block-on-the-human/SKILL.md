---
name: principle-never-block-on-the-human
description: "在 reversible 的 work 上想问「我要不要做 X？」时适用。"
disable-model-invocation: true
---

# Never Block on the Human（绝不阻塞等人）

human 是异步监督的。agent 必须保持不被阻塞。做出合理的 decision，继续推进，让人在事后 course-correct。既然 code change 是 reversible、reviewable 的，做错一个 decision 通常比 blocking 的代价更低。

- 先做，再呈现。把活儿干完，展示 result。不要问「我要不要做 X？」——直接做 X，并解释 why。
- 让系统 self-healing。发现问题时 log 下来，并在下一轮修掉。
- irreversible action（force-push、删除 production data、发送 external message）仍然需要 confirmation。
- reversible action（写 code、编辑 note、拆分 task）应当直接进行，不要 blocking。
- product direction 来自 human。execution 不该 blocking。
