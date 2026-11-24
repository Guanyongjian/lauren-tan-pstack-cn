# Linear Tickets

## What this source contains

- 描述 feature、bug 及其动机的 issue
- 挂在 issue 上的 project doc（常是 PRD 或 spec）
- parent/sub-issue 关系（更大的 initiative → 具体 ticket）
- issue 上的 comment（澄清、范围变化、「我们为什么做这个」的理由）
- label（例如 `compliance`、`customer-request`、`perf`），提示动机的类型
- 解释范围变化的 status update
- 附件与关联的 GitHub PR

Linear 常常是产品与业务上下文所在之处：那层「我们做这个是因为客户 X 提了」或「这是为了 Q3 合规专项」的信息。

## How to search it

使用 Linear MCP。

1. **从关联 ticket 开始。** 如果种子 commit 或 PR 引用了 ticket ID（例如 `ENG-1234`、`[BUG-567]`），先用 `get_issue` 取回它们。读完整个 issue，包括 comment。
2. **按关键词列出相关 issue。** 用 `list_issues` 以 feature 名、关键 symbol 或业务术语做文本检索。多试几种说法。
3. **沿 issue 树走。** 如果落到某个 sub-issue 上，就去取它的 parent。sub-issue 是战术层的。parent 往往承载「为什么」。
4. **读 project doc。** 如果该 issue 属于某个 project，用 `get_project` 并查看挂载的 doc。project 级的 document 是最常记录 spec 与理由的地方。
5. **查 label 与 milestone。** label 暗示动机的类别（customer-request、incident-followup、compliance）。milestone 把工作绑到 deadline 上，这常常能揭示动机。

## What good evidence looks like here

- 描述业务问题的 issue description："Customer Acme needs X because of their SOC2 audit"
- 记录某个决定的 comment："We decided to go with approach B because approach A would require touching the billing service"
- 标题像某个 initiative 的 parent issue："Q3 Enterprise Readiness" 或 "Reduce Payment Failures"
- 挂载的 PRD 或 spec
- 形如 `customer:acme`、`incident-followup`、`compliance`、`perf-regression` 的 label

## Common pitfalls

- **范围漂移。** PR 引用的那个 ticket 可能曾被关闭、又以不同的范围重开。要把整段历史读完。
- **机械模板。** 有些团队强制要求写「Why」一节，却用套话填充。泛泛的文字（"improve user experience"）多半不是真正的答案。
- **陈旧 ticket。** 旧 ticket 常反映的是某个后来变过的计划版本。核对日期，并与 code 的 ship 日期交叉比对。
- **closed-as-duplicate 链。** 沿 duplicate-of 关系回溯到那个 canonical ticket。
- **私有 workspace 内容。** 如果某个 issue 你访问不了，就把它记为缺口，而不是去猜。

## What to return

对每个相关的 ticket：
- Ticket ID 与标题
- 从 description 或 comment 中引用的那个问题/动机（不要转述。synthesizer 需要确切原文才能引用）
- label、parent issue、project
- 作者、创建日期、关闭日期
- ticket 链接（若有）