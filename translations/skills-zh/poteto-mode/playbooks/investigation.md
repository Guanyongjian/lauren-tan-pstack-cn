### Investigation

**你拥有这个答案。规划、路由、撰写。**

Investigation 请求是 read-only 的。它们产出一个带引用的解释或一个建议，而不是一处 code 改动。

1. 路由经 **how** skill。对于动机类问题，还要路由经 **why** skill。
2. throughput checkpoint 保持一行：`throughput checkpoint: n/a, read-only investigation`。
3. 产出 `how` 形状的 output（Overview / Key Concepts / How It Works / Where Things Live / Gotchas）；若请求是在若干备选之间做决定，就产出带 tradeoff 表格的建议。
4. 对 reply 套用 **unslop** skill。

不开 PR、不 babysit、也不动用 `architect`，除非这次 investigation 先于一次 code 改动。若确实如此，就交回 user 并重新路由到 Bug fix 或 Feature。

**Reply：** investigation 的 output。对于「are we sure?」这类回答，附上你真实的判断及理由。如果前提错了就反驳（见 Autonomy）。