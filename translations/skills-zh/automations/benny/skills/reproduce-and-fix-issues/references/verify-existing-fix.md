# Verify an existing fix

当某个打开的 pull request 或已 merge 的 commit 看起来很可能修好了这份 report 时，用这个 mode。

现有的那个 artifact 拥有这次修复。去核实它。不要编辑它，不要另写一个竞争的 patch，也不要再开一个 pull request。

## Qualify the artifact

要求恰好一个具体 artifact：

- 一个带有针对该 symptom 的 code 改动的打开的 pull request
- 一个已 merge 的 pull request
- 一个带匹配 code 与意图的已 merge commit

thread 里的一句声称、tracker 状态、branch 名，或没有 pull request 或 commit 支撑的成因假设，都不够。

当存在多个 artifact 时，选那个被 source thread 或 tracker 链接过来的。否则选与受影响 code 最接近的那个，并说明理由。

## Protect the working tree

当 repository 支持时，使用一个隔离的 worktree 或另一个干净的 checkout。不要覆盖 user 的改动。

记录：

- baseline revision
- patched revision
- pull request 或 commit URL
- 两次运行共用的 build 与 environment 输入

使用常规的 `github.com` pull request 链接。

## Measure the baseline

对打开的 pull request，用它的 base branch 作为 baseline。

对已 merge 的修复，当紧邻其前的那个 revision 能构建且代表旧行为时，用它。

通过配置好的 control adapter：

1. 启动 baseline app。
2. 确认 app 与环境正确。
3. 通过真实 UI 动作跑一遍所报告的路径。
4. 观察到那个区分性的 symptom。
5. 重置并再复现一次。
6. 抓取 baseline 的 recording、screenshot 和 state check。

如果该 symptom 在 baseline 上没有出现两次，就不存在 baseline。不要声称该修复有效。

## Measure the patched build

用同一套 environment 和数据构建并运行那个 pull request 或修复 commit。

1. 跑同一条 UI 路径。
2. 重复两次。
3. 确认坏掉的 state 已消失。
4. 确认预期的 state 出现。
5. 抓取 after 的 recording、screenshot 和同一个 state check。

不要止步于编译或 test。after 的结果必须来自一个正在运行的、打过补丁的 app。

## Outcomes

### Confirmed

baseline 复现两次，且打过补丁的 build 两次都解决了它。

- 把 operations status 标为 verified。
- 链接该 artifact。
- 在 source preflight 之后，在 source thread 里发一条简明的回复。
- 包含 before 与 after 的结果。
- 不开任何 pull request。

### Insufficient fix

该 symptom 在 baseline 与打过补丁的 build 上都出现。

- 把 operations status 标为 reproduced but not fixed。
- 链接该 artifact，并说明它没有解决该 symptom。
- 如果这次运行还没有用过常规的 confirmed-repro 更新，就发它。
- 不开任何竞争的 pull request。

### Inconclusive

baseline 不复现、打过补丁的 app 跑不起来，或证据没有展示那个区分性的 state。

- 不要声称成功。
- 说明是哪一半无法测量。
- 把结果留在 operations thread 或运行 output 里。
- 除非有直接提问需要回答，否则在 source thread 里什么都不发。

## Cleanup

停掉两个 build，按保留策略移除临时 profile 与抓取物，并把 repository 恢复到先前的状态，且不丢弃 user 的工作。