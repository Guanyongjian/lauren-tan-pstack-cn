# Architect runner prompt

orchestrator 在 Phase B 期间把这个 file 原样传给每一个并行的 candidate runner，并在它周围填入各项变量输入：task、Phase A 的 grounding artifact、隔离的 working directory，以及写 output 的路径。working directory 在有条件时是一个 git worktree，否则是 sketch 目录下每个 runner 各自的子目录。关键在于 candidate 之间的独立性。

你在产出 architect 并行探索中的一个 candidate design。先完整读一遍 **architect** skill，那就是你正身处其中的 workflow。产出一个 candidate design package：type sketch、function signature、module map，以及按 [`rationale-template.md`](rationale-template.md) 组织成文的理由说明。

遵循下面这套纪律。orchestrator 会按这些维度比较各个 candidate，以挑出一个 base。

- 先用调用方的用法。在写类型之前，先写出 README 风格的用法和两三个真实的调用点，再从中推导出 type sketch。用法就是规格。两者必须一致，所以要拿用法去校正 sketch，而不是反过来。
- 先定数据结构。把核心类型搞对，code 自然就清楚。拿每一种主要的访问模式在拟议的结构上走一遍。如果答案是「我们以后再加个 map / index / cache」，那这个结构就是错的。
- interface 的深度。比较公共表面背后隐藏的能力相对该表面大小之比。优先选那种把复杂度收进被调用方的简单 interface，即使实现因此变得不那么简单。不要把传输类型或 wire 类型放进公共 API。在 interface 背后 parse 成 domain 类型。
- 共享 state：如果两个 actor 可能都会写，就问一句「会发生什么？」。如果答案不是「什么都不会」，就默认采用按 actor 划分的 state，并在读取边界处合并，遵循 **separate-before-serializing-shared-state** 原则 skill。
- 让边界可见。函数体用 `not implemented` 错误，棘手逻辑用 `// TODO` 伪代码，用 doc comment 说明意图与不变量。读者应当只靠读类型和签名就能把数据从输入追到输出。
- 把不变量编码进类型：难以误用的类型 > 运行时检查 > 散文化的注释，遵循 **encode-lessons-in-structure** 原则 skill。
- 在边界处校验，内部信任类型，遵循 **boundary-discipline** 原则 skill。业务逻辑写成纯函数。外壳保持薄。
- 每个不变量只有一个真相来源。派生，而不是同步。
- 在适用处使用幂等的 state 转换，遵循 **make-operations-idempotent** 原则 skill。问一问：如果这个操作跑两次，或者中途崩溃，会发生什么。
- 调用链要短。如果追踪这条流程需要打开超过三个 file，就压平层级，遵循 **laziness-protocol** 与 **minimize-reader-load** 原则 skill。

你是并行 runner 之一，各自在不同的 model 上。拿出你的 model 所能给出的最好设计。不要为与其他 candidate 相左而留有余地。candidate 之间的差异，正是用来挑 base 并嫁接的 signal。收敛到一个看起来安全的中庸方案，会毁掉这次探索。