---
name: blast-radius
description: "在 change 上线之前，找出它可能在别处弄坏什么，范围超出 diff 本身；并靠跑真实 code 而不是写一份说明，来证明那个「因为它才安全」的关键事实。用于 'blast radius of X'、'what could this break'，或 review 一个你还不敢信的小 diff。"
disable-model-invocation: true
---

# Blast radius

在 change 上线之前，找出它在别处弄坏什么。用于 "blast radius of X"、"what could this break"，或 review 一个你还不敢信的小 diff。

与 `how` 和 `why` 配套。`how` 告诉你 code 做什么。`why` 告诉你它为什么是这个形状。blast radius 告诉你在别处会弄坏什么。

列出 caller 不是这项工作。agent 一秒就能 grep 出来。这项工作是找出 grep 显示不出来的 breakage。

## 不要相信你自己写的说明

一份听起来对的 blast-radius 说明毫无价值。无论真假，它读起来都很有说服力。所以不要只交说明。找出整件事所依赖的那一两个 fact，并靠跑 code 证明它们。

### 你有多确定

对一个 change 的安全性所依赖的每个 fact，用尽可能便宜的方式把它推到下面这个清单的越靠后越好，并说明它停在了哪一级。

1. 你这么说。单凭这一条毫无价值。
2. 你指出了那一行。真实的 `file:line`，或库自身的源码。
3. 你证明了这个坏情况不可能发生。你把 failure 一步步走了一遍，走不到。
4. 你跑过了。一个 script 或 test 调用真实 code，你错了它就大声失败。
5. 你在运行中的应用里复现了。

第 4 步通常就是一个小 script：import 应用所发布的同一个库，调用你担心的那个确切的 function。

## Steps

1. 读这个 change。diff、它新增/修改/删除的 symbol，以及它现在行为上有何不同，包括 diff 没有明说的部分。用 `why` 的 step 2 把 PR 和 commit 拉出来。
2. 找出那个「因为它才安全」的关键 fact。看起来有风险的 change，大多数是因为某一个 fact 才安全的，比如 "this call only drops already-dead cache entries and does nothing else"。找到这个 fact。如果它成立，大部分有风险的情况就一次性排除了。把时间花在这里，而不是花一长串「也许」上。
3. 看 grep 停在哪里。读你调用的那个库的源码，核对你 pin 的版本以及任何本地 patch。搞清楚东西在什么时机运行：microtask、unmount 与 teardown、Solid 与 React。跟着 symbol 搜索会漏掉的东西走：API 返回的 JSON、一个 DB 列、一种 wire format、另一个语言读取同样的 bytes、一个 feature flag、下游三跳之外的 code。
4. 对每个 risk 保持诚实。给它真实的概率和真实发生时的代价。保留你确认过的 risk。把你查过并排除的单独列出。规则与 `why` 相同。引用真实的 `file:line`；搜不到东西也是一个答案；绝不要编造 caller 或 API。
5. 证明那个关键 fact。写一个 script 或 test 跑真实 code，跑一遍，把结果贴出来。
6. 对大的或影响面广的 change，把它当成 `arena` 来跑。让不止一个 model 回答同一个问题，再合并答案。不同的 model 会抓到不同的真实 bug。

## 要交回什么

- **它做了什么。** 改了什么，包括不明显的那部分。
- **那个「因为它才安全」的关键 fact。** 把它陈述出来，说明你把它推到了第几步，并展示证据。如果证不出来，就写 unproven。
- **Risks。** 每条点名它如何坏、`file:line`、有多可能、有多严重，以及怎么查。对重要的那些贴上证据。
- **Cleared。** 你查了什么、为什么没问题。
- **Before you merge。** 能抓到真实 bug 的最便宜的 test 或 repro，包括你写的那个 script。

通过 `unslop` 来写，引用真实 code，在任何对外发布之前把私有内容剥离掉。

**Reply：** 上面那份说明，其中那个安全性 fact 要么已被证明，要么标注为 unproven。
