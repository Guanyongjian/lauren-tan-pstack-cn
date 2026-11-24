# pstack

我是 [poteto](https://x.com/poteto)。我不是总裁也不是 CEO，但我在 Meta、Netflix 和 Cursor 处理过数百万行代码。我也是 react 核心团队的成员，参与构建并维护 react compiler。

越来越多的人觉得 ai 写了太多 slop code。我同意。我不想带着二十个 slop 艺术家组成的团队去交付。没有质量的吞吐量不是我想追求的目标。如果你想走得快，先往深里走。

**pstack 就是我的答案。** 这些正是我在 Cursor 每天用来交付高质量代码的那套 skill。它把 cursor 变成一个真正的工程团队。目标不是把 loc 最大化，恰恰相反，pstack 帮你写得更少，但质量更高。

**pstack 给你无所畏惧的并行。** 当你能在一个 agent 上往深里走、并信任它写出可验证的好代码时，你才能真正放心地并行。用 `poteto-mode` 起多个 agent，并相信它们会对自己的工作施加严格的工程原则。

**cursor 给你各家的长处。** 每个前沿 model 都有各自的强项和短板。在 pstack 里可以用任何 model。事实上我的很多 skill 都用多 model 的 workflow，以发挥每个 model 独有的长处。

fork 它，改进它，变成你自己的。欢迎 PR！

## install

```bash
/add-plugin pstack
```

在 claude code 里：

```bash
/plugin marketplace add cursor/plugins
/plugin install pstack@cursor-plugins
```

claude code 对第三方 marketplace 默认关闭 auto-update，所以 pstack 会停在你安装的那个版本。要打开它，运行 `/plugin`，打开 **marketplaces** 标签页，选中 `cursor-plugins`，然后选择 **enable auto-update**。要手动更新一次，运行 `claude plugin update pstack@cursor-plugins`。

claude code 会给 plugin 命令和 agent 加前缀，所以 `/poteto-mode` 是 `/pstack:poteto-mode`。[claude code 适配说明](./docs/harness/claude-code.md)映射了其余每一个 cursor 名字。在 claude code 里，`/pstack:setup-pstack` 把你的 model 选择写到 `~/.claude/rules/pstack-models.md`，而某个需要 cursor 专有能力的步骤（例如 bugbot 或 automations）会被跳过，并附一行说明。

claude code 安装的是 pstack 的一份生成副本，其中的 readme 和指南也包含在内，来自 repository 根目录下的 [`harness/pstack/`](https://github.com/cursor/plugins/tree/main/harness/pstack)。改动 pstack 之后，从 repository 根目录运行 `node scripts/generate-pstack-harness-trees.mjs` 并 commit 结果。只要生成副本过期，ci 就会失败。

## get started

两步：

1. 运行 [`/setup-pstack`](./skills/setup-pstack/SKILL.md)，挑一个 reasoning budget，并选出你想用的 model。
2. 凡是需要严谨的活，都用 [`/poteto-mode`](./skills/poteto-mode/SKILL.md)。

第一次来？[pstack 指南](./docs/guide/README.md)带你走一遍第一个真实任务，从 setup、prompt 一直到验证和隔夜运行。卡住了，或者不确定该用哪个 skill？问 [`/poteto-help`](./skills/poteto-help/SKILL.md)。

就这样。其余 skill 都是按情况用的，而那个 mode skill 会在需要时替你调用它们。开箱即用时，该 mode 按 model 强度分工：code 委派（feature、refactoring、bug fix、perf、hillclimb）交给 grok，而最难的改动、prose 与判断交给 opus 5.5。默认 panel 是 opus 5.5 / grok。[`/setup-pstack`](./skills/setup-pstack/SKILL.md)可以改其中任何一项。

## usage

在一个 task 开始时用 [`/poteto-mode`](./skills/poteto-mode/SKILL.md)。它读你的请求，从一组 playbook 中挑一个，并在各步骤需要时运行其他 skill。

在输入你的 task 之前，先从 `/` 菜单里选 `/poteto-mode`，这样 cursor 会把这个 skill 附到 message 上。

### 直接用 [`/poteto-mode`](./skills/poteto-mode/SKILL.md)

这个 skill 就是主快捷键。每当我需要 agent 做严谨的工程工作，我就用它。它自带二十三个 playbook：

```
/poteto-mode this pr has a subtle bug where the scroll drifts every 750ms even when idle. repro
first, then fix and verify.
```

```
/poteto-mode i'm going to bed. land the stack even if ci flakes. i want everything merged by
morning.
```

<details>
<summary>那二十三个 playbook</summary>

| playbook | 用于 |
|---|---|
| [investigation](./skills/poteto-mode/playbooks/investigation.md) | 一个 read-only 的问题。x 是怎么工作的、y 为什么这样建、我们确定吗。 |
| [bug fix](./skills/poteto-mode/playbooks/bug-fix.md) | 复现一个缺陷、定位根因，并用 runtime 证据修复。 |
| [perf](./skills/poteto-mode/playbooks/perf-issue.md) | 追踪一处测量得到的缓慢，并对着 baseline 改进它。 |
| [hillclimb](./skills/poteto-mode/playbooks/hillclimb.md) | 对着一个目标对某一指标做持续的、科学的改进，用 before/after 测量循环假设，每接受一次胜出就一个 commit。 |
| [runtime forensics](./skills/poteto-mode/playbooks/runtime-forensics.md) | 从 instrumentation 诊断一个活着的 symptom（泄漏、idle-cpu spin、毛刺）。 |
| [trace forensics](./skills/poteto-mode/playbooks/trace-forensics.md) | 诊断一份抓取下来的 profiling artifact（cpuprofile、trace、spindump、heap snapshot）。 |
| [feature](./skills/poteto-mode/playbooks/feature.md) | 新增或改变行为，从某个具名的 data shape 建起。 |
| [refactoring](./skills/poteto-mode/playbooks/refactoring.md) | 一次保持行为的结构或形状改动。 |
| [prototype](./skills/poteto-mode/playbooks/prototype.md) | 一次用完即弃的草图，用来廉价地做出 design 或行为决定，或靠观察来定下一个实证上的分叉。 |
| [visual parity](./skills/poteto-mode/playbooks/visual-parity.md) | 两份实现之间的像素级 ui 等价。 |
| [authoring a skill](./skills/poteto-mode/playbooks/authoring-a-skill.md) | 写或编辑一份 SKILL.md。 |
| [eval](./skills/poteto-mode/playbooks/eval.md) | 盲测一个 skill 或 prompt 改动如何影响 agent 行为。 |
| [babysit](./skills/poteto-mode/playbooks/babysit.md) | 把一个 pr 或一个 stack 推到可 merge：冲突、review thread、ci。 |
| [shipping](./skills/poteto-mode/playbooks/shipping.md) | 独立核实一个全绿的 stack，然后默认经 github、可用时经 origin，自底向上交付那段连续的已验证运行。 |
| [autonomous run](./skills/poteto-mode/playbooks/autonomous-run.md) | 不停地把一个长任务推到完成。 |
| [orchestrate](./skills/poteto-mode/playbooks/orchestrate.md) | 一个常驻项目交给一个 coordinator chat：多天、许多 stacked pr、成群的 subagent。 |
| [autopilot-full](./skills/poteto-mode/playbooks/autopilot-full.md) | 把互相独立的 pr 跑到已 merge，每个 pr 一个 owner。一个 swarm 核实每个 code-ready head，此后对 patch 的每一次改动都重新检查。 |
| [autopilot-stack](./skills/poteto-mode/playbooks/autopilot-stack.md) | autopilot-full 去掉 merge 那一步。把 pr 构建并验证好，交给操作者 review 和 land，只在它所基于的那个 pr 上叠 pr。 |
| [session pickup](./skills/poteto-mode/playbooks/session-pickup.md) | 恢复或接管前一个 agent 尚在进行中的工作。 |
| [pause safely](./skills/poteto-mode/playbooks/pause-safely.md) | 干净地挂起进行中的工作，以便之后恢复。 |
| [multi-phase plan](./skills/poteto-mode/playbooks/multi-phase-plan.md) | 跨阶段或跨 stacked PR 的工作。 |
| [worktree cleanup](./skills/poteto-mode/playbooks/worktree-cleanup.md) | 通过修剪已 merge 或已废弃的 worktree 以及陈旧的 ios simulator 来回收磁盘，带安全门。 |
| [opening a pr](./skills/poteto-mode/playbooks/opening-a-pr.md) | 用小的、有序的 commit 开一个 ready pr，标题遵循 conventional commits，正文用简报风格。在其他每个 playbook 的结尾处调用。 |

</details>



被调用时它：

1. 把你的 task 匹配到一个 [playbook](./skills/poteto-mode/playbooks/)，并打开一个 todo list，其头几项就是该 playbook 的步骤，逐字抄入。
2. 在步骤触发时路由到其他 skill。
3. 写出经过 unslop 的 reply，面向消费者与维护者来组织。

完整的规则与 playbook 在 [`skills/poteto-mode/SKILL.md`](./skills/poteto-mode/SKILL.md) 里。

要让 [`/poteto-mode`](./skills/poteto-mode/SKILL.md) 跨轮次保持生效，请从 `/` 菜单里选中它，然后按 option+enter（mac）或 alt+enter（windows）而不是 enter。这样它会成为一个 [custom mode](https://cursor.com/docs/skills#using-a-skill-as-a-custom-mode)，cursor 在 agents 窗口和 cli 里都会提供它。它会一直留在上下文里，直到你退出该 mode。直接按 enter 只会把它附到一条 message 上。

[`/poteto-mode`](./skills/poteto-mode/SKILL.md) 与 cursor 的 `/loop` 命令配合得非常好。你可以让 cursor 连续工作很多小时而不牺牲严谨性。

## skills

[`/poteto-mode`](./skills/poteto-mode/SKILL.md) 在某个步骤需要时会替你运行其中大部分（`how`、`why`、`architect`、`arena`、`swarm`、`interrogate`、`unslop`、`no-comments`、`technical-writing`、`tdd`，以及那些原则）。下面的表是给你想直接用一个的时候用的：

```
/how do we cancel runs? do we have an n+1 when we look up every run to cancel?
```

```
/interrogate review this pr.
```

<details>
<summary>全部 skill</summary>

| skill | 什么时候用 |
|---|---|
| [`/poteto-mode`](./skills/poteto-mode/SKILL.md) | 任何非平凡 task 的默认入口。 |
| [`/poteto-help`](./skills/poteto-help/SKILL.md) | 你是 pstack 新手，或不确定哪个 skill、playbook、原则合适。它弄清你想做什么，回答那一部分，并递给你一段可以输入的 prompt。只有你输入 `/poteto-help` 时才运行。 |
| [`/in-your-own-words`](./skills/in-your-own-words/SKILL.md) | 你希望 agent 在开工前先把你的目标与问题复述一遍。只有你输入 `/in-your-own-words` 时才运行。 |
| [`/sharpen`](./skills/sharpen/SKILL.md) | 你希望发送前把一段 prompt 变深而不是变大：一个顶尖专业人士会做而你没要求的事、他们会从什么原始素材起步、他们的方法与工具，以及一次对「结果是对的」的外部核查。它交回重写后的 prompt，把你的选择留开着。它不做这个 task。只有你输入 `/sharpen` 时才运行。 |
| [`/how`](./skills/how/SKILL.md) | 你想要一个子系统如何运作的走读。 |
| [`/why`](./skills/why/SKILL.md) | 你想知道某样东西为什么这样建。它在运行时发现可用的 MCP，并并行查询每一个证据类别（source control、issue tracker、长文文档、实时 chat、基础设施 observability、错误追踪、analytics warehouse）。 |
| [`/recall`](./skills/recall/SKILL.md) | 你正在开始或接手工作，想把自己最近的 chat 历史与共享记录中关于某个主题的上下文重建出来，作为一份紧凑的当前状态简报交回。 |
| [`/ketchup`](./skills/ketchup/SKILL.md) | 你想要这个 chat 里自你上一条 message 以来的变化，用平实的话和少量小图讲清，并列出每一项在等你的事，且仅凭这条 reply 就能定夺，即便这会让 reply 变长。 |
| [`/ketchup-video`](./skills/ketchup-video/SKILL.md) | 你想要 `/ketchup` 的同步进展做成一段带字幕的短幻灯片视频，下面用文字列出在等你的决定。 |
| [`/blast-radius`](./skills/blast-radius/SKILL.md) | 你有一处看似很小的改动，想知道它还可能弄坏什么，并且那个「之所以安全」的唯一事实是由运行 code 证明的，而不是断言出来的。 |
| [`/architect`](./skills/architect/SKILL.md) | 你即将写跨函数边界的 code，想先把调用方的用法、类型和 module 形状定下来。 |
| [`/arena`](./skills/arena/SKILL.md) | 你想要同一件事的 N 个并行尝试，然后取各自最好的部分。 |
| [`/swarm`](./skills/swarm/SKILL.md) | 你想要 N 个并行 worker 分头处理不同切片或竞速，然后一份汇总报告。 |
| [`/interrogate`](./skills/interrogate/SKILL.md) | 你手上有份 diff，想让不同的 model 试着攻破它，只保留经一次运行证明的 finding。 |
| [`/automate-me`](./skills/automate-me/SKILL.md) | 你想要一个自己的 `-mode` skill，依据你实际的工作方式起草。 |
| [`/make-bot-ui`](./skills/make-bot-ui/SKILL.md) | 你想要一个页面或 dashboard，其按钮通过 webhook 唤醒 Grok Bot，包含 sender-key 交接与 Tailscale。 |
| [`/setup-pstack`](./skills/setup-pstack/SKILL.md) | 你想挑选 pstack 各角色用哪些 model。它会检测你的 model 并写一条配置规则。 |
| [`/reflect`](./skills/reflect/SKILL.md) | 一个长任务落地了，你想把这次的配方固化成一次 skill 编辑。 |
| [`/correct`](./skills/correct/SKILL.md) | 你反复因同样的错误纠正 agent。它从历史里挖出错误类别，在能生效的最高层级逐个修好（架构，然后类型、lint、ci，然后测试，文档放最后），并维护一张表，把每条规则与强制执行它的东西配对。 |
| [`/teach`](./skills/teach/SKILL.md) | 你想真正理解一处改动或一个子系统，而不只是拿到一份摘要。它运行 how + why，并编织成一份平实的解释，一张图一张图地搭起来。 |
| [`/tdd`](./skills/tdd/SKILL.md) | 你在修 bug，且有廉价的本地测试路径。先写失败的 test，再修复。 |
| [`/benchmark-checklist`](./skills/benchmark-checklist/SKILL.md) | 你跑了一个 benchmark 或测到了一次加速或回归。在报告或据此行动之前，先审查这个数字（limiter、tuning、error、重复运行、端到端相关性）。 |
| [`/no-comments`](./skills/no-comments/SKILL.md) | review 之前先剥掉注释；它起 Comment Sicko，修好被接受的 finding，并为声称的约束提供编码方案。 |
| [`/typescript-best-practices`](./skills/typescript-best-practices/SKILL.md) | 你在读或改 typescript。它把 type-system-discipline 原则落到语法层面。 |
| [`/figure-it-out`](./skills/figure-it-out/SKILL.md) | 没有一个自带 playbook 合适。为这个 task 设计一套严谨、可审计的 playbook。 |
| [`/show-me-your-work`](./skills/show-me-your-work/SKILL.md) | 你想要一条可 review 的决策轨迹。把决定记进一份可以 commit 的 tsv。 |
| [`/create-verification-skill`](./skills/create-verification-skill/SKILL.md) | 你的项目没有用脚本证明 app 行为的办法。它生成一个带 feature map 的项目内 verify skill，适用于任何语言或平台。 |
| [`/maintain-verification-skill`](./skills/maintain-verification-skill/SKILL.md) | 你的 verify skill 的 feature map 已与 app 脱节。source 波次加一次实跑，至多一个 PR 的已证明修正。 |
| [`/create-formal-verification-skill`](./skills/create-formal-verification-skill/SKILL.md) | 测试够不到那个会打穿 race、retry、state machine、parser 或 unsafe code 的 case。用合适的工具验证一条性质，并生成一个项目内 skill 好在每次改动时复查它。 |
| [`/maintain-formal-verification-skill`](./skills/maintain-formal-verification-skill/SKILL.md) | 你的形式化验证所覆盖的 code 自上次检查后改过。更新 model、harness 或性质以匹配 code，重跑，并说明每个失败是验证侧的漂移还是 code 里的 bug。 |
| [`/statechart`](./skills/statechart/SKILL.md) | 拥有该行为的人需要看见它，而不是读一份规格。它检查一个 tla+ model，把 user 看到的东西画成 mermaid statechart，标出每个破坏规则的 state，并给出通往每个 state 的最短路径。 |
| [`/unslop`](./skills/unslop/SKILL.md) | 你在整理写作。它移除 AI 腔。 |
| [`/bro`](./skills/bro/SKILL.md) | 你想把上一条 message 用平实人话重述一遍，不用术语。 |
| [`/technical-writing`](./skills/technical-writing/SKILL.md) | 分层文档标准（Diátaxis + Google developer style + STE + Global English），用于文档、RFC、readme、PR 描述、commit message。 |

</details>



### examples

大多时候我在 task 开始时输入 [`/poteto-mode`](./skills/poteto-mode/SKILL.md)，让它路由到一个 playbook。其他 skill 在步骤需要时触发。少数几个我会直接调用。


<details>
<summary>全部示例</summary>

```
bug fix:           /poteto-mode this pr has a subtle bug where the scroll drifts every 750ms even
                   when idle. repro first, then fix and verify.
perf:              /poteto-mode a big list takes a second or two to load even though we virtualize.
                   run a cpu trace and tell me why.
feature:           /poteto-mode build a small feature behind a feature flag. verify it really works.
prototype:         /poteto-mode build two prototypes of the markdown renderer so we can compare.
                   spawn an agent for each.
multi-phase:       /poteto-mode open source these skills as a plugin. nothing internal leaks, work
                   in a temp dir, show me the dependency graph first.
overnight run:     /poteto-mode i'm going to bed. land the stack even if ci flakes. i want
                   everything merged by morning.
babysit:           /poteto-mode check on pr 123. anything outstanding?
visual parity:     /poteto-mode the row spacing is too tall when this flag is on. the second image
                   is correct. repro and fix until it matches.
figure it out:     /poteto-mode i'm stepping away. migrate every caller from the synchronous store
                   to the new async one, keeping behavior identical. i want to trust it was done
                   right when i'm back.
how:               /how do we cancel runs? do we have an n+1 when we look up every run to cancel?
why:               /why is this feature flag not on yet?
architect:         design this instrumentation to be high signal with no false positives. /architect
                   this first.
arena:             /arena take my prompt to the arena verbatim. i want to compare their proposals
                   with yours.
swarm:             /swarm check every package under packages/ against its check.sh. one worker per
                   package. one report.
interrogate:       /interrogate review this pr.
tdd:               /tdd implement
unslop:            can we unslop and tighten the new changes?
reflect:           /reflect that took too long. capture what we learned so the next run doesn't
                   repeat it.
correct:           /correct
show-me-your-work: /show-me-your-work keep a decision trail i can review when i'm back.
automate-me:       /automate-me
help:              /poteto-help which skill should i use to review this branch?
```

</details>

## `poteto-agent` 与 Comment Sicko 两个 subagent

[`/poteto-mode`](./skills/poteto-mode/SKILL.md) 在接收它的那个 chat 里运行。那个 chat 拥有 playbook、todo list，以及每一次 subagent 的启动。

pstack 还随附 [`subagent_type: "poteto-agent"`](./agents/poteto-agent.md)，作为一次 run 期间所启动 delegate 的外壳。它在做任何工作之前先完整读一遍 `poteto-mode`，包括其中的内联原则索引。换成 `generalPurpose` 就会跳过这次阅读并产生漂移。不要启动 `poteto-agent` 去跑 playbook 本身。

[`/poteto-mode`](./skills/poteto-mode/SKILL.md) 与 [`subagent_type: "poteto-agent"`](./agents/poteto-agent.md) 走的是同一个外壳。

pstack 还随附 [Comment Sicko](./agents/comment-sicko.md)，一个 read-only 的注释 reviewer，可作为 `subagent_type: "comment-sicko"` 使用。通常通过 [`/no-comments`](./skills/no-comments/SKILL.md) 调用，而不是直接调用。

## principles

二十四个短 skill，一个一条原则。`poteto-mode` 把它们内联索引，并在 task 开始时读那份索引。独立文件的存在，是为了让其他 skill 能按名字引用某条原则，也是为了让索引能指向每条的完整规则。

<details>
<summary>全部二十四条原则</summary>

| principle | 分组 | 规则 |
|---|---|---|
| [laziness-protocol](./skills/principle-laziness-protocol/SKILL.md) | core | 偏向删除，偏向能解决问题的最小改动。 |
| [foundational-thinking](./skills/principle-foundational-thinking/SKILL.md) | core | 在写逻辑之前应用：挑选核心类型与数据结构、排定 scaffold 与 feature 的先后、问清并发的 actor 共享了什么。把数据结构搞对，下游 code 自然变得显然。 |
| [redesign-from-first-principles](./skills/principle-redesign-from-first-principles/SKILL.md) | core | 就像这个需求从第一天起就是一条基础假设那样重新设计，而不是把它硬接上去。 |
| [attack-the-premise](./skills/principle-attack-the-premise/SKILL.md) | core | 当两个或更多共享同一个前提的修复都在同一道门上失败时应用。把那个前提写下来，直接检验它，然后再写下一个以它为假设的修复。 |
| [subtract-before-you-add](./skills/principle-subtract-before-you-add/SKILL.md) | core | 先移除死重、冗余的校验器和残留引用，再在更简单的基础上构建。 |
| [minimize-reader-load](./skills/principle-minimize-reader-load/SKILL.md) | core | 数一数问题与答案之间隔了几层，以及读者脑子里藏了多少 state；合并只有一个调用方的 wrapper，缩小可变作用域。 |
| [outcome-oriented-execution](./skills/principle-outcome-oriented-execution/SKILL.md) | core | 在带有明确阶段边界的计划性重写与迁移中应用。向目标架构收敛；不要用一次性的兼容 code 去保住顺滑的中间状态。 |
| [experience-first](./skills/principle-experience-first/SKILL.md) | core | 宁选 user 的愉悦，而不是实现的便利；宁少发几个打磨好的功能，也不多发几个粗糙的。 |
| [exhaust-the-design-space](./skills/principle-exhaust-the-design-space/SKILL.md) | core | 在定案之前，建 2-3 个互相竞争的原型并排比较。 |
| [build-the-lever](./skills/principle-build-the-lever/SKILL.md) | core | 适用于任何非平凡的工作，不只是批量工作：编辑、迁移、分析、检查。造那个能完成或能证明它的工具（codemod、script、generator，或一个 subagent 遵循的 skill），而不是靠手工干。工具才是 reviewer 可以重跑的 artifact。 |
| [model-the-domain](./skills/principle-model-the-domain/SKILL.md) | architecture | 把领域编码进一个结构，而不是散落各处的条件判断。 |
| [boundary-discipline](./skills/principle-boundary-discipline/SKILL.md) | architecture | 把 guard 集中在系统边界（CLI、config、网络、外部 API）；信任内部类型，把业务逻辑留在纯函数里。 |
| [type-system-discipline](./skills/principle-type-system-discipline/SKILL.md) | architecture | 让非法状态无法表示、给语义化的原语打上品牌、在边界处 parse 外部数据、穷尽各个 variant、从权威 schema 派生。 |
| [make-operations-idempotent](./skills/principle-make-operations-idempotent/SKILL.md) | architecture | 无论此前是否部分运行过，都收敛到同一个最终 state。 |
| [migrate-callers-then-delete-legacy-apis](./skills/principle-migrate-callers-then-delete-legacy-apis/SKILL.md) | architecture | 在同一波里迁移调用方并删掉旧 API，而不是保留兼容层。 |
| [separate-before-serializing-shared-state](./skills/principle-separate-before-serializing-shared-state/SKILL.md) | architecture | 先消除共享；只有当单一共享写入方是一条真正的不变量时，才从结构上做串行化。 |
| [prove-it-works](./skills/principle-prove-it-works/SKILL.md) | verification | 在完成一个 task 之后、宣称完成之前应用。对着真实的 artifact 验证（运行该 feature、读真实的值、检视 diff），而不是代理指标、self-report，或「它能编译」。 |
| [fix-root-causes](./skills/principle-fix-root-causes/SKILL.md) | verification | 把每个 symptom 追到系统第一次出错的那个地方，并在那里修。只有它所处理的 state 是正当的，一个 guard 才算修复。 |
| [sequence-verifiable-units](./skills/principle-sequence-verifiable-units/SKILL.md) | verification | 适用于多步工作（清扫、迁移、成批的类似编辑），也适用于你如何叠 commit 和 PR。把工作切成一个个小的单元，每个都终结在一个可验证的 state，进下一个之前先检查这一个，并安排交付顺序，让这个序列在 reviewer 面前自证。 |
| [test-behavior-not-implementation](./skills/principle-test-behavior-not-implementation/SKILL.md) | verification | 在你写、改或保留一个 test 时应用。断言 code 的使用者能观察到的东西，这样当该行为坏掉时 test 会失败，而当只有内部实现变化时它仍通过。 |
| [explain-the-number](./skills/principle-explain-the-number/SKILL.md) | verification | 在信任、报告或据以行动一个你测出的数字之前应用：一次加速、一次回归、一个吞吐量、一个延迟、或一个 eval 结果。找出是什么限制了它，并排除它测到的是别的东西而非你以为的那个工作。 |
| [guard-the-context-window](./skills/principle-guard-the-context-window/SKILL.md) | delegation | 把批量工作路由给 subagent；主线程里留摘要，不要留原始 payload。 |
| [never-block-on-the-human](./skills/principle-never-block-on-the-human/SKILL.md) | delegation | 继续推进，呈现结果，让人在事后纠正方向；把确认留给不可逆的动作。 |
| [encode-lessons-in-structure](./skills/principle-encode-lessons-in-structure/SKILL.md) | meta | 把规则编码成 lint、metadata flag、运行时检查或 script，而不是更多的文字。 |

</details>

## not shipped here

有几样 `poteto-mode` 会引用但没有随附的东西：

- `/deslop` 与 `deslop` skill 随 `cursor-team-kit` plugin 发布。
- `control-cli`（用于 CLI 与 TUI）与 `control-ui`（用于 browser、Electron、web）也在 `cursor-team-kit` 里。
- `/create-skill` 是 cursor 的内置项。cursor 还随附一个内置的 `/autopilot`，它会盯着一个 pr。在 `poteto-mode` 里，pr 状态类的请求改为走 [babysit playbook](./skills/poteto-mode/playbooks/babysit.md)。

想要全套就把 `cursor-team-kit` 和 pstack 一起装上。

## 为什么没有规划类 skill？

cursor 已经有一个很好的 plan mode，它与 pstack 配合得很好。但就我个人而言，我不相信规划。最好的规格是 code。如果你确实想做一份计划，[`/poteto-mode`](./skills/poteto-mode/SKILL.md) 覆盖了它，但它不是默认。

## 变成你自己的

`poteto-mode` 是我的风格。你可能不想要完全一样的东西。

输入 [`/automate-me`](./skills/automate-me/SKILL.md)。它挖掘你最近的 transcript，依据你实际的工作方式起草一个 `<your-name>-mode` skill，并在底下路由到 pstack。你把 pstack 当作基底，最终在 `poteto-mode` 旁边得到自己的路由 skill。

model 也是可配置的。输入 [`/setup-pstack`](./skills/setup-pstack/SKILL.md)。它检测你能用到的 model，并写一条始终生效的小规则，把每个角色（code、judgment、各个 review panel）映射到一个 model。每个 skill 都读它，规则缺失时回退到合理的默认值，所以你只覆盖你想改的部分。

当某个默认值变了，在变动之前写下的规则仍然钉着旧的默认值。删掉那些 role 行，或删掉这个 file，再运行一次 `/setup-pstack`。重跑会保留任何 model 与默认值不同的 role。

## automations

pstack 还随附一个休眠的 [benny automation pack](https://github.com/cursor/plugins/tree/main/pstack/automations/benny)。benny 对 slack 的 issue report 做分流，然后用真实的 ui 证据复现并修复已确认的 bug。它的 file 不会被注册为 slash skill。

要配置它，让 cursor 指向 [`FOR_AGENTS.md`](https://github.com/cursor/plugins/blob/main/pstack/automations/benny/FOR_AGENTS.md)。setup 会把这个 pack 复制进目标 repository 的 `.cursor/automations/benny/`，在那里启用 pstack 以共享 skill，并把 user 配置留在被复制的 pack 之外。benny 运行在 cursor automations 上，所以它只适用于 cursor。

## license

MIT