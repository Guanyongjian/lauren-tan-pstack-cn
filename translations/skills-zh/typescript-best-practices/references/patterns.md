# TypeScript patterns

`SKILL.md` 中每条规则的代码示例。底层原则不依赖语言。见 **type-system-discipline** 和 **boundary-discipline** 原则 skill。

## Branded types

给 primitive 打 brand，使它们不会被混用。在 boundary 处只 validate 一次。下游 code 信任 type。

```ts
type AgentId = string & { readonly __brand: "AgentId" };

function isAgentId(input: string): input is AgentId {
  return isUUID(input);
}

function parseAgentId(input: string): AgentId {
  if (!isAgentId(input)) throw new Error(`Invalid agent id: ${input}`);
  return input;
}

function focusAgent(id: AgentId): void {
  /* input is trusted */
}
```

使用 `readonly __brand: 'X'` 这一形式。不要另造约定。

## Discriminated unions

用字面量 discriminant 建模 variant。每个 variant 共享字段名，而每个 variant 的值唯一，因此不可能的组合无法表示。

```ts
// Don't. Boolean + optionals lets contradictory states exist.
type DiffState = { loading: boolean; diff?: GitDiff; error?: string };

// Do. Only valid states exist.
type DiffState =
  | { kind: "loading" }
  | { kind: "ready"; diff: GitDiff }
  | { kind: "error"; error: string };
```

选择一个 discriminant 名称（`kind`、`type`、`tag`）并坚持使用。

## Constructive modeling

用全部合法的组成部分构建 type，而不是用 runtime 检查限制一个宽松的 type。

通过 variadic tuple 表示非空：

```ts
type NonEmpty<T> = [T, ...T[]];

// Don't: T[] plus a length check every caller must repeat
function pickWinner(entries: string[]): string {
  if (entries.length === 0) throw new Error("no entries");
  return entries[Math.floor(Math.random() * entries.length)];
}

// Do: an empty value of the type can't exist
function pickWinner(entries: NonEmpty<string>): string {
  return entries[Math.floor(Math.random() * entries.length)];
}
```

普通 `T[]` 到达时，用 guard 收窄一次。这个事实随后由 type 携带：

```ts
const isNonEmpty = <T>(arr: T[]): arr is NonEmpty<T> => arr.length > 0;
```

用 pair 表示偶数长度：

```ts
type Pairs<T> = [T, T][];
```

用开始时间加 duration 表示时间范围：

```ts
// Don't: a comment holds the invariant
type TimeRange = { start: Date; end: Date }; // start <= end

// Do: a negative range can't be written; derive end when needed
type TimeRange = { start: Date; durationMs: number };
```

让 `durationMs` 保持普通 number。只有当原始 number 可能被传给预期 duration 的位置时，才按 Branded types 给它打 brand，不要条件反射式地打 brand。选择让坏状态无法构造的表示，然后在其上暴露所需的读取方式（`pairs.flat()`、一个 `rangeEnd()` helper）。

## Simplest total type

不要强化一切。只要对它的每种操作都是 total，就保留 `T[]`：

```ts
const sum = (xs: number[]) => xs.reduce((a, b) => a + b, 0); // [] is 0, fine
```

当宽松的 type 迫使你在使用点说谎时，再强化。迹象是 `!`、`arr[0] as T`，以及一个「should never happen」的 throw：

```ts
// Don't: partiality smuggled past the compiler
function newestSession(sessions: Session[]): Session {
  return sessions.at(0)!;
}

// Do: strengthen the input; the assertion disappears
function newestSession(sessions: NonEmpty<Session>): Session {
  return sessions[0];
}
```

把结果放宽为 `Session | undefined` 是另一种 total signature。

## `unknown` over `any`

外部 data 一律是 `unknown`。使用前收窄。

```ts
// Don't
function handle(input: any) {
  return input.foo.bar;
}

// Do
function handle(input: unknown) {
  if (typeof input === "object" && input !== null && "foo" in input) {
    // narrowed; compiler verifies access
  }
}
```

外部来源包括 RPC payload、`JSON.parse`、`postMessage`、IPC、文件内容、环境变量、数据库结果。

## Schemas before hand-rolled guards

在为外部 data 手工编写逐 property 的 type guard 之前，先寻找仓库的 runtime schema 库和现有 schema。让一个 schema 拥有 validation，并从中推导 TypeScript type。不要同时维护一个 schema、一个重复 interface 和一个可能逐渐不一致的 guard。

```ts
import { z } from "zod";

const UserSchema = z.object({
  id: z.string().uuid(),
  role: z.enum(["admin", "member"]),
});

type User = z.infer<typeof UserSchema>;

function parseUser(input: unknown): User {
  return UserSchema.parse(input);
}
```

当失败是预期分支时，使用 `safeParse`。仓库使用其他 schema 库时，使用等价的 inference helper。不要为了一个 guard 新增 schema dependency。这条规则优先使用 codebase 已经信任的 schema 系统。

## No `as` casts

每个 `as` 都是潜在的 runtime crash。只有在 type system 验证了 claim 之后才 cast。

```ts
import { z } from "zod";

// Don't
const user = data as User;

// Don't
function isUser(data: unknown): data is User {
  return typeof data === "object" && data !== null && "id" in data;
}

// Do
const userSchema = z.object({ id: z.string(), name: z.string() });
type User = z.infer<typeof userSchema>;

function parseUser(data: unknown): User {
  return userSchema.parse(data);
}
```

当 type 先存在时，用它要证明的 type 标注 validator。这样 compiler 会拒绝证明内容少于该 type 的 validator。从下面的 object 中删掉 `name`，赋值就无法编译。

```ts
type User = { id: string; name: string };

const userSchema: z.ZodType<User> = z.object({ id: z.string(), name: z.string() });
```

在重构现有 code 中的 `as` 时，找出 TypeScript 无法推断的原因：

- 缺少 discriminant：添加一个，改用 discriminated union。
- 来源 type 过宽（例如 `Record<string, unknown>`）：收窄它。
- 未标注 type 的 boundary：用拥有该 shape 的 schema 解析。只在不存在 schema 的地方添加 schema。
- 确实无法表达：使用 branded type 或 `satisfies`。

## Narrowing hierarchy

从最佳到最后手段：

1. **Discriminated union switch / if。** Compiler 自动收窄。
2. **`in` operator。** `"key" in obj` 收窄到包含该 key 的 variant。
3. **`typeof` / `instanceof`。** 用于 primitive 和 class instance。
4. **用户自定义 type guard。** 上述方式不够时使用。
5. **`as` cast。** 仅在 validation 之后。

```ts
function area(s: Shape): number {
  if ("radius" in s) return Math.PI * s.radius ** 2; // narrowed to circle
  return s.width * s.height; // narrowed to rect
}
```

## Type guards

guard 必须真正验证它声称的东西。说谎的 guard 比 `as` 更糟。

```ts
function isCircle(s: Shape): s is Shape & { kind: "circle" } {
  return s.kind === "circle";
}
```

可能时优先使用 discriminant narrowing。

## Exhaustiveness

在 default 分支中，把 discriminant 赋给一个 `never` 类型的局部变量。

```ts
// Value-returning switch
function area(s: Shape): number {
  switch (s.kind) {
    case "circle":
      return Math.PI * s.radius ** 2;
    case "rect":
      return s.width * s.height;
    default: {
      const _exhaustive: never = s;
      return _exhaustive;
    }
  }
}

// Void switch
function handle(s: Shape): void {
  switch (s.kind) {
    case "circle":
      drawCircle(s);
      break;
    case "rect":
      drawRect(s);
      break;
    default: {
      const _exhaustive: never = s;
      void _exhaustive;
    }
  }
}
```

返回值的 switch 使用 return 形式，语句 switch 使用 void 形式。

## `satisfies` over `as`

`satisfies` 在不放宽字面量 type 的情况下进行验证。

```ts
// Don't. Widens, loses literal types.
const config = { theme: "dark", cols: 3 } as Config;

// Do. Validates AND preserves literal types.
const config = { theme: "dark", cols: 3 } satisfies Config;
// config.theme is "dark" (literal), not string
```

## Boundary validation

在 data 跨入的位置只验证一次。内部信任 type。见 **boundary-discipline** 原则 skill。

- **传输格式**（proto、JSON-RPC）：使用 `ignoreUnknownFields` 解析，使向前兼容的变化不会破坏旧 client。
- **持久化 JSON：** 带版本的 blob，并在解析外层加 try/catch。
- **不要**在调用链深处重复验证。

## Schema-derived types

当 `.proto`、OpenAPI spec、GraphQL schema 或数据库 migration 已定义 shape 时，从生成的 type 推导，而不是重复定义。

```ts
// Don't. Duplicate shape, drifts when the schema changes.
type CheckSummary = {
  totalCount: number;
  checks: { name: string; status: string }[];
};
function renderChecks(s: CheckSummary) {
  /* ... */
}

// Do. Derive from the generated schema type.
import type { ChecksMessage } from "<generated module>";
function renderChecks(s: Pick<ChecksMessage, "totalCount" | "checks">) {
  /* ... */
}
```

在编写新 interface 之前，先考虑 `Pick`、`Omit`、`Parameters`、`ReturnType`、`Awaited`、`typeof`。

## Object args

```ts
// Don't. Swap two args, still compiles.
openFile(uri, {
  startLineNumber: 10,
  startColumn: 1,
  endLineNumber: 10,
  endColumn: 1,
});

// Do. Order-independent, self-documenting.
openFile({
  uri,
  selection: {
    startLineNumber: 10,
    startColumn: 1,
    endLineNumber: 10,
    endColumn: 1,
  },
});
```

在 hot path 上跳过：逐帧 render、tokenizer、parser，以及任何分配成本重要的 tight loop。
