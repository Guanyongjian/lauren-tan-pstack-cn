---
name: typescript-best-practices
description: TypeScript best practices。在读取或编辑任何 .ts 或 .tsx 文件时使用。
paths: ["**/*.ts", "**/*.tsx"]
disable-model-invocation: true
---

# TypeScript best practices

先应用 **type-system-discipline** 原则 skill。

| Rule | Summary |
|------|---------|
| Discriminated unions | 用 `kind` 字面量 discriminant 来建模各个 variant，使 impossible state 无法表示。不要用一堆 optional field。 |
| Branded types | 给 primitive 打 brand，用 `& { readonly __brand: "X" }`，使它们不会被混用。在 boundary 处只 validate 一次。brand 来自一个会验证的 type guard（`input is AgentId`），绝不来自 `as`。 |
| Constructive modeling | 把 shape 建成让 illegal value 无法被构造。非空用 `[T, ...T[]]`，偶数长度用 `[T, T][]`，range 用 `start` 加 `duration`。不是 runtime guard，也不是指望 refinement type。 |
| Simplest total type | 只要对它的每种操作都保持 total，就保留 `T[]`。只有当宽松的 type 逼你写 `!`、cast，或「should never happen」的 throw 时，才加强为 `NonEmpty<T>`。 |
| `unknown` over `any` | external data 一律是 `unknown`。 |
| Schemas before guards | 在手工写逐 property 的 type guard 之前，先用仓库的 runtime schema 库，并从 schema 推断 type，例如 `z.infer`。 |
| No `as` casts | 每个 `as` 都是一次迟早发生的 runtime crash。只在 validation 之后才 cast。 |
| Narrowing hierarchy | discriminant switch > `in` operator > `typeof`/`instanceof` > 用户自定义 type guard > `as`。 |
| Type guards | 必须真的验证它声称的东西。说谎的 guard 比 `as` 更糟，因为 bug 藏在一个宣称它安全的名字后面。命名为 `isX` 或 `hasX`。 |
| Exhaustiveness | 在 default 分支里内联 `const _exhaustive: never = x;`，这样新增 variant 时 compiler 会报错。 |
| `satisfies` over `as` | 在不放宽 literal type 的前提下验证 value。 |
| Boundary validation | 在 data 跨入的地方 parse 成具名的 domain type。`Record<string, unknown>`（无论怎么写）到那次 parse 为止。内部则信任 type。见 **boundary-discipline** 原则 skill。 |
| Schema-derived types | 在声明新 interface 之前，先想到 `Pick`/`Omit`/`Parameters`/`ReturnType`/`Awaited`/`typeof`。 |
| Object args | 传 object，而不是 positional，这样 argument 的顺序本身就说明了含义。hot path（逐帧 render、tokenizer、parser）上除外。 |
| Real tests | 能跑的就不要 mock。优先用框架真实的 test primitive，配合 leak/disposable 检查，并在运行中的 build 里验证 UI。只 mock 你在本地跑不了的东西。 |
| Structured telemetry | 优先用带足够 context 的 structured logger 诊断，能凭一个 id 去 debug。ship 出去的 code 里不要 `console.log`。 |

Examples：`references/patterns.md`。