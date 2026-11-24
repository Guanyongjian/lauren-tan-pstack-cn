---
name: setup-benny
description: Configure Benny and prepare its triage and repro automations. Use when installing Benny or changing its Slack, tracker, repository, routing, control, model, or budget settings.
disable-model-invocation: true
---

# Set up Benny

Benny 以休眠的 automation pack 形式随 pstack 发布。plugin manifest 只暴露 pstack 常规的 skill root；这个 file 和那两个 operational file 都不是 slash skill。

人通过让 Cursor 指向该 pack 的 `FOR_AGENTS.md` 来进入 setup。bootstrap 流程把整个 pack 复制进目标 repository，然后直接在 `.cursor/automations/benny/skills/setup-benny/SKILL.md` 读这个 file。

Benny 需要外部配置和两个 live 的 Cursor automation。

在 user 明确要求之前，不要创建或更新任何 automation。绝不把密钥值放进 plugin file、prompt 或已 commit 的配置里。

## 1. Copy the pack and enable shared pstack skills

在询问 Benny 配置之前、以及在调用内置的 `/automate` skill 之前，先做这一步。

问清楚哪个 repository 将运行这些 automation。source pack 是包含 `FOR_AGENTS.md` 的那个目录。目的地是 `<target-repository>/.cursor/automations/benny/`。

把整个 source pack 合并到目的地：

1. 目的地不存在时就创建它。
2. 把每个 source file 复制到相同的相对路径。
3. 保留目的地独有的 file。安装或刷新期间绝不删除无关 file。
4. 把 user 自有的配置、feature map 和 routing map 留在目的地之外。绝不覆盖它们。
5. 当源端管理的某个 file 已存在且内容不同时，查看 diff 并在不丢弃本地改动的前提下合并。若归属不明确，停下并在替换之前先问。
6. 核实目的地包含 `FOR_AGENTS.md`、这份 setup file、两个 operational file、它们的 reference，以及 templates。

如果这个 file 本来就是从目标目的地读到的，就把复制视为已完成，并在继续之前跑同一套核验。

把 pstack 加进目标 repository 的 `.cursor/settings.json`。如果该 file 或 `.cursor` 目录不存在，就创建它。

把这一条合并进现有的 JSON 或 JSONC：

```json
{
	"plugins": {
		"pstack": { "enabled": true }
	}
}
```

保留每一项无关的顶层设置和每一个其他 plugin 条目。如果 `plugins.pstack` 已存在，只改它的 `enabled` 值。当该 file 用的是 JSONC 时，保留注释和合法的 JSONC 语法。编辑之后验证该 file。

重新加载目标 project，或在那里启动一个全新的 agent。核实这些共享的 pstack skill 能从 project scope 解析出来：

- `how`
- `why`
- `tdd`
- `unslop`
- `principle-separate-before-serializing-shared-state`
- `principle-minimize-reader-load`
- `principle-guard-the-context-window`
- `principle-sequence-verifiable-units`
- `principle-fix-root-causes`
- `principle-prove-it-works`

不要把从当前 session 或 user 级 plugin 加载的 skill 算进去。这项检查必须表明：目标 repository 里的一个全新 agent 是通过 project settings 拿到 pstack 的。

如果 project 级的 plugin 安装不可用，或任何共享依赖解析不出来，就停下并说明失败。

Benny 的 file 直接从 `.cursor/automations/benny/` 读取。不要把这个目录加进 plugin manifest，也不要指望它的 `SKILL.md` file 出现在 slash-skill 列表里。

告诉 user：在启用任一 automation 之前，`.cursor/settings.json`、`.cursor/automations/benny/`，以及任何被引用的、不含密钥的配置都必须 commit。除非 user 要求，否则不要 commit 它们。

这项检查通过之后，live automation 的 prompt 可以按稳定的 repository 相对路径去读那些已 commit 的 operational file。它们绝不能内嵌 plugin cache 路径，也不能复制 file 内容。

## 2. Adapt the configuration

打开这些被复制的示例：

- `../../templates/configuration.example.yaml`
- `../reproduce-and-fix-issues/references/feature-map.example.md`

在 `.cursor/automations/benny/` 之外创建 user 自有的副本。这些是配置文件，不是 pack file。示例位置：

- project 配置，例如 `.cursor/benny/configuration.yaml`
- project feature map，例如 `.cursor/benny/feature-map.md`
- project routing map，例如 `.cursor/benny/routing.md`
- user 配置，例如 `~/.config/benny/configuration.yaml`
- user feature map，例如 `~/.config/benny/feature-map.md`

为每一个该 automation 可能复现的、面向 user 的 feature 填一节 feature map。保持在 user 视角。不要把实现细节或当前 code 路径冻进这份 map。

不要编辑被复制的示例。pack 刷新可能会在做完冲突 review 之后更新源端管理的 file，但绝不能碰 user 自有的副本。

当某个全新的 automation checkout 需要读到它们时，优先使用目标 repository 里已 commit 的、不含密钥的 file。否则把所需的值转述进 live prompt。只有在内置的 `/automate` skill 确认该 file 已 commit 在 automation 将要运行的那个 repository 里之后，才引用这个 repository file。

对于已 commit 的 pack file 与配置文件，使用稳定的 repository 相对路径。绝不要从 live automation 里引用 plugin 源目录或 plugin cache 路径。

## 3. Fill the required choices

询问或确认：

- source Slack channel ID
- 可选的 operations 或 status channel ID
- repository URL 与默认 branch
- triage 身份或 Slack user ID
- issue tracker 的类型、team、project、label 与 intake status
- tracker adapter skill 或 MCP action
- 可选的 routing map 路径
- 所需的 control skill 名
- 所需的、面向 user 的 feature-map 路径
- status emoji 字符串
- pull request URL 格式
- polling 与 effort 预算
- 用于 triage、repro、code 工作与 media review 的 model slug

只使用在 user 的 Cursor model picker 或受支持的 model 列表里显示为可用的 model slug。不要猜一个 slug，也不要沿用某个私有默认值。

source channel、triage 身份、repository、tracker adapter、control skill 和 feature map 都必须明确。任何必需的值仍然含糊，就让 setup 失败。

在保存之前，对最终的 automation 名称、description 和 prompt shim 套用 pstack 的 `unslop` skill。

## 4. Check integration capabilities

triage automation 需要：

- 对配置好的 source Slack channel 及其 thread 的读权限
- 在该 channel 里的 thread-reply 权限
- 当 report 带媒体时的附件元数据与 file 下载权限
- 通过配置好的 issue-tracker adapter 的检索、读取、创建与更新权限

repro automation 需要：

- 对 source thread 的读权限
- source channel 里的 thread-reply 权限
- 配置好的 operations channel 里可选的 post 与 edit 权限
- repository 的读取与历史访问权限
- 一个能开 draft pull request 的 pull request 动作
- 配置好的 control-adapter skill

读取与发帖优先用配置好的 Cursor Slack action。可选的 `BENNY_SLACK_BOT_TOKEN` 可以补上一个很窄的缺口，例如编辑一条 operations status message 或下载一份附件。把该值存在 secret manager 或环境变量里，不要放进 YAML。

不要使用未记录的集成 endpoint。

## 5. Prepare the routing map

如果 user 想要 reroute 或 owner ping：

1. 把 `../triage-issue-reports/references/routing.example.md` 复制到 `.cursor/automations/benny/` 之外。
2. 把每个 placeholder 换成公开的或组织内部的值。
3. 保持 owner ping 默认关闭。
4. 只对配置过的 feature owner 或已确认的、可能的回归作者允许 ping。

如果没有配置 routing map，triage 可以对一份 report 做分类，但不得猜测目的地或 owner。

## 6. Verify the control adapter

读 `../reproduce-and-fix-issues/references/control-adapter.md` 和 user 填好的 feature map。

确认那个具名 skill 能够：

- 启动目标 app
- 通过真实 UI 导航到每一个被映射的 feature
- 通过声明的 adapter action 演练被映射的 state
- 检查 state 而不强制造出结果
- 抓取 screenshot
- 开始并停止一段录制
- 清理它自己的进程与临时数据

如果任何能力缺失，就让 repro automation 保持禁用。它必须 fail closed，而不是声称一次它并未执行过的复现。

## 7. Prepare the live automations

问清楚这是首次创建，还是对已有 automation 做配置。

把被复制 pack 里的 `../../FOR_AGENTS.md` 读作这两条路径共同的主要 user 意图书。用它来理解两个 trigger、tools、instruction、outcome 和 shared rule。

### First-time creation

一次只创建一个 automation。

对每个 automation：

1. 把对应的、被复制的 prompt template 读作次要的内部源料。
2. 把 `FOR_AGENTS.md`、最终定稿的 Benny 配置，以及该模板的意图，变成一份完整的自然语言请求。
3. 让 live prompt 去读并遵循它在 `.cursor/automations/benny/` 下的那个确切的、已 commit 的 operational file。
4. 使用稳定的 repository 相对路径，而不是 plugin 源路径或 cache 路径。不要把 operational file 的内容复制进 live prompt。
5. 阅读并遵循内置的 `automate` skill。
6. 让 `automate` 去发现 Slack channel、repository 以及已连接的 integration。
7. 让 `automate` 确认被复制的 pack 以及任何被引用的配置文件都已 commit 在 automation 将要运行的那个相同 repository 里。
8. 让 `automate` 展示它的 draft 表、取得批准、询问 readiness，并打开 Automations editor。
9. 先完成这个 automation 的 editor 交接，再开始下一个。

把下面这份完整的 triage 意图交给 `automate`，其中的值按配置填好：

- 名称为 `benny-triage`。
- 每次运行都读并遵循 `.cursor/automations/benny/skills/triage-issue-reports/SKILL.md`。
- 在配置好的 source Slack channel 里，对每一份新的顶层 report 触发。
- 读触发它的那个 thread，并且只在其中回复。
- 使用配置好的 issue-tracker 集成。
- 做分类、检查证据、追原因、去重，并且只为明确的新 bug 创建。
- 用配置好的 `[benny:bug]`、`[benny:performance]` 或 `[benny:other]` 标记以及可选的 tracker URL，结束这一条只在 thread 内发布的 verdict。
- 绝不发 source-channel 的 root message。

triage 的 editor 交接完成之后，把下面这份完整的 repro and fix 意图交给 `automate`：

- 名称为 `benny-reproduce`。
- 每次运行都读并遵循 `.cursor/automations/benny/skills/reproduce-and-fix-issues/SKILL.md`。
- 在配置好的 source Slack channel 里，对同一类新的顶层 report 触发。
- 使用配置好的 repository 与默认 branch。
- 读 source thread，并且只在其中回复。
- 包含 pull request 创建，以及配置好的 tracker、control-adapter 和 feature-map 要求。除非 `automate` 确认同一个 repository 里存在一份合格的已 commit file，否则转述被映射的 user 路径与 state。
- 行动之前先等待一个可信的 triage 标记。
- 通过被映射的真实 UI 把那个确切的 symptom 复现两次，并抓取证据。
- 核实已有的修复，而不在其之上另写。
- 只有在 repro 确认之后才尝试一个可选的有界修复，然后在证明与检查都通过时开一个 draft pull request。
- 绝不发 source-channel 的 root message。

不要重复 `automate` 在 Slack、repository、integration、完整性、认证、draft review、批准、readiness 或 editor 交接方面的工作。

### Existing automations

内置的 `automate` skill 仅用于创建。不要用它去检索、查看或更新已有的 automation。

先完成配置、routing、control-adapter 与 feature-map 的验证。然后把下面这份简明的 editor checklist 交给 user。

对于已有的 triage automation，更新：

- 名称与 description
- 直接指令：读 `.cursor/automations/benny/skills/triage-issue-reports/SKILL.md`
- 新的顶层 Slack report trigger 与 source channel
- Slack thread 的读与回复能力
- issue-tracker 集成
- 转述后的 triage 指令、thread-only 规则，以及 Benny 的 verdict 标记

对于已有的 repro automation，更新：

- 名称与 description
- 直接指令：读 `.cursor/automations/benny/skills/reproduce-and-fix-issues/SKILL.md`
- 与之匹配的 Slack trigger 与 source channel
- repository 与默认 branch
- Slack thread 的读与回复能力
- pull request 动作
- tracker、control-adapter 和 feature-map 要求
- 转述后的 marker 等待、证据、核实与有界修复指令

请 user 直接在各自的 Automations editor 里更新每一个已有的 automation。不要创建替换项或重复项。

### Creation boundary

绝不直接调用 automation 的后端服务或后端 automation 工具。绝不使用携带 draft 字段的 browser URL。绝不构建或打开 Cursor 协议的 deep link。对新建的 automation，唯一可用的完成路径就是内置 `automate` skill 那条经过 review 的 Automations editor 交接。

在 editor 保存之后、且 thread 安全测试通过之前，不要启用任何一个 automation。

## 8. Test thread safety

用一个 test channel 或一份无害的测试 report。

测试之前，确认目标 repository 的 `.cursor/settings.json`、`.cursor/automations/benny/`，以及每一份被引用的、不含密钥的配置文件，都已 commit 在 automation checkout 所用的那个 branch 上。确认两个 live prompt 都指向它们各自确切的、已 commit 的 operational file。如果任何一项检查失败，就停下。告诉 user 这个 automation 目前还不能启用。

核实：

1. triage 存下 root 的 `thread_ts`，并只发一条 verdict 作为 reply。
2. 该 verdict 恰好包含一个配置好的 marker。
3. repro 只接受来自配置好的 triage 身份的 marker。
4. repro 保持同一套不可变的 source 坐标。
5. 不出现任何 source-channel 的 root message。
6. 被委派的 worker 无法使用任何 Slack 写动作。
7. 坐标缺失、parent 被删除，或 preflight 失败时，不产生任何发帖，也不产生任何 tracker issue。

只有当这七项检查全部通过之后，才放行正常流量。