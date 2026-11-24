### Autopilot-full

**你负责 verdict，绝不负责 PR。一个 owner 带着每个 PR 从 build 走到 merge，而在你的 swarm（它从没写过这段 code）证明将要落地的 code 之前，什么都不 merge。**

一个 verdict 覆盖一个 patch，绿的 CI 覆盖一个 head。step 4 完整跑一次 swarm，之后只对重大改动再跑。`playbooks/shipping.md` 里的 patch-id 规则可以沿用一个 lane 的结果，而每个新 head 都需要它自己的绿 CI。

1. **operator 的 gate 优先。** 授权只覆盖队列里的条目，所以 operator 点名属于他们的条目、以及队列之外的 PR，都停在 merge-ready。请求陈述计划不等于放行。
2. **每个 PR spawn 一个 owner，并把它的工作留在替换者找得到的地方。** 为整个 program 只解析一次 forge。默认用 GitHub CLI（`gh`）。如果 `command -v origin` 成功且 Origin 能解析该 repo，则所有 PR 操作都用 `origin pr`。否则留在 `gh` 上并记下这次 fallback。绝不要要求 Graphite（`gt`）。每个 owner 是一个 Cursor cloud agent，它构建、按 `playbooks/opening-a-pr.md` 开出自己的 PR、在真实 artifact 上证明改动、按 `playbooks/babysit.md` babysit 到绿，并在 step 4 与 step 5 放行之后 merge。

   早点开 PR，好让 CI 和 bot 与工作并行跑。只有在 slop-strip（来自 `cursor-team-kit` plugin 的 `deslop` skill，即 `/deslop`）和 `/no-comments` pass 之后，code 才算就绪，所以完整 swarm 跑的是已完成的 code。然后 rebase 到当前 trunk 并在 self-proof 之前报告 code-ready head，让验证跑在补丁将要落地的那个 base 上。报告之后每一个 head，并在 self-proof、CI 和 babysit 都完成时报告 merge-ready。fix 轮次留在那个 base 上，除非 trunk 冲突、弄坏 CI，或落地了一处对相同 file 的已知并发改动，因为每次 rebase 都会重启 CI。在 code-ready 那次 push 之前、以及任何需要 verifier 的后续 push 之前，对已提交的 head 跑该 repo 针对受影响路径的检查。

   假定这台 VM 会死。开始后不久就 push，并按 **show-me-your-work** skill 在 root agent 的 store 里开一条 decision trail（路径见 system prompt），然后在你开始下一个 unit 之前 push 掉每个已完成的 unit。spawn subagent 的人要把它的 id、状态，以及根据同类历史运行得出的 stuck-after 时长记进那个 store，这样 parent 若死了 root 能去探测它。只 force-push 你自己的 branch，用 `--force-with-lease` 并钉住你最后 push 或接手的那个 SHA；任何不是你做的 push，都停下并向 root 报告。
3. **owner 从 trunk 并行跑，绝不 stack，** 好让每个 PR 各自独立落地。
4. **swarm 验证一次。** 完整 swarm 只跑一次，在 code-ready head 上。另一次完整 swarm 只在新行为、重设计或大块新 diff 时才跑。rebase、解决 merge 冲突或小修复，在新 head 上配单个 verifier；仅措辞改动则一个都不配。按 **swarm** skill 在 code-ready SHA 上 fan out 相互独立的 verifier。它们重跑 gate、通过对应的 control skill（例如来自 `cursor-team-kit` 的 `control-ui` 或 `control-cli`）或一个具名 driver 在真实 surface 上 live 证明承重行为，并审计 diff。没有 live lane，或在你审计 merge-ready report 的凭证之前，verdict 不算干净，因为没有任何 lane 会相信它没查过的 claim。

   只有你能出示的问题才 block 一个 PR：在 head 上失败的运行，或该 PR 弄错的一行 doc。PR 的 base 本来就有的问题（无论 trunk 还是 stack 里它下面那个 PR）不 block，除非该 PR 复制了它或新近触及了它。只有 user 会撞上的 bug、失败的 gate，或写错的已 ship doc 才 block，其余一律进 follow-up。
5. **owner 只 merge 你验证过、且在其将要落地的那个 trunk 上测过的东西。** 光有绿 CI 从不构成 merge 的授权。swarm 各 lane 启动之后，merge prep 要 rebase 到当前 trunk、报告新 head，并等绿的 CI。

   就在 merge 之前，fetch trunk 并问它的改动是否会影响这个 patch，因为为每一次 trunk 移动都 rebase 是永远不会结束的。当将要落地的 code 从未被测过时就 rebase 并等 CI，例如冲突、两侧都改过的 file，或改动了「哪些检查会为该 PR 运行」。若两侧都改过某个 lockfile，而当在 merge 结果上 frozen install 通过、且该 PR 所改的包在那里解析结果与 head 上一致时，就不需要 rebase，因为那次 install 测的正是将要落地的 lockfile，而 install 失败意味着 rebase 必须把它修好。当 trunk 改动了这个 patch 的某个 caller、或该 patch 依赖的某样东西（例如它调用的 code 或某个依赖版本）时，就在 merge 结果上跑该 patch 的检查，通过即 merge。否则直接 merge。如果 trunk 会迫使在 merge prep 之后再第三次 rebase，就 hold 并向 root 报告，由 root 来编排相撞的工作。
6. **运行 root 层。** 任何放松 gate 的动作（例如提高 budget 或加一条 allowlist 条目）都需要 verifier 的证明，然后由你再签一次，因为 owner 正是那个想要变绿的人。在覆盖审批的授权下，这次再签就是那次批准，而 owner 对它的记录指向你的再签，供 lane 核查。被禁用或软失败的检查永远要浮出来，因为它停止守护每一个 case。绝不要给出或绕过 forge 强制的审批，因为没有再签能覆盖它。

   在 operator 放行后，arm `/loop 1h` 来审计到没有委派出去的工作为止，因为长跑会漂移、agent 会悄悄卡住。每个 tick 都从 trunk 重读这个 playbook 并修正漂移，例如一个未报告的 head 或一个未记录的 agent，办法是让它的 owner 把它记录下来，因为漂移是记录上的缺口，不是卡住。它探测每个 agent，直达叶子 lane，并按各自的副作用判断，因为状态文本和 summary 会掩盖一个卡住的孩子。一个 agent 在报错、无法启动 turn，或在超过其 stuck-after 时长后没有任何新动静时，就算卡住；一个到第一个 tick 时既没 push 也没写 trail 行的 owner 同样算卡住。正在等你或 operator 的不算卡住，所以要去应答它。立刻替换卡住的 agent，不要等它的 stop 落地。为 operator 改变了什么的 tick，结尾按 **ketchup** skill 给他们补上近况；什么都没改变的 tick 保持安静。
7. **operator 叫停就立刻收手。** hold 以零写入命令的形式到达每个 owner。各自报告所处位置，并保留其 brief 直到 operator 放行。

**Reply：** 按 **ketchup** skill 给 operator 补近况，涵盖每个 PR 的状态与 verdict、merge 了什么、再签及理由、尚未放行的 operator gate、以及搁置的 follow-up，附上每个 PR 与 trail 的链接。