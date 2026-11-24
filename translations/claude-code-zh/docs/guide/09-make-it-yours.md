# 变成你自己的

poteto-mode 是一个人的风格。它底下的那些 playbook、路由和 model 角色，配上你自己的风格一样好用。本页覆盖：生成一个个人化的 mode、从一次 session 里捕获教训、修好 repo 让 agent 不再犯同样的错、编写一个聚焦的 skill，以及在你信任它之前先测试一次 skill 改动。

起步比你想象的更小。第一天你不需要很多 skill，甚至不需要这整个 plugin。就平实地写 prompt，看 agent 在哪里失败，当同一个失败出现两次时再加一个 skill 或一条检查。

## 用 `/automate-me` 生成你自己的 mode

```text
/automate-me
```

你不描述自己的风格，因为 [`/automate-me`](../../skills/automate-me/SKILL.md)从你的历史里把它读出来。它挖掘你在当前 workspace 里近期的 transcript，找出重复出现的偏好——你喜欢 reply、委派、验证、code、prose 和流程以什么方式呈现——然后问你这个用户哪些模式才是真正的你。它通过 Cursor 内置的 `create-skill` 流程起草 `.cursor/skills/<your-name>-mode/SKILL.md`，把草稿过一遍 [`/unslop`](../../skills/unslop/SKILL.md)，并从 worktree 开一个 PR，好让你像 review 任何别的改动那样 review 它。

每当你的习惯漂移了，就再跑一次：

```text
/automate-me update my mode skill with everything since its last edit
```

update 模式只挖掘该 skill 上次改动以来的历史。它保留你没有反驳过的规则、修订那些有新证据的，并只为新模式新增章节。

## 用 `/reflect` 捕获一次 session 的教训

在一个教了你点东西的 task 刚结束之后，运行：

```text
/reflect that took way too long. capture what we learned so the next run doesn't repeat it.
```

[`/reflect`](../../skills/reflect/SKILL.md)把 transcript 发给三个并行的 reviewer，然后一个 synthesizer 把提案分成 `Accepted`、`Rejected` 和 `Backlog`，并在任何 skill 改动之前等你批准。只有当一条提案会改变将来的某个决定时，才批准它。一次古怪的 session 是一则轶事，不是一条规则。

## 用 `/correct` 修好环境

当你为同一个错误一次又一次地纠正 agent 时，修复应当落在 repo 里，而不是你的下一条 prompt 里。把这些选项按它们有多大效力排个序：

1. 用架构或更好的数据结构让这个错误无法发生。
2. 用类型挡住它，或者用一条 lint 或 CI 检查，让错误信息点名该怎么修。
3. 用一个 test 抓住它。
4. 把它写进一份文档或 agent 规则。agent 跳过一条规则时什么也不会失败，所以这一条排最后。

人的 review 不在这份清单上。一个必须在每个 PR 上都抓住同一个错误的 reviewer，正是这件事要解决的问题。[`/correct`](../../skills/correct/SKILL.md)来做这件事：

```text
/correct agents keep calling the database client directly instead of going through the repository layer
```

它读近期的 commit、回退、review comment，以及解释 workaround 的那些注释，然后把错误归成类。一个类只要发生过两次就算数。它把最频繁的那些类各用一个 commit 修掉，在能生效的最高层级上修，并证明每一条新检查都在一个真实的旧错误上失败。它还在 agent 指令 file 里维护一张表，把每条规则与强制执行它的东西配对，这样一条没有任何东西强制的规则就会以重复的形式露出来。reply 会列出每个类及其证据、所选层级，以及为什么更高一层行不通。

不带参数运行它，它会自己从历史里找出那些类。`/reflect` 与 `/correct` 分工。`/reflect` 从一次 session 改进 skill。`/correct` 改动 repo，让某个错误类不再回来。当修复是一条新边界时，把它与 `/architect` 配着用。[并行跑许多项目](./07-overnight.md#run-many-projects-in-parallel)里有一段 prompt，能在整个 repo 上同时做这两件事。

## 编写一个聚焦的 skill

当你已经清楚想捕获的 workflow：

```text
/poteto-mode write a skill for verifying database migrations in this repo
```

写 skill 会匹配上 [Authoring or modifying a skill playbook](../../skills/poteto-mode/playbooks/authoring-a-skill.md)，它走 Cursor 内置的 `create-skill`、校验 frontmatter 和链接，并通过 Opening a PR playbook 交付结果。面向 agent 的 prose 比面向人的 prose 标准更高，因为一句没有帮助的话会变成某个将来的 agent 遵循的指令。让 playbook 去守那条标准，而不是随手写一份 `SKILL.md`。

有两种特殊情况各有自己的生成器。一个必须驱动你 app 并证明行为的 skill 是验证 skill，所以改用 [`/create-verification-skill`](../../skills/create-verification-skill/SKILL.md) 和 [`/maintain-verification-skill`](../../skills/maintain-verification-skill/SKILL.md)。一个用 model checker、一次证明或别的 verifier 检查你 code 某条性质的 skill 是形式化验证 skill，所以改用 [`/create-formal-verification-skill`](../../skills/create-formal-verification-skill/SKILL.md) 和 [`/maintain-formal-verification-skill`](../../skills/maintain-formal-verification-skill/SKILL.md)。[验证并交付](./06-verify-and-ship.md#prove-a-property-with-a-formal-verification-skill)覆盖这两种。

## 用 `/technical-writing` 按标准写文档

skill 不是你会交付的唯一一种 prose。对文档、RFC、readme、PR 描述和 commit message：

```text
/technical-writing review the readme changes
```

[`/technical-writing`](../../skills/technical-writing/SKILL.md)施加一套分层标准。它的目标是一段让一个疲惫的工程师第一遍就读懂的 prose。它先选文档的模式（tutorial、how-to、reference 或 explanation），然后逐句打磨：谁做什么、一句话一个想法、不留能被两种方式读解的余地。用它来 review 你或 agent 刚写好的东西，或者在你索要一份文档时就点名它。

## 盲测一次 skill 改动

一次 skill 编辑会影响将来的每一个 session，所以要像对待一次实验那样测试它。采用别人的 skill 也一样。在保留它之前，先确认它在你的工作上让 agent 变好了。

```text
/poteto-mode run the eval playbook on this skill change. same task for both variants, candidates stay blind.
```

当某个 skill 一直漏掉，而你知道它该做什么时，在一个 task 里改动并测试它：

```text
/poteto-mode update the review skill so it flags missing migrations, and eval the change.
```

一开始就要求做 eval，能让这次编辑保持诚实。从一次糟糕 session 写出来的修复，往往会对那次 session 过拟合，而经过许多次编辑之后 skill 就漂了。eval 在它交付之前就抓住这种漂移。

[Eval playbook](../../skills/poteto-mode/playbooks/eval.md)围绕一种失败模式来构建，即观察者效应。一个知道自己被评估的 agent 会表现不同。所以 candidate agent 在一个净化过的目录里拿到一个看起来自然的 task，永远见不到「eval」或「candidate」这两个词，也永远见不到彼此的存在。一个 judge 在中立的标签下给所有输出打分，而「有没有顺着链条追」是从每个 candidate 实际读了哪些 file 来评的，不是从它自己的声称。

在接受裁定之前，自己把每一份输出都读一遍。如果你不同意 judge，先怀疑 rubric，再怀疑你自己的判断。

## 用 `/make-bot-ui` 建一个 bot UI

有一个按情况用的 skill 是给 Grok Bot 用户的。[`/make-bot-ui`](../../skills/make-bot-ui/SKILL.md)建一个小页面，其按钮通过一条 webhook routine 唤醒一个 bot。例如，你可以滑动浏览一条 review 队列，让每次滑动都请这个 bot 对那一条动手。你机器上的一个服务器持有 webhook 的 sender key，所以这个 key 永远不会到达浏览器或 chat。该 skill 还覆盖在 Tailscale 上暴露这个页面。

**陷阱：** 不要在 task 中途因为它闹毛病就去编辑一个 skill。在它自己的 PR 里修，让 task 继续走。一次纠缠进 feature 工作里交付的 skill 编辑，对 review 是不可见的，也无法评估。

下一节：[配方与陷阱](./10-recipes-and-pitfalls.md)。