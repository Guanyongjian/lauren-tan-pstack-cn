### Opening a PR

在每个其他 playbook 结尾处调用。

**Worktree。** 从一个基于 main 的 git worktree 里工作。subagent 继承它。同一 branch 上的多次 `Task` 调用各得自己的 worktree，或在它们之间执行 `git fetch && git reset --hard origin/<branch>`。branch 是脏的且有无关工作：把改动 patch 出来，换一个干净的 worktree，再 apply 回去。worktree 一团乱：从 main reset，最小化重做。

**Commits。** 多 commit。开 PR 之前 rebase 成小的、有序的 commit。每个 commit 都是未来的一个 PR：可落地，排列起来能讲清这条脉络。修复属于刚做下的那个 commit 时就 amend。可分离的就新开一个 commit。commit body 不要重复 subject。

**PRs。** commit 之前对 diff 跑来自 `cursor-team-kit` 的 `/deslop`，review 之前跑 `/no-comments`。用 `/technical-writing` 写每个 PR title、description 和 commit body（除 Diátaxis 之外的每一层，并应用 STE 词汇规则：每个动作一个词、保留冠词、能用的地方用朴素动词替代 `-ing`），然后再套 `/unslop`。

**Titles。** Conventional Commits 的 `type(scope): subject`，结尾不加句号。type 例如 `feat`、`fix`、`docs`、`refactor`、`test`、`chore` 或 `perf`。scope 是区域，例如 `pstack` 或 `poteto-mode`。subject 简短、祈使式，当某个真实 symbol 承载了这处改动时就点名它，例如 `fix(pstack): retarget opening-a-pr babysit trigger`。

**Descriptions。** PR body 是给手里有 diff 的 reviewer 的一分钟简报，不是实验记录本。它说明这处改动为何存在、省掉了什么、可能弄坏什么，以及你如何证明它可用。写短而简单的句子，标识符要少，不要一大堵文字。这个 body 会成为 squash commit body，所以让那个 commit 保持在约 40 行以内。用 `##` 标题而不是粗体引导句，顺序如下，没有内容的章节直接删：

- `## Why`：问题与做法，1-3 句短句。不要 SHA、不要 rebase 谱系，也不要「based on main」这类前言。
- `## What changed`：1-3 条短 bullet。只有当某个真实 symbol 或路径承载了这处改动时才点名它。rename 或 retarget 要写出两侧。
- `## Scope`：永远要有。1-3 条短项，说明它覆盖什么、有意省掉什么（一个 follow-up、一个已知缺口）。不要 symbol、路径或逐 file 的长篇。
- `## Tradeoffs`：只写 reviewer 否则一定会问的被否决备选。没有真正选择时跳过。
- `## Blast Radius`：1-2 句说明它触及谁或什么，以及为何因此安全或冒险。如果 main 是红的，就陈述让它继续红着的代价。
- `## Verification`：1-3 条 bullet，每条是一个真实的运行路径及其结果。perf：一个带单位的主数字、`before → after`，以及指向 arena 或 swarm 目录的链接以容纳其余。不要 sample-size 方法论、swarm 复述或指标表格。

各章节之后，当 video 或 screenshot 能证明某个 claim 时就附上。完整 SHA、swarm 或 arena 的 lane 复述、lever 校正的长文、逐 file 清单，以及 "CLEAN" verdict，都放进一个链接的 artifact，而不是 body。

**Forge。** 在第一次 PR 操作之前就确定用哪个 forge，并在 create、edit、view、watch 和 merge 上保持这个选择。默认用 GitHub CLI（`gh`）。如果 `command -v origin` 成功且 Origin 能解析该 repo，优先 `origin pr ...`。如果 Origin 不存在或解析不了该 repo，就留在 `gh` 上并记下这次 fallback。不要要求 Graphite（`gt`）。

**内置 PR 工具。** 当运行环境提供内置 PR 工具时，create、edit、retarget 和 mark ready 都通过它，绝不通过 forge CLI。用 CLI 建出的 PR 会缺少该工具所追踪的东西。工具不覆盖的一切都用已解析的 forge 来做；运行环境没有这种工具时，所有 PR 操作都用它。

**Size and stacks。** 宁要五个窄 PR，不要一个大 PR。stack 是一条 base-branch 链。root PR 指向 trunk。每个 child branch rebase 到其 parent 的确切 tip 上，其 PR 则指向 parent branch。parent merge 后，按 `playbooks/shipping.md` step 4 把它的 child 挪到 trunk 上。没有内置 PR 工具时，按已解析的 forge，用 `origin pr create --status open --base <parent-branch>` 或 `gh pr create --base <parent-branch>` 创建 child，用 `origin pr edit <pr> --base <parent-branch>` 或 `gh pr edit <pr> --base <parent-branch>` 做 retarget。只有独立工作才从 trunk 开 branch。做实质性的 stack 工作之前先在 trunk 上 rebase。

**Readiness。** 每个 PR 都以 ready 状态打开，绝不要开成 draft。内置 PR 工具可能默认 draft，所以通过它创建时每次都设 `draft: false`。用 Origin 时传 `--status open`。用 `gh` 时省略 `--draft`。如果 PR 仍然以 draft 打开，就通过 PR 工具把它标为 ready，或按已解析的 forge 执行 `origin pr ready <number>` 或 `gh pr ready <number>`。在提到 PR 状态之前先跑 `origin pr view <number>` 或 `gh pr view <number>`。

**Babysit。** 开 PR 并不会启动 babysit。把 URL 贴出去，继续构建。先把 phase 或 stack 做完。只有当整个 stack 都已存在、且 user 要求时，才跑一次单独的 babysit pass。为每个新 PR 各跑一次 babysit 会拖住构建，并把 check 花在后续批次会重启的那些 commit 上。当反馈偏离意图时就反驳。

开 PR 的 subagent 要跑 `/deslop` 和 `/no-comments`，并贴出 URL。它回到 parent 而不做 babysit，除非它是 Autopilot-full 或 Autopilot-stack 的 owner。那种 owner 的 brief 指派了 babysit loop，也正是 `playbooks/babysit.md` 所等待的那个 ask。owner 在其 code-ready report 之后启动该 loop，报告 merge-ready，并免受此处及 `playbooks/babysit.md` 中那些「必须等整个 stack 建完才 babysit」规则的约束。