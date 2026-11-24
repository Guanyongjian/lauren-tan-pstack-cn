# 实现这次改动并清理 diff

那些 build playbook 共享同一套纪律。你说出你观察到的，让 playbook 去索要证据。本页展示每个常见的 build 任务该往 prompt 里放什么，然后是那个让 diff 保持可 review 的清理习惯。

## 用你知道的东西给每个 build playbook 写 prompt

一段 bug prompt 陈述 symptom，并要求先来一次复现：

```text
/poteto-mode this command emits two records after a retry. repro first, then fix and verify.
```

一段 feature prompt 陈述行为，以及什么绝不能变：

```text
/poteto-mode add a --json flag. text output stays byte-identical. verify both forms.
```

一段 refactoring prompt 在结构移动之前把行为钉住：

```text
/poteto-mode move parsing into one module, zero behavior change. record the current output first and prove it's unchanged after.
```

一段 perf prompt 陈述测量值，而不是一个印象：

```text
/poteto-mode startup takes 1.8s on this fixture. trace it, fix the measured cause, show me before and after.
```

这些都各自路由到它的 playbook（[Bug fix](../../skills/poteto-mode/playbooks/bug-fix.md)、[Feature](../../skills/poteto-mode/playbooks/feature.md)、[Refactoring](../../skills/poteto-mode/playbooks/refactoring.md)、[Perf issue](../../skills/poteto-mode/playbooks/perf-issue.md)），而 playbook 会补上你没打出来的那些步骤：修之前先复现、实现之前先点名 data shape、重构之前先钉住行为、优化之前先 profile。

要对某一个数字做持续的改进，有 [Hillclimb playbook](../../skills/poteto-mode/playbooks/hillclimb.md)。给它指标、一个目标，以及尝试次数的下限，它就用一套冻结的测量 harness 一次一个假设地循环。它留下胜出的，其余全部回退。

两个 perf playbook 都会对自己的数字跑 [`/benchmark-checklist`](../../skills/benchmark-checklist/SKILL.md)。Perf issue 审查它的 baseline 及其后的每一个数字，Hillclimb 在冻结它的 harness 之前先审查它。[验证并交付](./06-verify-and-ship.md#vet-a-measured-number-with-benchmark-checklist)说明了你自己该在什么时候输入它。

有时你想要在任何修复之前先拿到成因。对一个活着的 symptom，例如一处泄漏、一次 idle CPU spin 或一个视觉上的毛刺，[Runtime forensics playbook](../../skills/poteto-mode/playbooks/runtime-forensics.md)给运行中的进程加上 instrumentation。对一份你已经抓下来的 profile，[Trace forensics playbook](../../skills/poteto-mode/playbooks/trace-forensics.md)读这份 artifact，并把热点帧映射到源码。两者都交回诊断，而不是修复：

```text
/poteto-mode here's a cpuprofile from the slow startup. tell me where the time goes and which source lines own it. no fix yet.
```

## 用 `/tdd` 先写失败的 test

当一个 bug 有廉价的本地测试路径时，整段 prompt 可以是两个词：

```text
/tdd implement
```

在有上下文的场合，这就够了。[`/tdd`](../../skills/tdd/SKILL.md)写出因为预期原因而失败的那个最小 test，然后修复，然后重跑该 test。如果一个 test 会需要大范围的 harness 搭建或脆弱的 mock，该 skill 会说明这一点，并改用最接近的可执行检查。不要在有更强的真实命令做证据的地方硬塞一个 test。

## 按名字加载 TypeScript 规则

[`typescript-best-practices`](../../skills/typescript-best-practices/SKILL.md)把类型系统的原则落成具体规则：可辨识联合、边界处的 `unknown`、穷尽的 variant、从 schema 派生的类型。它不会自己加载，所以当 task 涉及 `.ts` 或 `.tsx` file 时，输入 `/typescript-best-practices`。

## 提交之前先清理

[Opening a PR playbook](../../skills/poteto-mode/playbooks/opening-a-pr.md)在每次 commit 之前对 diff 跑 `/deslop`，并对 PR 描述与 commit 正文施加 [`/unslop`](../../skills/unslop/SKILL.md)。`/deslop` 随 `cursor-team-kit` plugin 发布，不在 pstack 里。如果你没有它，就用平实的话要同样的结果：移除叙述性的注释、没有依据的 guard、死掉的兼容路径，以及无关的编辑。

对 prose，`/unslop` 接受一个目标外加你有的任何额外规则：

```text
/unslop the readme changes, no emdashes
```

你会攒出自己的简写。该 skill 能从 `unslop that, tighten it` 这类极简的 prompt 里读懂意图。

## 用 `/no-comments` 剥掉注释

注释需要单独过一遍，而且不该由写它们的那个 agent 来干。作者会为自己的注释辩护，就像你会为你的辩解一样。所以在 review 之前，把它们交给全新的眼睛：

```text
/no-comments the diff
```

[`/no-comments`](../../skills/no-comments/SKILL.md)起 [Comment Sicko](../../agents/comment-sicko.md)，一个 read-only 的 reviewer，它的保留清单很短：license 头、公共 API 上的 doc comment、解释 code 无法表达之事的链接、由你无法改造的外部依赖所强加的行为。其余一律删掉。你自己 code 里的一个意外，不给这种豁免。那条注释会作为一条 refactor flag 回来，而 `/no-comments` 会把它所接受的 flag 从根因上修好。当一条注释声称某个约束——「do not remove」——该 skill 会提议把这个主张编码成类型、test 或 lint。无论走哪条，注释都出来。

这个分工值得记清。`/deslop` 把 slop 从 code 里清掉，`/unslop` 把它从 prose 里清掉，而 `/no-comments` 把注释交给一个没写它们的 reviewer。

**陷阱：** 清理不是可选的润色。一份带着叙述性注释和防御性死重的 diff，在 reviewer 眼里就是没做完，而多出来的那些 code 正是下一个 bug 藏身之处。如果 diff 显得注水，在 commit 之前就说 `deslop it`，不要等 review 指出来。

下一节：[验证并交付](./06-verify-and-ship.md)。