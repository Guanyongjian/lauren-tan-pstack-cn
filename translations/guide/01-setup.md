# 第 1 章：安装与配置 P-Stack

> 上游来源：[docs/guide/01-setup.md](https://github.com/cursor/plugins/blob/main/pstack/docs/guide/01-setup.md)  
> 研究范围：安装、模型角色配置、推理预算、验证能力初始化和首次任务。

本章介绍如何安装 P-Stack、选择各个 Agent 角色使用的模型，并完成第一个任务。整体过程是执行一条安装命令，再进行简短配置。

## 1. 安装插件

在 Cursor Chat 中执行：

```text
/add-plugin pstack
```

Cursor 会确认插件安装完成。

在 Claude Code 中，先添加插件市场，再安装插件：

```text
/plugin marketplace add cursor/plugins
/plugin install pstack@cursor-plugins
```

Claude Code 会给插件命令增加 `pstack:` 前缀。例如，`/setup-pstack` 对应 `/pstack:setup-pstack`。Claude Code 适配器还会处理 Cursor 与 Claude Code 之间的其他差异。

注意：第三方市场的自动更新默认关闭。需要时可以在 `/plugin` 的 marketplaces 页面为 `cursor-plugins` 开启自动更新，也可以手动执行：

```bash
claude plugin update pstack@cursor-plugins
```

## 2. 配置模型

安装后运行：

```text
/setup-pstack
```

该 Skill 会检测当前会话可用的模型，询问推理预算，并展示不同职责对应的模型角色，例如代码委派、判断与写作、评审面板等。确认选择后，它会写入：

```text
~/.cursor/rules/pstack-models.mdc
```

这是一个持续生效的用户规则文件，P-Stack 的相关 Skill 会读取它。

### 推理预算

上游提供四档预算：

| 预算 | 推理级别 | 含义 |
|---|---|---|
| unlimited | max | 尽可能使用模型支持的最高推理级别 |
| large | xhigh | 默认高推理预算 |
| medium | high | 降低推理开销 |
| small | medium | 更节省 Token |

不同模型的能力上限可能不同。例如，上游文档说明部分模型最高只支持 xhigh，因此 unlimited 不意味着所有模型都能达到 max。

### 角色与模型分离

每个角色可以配置不同模型。没有覆盖的角色继续使用 Skill 自己的默认模型。重新运行配置流程时，会保留已经偏离默认值的角色选择。

若想恢复某个角色的默认模型，可以删除规则文件中该角色对应的一行；如果上游默认模型发生变化，而本地规则仍固定旧模型，则需要删除旧角色行或整个规则文件，再运行配置流程。

### Auto / inherit-parent

将角色设置为 `auto` 或 `inherit-parent` 时，P-Stack 不会向子 Agent 指定 model 字段，子 Agent 继承父会话的模型。两者在此处语义相同，都不是模型名称。

对于面板角色，配置值是一个列表，每个条目会启动一个子 Agent，因此列表长度决定面板规模。配置还包括 `swarm workers)，作为 Swarm 工作者的默认模型；如果某次竞赛为每个候选指定了模型，则以任务配置为准。

## 3. 配置验证能力

配置结束时，`setup-pstack` 会检查项目是否已有验证应用行为的方式，例如 `verify-*` Skill 或已有测试 Harness。

如果两者都不存在，它会询问是否生成项目级验证 Skill：

```text
/create-verification-skill
```

生成结果位于项目的：

```text
.cursor/skills/verify-<app>/
```

该 Skill 教会 Agent 像真实用户一样操作应用，并在交付前实际运行一次验证流程。它应包括启动应用、检查实例状态、驱动功能、收集证据和清理环境等步骤。

上游还会询问是否生成 Formal Verification Skill。普通测试只覆盖编写者考虑到的输入和路径；形式化验证则针对一个明确性质，在声明的范围内检查更多状态或输入。例如“同一个任务不能同时运行两次”。对于并发、重试、状态机和解析器等 Bug 代价较高的代码，这类验证可能更有价值。

## 4. 控制成本

P-Stack 使用子 Agent 和评审面板会增加 Token 消耗。上游建议：

- 重新运行 `/setup-pstack`，选择较低推理预算或成本更低的模型。
- 主 Agent 使用强模型，代码执行角色使用更便宜、更快的模型。
- 将不需要独立模型的角色设为 `auto` 或 `inherit-parent`。
- 缩小评审面板列表；每个条目都会对应一个子 Agent。
- 将 `/poteto-mode` 留给确实需要严谨流程的任务，小型明确修改不必使用完整流程。

## 5. 执行第一个任务

选择一个真实但范围较小的任务，用自然语言描述目标和完成条件：

```text
/poteto-mode add a --json flag to this command. text output stays byte-identical. verify both.
```

观察待办列表：最前面的条目来自匹配到的 Playbook。上述示例会匹配 Feature Playbook。如果某个步骤被跳过，待办列表应保留该步骤，并标记跳过原因，而不是让用户误以为它已经执行。

在 Windows 中，如果希望将 `/poteto-mode` 保持在整个会话上下文中，可以从斜杠菜单选择该 Skill，并使用 Alt+Enter；Mac 使用 Option+Enter。这会将它作为 Custom Mode 持续应用。普通 Enter 则只附加到当前消息。

## 6. 本章解读：迁移到 Codex + 多模型工作台

P-Stack 的配置方法值得借鉴，但不能直接照搬 Cursor 的配置文件路径和 Task 工具。我们的工作台应抽象出：

- **Role Registry**：定义开发、架构、评审、测试、协调等职责。
- **Model Registry**：记录模型提供方、模型 ID、能力、成本和上下文限制。
- **Reasoning Budget**：统一表达推理强度，再映射到各提供方实际支持的参数。
- **Runtime Adapter**：把角色任务映射到 Codex CLI、模型 API 或其他执行器。
- **Verification Adapter**：为不同项目配置真实运行和证据采集方式。

角色不能与模型绑定为同一个概念。更换模型时，应尽量不改变工作流和验收标准。

> 迁移边界：P-Stack 的模型配置 Skill 面向 Cursor / Claude Code 宿主。上述工作台设计是本项目的迁移建议，不代表 P-Stack 原生支持 Codex CLI 或任意模型 API。
