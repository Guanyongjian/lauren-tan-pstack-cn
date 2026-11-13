# 第 5 章：实现变更并清理代码差异

> 来源：[上游 05-build-and-clean.md](https://github.com/cursor/plugins/blob/main/pstack/docs/guide/05-build-and-clean.md)。

各类实现 Playbook 有一个共同原则：描述你观察到的现象，让 Playbook 要求相应证据。本章说明常见开发任务应如何写提示词，以及如何保持代码差异（Diff）易于审查。

## 1. 为不同开发任务提供已知事实

### Bug 修复：描述症状，先复现

```text
/poteto-mode this command emits two records after a retry. repro first, then fix and verify.
```

### 功能开发：说明目标行为和必须保持不变的行为

```text
/poteto-mode add a --json flag. text output stays byte-identical. verify both forms.
```

### 重构：在调整结构前固定现有行为

```text
/poteto-mode move parsing into one module, zero behavior change. record the current output first and prove it's unchanged after.
```

### 性能优化：提供测量数据，不要只说“感觉慢”

```text
/poteto-mode startup takes 1.8s on this fixture. trace it, fix the measured cause, show me before and after.
```

这些任务会分别路由到 Bug Fix、Feature、Refactoring 和 Perf Issue Playbook。Playbook 会补充你没有在提示词里写出的必要步骤：
- Bug：先复现，再修复；
- Feature：实现前明确数据形状；
- Refactoring：先固定行为，再改变结构；
- Perf：先分析性能数据，再优化。

## 2. 使用 Hillclimb 持续优化单一指标

如果要持续改进某一个数值指标，可以使用 Hillclimb Playbook。给出：
- 要优化的指标；
- 目标值；
- 最少尝试次数或尝试下限。

它会在固定的测量工具链下，一次验证一个假设，只保留真正带来收益的改动，撤销没有收益的尝试。

Perf Issue 和 Hillclimb 都会使用 `/benchmark-checklist` 检查测量结果。Perf Issue 会核验基线和每次优化后的数值；Hillclimb 则在冻结测量工具链前先核验它。

## 3. 先诊断，再决定是否修复

有时你只想知道原因，暂时不希望 Agent 修改代码。

- **Runtime Forensics**：针对正在运行的程序进行诊断，例如内存泄漏、空闲 CPU 持续占用或视觉异常。
- **Trace Forensics**：分析已经采集的性能文件，例如 CPU Profile、Trace、Spindump 或 Heap Snapshot，并把热点映射回源码。

两者都以诊断为交付物，而不是直接修改代码。

示例：

```text
/poteto-mode here's a cpuprofile from the slow startup. tell me where the time goes and which source lines own it. no fix yet.
```

## 4. 使用 /tdd 先写失败测试

当 Bug 有成本较低的本地测试路径时，提示词甚至可以非常短：

```text
/tdd implement
```

`/tdd` 会先编写一个因预期原因失败的最小测试，再实现修复，最后重新运行测试。

如果测试需要大规模搭建 Harness 或依赖脆弱 Mock，Skill 应说明原因，并改用最接近的可执行检查。不要为了遵循 TDD 而强行创建低价值测试；真实命令验证可能更有说服力。

## 5. 显式加载 TypeScript 规则

`typescript-best-practices` 将类型系统原则转化为具体规则，例如：
- 使用判别联合类型；
- 在边界处使用 `unknown`；
- 穷尽处理所有变体；
- 从 Schema 派生类型。

该 Skill 不会自动加载。处理 `.ts` 或 `.tsx` 文件时，应明确调用它。

## 6. 提交前清理差异

Opening a PR Playbook 会在每次提交前对 Diff 运行 `/deslop`，并对 PR 描述和 Commit Body 使用 `/unslop`。

注意：上游说明 `/deslop` 来自 `cursor-team-kit` 插件，并非 P-Stack 自带能力。如果没有该 Skill，可以用自然语言要求 Agent 清理：
- 只是在叙述代码行为的注释；
- 没有依据的防御性判断；
- 已失效的兼容逻辑；
- 与当前任务无关的改动。

对于文档和其他文字，可以使用：

```text
/unslop the readme changes, no emdashes
```

它也能理解更短的指令，例如“unslop that, tighten it”。

## 7. 使用 /no-comments 独立审查注释

注释应由没有编写这些注释的 Agent 单独审查。作者往往会本能地为自己添加的注释辩护，因此上游使用新 Agent 执行：

```text
/no-comments the diff
```

`/no-comments` 会启动 Comment Sicko，一个只读审查角色。它的保留范围很窄：
- 法律或许可证头；
- 定义公共 API 契约的文档注释；
- 解释代码本身无法表达的外部约束或 Issue/RFC 链接；
- 由无法改变的外部依赖、平台、供应商或协议强制要求的非显而易见行为。

其他注释通常应删除。若自有代码中的行为令人意外，不应仅靠注释解释，而应把代码重构得更清楚。对于声称“不能删除”的注释，Skill 会考虑将约束编码为类型、测试或 Lint 规则。

职责需要区分：
- `/deslop`：清理代码中的低质量内容；
- `/unslop`：清理文字表达中的冗余；
- `/no-comments`：让独立审查者检查注释是否有必要。

## 常见陷阱：清理不是可选的美化工作

包含大量叙述性注释和无效防御代码的 Diff，会让审查者觉得变更尚未完成；多余代码也可能成为下一处 Bug 的藏身之处。如果 Diff 显得臃肿，应在提交前清理，而不是等 Review 指出问题后再处理。

---

## 本章解读：对 BMC/Lua 代码审查的意义

可将本章转化为一条提交前流水线：

1. 明确行为变化与不变量；
2. 能复现的 Bug 优先建立失败用例；
3. 结构调整前保存基线输出；
4. 性能问题必须有可重复的测量基线；
5. 清理无效注释、死代码和无依据的保护分支；
6. 由独立 Agent 检查注释和 Diff；
7. 在真实目标环境验证，而不是只凭“编译通过”结束。

对 BMC 代码尤其要避免机械删除协议约束、硬件时序说明和公共接口契约。P-Stack 的“少注释”原则不能覆盖安全、协议、硬件和项目规范中的强制要求；应把必要约束转化为类型、测试、接口契约或准确的说明。
