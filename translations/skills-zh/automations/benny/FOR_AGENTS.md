# benny automation intent

## what i want to automate

我想要两个 cursor automation，它们在同一个 slack issue channel 里协同工作。

### automation 1: triage issue reports

- trigger：当有人在我配置好的 source slack channel 里发一份新的顶层 report 时，我想让这个 automation 从那份 report 开始，并保留它原来的 thread 坐标。
- behavior：我想让它读 thread 和附件，把该 report 分类为 bug 或性能问题、feature 请求、疑问或反馈、或 reroute，并在路由之前追出大概的归属层。
- tracker：我想让它在配置好的 tracker 里搜重复项，更新一个确信的重复项，并且只为一个明确的净新增 bug 建 ticket。
- tools：我需要 slack thread 的读与回复权限、我配置好的 tracker 集成，以及我可选的 routing map。
- outcome：我想在 source thread 里只得到一条回复，带一句简短的 verdict 和 `[benny:bug]`、`[benny:performance]` 或 `[benny:other]`。bug 或 performance 标记可以附上 tracker url。
- boundary：我绝不想让这个 automation 在 source channel 里发 root message。

### automation 2: reproduce and fix confirmed bugs

- trigger：我想让这个 automation 从同一份新的顶层 report 开始，或从 setup 时选定的另一个受支持的 trigger 开始，然后在原 thread 里等待那个可信的 triage 标记。
- gates：当某事已明确有人认领修复时，我想让它停下。如果某个已有的 pull request 或已 merge 的 commit 可能修好这份 report，我要的是核实，而不是一个竞争的改动。
- behavior：我想让它用我配置好的 control adapter 和 feature map，通过真实 ui 把这个确切的 symptom 复现两次，并抓取 screenshot、video，以及一次 read-only 的 state 交叉核对。
- fix：我想让它核实已有的 pull request，而不在其之上另写。repro 确认之后，它可以尝试一个有界的根因修复，在 test 廉价时用 tdd，对 blast radius 做 smoke，并且只有在前后对照的证明通过时才开 draft pull request。
- tools：我需要 slack thread 的读与回复权限、repository 与历史访问权限、创建 draft pull request 的能力、我配置好的 tracker，以及我的 control adapter。
- outcome：我想在 source thread 或可选的 operations thread 里得到证据和一个已验证的结果，外加一个可选的 draft pull request。更新应当简洁。
- boundary：我绝不想让这个 automation 在 source channel 里发 root message。

### shared rules

- 我想让 source channel 和 root thread 坐标在整次运行期间保持不可变。
- 我把 utility 和 debug bot 当作证据，而不是委派对象或修复归属方。
- 我允许 subagent 协助，但它们不能向 slack 发帖，也不能拿到 slack 凭据。
- 我想让这整个 pack 被 commit 到目标 repository 的 `.cursor/automations/benny/`。其中的 `SKILL.md` file 是直接的 automation 指令，不是注册的 plugin skill。
- 我只想通过目标 repository 已 commit 的 `.cursor/settings.json` 启用 pstack，且仅用于共享依赖，例如 `how`、`why`、`tdd`、`unslop` 以及所需的原则 skill。
- 我想让每个 live automation 的 prompt 直接读它那份已 commit 的 operational file。我不要 plugin cache 路径、被复制的摘录，也不要 slash-skill 发现机制。
- 我把 user 自有的配置、feature map、routing map 和密钥都留在 `.cursor/automations/benny/` 之外，这样 pack 刷新不会覆盖它们。
- 当 channel 坐标、tracker 访问、control adapter 或 feature map 缺失或不确定时，我想让两个 automation 都 fail closed。
- 我只要 draft pull request。不要 merge，也不要 deploy。

### my configuration

- source slack channel：`<channel>`
- 可选 operations channel：`<channel or none>`
- repository 与默认 branch：`<repo>`、`<branch>`
- tracker：`<type, team, project, labels, intake status>`
- routing map：`<path or none>`
- triage 身份：`<slack identity>`
- control skill：`<configured skill or adapter>`
- feature map：`<committed same-repo path outside the copied pack, or behavior to paraphrase>`
- models：`<triage, reproduce, code, media review>`
- status emoji 字符串：`<seen, reproducing, reproduced, blocked, fixing, failed, pull request opened>`
- budgets：`<polling, verdict wait, follow-up, repro, rejection, fix>`
- 可选的 bot token 能力：`<none, file download, or editable operations status>`

从 [`configuration.example.yaml`](./templates/configuration.example.yaml) 和 [`feature-map.example.md`](./skills/reproduce-and-fix-issues/references/feature-map.example.md) 起步。把它们复制到这个 pack 之外并填好，例如放在 `.cursor/benny/` 下。把密钥值存放在 secret manager 或环境变量里。

## for the agent

人通过让 cursor 指向这个 file 来进入 setup。不要去找或调用一个被发现的 benny slash skill。

1. 问清楚哪个 repository 将运行这些 automation。
2. 把这个 `FOR_AGENTS.md` 所在的目录当作 source pack。
3. 把整个 source pack 合并到 `<target-repository>/.cursor/automations/benny/`。
4. 保留每一个目标端独有的 file。绝不删除无关 file，也绝不覆盖 user 自有的配置、feature map 或 routing map。
5. 当源端管理的路径上已存在一个不同的目标 file 时，review 这个 diff 并在不丢弃本地改动的前提下合并。若归属不明确，停下并在替换之前先问。
6. 核实被复制的 `FOR_AGENTS.md` 与 `skills/setup-benny/SKILL.md` 存在于目标 repository。
7. 直接从目标 repository 阅读并遵循 `.cursor/automations/benny/skills/setup-benny/SKILL.md`。

我想让你把这一条合并进目标 repository 的 `.cursor/settings.json`：

```json
{
	"plugins": {
		"pstack": { "enabled": true }
	}
}
```

保留每一项无关的设置和 plugin。当现有 file 用的是 jsonc 时，保留注释和合法的 jsonc 语法。

我想让一个以目标 repository 为根的、全新的 agent 来做核验。确认 pstack 的 `how`、`why`、`tdd`、`unslop` 以及 benny 所用的原则 skill 在 project scope 下能解析出来。不要把从当前 session 或 user 级安装加载的 skill 算进去。

如果 project 级的 plugin 不可用，或任何共享依赖解析不出来，就停下并说明哪里失败了。不要为了让它出现而把 `.cursor/automations/benny/skills/` 加进 plugin manifest，也不要指望它的 file 出现在 slash-skill 列表里。

告诉我 `.cursor/settings.json`、`.cursor/automations/benny/`，以及任何被引用的、不含密钥的配置，必须在启用任一 automation 之前就 commit。在我明确要求之前，不要创建或更新任何 automation。

首次创建时，对 triage 用一次内置的 `/automate`，对 repro and fix 再用一次。在开始第二个之前，先完成第一个 automation 的草稿 review、批准、readiness 检查以及 Automations editor 的交接。

把这份意图和最终的配置转述进每一份草稿。triage 的 prompt 必须阅读并遵循 `.cursor/automations/benny/skills/triage-issue-reports/SKILL.md`。repro 的 prompt 必须阅读并遵循 `.cursor/automations/benny/skills/reproduce-and-fix-issues/SKILL.md`。只有在 `/automate` 确认这些 repo 相对路径已 commit 在 automation 将要运行的那个 repository 里之后，才使用它们。

对于已存在的 automation，不要用 `/automate` 去查看或更新它们。先验证配置，然后使用被复制的 setup file 里那份简明的 field checklist，好让我能在各自的 editor 里直接编辑每个 automation。不要制造重复项。