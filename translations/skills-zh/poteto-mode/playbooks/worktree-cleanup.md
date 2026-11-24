### Worktree and simulator cleanup

1. 快照并审计。记下 `df -h /`，然后运行 `scripts/worktree-audit.sh [-b <pr-base-ref>] [repo-path]`（principle-build-the-lever）。不带 `-b` 时它对照 `origin/HEAD` 判定 `MERGED`，所以当 PR 指向别的 branch 时要传 `-b origin/<branch>`。它从 `git worktree list` 读路径，绝不手打，因为手打的 `myrepo-worktrees/x` 会漏掉那个位于 `.cursor/worktrees/myrepo/x` 的 worktree（principle-encode-lessons-in-structure）。它按大小、年龄、merge 状态、未提交工作、PR 状态，以及最近一次触及它的 chat，给每个 worktree 分类，然后建议一个 bucket。transcript 扫描很慢，放到后台跑。
2. bucket 只是建议，不是许可。被 pin 的 chat 和在用的 chat 才是真正的权威（principle-prove-it-works）。从 user 或侧栏拿到这个集合，并逐一交叉核对每个候选。工具曾把一个 user 已 pin 的 worktree 标为 `safe`，所以 pin 集合优先。
3. 删除前先核实使用情况。对每一行 `verify-recent-chat`，或任何你有疑问的东西，把 subagent fan out 出去读 transcript，报告该 chat 是否被 pin 或仍在进行、以及它触及哪些 worktree（principle-guard-the-context-window，transcript 属大宗内容）。被 pin 的 chat 会通过后台 subagent 往同级 worktree 里 spawn arena 和 repro 目录树，那些即使名字从没出现在侧栏里也是在用的。按 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。
4. 遇到不可逆损失就暂停。`wip:N` 是 N 处已跟踪的未提交编辑。先把 diff 摆出来征得决定，因为删掉一个干净的 worktree 可以从其 branch 恢复，而未提交的工作就没了。`scratch:N` 是未跟踪的一次性内容，可以安全丢弃，但要点名那些 file。按 Autonomy，干净、已 merge 且不在使用的直接推进。`wip` 与在用中的则暂停。
5. 清理已确认的集合。逐个路径 `git worktree remove --force <path>`。若该目录因被忽略的构建产物而残留，就 `rm -rf` 它，然后 `git worktree prune`。branch ref 仍在，所以不会丢 commit。用 `df -h /` 确认并重新列一遍。
6. Simulator 与其他回收项。Simulator 通常是下一个最大的收益点。`xcrun simctl --set testing delete all`（XCTestDevices 克隆）、`xcrun simctl delete unavailable`，以及先 `xcrun simctl runtime list` 再对旧 runtime 执行 `runtime delete <id>`。需要更多时：Xcode 的 `DerivedData` 与 `iOS DeviceSupport`、`~/Library/Application Support/Cursor`（`state.vscdb.backup`，以及 `snapshots/roots/<root>`——某个以你曾作为 workspace 打开的文件夹命名的 `<root>` 会膨胀）、包缓存（pnpm、uv、brew、yarn）。只清理 user 没说要保留的缓存。

这是唯一一个会删除 user 状态、又没有 code review 来拦住失误的 playbook，所以上面这些 gate 就是那道 review。

**Reply：** 前后各一次 `df -h /` 与回收的空间、被清理的 worktree，以及每个被留下的东西用一行理由说明（被哪个 chat 占用，或有未提交工作）。