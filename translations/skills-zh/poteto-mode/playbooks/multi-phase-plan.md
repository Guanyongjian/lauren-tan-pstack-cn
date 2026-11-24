### Multi-phase or multi-PR plan

**你负责计划，不负责 code。这份计划是一份清单，owner 逐格勾选，operator 依据证据审计。** 计划就是交付物。不要实现。

1. 当改动只是一两个 file、做法也显而易见时，跳过计划。说明这一点然后停下。
2. 动笔之前先用 prototype 把悬而未决的问题定下来。每个问题跑一次 `playbooks/prototype.md`。把 branch、SHA 和 screenshot 留给 Appendix A。只就任何运行都定夺不了的产品或偏好取舍去问 operator。给出选项（**never-block-on-the-human** 原则 skill）。
3. 在 subagent 里探索，用 `subagent_type: "poteto-agent"` 并按 Subagents 一节显式指定 model（**guard-the-context-window** 原则 skill）。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。各自返回 file 指针、约定、test command 和入口点。不要内联大段内容。
4. 把下面的骨架复制进计划 file 并填满每个 placeholder。除非 operator 指定路径，否则把该 file 写在 agent store 的 `docs/` 下。保留每个标题、每个子块及其顺序。一个 PR 一节。一个 PR 就是一处改动，带它自己的证据（**sequence-verifiable-units** 原则 skill）。在 **How to read this** 里点名执行的 playbook。运行可能 merge 时选 `playbooks/autopilot-full.md`。由 operator 落地 PR 时选 `playbooks/autopilot-stack.md`。常设 program 用 `playbooks/orchestrate.md`。
5. 全程按 `/technical-writing` 写，然后套 `/unslop`。正文只用一个 Diátaxis mode，即 how-to。Appendix 承载 explanation 与 reference。每个标题陈述 task 或 finding。不要长横线。不要句中冒号。
6. 运行 `node pstack/skills/poteto-mode/scripts/check-plan.mjs <plan.md>` 并修掉它打印的每一行（**encode-lessons-in-structure** 原则 skill）。
7. 交回。贴出计划路径和 script 的 output，然后停下。执行在 operator 显式放行时、按计划点名的执行 playbook 开始。

**Verification。** 只有 test 不够作为验证。一个 PR 只有在它的 unit、live 和 perf 三块都勾选之后才算已验证（**prove-it-works** 原则 skill）。那句话就是验证规则。每个 verification block 都以它开头。live 块是强制的。在 PR head 上十条 lane 通过对应的 control skill 驱动真实 surface，按 **swarm** skill，跑在 `swarm workers` model 上（默认 `grok-4.7-xhigh-fast`）。每条 lane 是一个格子，含一个具体 scenario、它保存的 screenshot 和它的 pass predicate。其中一条 lane 是 **Regression lane against trunk。** 它在 trunk 和 head 上跑同一个承重 scenario。如果 trunk 没有这个 feature，该 lane 记录这一事实，并改为对 diff 新增的行为加上 user 所等的 end state 设 gate。perf gate 是双向的。trunk 和 head 都必须产出那具名指标。如果 trunk 缺少该 feature，还要单独隔离 diff 新增的工作，并为这部分工作加上 user 所等的 end-to-end 状态设一个绝对预算。不要在不同质的 scenario 之间声称比值。perf 块点名指标、交错进行的 probe、先测得的 trunk baseline，以及带失败数字的那条规则。改动交互的 PR 要过 review gate。operator 在 chat 里带着 screenshot 和 video 于 merge 前 review 它。不改动交互的 PR 写 `**Review gate.** None. <PR id> is not review-gated.`，其下不放格子。

**Control skill。** 按 surface 选。Browser、Electron 和 web UI 用来自 `cursor-team-kit` 的 `control-ui`。CLI 和 TUI 用来自 `cursor-team-kit` 的 `control-cli`。原生移动端用该 repo 拥有的、任何能驱动 simulator 的 skill。触及两个 surface 的 PR 在两边都要有 lane。没有 control skill 的 surface 是 Appendix C 里的一条风险，其 live 块仍要点名每条 lane 如何驱动它。

````markdown
# <Program> plan

<Under ten lines. What changes, for whom, the rule the program enforces, and the PR ids in order.>

## How to read this

One box is one unit of work. Every box names the evidence that checks it. A nested box is a sub-step of the box above it. Check a box only when its evidence exists, a file, a log line, a screenshot, a test run, or a SHA. The body is a how-to. The appendices explain and record.

The program runs `pstack/skills/poteto-mode/playbooks/<execution playbook>.md`. <Who merges, and which PR ids are the operator's items that stop at merge-ready.>

Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

## Program checklist

### Arm the program

- [ ] State the protocol and this plan to the operator, then stop. Start execution only on the operator's explicit go.
- [ ] Read these from trunk at program start. Re-read them at every tick.
  - [ ] `git show origin/main:pstack/skills/poteto-mode/playbooks/<execution playbook>.md`
  - [ ] `git show origin/main:pstack/skills/swarm/SKILL.md`
  - [ ] `git show origin/main:<control skill path>`
  - [ ] `git show origin/main:pstack/skills/poteto-mode/playbooks/opening-a-pr.md`
  - [ ] `git show origin/main:pstack/skills/<each other leaf skill the program uses>`
- [ ] On the operator's go, arm the audit tick as `/loop 1h` with the tick prompt below. Never leave the cadence to memory.
- [ ] Use this tick prompt, verbatim. "Re-read the execution playbook from trunk. Audit the operation against it and fix drift in this tick. Probe every active lane and judge progress by side effects only. Stand down a stuck lane and dispatch its replacement now. Then post a short status message to the operator in chat only when the audit found a tracked change that no earlier status message reported, such as a PR opened, a code-ready head, a round launched or closed, a verdict, a merge, a stuck agent and the action taken, a blocker added or cleared, or a decision only the operator can make. Name every such change and nothing else. Do not repeat a table, the merged list, or an unchanged blocker. If the audit found none, end the turn with no reply text. Either way, log this tick's row in your decision trail. The row names the items reported, or none."
- [ ] On the operator's hold or stand-down, send every owner a zero-writes order at once.

### Spawn owners

- [ ] Spawn one owner per PR with the full lifecycle the execution playbook names.
- [ ] Follow this dependency graph. Start dependent work only after its parent merges, or base it on the parent branch when the execution playbook stacks.
  - [ ] <PR id> and <PR id> are independent and first. Both branch from `main`.
  - [ ] <PR id> after <PR id>.
- [ ] Hold the file boundaries. <PR id or class> touches only `<glob>`.
- [ ] Hold the review gate. <PR ids> change an interaction. They wait for the operator's review in chat with screenshots and a video before merge.

### PR mechanics, for every PR

- [ ] Resolve the forge once. Default to `gh`; if `command -v origin` succeeds and Origin can resolve the repository, use `origin pr` for every PR operation. Record any fallback to `gh`. Never require `gt`.
- [ ] Open the PR ready, never draft, per **Opening a PR**. Use the run's built-in PR tool when it has one, else `origin pr create --status open --base <base-branch>` or `gh pr create --base <base-branch>` according to the resolved forge. A stack child targets its parent branch.
- [ ] Run the repo's lint and typecheck once before the PR-facing push. Push with hooks on.
- [ ] Run `/deslop` before each commit and `/no-comments` before review.
- [ ] Triage every Bugbot and security-reviewer comment per `../references/bugbot-triage.md`.
- [ ] Rebase onto current trunk before the code-ready report and babysit. Keep that merge base in fix rounds. Rebase again only at merge prep, on a `git merge-tree` conflict with trunk, on a CI failure that comes from a change on trunk, or when a known concurrent change to the same files lands.

### Verdict and merge, for every PR

- [ ] A full swarm runs once, at the code-ready head. Another full swarm runs only for new behavior, a redesign, or a large new diff. A rebase, a merge-conflict resolution, or a minor fix gets a single verifier at the new head, and a wording-only change gets none. Run each full swarm per `pstack/skills/swarm/SKILL.md`. One gates lane. The ten live lanes from the PR's **Verify, live** block. The perf lane from its **Verify, perf** block. Two or more audit lanes, each with its own focus, that read the diff and the receipts and distrust the PR body. The root audits the receipts in the merge-ready report before the verdict.
- [ ] Judge every finding by the execution playbook's blocking rule. The verdict is clean when none blocks. A failure on trunk behavior in a lane marked `Regression lane against trunk.` is recorded against trunk and does not block the PR. A new head gets a fresh verdict, except for results that stay valid under the patch-id rule in `playbooks/shipping.md`.
- [ ] <The merge or handoff rule from the execution playbook, with the patch-id rule from `playbooks/shipping.md`.>

### Boot recipe, for every live lane

Each live lane runs on its own cloud VM at the PR head. Drive through `control-ui` or `control-cli` from `cursor-team-kit`.

- [ ] `git fetch origin <head-branch> && git checkout <head SHA>`.
- [ ] <Start the backend and the surface. Wait for ready.>
- [ ] <Deliver input only through the control skill's commands. Name the read-only diagnostics.>
- [ ] Save every screenshot to `/tmp/swarm-<pr-id>/worker-<n>/<slug>.png` and return the paths with the report.

## <Task as a verb phrase> (<PR id>)

**Depends on.** <PR id, or None.>

**Files.**

- [ ] Edit `<path>`.
- [ ] Create `<path>`.
- [ ] Delete `<path>`.

**Build.**

- [ ] <One change. Name the symbol and the file.>

**You see.**

- [ ] <One observable result, with the exact log line or screen state.>

**Verify, unit.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] <Test file and the case it gains.> Run `<command>`.

**Verify, live.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked. Ten lanes on `<swarm workers model>` at the PR head, per the boot recipe.

- [ ] Lane 1. Regression lane against trunk. Run <the same load-bearing scenario> at trunk and head. If trunk lacks the feature, record that and gate <the behavior the diff adds plus the end state the user waits for>. Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 2. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 3. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 4. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 5. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 6. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 7. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 8. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 9. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 10. <Scenario.> Save `<slug>.png`. Pass when <predicate>.

**Verify, perf.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] Metric. <What is measured at both trunk and head. If trunk lacks the feature, also name the diff-added work and the end-to-end state the user waits for.>
- [ ] Probe. <The command or procedure, run at trunk and at the head, interleaved. Both sides must produce the metric.>
- [ ] Baseline. Record the trunk <value> first.
- [ ] Rule. <Head against trunk, with the number that fails. If the scenarios differ, add absolute budgets for the diff-added work and the user-visible end state instead of an invalid ratio.>

**Review gate.** The operator reviews before merge.

- [ ] Copy lane <n> screenshots into `<media path>/<pr-id>-review-<slug>.png`.
- [ ] Record a 30 to 60 second video of the change on a lane VM. Save it as `<media path>/<pr-id>-review.mp4`.
- [ ] Post the screenshots and the video in chat. Stop at merge-ready. Wait for the operator's click.

**Merge.**

- [ ] Root's clean verdict at the exact head SHA.
- [ ] Bugbot triage done.
- [ ] Rebased onto current trunk after the verdict, patch-id unchanged.
- [ ] <The owner squash-merges its own PR, or the root appends it to the base-branch stack and the operator lands it bottom-up.>

## Close the program

- [ ] Every box above is checked with its evidence.
- [ ] Reply to the operator with the report the execution playbook names.

## Appendix A. Prototype evidence

<Each open question a prototype answered, with the branch, the SHA, and the artifact links. Each question that stays unproven.>

## Appendix B. Alternatives rejected

<Each approach weighed and why it lost.>

## Appendix C. Risks

<Each risk with the PR it lands in and what the owner watches.>

## Appendix D. Links and reading list

<Docs to read before editing. Which PRs get `pstack/skills/how/SKILL.md` and `pstack/skills/interrogate/SKILL.md`. The trail per `pstack/skills/show-me-your-work/SKILL.md`.>
````
**Reply：** 计划路径、各 PR id 及其依赖与被 review gate 覆盖的集合、prototype 证明了什么、什么仍未被证明，以及检查 script 的 output。
