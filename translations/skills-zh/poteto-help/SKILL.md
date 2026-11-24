---
name: poteto-help
description: 引导 user 完成 pstack 的 setup、/poteto-mode，以及为某个 task 挑选合适的 skill、playbook 或 principle。用 /poteto-help 加一个问题来使用。
disable-model-invocation: true
---

# Poteto help

回答 user 关于 pstack 的问题，交给他们一段可以直接发送的 prompt，并给出答案所出自的 file 链接。对 help 类问题，不要开始做那件事。user 问的是「怎么做」，而一次 pstack 运行会消耗真实 token，所以让他们自己去发送 prompt。

一个要求做事的 message，例如 "use pstack to fix this bug"，不是 help 问题。去读 [`poteto-mode`](../poteto-mode/SKILL.md)，在它之下把事做完，并提一次 Custom Mode 能让它保持开启。

这个 file 把问题映射到持有答案的 skill 与 guide 页面。那些 file 才拥有细节。在引用之前先读你要路由到的 file，当它与这份 map 冲突时以它为准。这里的链接指向已安装的 plugin，user 可能打不开，所以要给 user 该 file 的公开副本：`https://github.com/cursor/plugins/blob/main/pstack/` 后面接它的 path。

## 弄清他们需要什么

从 message 和对话中推断需求。点名了某个情境的，例如 "which skill reviews a PR?"，直接跳到对应小节。如果需求仍不清楚，问一个多选问题，给出这些选项，然后只回答他们选中的那一节：

- Get set up
- Start a task with `/poteto-mode`
- Pick a skill for a situation
- Fix a run that went wrong
- Make pstack my own

检查那些会改变答案的状态，只在它确实改变答案时才提及：

- 没有 `~/.cursor/rules/pstack-models.mdc`，意味着该 user 从未运行过 `/setup-pstack`，于是每个 role 都用其默认 model。
- 项目里没有 `verify-*` skill 或其他 app harness，意味着 agent 没有脚本化方式来驱动 app。当问题关于「证明某次改动可用」时，提及 `/create-verification-skill`。
- 项目里没有 formal verification skill，意味着超出 test 所能触及的部分没有被检查任何 property。当问题关于 race、invariant，或其他 test 很少触及的 case 时，提及 `/create-formal-verification-skill`。当已存在一个，且它覆盖的 code 在其记录为最后同步的那个 commit 之后发生了变化，而问题又触及那段 code 时，提及 `/maintain-formal-verification-skill`。

当 model 规则缺失且这件事要紧时，问 user 是否想现在就为每个 role 选 model、并选一个 reasoning budget。要紧的情形是：user 是新手、问题关于 setup 或成本、或答案取决于哪些 model 在跑。每个 chat 最多问一次。如果需求也不清楚，就把两个问题一起问。给两个选择：

- Now：给他们 `/setup-pstack` 让他们自己输入，同时也回答他们的问题。
- Later：回答他们的问题，并加一行说明：在他们运行 `/setup-pstack` 之前，每个 role 都保持其默认 model。

## Get set up

1. 在 chat 里用 `/add-plugin pstack` 安装，或从侧栏的 Customize 安装。
2. 运行 [`/setup-pstack`](../setup-pstack/SKILL.md)。它会询问 reasoning budget、为每个 role 映射一个 model，并写出一个规则。该规则对新 chat 生效。然后它为该项目各提供一次生成 verification skill 和 formal verification skill 的机会，除非项目里已经有了。
3. 用一个 `/poteto-mode`、一个目标，以及一个能通过或失败的 check 来开始一个真实 task。

安装本身不改变任何东西，直到 user 调用某个 skill。只有 `/setup-pstack` 会从 user 的话语中加载。[README](../../README.md) 和 [guide page 1](../../docs/guide/01-setup.md) 有细节。按 [`references/prompting.md`](references/prompting.md)，主动提出与他们一起打磨第一条 prompt。

如果顾虑的是成本，说明 token 花在哪里、以及如何少花。pstack 会在 subagent 和 review panel 上多花 token。重跑 `/setup-pstack` 并选更小的 budget 或更便宜的 model。设为 `auto` 或 `inherit-parent` 的 role 跑在 chat 的 model 上，当 chat 跑在 Auto 或更便宜的 model 上时能省 token。panel 列表越短，跑的 subagent 越少，每个条目一个。把 `/poteto-mode` 留给需要 rigor 的工作。

pstack 是为 Cursor 构建的，它也能装进 Claude Code，用 `/plugin marketplace add cursor/plugins`，再 `/plugin install pstack@cursor-plugins`。在那里，每个 command 都要带 `pstack:` 前缀，例如 `/pstack:poteto-mode`。[Claude Code adapter](../../docs/harness/claude-code.md) 映射了 Cursor 的名字，而某个需要 Cursor 专属功能（例如 Bugbot 或 Automations）的步骤会被跳过，并附一行说明。

其他工具也能读这些 skill，因为它们使用 Agent Skills 格式。但大多数 workflow skill，包括 `/poteto-mode`、`/how`、`/why` 和 `/teach`，都会以 per-role model spawn Cursor subagent，而 Custom Mode 和 `/loop` 是 Cursor 的功能，所以那些部分在那里可能不工作。

## Start a task with `/poteto-mode`

`/poteto-mode` 把 task 匹配到一个 playbook，把该 playbook 的步骤复制进 todo list，并在步骤需要时运行其他 skill。它跳过的步骤会留在列表里，记作 `skip: <reason>`。一条好的 prompt 陈述目标以及如何判断完成。它不列 skill，因为手写的序列往往会丢掉或打乱 playbook 本会保留的步骤。在帮忙措辞之前先读 [`references/prompting.md`](references/prompting.md)。[Guide page 2](../../docs/guide/02-poteto-mode.md) 有示例。

`/poteto-mode` 是否保持开启，取决于 user 如何启动它：

- 在 `/poteto-mode` 上按 Enter，会把该 skill 附加到一条 message 上。随着 chat 推进它会淡出。
- Mac 上按 Option+Enter、Windows 上按 Alt+Enter，或从 skill 条目选 Use as Mode，会把它变成 Custom Mode。它会每一轮都留在 context 里，直到 user 退出该 mode，且它不会进入随意的闲聊轮次。
- Cursor 的 doc 把 Custom Mode 列在 Agents Window 和 CLI 中。在其他地方，每个新 task 都要用 `/poteto-mode` 启动。

这件事出现时，链接 [Cursor's skills docs](https://cursor.com/docs/skills)。在 chat 中途说 "new task" 会让该 mode 匹配一个全新的 playbook。`/poteto-mode` 已经为其 playbook 步骤 spawn 的 subagent 使用 `poteto-agent`。若想让自己 spawn 的 subagent 也有同样的风格，用 `subagent_type: "poteto-agent"` 去 spawn 它。

## Pick a skill

默认答案是 `/poteto-mode`，它在步骤需要时运行大多数其他 skill。当 user 想要比 playbook 给的多一些或少一些时，就直接点名某个 skill。在推荐之前先读那个 skill，并给一条示例 prompt。

| The user wants to | Skill |
|---|---|
| 带着 rigor 做任何非平凡 task | [`/poteto-mode`](../poteto-mode/SKILL.md) |
| 在开始之前确认 agent 理解了他们的目标与问题 | [`/in-your-own-words`](../in-your-own-words/SKILL.md) |
| 在发送之前把 prompt 改写得更深入而不是更庞大：顶尖专业人士会补充什么、他们的原始材料与方法，以及一个外部检验。它返回 prompt，不做那个 task | [`/sharpen`](../sharpen/SKILL.md) |
| 了解 code 现在如何工作，或新 code 应该放在哪里 | [`/how`](../how/SKILL.md) |
| 了解 code 为什么是这个形状，或某个数字从哪来 | [`/why`](../why/SKILL.md) |
| 平实地理解一处改动或一个 subsystem 的解释 | [`/teach`](../teach/SKILL.md) |
| 追上一个主题上自己最近的工作 | [`/recall`](../recall/SKILL.md) |
| 用平实的话和少量小图追上这个 chat 自他们上一条 message 以来的变化，所有在等他们的事都列出来、且仅凭 reply 就能定夺 | [`/ketchup`](../ketchup/SKILL.md) |
| 像 `/ketchup` 那样追上，但用一段带字幕的幻灯片短视频，等待决定的事以文字放在下方 | [`/ketchup-video`](../ketchup-video/SKILL.md) |
| 了解一个小 diff 可能在其之外弄坏什么 | [`/blast-radius`](../blast-radius/SKILL.md) |
| 在写跨 function 边界的 code 之前定下 type 与 module 形状 | [`/architect`](../architect/SKILL.md) |
| 对同一份 brief 拿到多次尝试，并合并成最好的一个 | [`/arena`](../arena/SKILL.md) |
| 以 cloud agent 的形式跨切片跑并行检查，或让 worker 赛跑 | [`/swarm`](../swarm/SKILL.md) |
| 让不同的 model 审一个 diff 并试着打破它 | [`/interrogate`](../interrogate/SKILL.md) |
| 在有廉价本地 test 时 test-first 修一个 bug | [`/tdd`](../tdd/SKILL.md) |
| 把 TypeScript 规则套用到 `.ts` 或 `.tsx` 的工作上 | [`/typescript-best-practices`](../typescript-best-practices/SKILL.md) |
| 在 review 之前剥掉注释，用没写过它们的 reviewer | [`/no-comments`](../no-comments/SKILL.md) |
| 清掉 prose 里的 AI 痕迹 | [`/unslop`](../unslop/SKILL.md) |
| 按标准写 doc、RFC、README、PR description 或 commit message | [`/technical-writing`](../technical-writing/SKILL.md) |
| 用平实的话再听一遍上一条 reply | [`/bro`](../bro/SKILL.md) |
| 给 agent 一种脚本化方式来驱动 app 并证明行为 | [`/create-verification-skill`](../create-verification-skill/SKILL.md) |
| 把 verification skill 及其 feature map 重新对齐到 app | [`/maintain-verification-skill`](../maintain-verification-skill/SKILL.md) |
| 对 race、invariant 或其他 test 很少触及的 property 做形式化验证 | [`/create-formal-verification-skill`](../create-formal-verification-skill/SKILL.md) |
| 在其覆盖的 code 变化之后把 formal verification 重新对齐，并弄清某个 failure 是 drift 还是 bug | [`/maintain-formal-verification-skill`](../maintain-formal-verification-skill/SKILL.md) |
| 用一张由 TLA+ model 检验过的 chart 向 PM 或设计师展示 user 看到的东西，附上到达每个破坏规则状态的最短路径 | [`/statechart`](../statechart/SKILL.md) |
| 在汇报或据此行动之前给一个性能数字做体检 | [`/benchmark-checklist`](../benchmark-checklist/SKILL.md) |
| 跑一次大型或横切多处的改动，或一次走开回来才 review 的工作 | [`/figure-it-out`](../figure-it-out/SKILL.md) |
| 在运行期间保留一份 decision log，并在事后 review | [`/show-me-your-work`](../show-me-your-work/SKILL.md) |
| 为每个 role 选 model 并选一个 reasoning budget | [`/setup-pstack`](../setup-pstack/SKILL.md) |
| 把他们自己的工作习惯变成一个个人 mode skill | [`/automate-me`](../automate-me/SKILL.md) |
| 把刚完成的 task 教到的东西变成 skill 编辑 | [`/reflect`](../reflect/SKILL.md) |
| 阻止 agent 在这个 repo 里重复同样的错误 | [`/correct`](../correct/SKILL.md) |
| 做一个按钮能通过 webhook 唤醒 Grok Bot 的 page | [`/make-bot-ui`](../make-bot-ui/SKILL.md) |
| 在 pstack 里找到方向 | `/poteto-help` |

如果这张表漏掉了旁边某个 skill 目录，就读它的 frontmatter 并按它的 description 路由。`principle-*` 目录在下面的 principles 一节中涵盖。

近似难分的几组：

- `/how` 解释 code 做什么。`/why` 解释原因。`/teach` 跑其中之一或两者，并平实地解释结果。
- `/arena` 给每个 worker 相同的 brief 并合并最好的部分。`/swarm` 把工作切成切片或一场 race，并返回一份 report。
- `/architect` 在定下 design 之后立即实现。加上 "with checkpoint" 就能在它写 code 之前 review design。
- `/interrogate` 审这个 diff。`/blast-radius` 在 diff 之外寻找 breakage，并证明那个让改动安全的关键 fact。
- `/recall` 跨最近若干 chat 重建 context。`/ketchup` 只覆盖这个 chat 自 user 上一条 message 以来的部分。恢复某一个特定 chat 或 branch 是 Session pickup playbook。
- `/figure-it-out` 设计一次严谨的运行。Orchestrate playbook 运行一个跨越数天、涉及许多 PR 的程序。Autonomous run playbook 驱动一个 task 到某个完成条件。

不在 pstack 里：

- `/deslop`、`control-cli` 和 `control-ui` 随 `cursor-team-kit` plugin 提供。
- `/loop` 和 `/create-skill` 是 Cursor 内置的。
- pstack 没有 `/orchestrate` skill。Orchestrate 是一个 `/poteto-mode` playbook。如果 slash menu 里出现 `/orchestrate`，那是别的 plugin 提供的。

## Playbooks and principles

playbook 是 `/poteto-mode` 内部的步骤清单，不是 skill，所以它们没有 slash command。在 `/poteto-mode` 内部，描述 task 就能选出一个，而下面这些短语直接点名：

- "babysit this pr" 或 "check on pr 123" 运行 Babysit。它把 PR 驱动到 merge-ready 就停在那里。除非 user 要求 merge、land 或 ship，否则它不会 merge。
- "land the stack" 运行 Shipping。
- "take over this branch" 运行 Session pickup。
- "pause safely" 运行 Pause safely。
- "full autopilot on this queue" 运行 Autopilot-full。"autopilot, don't merge" 运行 Autopilot-stack。
- "run the eval playbook" 运行 Eval。

没有 `/poteto-mode` 时，像 "babysit this pr" 这样的短语可能启动 Cursor 自带的、做同样事情的 skill。[`poteto-mode`](../poteto-mode/SKILL.md) 的 Playbooks 一节列出了每个 playbook 及何时适用。[Guide page 6](../../docs/guide/06-verify-and-ship.md) 覆盖了开启、babysit 和落地一个 PR。

pstack 没有 planning skill。Cursor 的 Plan Mode 与它并用。对于跨 phase 或 stacked PR 的工作，向 `/poteto-mode` 要一份 plan 会运行 [Multi-phase plan playbook](../poteto-mode/playbooks/multi-phase-plan.md)，它写 plan 但不实现它。对于 design 问题，Prototype playbook 或 `/architect` 先在 code 里把它定下来。

principle 是单规则的 skill，`/poteto-mode` 在回复中读取并引用它们。user 很少直接调用其中一个。他们改用名字来引导，例如 "apply prove it works. show me the real output."。输入 `/principle-<name>` 仍可按需加载一个。[Guide page 8](../../docs/guide/08-principles.md) 列出了它们。

## Fix a run that went wrong

| Symptom | Fix |
|---|---|
| mode 用了几轮之后不再生效 | 它是用 Enter 启动的。以 Custom Mode 启动它，或每个 task 都用 `/poteto-mode` 启动。 |
| 一个问题被当成上一个 task 的下一步 | 说 "new task"，或说明这一轮不需要该 mode。 |
| 新的 model 选择没有效果 | `/setup-pstack` 写出的规则对新 chat 生效。开一个新的。 |
| 运行成本超出预期 | 见 Get set up 下的成本段落。 |
| 某个 skill 没有自行加载 | 只有 `/setup-pstack` 会从 user 的话语中加载。其余的要么在 user 输入时加载，要么在 `/poteto-mode` 运行时加载，而它不会运行每一个 skill。 |
| 并行 agent 互相覆盖 | 给每个 agent 自己的 worktree，或把它们作为 cloud agent 运行，各自获得自己的机器。 |
| 一次过夜运行有动静却什么也没完成 | `/loop` 需要一个能通过或失败的 check，而不是一个时长。见 [guide page 7](../../docs/guide/07-overnight.md)。 |
| reply 凭一次绿的 build 就声称成功 | 索要真实的 command、flow、存储值或 profile。那就是 prove-it-works 原则。 |

对于跑偏的运行，[`references/prompting.md`](references/prompting.md) 有一行式的引导。[Guide page 10](../../docs/guide/10-recipes-and-pitfalls.md) 有更多坑和值得照抄的 recipe。

## Make pstack my own

- [`/automate-me`](../automate-me/SKILL.md) 从 user 自己的历史中起草一个个人 mode skill，配合 `/poteto-mode` 使用。
- 一次 session 之后用 [`/reflect`](../reflect/SKILL.md) 把它的教训变成 user 批准的 skill 编辑。
- `/poteto-mode write a skill for <workflow>` 运行 authoring playbook。eval playbook 会盲测一个 skill 改动。
- 在它自己的 PR 里修一个行为异常的 skill，而不是在它出错的那次 feature 工作内部修。

[Guide page 9](../../docs/guide/09-make-it-yours.md) 覆盖了以上每一项。

## Reply

先给答案。最多在 code block 里给一条示例 prompt，合适时从 [`references/recipes.md`](references/recipes.md) 改写而来，然后给出那个 file 的链接。除非 user 要整张 map，否则保持简短。