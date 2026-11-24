# 验证结果并开一个 PR

「它能编译」不是证据。[Prove It Works 原则](../../skills/principle-prove-it-works/SKILL.md)让 agent 在报告成功之前先检查真实的 artifact，而你的活是让「真实的 artifact」可被检查。本页覆盖：陈述一个完成条件、审查一个测量出来的数字、为你的 app 生成一个验证 skill、对测试很少触及的性质做形式化验证、开 PR，以及把它推到已 merge。

验证在大多数 agent 工作里是最慢的一步，因为它通常是那种要等人来的一步。让 agent 能自己做它，你就不再是瓶颈。跳过它，跑更多 agent 只会给你更多未经检查的工作去 review。

![一架原型飞机在飞真实的测试航线，她拿着秒表给它计时，机器人在拍摄并对照清单核对这次飞行；终端上显示 verify: pass, evidence: captured。](./images/verification.jpg)

## 一开始就说清完成条件

把「做完」是什么意思放进第一段 prompt，用什么措辞都行：

```text
/poteto-mode add json output to this command. text output stays byte-identical, the json parses, both run against the sample project. show me the evidence.
```

现在 agent 有三项可以跑的检查，而不是一种要去取悦的情绪。当 reply 回来时，它应当带着确切的命令与输出。如果某项检查跑不了，一份好的 reply 会说「inconclusive」。一份自信却没有证据的 reply 是一个警示信号。

让检查与改动相配：

- 一处 CLI 改动，跑真实的命令。
- 一处 UI 改动，在运行中的 app 里走一遍被改的流程。当它必须与参考图逐像素相符时，[Visual parity playbook](../../skills/poteto-mode/playbooks/visual-parity.md)拿截图与一份冻结的 baseline 做 diff，而不是靠眼睛判断。
- 一个 parser 或一次迁移，重放一份保存下来的输入。
- 一处 perf 改动，比较改前改后的 profile。
- 一处存储改动，把写入的值读回来。

把证据作为你自己就能检视的 artifact 来要：先失败的 test 再通过的 test、一段改前改后的视频、那份 trace、那张截图。如果修复已经 merge 了，就在 main 上再要同样的检查。artifact 胜过一段貌似合理的解释，因为你可以挑战它，而不必重放整次运行。

对一份你不完全信任的小 diff，[`/blast-radius`](../../skills/blast-radius/SKILL.md)找出它在别处可能弄坏什么。它找出那条让这次改动安全的唯一事实，并靠运行 code 来证明那条事实，而不是靠论证。

## 用 `/benchmark-checklist` 审查一个测量出来的数字

一个改前改后的数字，是最容易不小心弄错的证据。一个热缓存、一侧是 debug 构建，或者计时区间里其实什么都没干，每一样都能造出一个令人信服的加速。在你报告或据以行动一个数字之前，输入：

```text
/benchmark-checklist vet the export speedup before it goes in the pr
```

[`/benchmark-checklist`](../../skills/benchmark-checklist/SKILL.md)问七个问题，每一个都要一次运行给出的证据：

1. 是什么限制了这个数字，为什么它不是两倍？
2. 每一侧是否都按 production 的方式调优后运行？
3. 结果是否突破了一个物理限制，比如磁盘带宽或核数？
4. 有没有东西报错或返回了错误的输出？
5. 它在交替运行下能否重现，中位数与范围是多少？
6. 它在端到端上、在 user 真正等待的那条路径上要紧吗？
7. 那些工作真的发生在计时区间里吗？

裁定会以 faster、slower、no measurable difference 或 inconclusive 回来，并带上运行次数、范围与 limiter。当它无法说出 limiter，或有一侧未调优就跑了，它会说 inconclusive。`/poteto-mode` 已经在 Perf issue 和 Hillclimb playbook 内部跑这份清单，所以你自己输入它的场合是：你在它们之外测了点什么，或者别人的数字看着太好。它就是 [Explain the Number 原则](../../skills/principle-explain-the-number/SKILL.md)的工作形态。

## 创建一个项目验证 skill

上面那条 UI 的要点藏着一个真实需求。agent 需要一种用脚本驱动你 app 的办法。如果你的项目里有，很好。如果没有，运行：

```text
/create-verification-skill
```

[`/create-verification-skill`](../../skills/create-verification-skill/SKILL.md)采访的是 repository，不是你。它弄清楚 user 会碰什么、app 在本地怎么启动、什么能驱动它（优先用现成的 harness，否则用 browser 与 CDP、一个 PTY，或纯 HTTP）、什么证据能证明行为，以及两个实例能否并排运行。它只问你 code 回答不了的事。

它写出 `.cursor/skills/verify-<app>/`，面向 agent 的指令，包含确切的 Launch、Doctor、Drive、Evidence 和 Cleanup 各节，一个用于它所附带的任何 script 的 Helpers 节，再加上 `features/` 下一张 feature map，索引这个 app 做什么、以及什么结果能证明每个 feature 有效。该 skill 随附一份[可参照的 feature-map 示例](../../skills/create-verification-skill/references/feature-map-example/)，含一个 README 索引，每个 feature 一个 file，使用那四个必需的 H2。在交付之前，生成器会把该 skill 端到端地证明一次：启动、doctor 检查、驱动一个 feature、抓取证据、清理，然后确认证据在清理后仍然存在。如果这个证明失败，就不要用这份产出。

从那时起，「在 app 里验证一下」就是任何 agent 在这个 repo 里都能执行的一步，无需再来一轮 setup 对话。当你要证据以某种特定形式呈现时，就在 prompt 里点名它：

```text
/poteto-mode build the bulk-archive action. use /verify-<app> to verify your changes and show me a video and screenshots as proof.
```

```text
/poteto-mode repro this with /verify-<app>. if it repros on main, fix it and show me a video as proof.
```

一旦这个 verify skill 能正常工作，一个 [`/swarm`](../../skills/swarm/SKILL.md)就能按 feature-map 条目把一个完整 pass 拆开，并聚合结果。一群 verifier 也能在足够大的样本上确认一次 perf 胜出，或在 PR 交付前对 app 做模糊测试找回归。

把验证 skill 当作基础设施，而不是一次性的东西。把它 commit，让团队里的每个人和每个 agent 都用同样的方式驱动这个 app。然后[造那个杠杆](../../skills/principle-build-the-lever/SKILL.md)。当 agent 反复写一次性 script 去点这个 app 时，就要一个小型控制 CLI，让该 skill 转而调用它。agent 会更少花 token，而每次运行都变得可重复。一个 agent 用得好的 CLI 有这些特质：

- 少数几个可组合的命令，每个都干真实的活，而不是许多薄命令。
- 任何具破坏性的东西上都带一个 `--dry-run` 选项。
- 子命令逐步揭示功能，而不是一次全摊开。
- 错误信息说明该怎么办。
- 丰富的 `--help` 文本。
- 机器可读的输出，例如 JSON。

顺手把开发环境的搭建也做成可重复的：种子数据、测试 user，以及一条每次都能把环境以同样方式拉起来的命令。

## 让验证 skill 保持诚实

app 会变，feature map 会过期。至少每天跑一次，最好从一个定时 automation 里跑，这样没人需要记着它：

```text
/maintain-verification-skill
```

[`/maintain-verification-skill`](../../skills/maintain-verification-skill/SKILL.md)审计这份生成出来的 skill：每个 feature 一个 read-only 的源码读取者并行跑，然后一次实跑，驱动每一个已映射的 feature。它以三种结局中的恰好一种收尾。`clean` 意味着覆盖完整、没有要交付的。`changed` 意味着一个 PR 的已证明修正，且限于验证 skill 自己的目录内。`blocked` 点名那个阻塞项。它绝不编辑产品 code。如果实跑抓到一处产品回归，它会报告这个回归，而不是用一次文档编辑把它藏起来。

## 用一个形式化验证 skill 证明一条性质

验证 skill 证明的是你驱动得了的那些路径。有些 bug 活在没人驱动的路径上：两次重试重叠了、一个 lock 在写入中途过期了、一次 state 变化乱序到达了。测试很少够到那些 case。对于这类 bug 代价很高的 code，运行：

```text
/create-formal-verification-skill
```

[`/create-formal-verification-skill`](../../skills/create-formal-verification-skill/SKILL.md)从 code 里挑出目标：一个 code 许下的承诺，破掉它会伤害 user，而测试又很少够到那个会破掉它的 case。它挑最强的目标，而不是最容易验证的那个。改成一个领域或一个 bug 从那里起步也行：

```text
/create-formal-verification-skill the job lease and retry logic. a job must never run twice at once.
```

问题决定工具。事件是否可能以坏顺序发生，适合用 model checker 检查该设计的一个小 model，而 TLA+ 是任何语言里这件事的默认选择。code 对每一个输入是否都表现正确，适合一个跑在 code 上的 verifier。如果你的语言上没有 verifier 能跑，agent 会说明这一点，并用生成的输入去测真实 code，而不是拿这个函数的手写 model 去测。一条必须在每个规模上都成立的性质，可能需要一次证明。agent 会告诉你它选了哪个工具、为什么。

它验证一条性质，并展示这条性质在 code 的一个坏变体上失败，因为一个你从没见过它失败的检查什么也证明不了。当当前 code 已经破坏了这条性质时，你会拿到反例——用你 code 的术语呈现的一小串步骤。性质保持原样陈述，所以那个 finding 仍然是一个 finding。除非你要求，产品 code 不会变。

它写一个项目内的 skill，告诉下一个 agent：一次改动是否触及被验证的 code、怎么用一条命令跑这个检查、以及怎么把真实的 bug 与建模错误区分开。在交付之前，生成器会在一处破坏了该性质的临时改动上遵循该 skill 一次，而检查必须抓到它。交接会说清验证了什么、用了哪个工具与什么界限、检查发现了什么，以及它不覆盖什么。一次通过覆盖的是那个 model 或那个界限，不是整个系统。

该 skill 还会记录每个检查覆盖哪些 code，以及该检查最后一次与 code 相符的那个 commit。跳过该 skill 的 merge 与重构，可能让这个检查还在对一份已经消失的 code 的描述通过。它们之后，运行 [`/maintain-formal-verification-skill`](../../skills/maintain-formal-verification-skill/SKILL.md)。它从 code 更新验证、重跑、展示每个更新后的检查仍能失败，并告诉你每个失败是验证侧的漂移还是 code 里的 bug。

## 把行为画成 statechart

用 model 术语呈现的反例说服得了你。拥有这个行为的 PM 或设计师需要按他们的术语看见它。运行：

```text
/statechart what the user sees when they edit a note offline
```

[`/statechart`](../../skills/statechart/SKILL.md)画一张 user 所见内容的 Mermaid statechart，它由一个 TLA+ model 生成，所以图和那份被检查的 model 不会彼此漂移。读者的规则（「你在离线时永远不会看到 Synced」）变成不变量。图上标出每个破坏规则的 state，报告用读者的措辞给出通往它的最短路径。在交接之前，agent 会在真实 code 里重现每条 bug 路径，这样一处建模错误就不会作为 bug 送到读者面前。

## 开这个 PR

```text
/poteto-mode open the pr. small ordered commits, evidence in the description.
```

[Opening a PR playbook](../../skills/poteto-mode/playbooks/opening-a-pr.md)从 worktree 工作，把工作 rebase 成小的有序 commit，清理 diff，unslop 掉 prose，并交回 PR 链接。五个窄的 PR 胜过一个肥的，而叠起来的后续胜过一根越长越大的 branch。

## 用 Babysit 把这个 PR 推到可 merge

一个开着的 PR 会立刻开始积攒阻塞项。检查失败、reviewer 评论、trunk 移动。把这种翻腾交给 [Babysit playbook](../../skills/poteto-mode/playbooks/babysit.md)：

```text
/poteto-mode babysit this pr. get it green.
```

Babysit 盯着这个 PR，在 GitHub 上或在其 CLI 可用时用 Origin CLI 上随附的一个 watcher，并按顺序处理阻塞项：先冲突，再 review thread，最后 CI。每一个已知的修复都攒进一次 push，所以检查只重启一次，而不是每次修复后都重启。comment 的分流是审慎的，因为人和 bot 会把真实的捕获与噪音投进同一份列表。真实的 finding 得到修复，噪音得到驳回，并把反证贴到那个 thread 上。当你只想要状态时，问得小一点，Babysit 会直接回答而不启动那个循环：

```text
/poteto-mode check on pr 123. anything outstanding?
```

Babysit 停在可 merge 处。它绝不 merge，即便一片全绿，因为 merge 是另一个决定。

## 用 Shipping 把 stack 落地

绿不等于安全。当你准备落地时，就明说：

```text
/poteto-mode land the stack.
```

[Shipping playbook](../../skills/poteto-mode/playbooks/shipping.md)在它武装任何东西之前先独立验证每个 PR。每个 PR 一个全新的 agent 实地证明行为，而判定一处改动的 agent 绝不是写它的那个。然后 Shipping 只从底部落地那段连续的已验证运行，默认经 GitHub、在其 CLI 可用时经 Origin，一次一个 PR，并报告第一个打断这条链的 PR。一个已验证的 PR 待在一个未验证的 PR 之上就得等，因为 merge 它会把下面的缺口一并拉上来。

下一节：[在你睡觉时继续干活](./07-overnight.md)。