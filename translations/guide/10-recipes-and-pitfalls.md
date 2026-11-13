# 第 10 章：常用提示词与实践陷阱

> 上游来源：[docs/guide/10-recipes-and-pitfalls.md](https://github.com/cursor/plugins/blob/main/pstack/docs/guide/10-recipes-and-pitfalls.md)

本章整理可以直接复用的提示词，以及 Agent 工程中常见的错误习惯。示例刻意保持口语化，因为真实使用时通常就是这样向 Agent 描述任务。替换其中的路径和完成条件即可。

## 1. 理解陌生子系统

```text
use /how first to understand how this initialization works. then use /why to figure out why it broke recently.
```

先理解当前机制，再追溯历史原因。每个 Skill 的报告应说明搜索过哪些来源，以便判断结论的证据基础。

## 2. 修改代码前先复述问题

```text
/poteto-mode read this thread. restate the underlying issue in your own words, in plain english. don't change any code yet.
```

先让 Agent 用自己的话重述问题。理解错误会在重述阶段暴露，此时纠正成本很低。不要一开始就把自己的根因猜测告诉 Agent，否则它可能只沿着你的方向搜索。

## 3. 发送任务前先打磨提示词

```text
/sharpen write the onboarding doc for the new billing service.
```

Sharpen 会指出专家通常会补充哪些工作、需要哪些原始材料、采用什么方法和工具，以及如何从外部检查结果。它只返回改写后的提示词，不执行实际任务。确认改写符合预期后，再提交给 Agent。

## 4. 先做原型再选择

```text
/poteto-mode prototype a few options for the settings layout. put them behind a switcher and send me screenshots of each.
```

从真正运行的方案中选择，而不是只比较文字描述。原型也能帮助 Agent 自己回答布局、耗时和行为方面的开放问题。

## 5. 将稳定设计转化为计划

```text
/poteto-mode turn this design into a plan. small verifiable PRs, each with its own proof.
```

应等设计稳定后再制定计划。计划本身是交付物，并应指出后续由哪个 Playbook 执行。

## 6. 对设计寻求第二意见

```text
ask /arena for a second opinion on this thread and our approach
```

将当前方案作为多个候选之一，让其他 Agent 独立尝试。综合结果可以指出是否有更好的方案，或当前方案是否经得住比较。对于难以逆转的设计，这项投入通常比返工成本低。

## 7. 并行检查独立切片

```text
/swarm check every package under packages/ against its check.sh. one worker per package. one report.
```

每个 Worker 负责一个包，父 Agent 等待所有切片完成后统一返回 PASS、ISSUES 或 BLOCKED，而不是把大量原始输出直接堆给用户。

## 8. 严格审查一个分支

```text
/interrogate the whole branch, but skeptically. don't change anything yet. no nitpicks unless it's an actual bug or regression in behavior.
```

“暂时不要修改”和“只关注真实 Bug 或行为回归”分别限制了写权限和噪声。Interrogate 只保留通过重新运行证明的问题。

## 9. 通过失败测试修复 Bug

```text
/poteto-mode repro the duplicate write first. if there's a cheap test path, /tdd it. then fix and rerun.
```

先复现，再决定是否适合 TDD。如果测试需要大量脆弱 Mock，真实命令或集成检查可能是更强的证据。

## 10. 用证据复现并修复报告

```text
/poteto-mode repro this with /verify-<app>. if it repros on main, fix it and show me a video as proof.
```

如果主分支已经不再复现，就可以提前结束，不必制造一个无意义修复。视频能让用户先确认行为，再审查代码。

## 11. 验证测试难以覆盖的性质

```text
/create-formal-verification-skill the retry queue. a message must never be delivered twice.
```

针对一个明确性质建立形式化验证，在声明范围内检查更多状态或输入，并在当前代码违反性质时给出反例。后续相关变更也应运行该检查。

## 12. 发布性能数字前先审核

```text
/benchmark-checklist vet this 40% speedup before it goes in the pr description
```

输出应包含更快、更慢、无可测量差异或无法得出结论，并说明运行次数、范围和瓶颈。不要只凭单次运行的百分比做结论。

## 13. 停止手工纠正重复错误

```text
/correct agents keep adding new config flags without registering them in the schema
```

目标是将修复落到架构、类型、Lint 或测试中，让下一次 Agent 无法轻易重复同类错误。

## 14. 只询问使用方法，不启动任务

```text
/poteto-help how do i get poteto-mode to stay on every turn?
```

Poteto Help 返回答案、可复制提示词和来源链接。只有用户真正发送提示词后才开始执行任务。

## 15. 查看长任务的进展

```text
/ketchup
```

Ketchup 用通俗语言总结上次消息后的变化，并列出仍等待用户决定的事项、候选方案、证据和风险。

如果需要视频式回顾，可以使用 `/ketchup-video`。

## 16. 常见陷阱

| 陷阱 | 为什么有问题 | 更好的做法 |
|---|---|---|
| 在提示词中枚举一串 Skill | 可能打乱 Playbook 已设计的步骤 | 先描述目标和约束，仅在需要覆盖默认行为时点名 Skill |
| 完成条件模糊 | 循环无法判断是否结束 | 给出可以通过或失败的命令、行为或产物 |
| 一开始就给出自己的根因理论 | Agent 容易被带偏 | 先让它独立重述和调查 |
| 直接接受第一个设计 | 过早锁定方案 | 使用原型或 Arena 比较证据 |
| 反复润色没有代码支撑的计划 | 容易制造虚构风险 | 先用原型解决开放问题 |
| 多个 Agent 共用一个 Worktree | 可能互相覆盖，无法归因修改 | 每个尝试使用独立 Worktree |
| 尚未建立验证能力就运行长循环 | 未验证工作会不断累积 | 先让验证 Skill 可用，再自主运行 |
| 相信未经核验的性能数字 | 缓存和测量区间可能制造假提升 | 使用 Benchmark Checklist |
| 反复手工纠正同一种错误 | 每次纠正只影响当前会话 | 用 Correct 将经验沉淀到仓库 |
| 用 Arena 做覆盖检查 | Arena 主要比较同一任务的候选方案 | 覆盖独立切片使用 Swarm |
| 接受所有 Review 意见 | 真实问题与噪声混在一起 | 使用 Interrogate 复现并验证发现 |
| 把 auto 当成模型 ID | 它实际表示继承父模型 | 不向子 Agent 传入 model 字段 |
| 只凭构建成功报告完成 | 编译不能证明运行行为正确 | 检查真实命令、流程、持久化结果或 Profile |
| 手写 SKILL.md 后直接使用 | 缺少结构和链接校验 | 使用专门的 Skill 编写流程 |

## 17. 让 Agent 用简单语言解释

```text
/bro
```

Bro 会把上一条回复改写得更短、更口语化，减少术语。技术内容完整但难以理解时可以使用。

## 本章解读：建立个人工程提示词库

建议不要把这些示例原封不动地复制为一套固定提示词。应提炼成可组合的任务合同：

- **目标**：需要改变什么行为？
- **范围**：允许读取和修改哪些文件？
- **不变量**：哪些已有行为必须保持？
- **证据**：用什么命令、测试或设备行为证明结果？
- **权限**：是否允许写文件、提交、推送或合并？
- **停止条件**：哪些情况应报告 BLOCKED，而不是猜测或继续扩大范围？

这比简单地堆叠 Skill 名称更稳定，也更适合跨模型和跨 Agent Runtime 迁移。
