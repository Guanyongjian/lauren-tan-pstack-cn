# 安装 pstack

本页你安装这个 plugin、挑选 pstack 用哪些 model，并运行你的第一个 task。setup 就是一条命令外加一小段对话。

## 安装 plugin

在一个 Cursor chat 里运行：

```text
/add-plugin pstack
```

Cursor 会确认 plugin 已安装。

在 Claude Code 里，先运行 `/plugin marketplace add cursor/plugins`，再运行 `/plugin install pstack@cursor-plugins`。Claude Code 会给 plugin 命令加前缀，所以本指南里每条命令在那边都要带 `pstack:` 前缀，例如 `/pstack:setup-pstack`，它把 model 规则写到 `~/.claude/rules/pstack-models.md`。[Claude Code 适配说明](../harness/claude-code.md)覆盖其余的差异。

## 挑选你的 model

运行：

```text
/setup-pstack
```

[`/setup-pstack`](../../skills/setup-pstack/SKILL.md) 检测你能用到的 model，询问一个 reasoning budget，把每个角色（code delegate、judgment、review panel）展示给你，并问你想怎么设。回答这些问题。它会写出 `~/.cursor/rules/pstack-models.mdc`，一条每个 pstack skill 都会读的小规则。

默认以 `xhigh` reasoning 运行，与 `large` budget 相同。`unlimited` 会把每个 model 抬到它最高的档，最高到 `max`。Opus 会到 `max`。Grok 最高只到 `xhigh`，所以它就停在那里。`medium` 与 `small` 会降低 reasoning 并少花 token。

你只覆盖你在意的那部分。规则里没有对应行的 role 保留该 skill 的默认值。要恢复某个默认值，删掉那个 role 的行。重跑 `/setup-pstack` 会保留任何 model 与默认值不同的 role。当某个默认值变了，在变动之前写下的规则仍然钉着旧的默认值，所以删掉那些 role 行，或删掉这个 file，然后再运行一次 `/setup-pstack`。

你也许会想，如果我用 Auto 会怎样。把某个 role 设为 `inherit-parent` 或 `auto`，pstack 就会省略 subagent 的 `model` 字段，于是该 subagent 继承你父 chat 的 model。两个值意思一样，都不是 model slug。对一个 panel role 来说，这个值是一个列表，每项跑一个 subagent，所以列表长度决定了 panel 的规模。setup 还会配置 `swarm workers`，也就是每个 `/swarm` worker 的默认 model，除非某次 race 为每一臂都指定了 model。

## 接受验证的提议，或者不接受

在 setup 结尾，`/setup-pstack` 会在你的项目里找一种证明 app 行为的办法，要么是一个 `verify-*` skill，要么是一套现成的 harness。如果两样都没找到，它会提议一次，用 [`/create-verification-skill`](../../skills/create-verification-skill/SKILL.md) 生成一个。

说 yes，它就会写出 `.cursor/skills/verify-<app>/`，一个项目内的 skill，教会 agent 像 user 那样驱动你的 app。它在交付之前会先证明该 skill 能正常工作一次。说 no，setup 就继续往下走。你随时可以自己运行 `/create-verification-skill`。[验证并交付](./06-verify-and-ship.md#create-a-project-verification-skill)深入讲这件事。

如果你是 pstack 新手，说 yes。一个能检查自己工作的 agent 会一直推进，直到检查通过。一个做不到的 agent 会把每一个结果都交回来让你手工检查。在本指南的所有内容里，这个验证 skill 的回报最大。

接着 setup 会提议一次，用 [`/create-formal-verification-skill`](../../skills/create-formal-verification-skill/SKILL.md) 生成一个形式化验证 skill，除非项目里已经有了。测试检查的是有人想到要去写的那些 case。一个形式化验证 skill 会在一个声明的作用域内的每一个 case 上，检查你 code 的某一条关键性质，例如「一个 job 绝不会同时运行两次」。当你的 code 里有并发、重试、state machine 或 parser——即 bug 代价高、而测试很少够到那个会打穿的 case 时——就说 yes。否则说 no，将来情况变了再跑它。[验证并交付](./06-verify-and-ship.md#prove-a-property-with-a-formal-verification-skill)覆盖了它。

setup 之后，新开一个 chat。model 规则对新 session 生效。

## 把成本控制住

pstack 会在 subagent 和 review panel 上多花 token。这就是严谨性的代价。要少花一些：

- 重跑 `/setup-pstack`，挑一个更小的 reasoning budget 或更便宜的 model。主 chat 里用强 model、code 角色里用更便宜更快的 model，是个好搭配。
- 把某个 role 设为 `auto` 或 `inherit-parent`，让它跑在 chat 自己的 model 上。
- 缩短一个 panel 列表。每一项跑一个 subagent。
- 把 `/poteto-mode` 留给需要严谨的活。一处小小的、显而易见的编辑用不上它。

## 运行你的第一个 task

挑一件真实但很小的事，像跟同事描述那样描述它：

```text
/poteto-mode add a --json flag to this command. text output stays byte-identical. verify both.
```

盯着那个 todo list。它的头几项就是所匹配 playbook 的步骤抄了进来，对这个 prompt 来说就是 Feature playbook。如果 `/poteto-mode` 跳过了某个步骤，那个步骤会带着 `skip: <reason>` 留在列表里，好让你看见它选择不做什么。

从这里开始你可以输入正常的追问。要让 `/poteto-mode` 整个 chat 都保持生效，请从 `/` 菜单里选中它，然后按 Option+Enter（Mac）或 Alt+Enter（Windows）而不是 Enter。这样它会成为一个 [Custom Mode](https://cursor.com/docs/skills#using-a-skill-as-a-custom-mode)，每一轮都留在上下文里，直到你退出它。Custom Mode 在 Agents Window 和 CLI 里都可用。直接按 Enter 只会把该 skill 附到一条 message 上，随着 chat 往下走它会淡出。

下一节：[让工作走 `/poteto-mode`](./02-poteto-mode.md)。