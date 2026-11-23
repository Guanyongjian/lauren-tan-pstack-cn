---
name: principle-fix-root-causes
description: "调试时适用。把每个 symptom 追溯回系统第一次出错的位置，并就地修复。只有当 guard 处理的状态是合法状态时，guard 才算是 fix。"
disable-model-invocation: true
---

# Fix Root Causes（修根因）

调试时，要修 **fault 本身**，而不是修 fault 显形的那个位置。symptom 是错误状态变得可见的地方；root cause 则是系统第一次做了不该做的事、或第一次没有处理它本该处理的状态的地方。

**Why:** 只修 symptom 会掩盖证据，并让 fault 继续在其他地方冒头。每做一次，系统就更难推理——因为代码从此背着一个谁也没点名的 bug 的 workaround。

**Pattern:**

- 先复现。
- 每一步都问「why」，直到答案落到某个具体的错误决策上，而不是上一个决策的后果。
- 卡住就 instrument。读真实的 error 和真实的 state，不要猜。
- 判断触发 symptom 的那个 state 是否合法。如果系统**可能**处于该 state，那么在这个 state 上崩掉的代码就是 root cause，就地处理该 state 才是 fix。如果该 state 本就不该存在，那么在崩溃点加 check 只会把 bug 藏起来——去找**产生**该 state 的东西。guard、retry、吞掉 error、clamp 取值、丢弃 state，都是常见的藏 bug 手法。
- 若故障只在重启后出现，优先怀疑持久化 state：config files、cache、lock file、serialized state。
- 找 **pattern**，不只找 instance。把同一类 fault 的所有位置都找出来，一并修掉。
- 若一个 workaround 需要一整段注释才能自圆其说，那说明代码错了。修代码，不要修注释。
- 若决定性的 fact 是深挖才发现的，就提出那个便宜的、常开的 signal，让它在第一眼就能暴露出来。
