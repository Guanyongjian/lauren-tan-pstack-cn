# pstack in Claude Code

pstack 的 skill 用的是 Cursor 的名字。在 Claude Code 里，每个 session 读一次这个 file，然后用下面的表把 skill 中的每个 Cursor 名字映射过去。`<pstack>` 指那个装着 `skills/` 和 `docs/` 的文件夹。如果某个 Cursor 字段在表里没有对应行，就丢掉它，并说明你丢掉了。绝不传递 tool schema 会拒绝的字段或值。

## Tools

| Cursor | Claude Code |
| --- | --- |
| `Task` | `Agent` |
| `AskQuestion` | `AskUserQuestion`。在 `-p` 模式下它不存在，所以改用纯文本提问。 |
| 打开 todolist | session 提供 `TodoWrite` 时就用它。否则把清单留在你的 reply 里，并在每个阶段更新它。 |
| 运行另一个 pstack skill（`/name` 或「the **name** skill」） | `Read` `<pstack>/skills/<name>/SKILL.md` 并遵循它。`Skill` tool 会拒绝大多数 pstack skill。当你让 user 去输入时，写成 `/pstack:<name>`。 |
| `Grep`、`Glob` | session 没有 `Grep` 或 `Glob` 时，用带 `rg` 的 `Bash`。 |

## Subagent fields

| Cursor | Claude Code |
| --- | --- |
| `subagent_type: generalPurpose` | `subagent_type: "general-purpose"` |
| `poteto-agent`、`comment-sicko` | `pstack:poteto-agent`、`pstack:comment-sicko` |
| `readonly: true` | `subagent_type: "Explore"`。它保留着 `Bash`，所以 brief 里还要写上「do not edit files」，并且事后你要检查 `git status`。 |
| `readonly: false` | `general-purpose`。它保留 session 的 MCP server。 |
| `environment: "cloud"` | `isolation: "worktree"`。点名该 worker 要 checkout 的 branch 或 commit。 |
| `environment: "local"` | 省略。 |
| `cloud_base_branch: <b>` | 告诉该 worker 先 checkout `<b>`。 |
| `run_in_background: true` | 省略。subagent 默认就在后台运行，完成时会通知你。 |
| `resume` | 起一个新的 agent，并把先前的 result 粘进它的 brief。 |
| `file_attachments` | 在 brief 里列出这些路径。 |

## Models

| Cursor | Claude Code |
| --- | --- |
| `claude-<family>-<version>-<effort>[-fast]`，例如 `claude-opus-5-5-xhigh` | `model: "opus"` 配 `effort: "xhigh"`。`model` 只接受 `opus`、`sonnet`、`haiku`、`fable`。丢掉 `-fast`。 |
| 一个 `grok-*`、`gpt-*` 或其他非 Claude 的 slug | 省略 `model`，让该 agent 跑在 session 的 model 上，并说明这一点。 |
| `auto` 或 `inherit-parent` | 省略 `model`。 |
| `pstack-models.mdc` 规则，`~/.cursor/rules/pstack-models.mdc` | `~/.claude/rules/pstack-models.md`。Claude Code 会把它加载进每个新 session，所以它的 role 行已经在上下文里。如果没有，就读这个 file。如果 file 或该 role 那一行缺失，就用 skill 的默认 slug。 |
| 一个 role 值 `<model> <effort>`，例如 `opus high` | `model: "opus"` 配 `effort: "high"`。 |

## setup-pstack

Claude Code 会把 `~/.claude/rules/` 里的每个 `.md` file 加载进每个新 session，所以 `setup-pstack` 把它的规则写在那里。按它的步骤走，但做以下改动：

- Detect。被检测出来的 model 就是 `Agent` tool schema 所列的那些 `model` 值，每个配一个来自其 `effort` 值的 effort。把真实的 model 写成 `<model> <effort>`，例如 `opus xhigh`。effort 是最后一个 token，所以 budget 那一步照原样即可生效。
- Defaults。用上面的行映射每个默认 slug：`claude-opus-5-5-xhigh` 就是 `opus xhigh`，`grok-4.7-xhigh-fast` 就是 `inherit-parent`。
- Write。写出 `~/.claude/rules/pstack-models.md`，不带 frontmatter，然后是那几行 comment、`# budget` 行，以及第 5 步里每个 role 一行。整份 file 覆写。绝不把 role 行放进 `CLAUDE.md` 或 `AGENTS.md`。

## Paths

| Cursor | Claude Code |
| --- | --- |
| `.cursor/skills/`、`~/.cursor/skills/` | `.claude/skills/`、`~/.claude/skills/` |
| `~/.cursor/plugins/`、`.cursor-plugin/plugin.json` | `~/.claude/plugins/`、`.claude-plugin/plugin.json` |
| `.cursor/rules/*.mdc`、始终生效的规则 | `CLAUDE.md`，或在没有 `CLAUDE.md` 时用 `AGENTS.md`。Claude Code 从不读 `.mdc` file。model 规则是例外，见 Models。 |
| `https://github.com/cursor/plugins/blob/main/pstack/<path>` | 当该 file 存在时用 `<pstack>/<path>`。plugin 随附 skills、`docs/guide/` 和 `README.md`。读本地副本，绝不去 fetch。user 需要链接时再把 URL 给他们。 |
| `~/.cursor/projects/<slug>/agent-transcripts/` 下的 transcript | `~/.claude/projects/<slug>/<session>.jsonl`。slug 是 workspace 路径把每个 `/` 和 `.` 换成 `-`，所以 `/Users/you/proj` 就是 `-Users-you-proj`。该文件夹下最新的 `.jsonl` 就是当前 session。它的 `<session>/subagents/` 文件夹存放 subagent 的 transcript。只读本 workspace 的文件夹。 |

## Cursor-only features

Claude Code 没有 Cursor Automations、Bugbot、Cursor cloud agent，也没有内置的 PR tool。当某个步骤需要其中一项时，在你的 reply 里写一行 `Skipped in Claude Code: <step>. <reason>.`，然后继续下一步。不要停下、不要发问、不要重试。当后续步骤需要被跳过的那一步所产出的东西（例如一个 URL 或一个 key）时，留一个 placeholder，并在那一行里点名它。

| Cursor | Claude Code |
| --- | --- |
| Cursor Automations：routine、`update_state` 的 routine 调用、`api2.cursor.sh/automations` webhook、routine 唤醒，以及 `SendToUser` 的密钥请求 | 用那一行跳过。 |
| Bugbot | Bugbot 在 GitHub PR 上的 comment 就是普通的 review thread，所以用该步骤给出的 forge command 去做 triage。当 PR 上没有 Bugbot 的 check 或 comment 时，跳过那种要启动、要等、或要配置 Bugbot 的步骤。 |
| Cursor cloud agent | `environment: "cloud"` 映射到 worktree，见 Subagent fields。跳过那种需要 cloud agent 本体的步骤，例如它的 dashboard 状态或它自己的机器。 |
| 内置的 PR tool | 用该步骤给出的 forge command，例如 `gh pr create`。这不算跳过，所以不要写那一行。 |