# 配方与陷阱

值得抄走的 prompt，然后是每个人都会犯一次的错误。换上你自己的路径和完成条件。这些配方是故意写得随意的。实践中就是这么打进去的，而这些 skill 读意图读得很好。

![她品尝一道做好的菜，机器人们照着一个配方盒在烹饪，柜台上方钉着的卡片写着 /how、/tdd 和 /loop。](./images/recipes.jpg)

## 理解一个陌生的子系统

```text
use /how first to understand how this initialization works. then use /why to figure out why it broke recently.
```

先看机制，再看历史。每个 skill 的报告都会告诉你它搜了哪些来源，所以你清楚这个答案是建在什么之上的。

## 动 code 之前先复述一份嘈杂的报告

```text
/poteto-mode read this thread. restate the underlying issue in your own words, in plain english. don't change any code yet.
```

读错了会在复述里暴露出来，在那里纠正只花一条 message。把你自己的理论留给自己，直到 agent 陈述了它自己的。`/in-your-own-words` 只要那段复述，不带 playbook。

## 发送之前先把 prompt 磨锋利

```text
/sharpen write the onboarding doc for the new billing service.
```

agent 会点名一个专家会做而你没要求的事、他们会从什么原始素材起步、他们的方法与工具，以及一次证明结果正确的旁证。它把你的 prompt 重写成恰好要这些，交回来，而且不做这个 task。等它读起来合适时，就把重写版发出去。

## 做原型再挑

```text
/poteto-mode prototype a few options for the settings layout. put them behind a switcher and send me screenshots of each.
```

你从真实能跑的东西里挑，而不是从描述里挑。agent 顺便就把自己那些布局和时序上的问题回答了。

## 把定下来的设计变成计划

```text
/poteto-mode turn this design into a plan. small verifiable PRs, each with its own proof.
```

只在设计定下来之后才要。计划就是交付物，它会点名接下来由哪个 playbook 执行它。

## 对一份设计要第二意见

```text
ask /arena for a second opinion on this thread and our approach
```

你现在的设计变成若干 candidate 中的一个，而综合结果会告诉你这个 panel 找到了更好的，还是确认了你原有的那个。相对于一个反向代价高昂的设计，这几乎不花什么。

## 并行检查互相独立的切片

```text
/swarm check every package under packages/ against its check.sh. one worker per package. one report.
```

每个 worker 拥有一个 package。父级等每一个切片结束，交回一份 `PASS`、`ISSUES` 或 `BLOCKED` 的报告，而不是各个 worker 的原始倾倒。

## 审慎地 review 一个 branch

```text
/interrogate the whole branch, but skeptically. don't change anything yet. no nitpicks unless it's an actual bug or regression in behavior.
```

那些限定词是干实事的。「don't change anything yet」让它保持 read-only，而挑刺规则预先滤掉噪音，好让被证实的 finding 值得你的时间。

## 通过一个失败的 test 修一个 bug

```text
/poteto-mode repro the duplicate write first. if there's a cheap test path, /tdd it. then fix and rerun.
```

「if there's a cheap test path」要紧。硬用一个脆弱的 mock 挤出一个 test，证明力不如跑真实命令，而 playbook 是可以说这句话的。

## 带证据地复现并修复一份报告

```text
/poteto-mode repro this with /verify-<app>. if it repros on main, fix it and show me a video as proof.
```

「if it repros on main」让这次 run 在 bug 已经消失时能提前停下。那段视频让你在读 diff 之前先检查这个修复。

## 证明一条测试很少触及的性质

```text
/create-formal-verification-skill the retry queue. a message must never be delivered twice.
```

你得到一条在一个声明作用域内每个 case 上都被检查过的性质，如果 code 已经破坏了它，就得到一个用你 code 的术语呈现的反例，以及一个项目内的 skill，供下一个 agent 在那段 code 的任何改动上运行。

## 发布之前先审查一个数字

```text
/benchmark-checklist vet this 40% speedup before it goes in the pr description
```

你会得到 faster、slower、no measurable difference 或 inconclusive，并带上运行次数、范围和限制这个数字的因素。

## 不再反复纠正同一个错误

```text
/correct agents keep adding new config flags without registering them in the schema
```

修复以架构、一个类型、一条 lint 或一个 test 的形式落进 repo，所以下一个 agent 犯不了这个错。

## 只问怎么做，不启动工作

```text
/poteto-help how do i get poteto-mode to stay on every turn?
```

你得到一个答案、一段可以发送的 prompt，以及一个指向来源的链接。在你发送那段 prompt 之前，什么都不会跑。

## 你不在时让一次 run 保持诚实

```text
im going to bed, keep going autonomously until every fixture passes. do not stop. keep a decision log i can audit in the morning.
```

完整的合同在[隔夜那一页](./07-overnight.md)。等 task 和完成条件已经在这段对话里时，用这个短版本就行。

## 把一次漂移的 run 拨回来

掌舵的 prompt 只有一行：

```text
i said the goal is to repro. i did not ask for a fix yet.
```

```text
apply prove it works. show me the real output, not the build log.
```

```text
/unslop that, no emdashes
```

你很少需要更多的字。你需要的是正确的名字，而[原则那一页](./08-principles.md)就是那套词汇。

## 用平实的话拿到 reply

```text
/bro
```

这就是整段 prompt。[`/bro`](../../skills/bro/SKILL.md)把上一条 message 像一个人对另一个人说话那样重述一遍，不用术语，更短。当一条 reply 技术上很周全而你还是不知道它说了什么时，用它。

## 同步一场你放着跑了的 chat

```text
/ketchup
```

[`/ketchup`](../../skills/ketchup/SKILL.md)用平实的话告诉你自你上一条 message 以来变了什么，然后列出每一项在等你的决定，带上它的选择、证据和风险。它在报告的同时什么都不改。

想改成看同步视频，运行 [`/ketchup-video`](../../skills/ketchup-video/SKILL.md)。它用一段带字幕的短幻灯片视频展示发生了什么，并在下面用文字列出在等你的那些决定。

## 那些陷阱

- **在 prompt 里列举 skill。**「先 use /how，再 /architect，然后 /arena」会打乱 playbook 已经排好的步骤。陈述目标与约束。只有在想覆盖某个默认选择时才点名一个 skill。
- **含糊的完成条件。**「做得更好些」没给 `/loop` 任何可检查的东西。给一条能通过或失败的命令或 artifact。
- **一上来就说出你对成因的理论。** agent 会朝你指的地方搜。先让它复述问题，再分享你的直觉。
- **采用第一版设计。** 一次尝试就把 model 想到的第一个形状锁死了。要原型或 `/architect`，并从证据里挑。
- **打磨一份抽象的计划。** 对一份背后没有 code 的计划做对抗性 review，会臆造出永远不会发生的风险。用原型把悬着的问题定下来，再去 review 实际建出来的。
- **并行的 agent 共用一个 worktree。** 它们会互相覆盖，而且没人分得清哪个 agent 改了什么。把它们作为 cloud agent 跑，或者说明「每次尝试各用自己的 worktree」。
- **在你信任这个循环之前就开循环。** 一个无法自证工作的循环只会把未经检查的工作做得更快。先把验证 skill 弄好。
- **信任一个未审查的数字。** 一个热缓存或一条被跳过的 code 路径都能伪造一个加速。在这个数字去任何地方之前先跑 `/benchmark-checklist`。
- **手工纠正同一个错误。** chat 里的一次纠正只帮一次 run。`/correct` 修好 repo，让之后任何 run 都不再重复它。
- **把 `/arena` 用在覆盖上。** `/arena` 重复同一份设计或 code brief，然后挑一个 base 并嫁接最好的部分。`/swarm` 把切片或声明过的竞速臂分开，并聚合一份报告。
- **接受每一条 review comment。** bot 和人都会把真实的捕获与噪音投进同一份列表。`/interrogate` 只保留重跑能证实的 finding，并列出它丢弃了什么、为什么，而你可以两边都推翻。
- **把 `auto` 当成一个 model slug。** `auto` 与 `inherit-parent` 的意思是「省略 model 字段，让 subagent 继承父 chat 的 model」。[安装](./01-setup.md)覆盖了各个角色。
- **凭一次全绿的 build 报告成功。** 一次 build 证明的是它能编译。要真实的命令、流程、存下来的值或 profile，并期待证据就摆在 reply 里。
- **随手写一份 `SKILL.md`。** 让它走 [Authoring or modifying a skill playbook](../../skills/poteto-mode/playbooks/authoring-a-skill.md)，好让校验与 review 发生。

这就是本指南。如果你是跳着读的，回到[安装](./01-setup.md)去跑一个真实的 task。习惯是从使用里扎下根的，不是从阅读里。

回到[指南目录](./README.md)。