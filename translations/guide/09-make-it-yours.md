# 第 9 章：将 P-Stack 方法变成自己的工作方式

> 上游来源：[docs/guide/09-make-it-yours.md](https://github.com/cursor/plugins/blob/main/pstack/docs/guide/09-make-it-yours.md)

Poteto Mode 是 Lauren Tan 自己的工程风格，但底层 Playbook、路由方式和模型角色可以适配成其他人的工作习惯。本章介绍如何生成个人 Mode、从会话中提炼经验、修复仓库以减少重复错误、编写专用 Skill，以及在信任 Skill 修改前进行测试。

从小处开始。第一天不需要几十个 Skill，甚至不必安装整个插件。先正常描述任务，观察 Agent 在哪里失败；同一种失败重复出现时，再增加 Skill 或自动检查。

## 1. 使用 /automate-me 生成个人 Mode

```text
/automate-me
```

用户不必先描述自己的风格。该 Skill 会从当前工作区近期 Transcript 中寻找重复偏好，例如回复方式、委派、验证、代码、文档和流程习惯，再让用户确认哪些模式确实代表自己。

确认后，它通过 Cursor 内置的 create-skill 流程生成：

```text
.cursor/skills/<your-name>-mode/SKILL.md
```

草稿还会经过 `/unslop` 清理，并从独立 Worktree 创建 PR，供用户像普通代码变更一样审查。

当工作习惯发生变化时，可以再次运行：

```text
/automate-me update my mode skill with everything since its last edit
```

更新时只分析上次 Skill 修改之后的历史，保留未被新证据推翻的规则，修订有新证据的规则，并只为真正的新模式增加内容。

## 2. 使用 /reflect 提炼一次会话的经验

```text
/reflect that took way too long. capture what we learned so the next run doesn't repeat it.
```

Reflect 会将当前会话 Transcript 交给三个并行审查者，再由一个综合者把建议分为：

- Accepted：建议采纳；
- Rejected：不采纳；
- Backlog：暂时留存。

在修改 Skill 之前，它会等待用户明确批准。只有会改变未来决策的经验才值得沉淀；一次偶发事件通常只是个案，不应直接变成长期规则。

## 3. 使用 /correct 修复重复出现的工程错误

如果你反复纠正 Agent 同一种错误，真正的修复应落到仓库，而不是每次重新写提示词。

上游给出的优先级是：

1. 通过架构或数据结构让错误无法发生；
2. 使用类型、Lint 或 CI 检查阻止错误，并在报错中指出修复方式；
3. 使用测试捕获错误；
4. 最后才写文档或 Agent 规则。

人工 Review 不应长期承担每次都发现同一问题的责任。

例如：

```text
/correct agents keep calling the database client directly instead of going through the repository layer
```

Correct 会读取近期提交、Revert、Review 评论和解释临时绕过方案的注释，将错误归类。一个错误类别至少重复两次才进入处理范围。它会优先处理频率最高的类别，每个类别单独提交，并尝试让新增检查在真实历史错误上失败，以证明检查有效。

Reflect 和 Correct 的职责不同：

- Reflect：从一次会话中改进未来使用的 Skill。
- Correct：修改仓库结构和检查机制，防止某类错误再次发生。

## 4. 编写专用 Skill

当工作流程已经明确、需要沉淀为可复用能力时，可以提出：

```text
/poteto-mode write a skill for verifying database migrations in this repo
```

Authoring or modifying a skill Playbook 会调用 Cursor 内置 create-skill 流程，检查 Frontmatter、链接和内容，并通过 Opening a PR 流程交付。

面向 Agent 的文字需要比普通人类文档更严格，因为未来 Agent 可能把其中每句话都当作操作指令。不要随手写一个 SKILL.md 就认为完成。

两个特殊场景应使用专门生成器：

- 应用行为验证：`/create-verification-skill` 与 `/maintain-verification-skill`。
- 形式化性质验证：`/create-formal-verification-skill` 与 `/maintain-formal-verification-skill`。

## 5. 使用 /technical-writing 规范技术文档

对于文档、RFC、README、PR 描述和 Commit Message，可以运行：

```text
/technical-writing review the readme changes
```

Technical Writing 会先判断文档类型：教程、操作指南、参考手册或解释型文档，再逐句检查。目标是让疲惫的工程师也能第一次阅读就理解。

## 6. 对 Skill 修改进行盲测

Skill 修改会影响未来所有会话，因此应像实验一样测试。采用别人的 Skill 时也一样：先确认它能否改善你的真实任务，再决定是否保留。

```text
/poteto-mode run the eval playbook on this skill change. same task for both variants, candidates stay blind.
```

如果 Skill 总是漏掉某项检查，也可以在一次任务中同时修改并评估：

```text
/poteto-mode update the review skill so it flags missing migrations, and eval the change.
```

Eval Playbook 重点防范观察者效应：候选 Agent 不知道自己正在接受 Eval，不看到 candidate 或 eval 等测试提示，不知道其他候选存在；Judge 只看到脱敏标签，并在统一尺度下评估。是否遵循了 Skill，应通过实际读取的文件和最终产物判断，而不是听候选自述。

最终结论前，实验负责人仍应完整阅读每个候选的输出。如果与 Judge 不一致，应先检查评分标准是否含糊，再判断模型是否存在偏差。

## 7. 其他场景：Bot UI

上游还提供面向 Grok Bot 用户的 `/make-bot-ui`。它可以构建一个带按钮的小页面，通过 Webhook 唤醒 Bot 并对指定项目执行操作。Webhook Sender Key 应由本机服务持有，不应暴露给浏览器或聊天内容。

## 8. 常见陷阱

不要在某项任务进行中，因为 Skill 表现不佳就顺手修改它。应将 Skill 修改放到独立 PR 中，让任务继续执行。否则 Skill 修改会和业务功能混在一起，难以审查，也无法独立评估。

## 本章解读：适用于个人多模型工作台

建议工作台建立“经验反馈闭环”：

1. 每次任务完成后，保存任务目标、执行步骤、证据和人工纠正。
2. 识别重复出现的失败模式，而不是把单次失误写成永久规则。
3. 将建议分流到 Prompt/Skill、自动测试、Lint、架构或工具层。
4. Skill 或模型路由策略变更必须有固定 Eval 任务集。
5. 新规则先在独立分支验证，再进入默认工作流。

最终目标不是让提示词越来越长，而是让重复经验逐步转化为可执行的结构约束。
