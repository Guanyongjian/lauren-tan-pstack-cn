---
name: swarm
description: "Fan out N 个并行 worker，把它们 drain 干净，返回一份 report。用于 /swarm、'swarm this'，或并行 coverage、race、gauntlet 与探索。"
disable-model-invocation: true
---

# Swarm

在 Claude Code 中，遵循本 skill 之前，每个 session 先读一次 [Claude Code 适配说明](../../docs/harness/claude-code.md)。它把 pstack skill 里的 Cursor 名字映射到 Claude Code。

## Start

在启动任何东西之前，打开一个 todolist，每个 phase 一条。

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. 陈述 done predicate，以及 swarm 必须返回的 artifact 或 report。
2. 选择 shape。切成 slice、用相同的 brief 让 N 个 worker 赛跑（race），或两者混用。对 race 或混用的 shape，在 spawn 之前先声明 `first pass`、`rank all` 或 `best-of`。
3. 从 `~/.cursor/rules/pstack-models.mdc` 里的 `swarm workers` 行取 worker 的 model。如果规则或该行缺失，就用 `grok-4.7-xhigh-fast`。若为 `auto` 或 `inherit-parent`，则不写 `model`，让 worker 跑在 parent model 上。如果 Task tool 拒绝某个 slug，就用默认值并说明。如果它连默认值也拒绝，就从它的 error message 里取同一 family 最接近的有效 slug。若是 model race，要提前点明每一 arm 的 model。按 **poteto-mode** skill 的 Subagents 一节，为每个 subagent 选择 reasoning level 以及 fast 或 standard speed。
4. 当 worker 要写东西时，给它自己的可写 output。当 worker 要验证或测量 commit 时，每份 brief 都要点名确切的 SHA。测量用的 brief 还要点名 method（sample 数、一个 sample 是什么、顺序）。worker 要把这两者都记在 result 里。

## Phase B: Fan out

在一条 message 里 spawn 全部 N 个 worker，用 `subagent_type: generalPurpose`、`environment: "cloud"`、`run_in_background: true`，以及第 3 步的 model；若为 `auto` 或 `inherit-parent` 则留空。只有当 worker 需要访问 user 电脑上的东西时，才用 `environment: "local"`。

当 worker 必须从一个非默认的、已 push 的 branch 起步时，传 `cloud_base_branch`。

每份 brief 都自成一体。包含 goal、scope、确切的 slice 或 race arm、如何验证，以及要汇报什么。report 使用 `PASS`、`ISSUES` 或 `BLOCKED`，并附证据。能证明缺陷的 worker 报 `ISSUES`，并列出它所能证明的每一个 issue，而不只是第一个。

如果某个 worker 掉队，就用 N-1 继续，并记录下来。

## Phase C: Aggregate

读 terminal result。丢掉没有记录其 brief 所点名的 SHA 和 method 的 result，并把那个 worker 重新 spawn 一次。第二次仍缺失，就记录一个 gap。gap 不算 pass。对 coverage 而言，每个必需的 slice 都要有 result。对 race 而言，套用事先声明的 selection rule，即 first pass、rank all 或 best-of。不要粘贴 worker 的原始 dump。

## Phase D: Report

返回一份合并后的 in-chat report，包含 result 表、issue 一行一条、gap 或掉队情况，以及用过的 race rule。