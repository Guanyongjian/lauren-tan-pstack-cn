# Databricks Analytics & System Tables

## What this source contains

Databricks 是产品分析、数据 pipeline 与 warehouse telemetry 这一层。它补足 Datadog。Datadog 是*基础设施/运行时*视角，Databricks 是*产品/数据*视角（user 做了什么、跑过哪些 experiment、feature 使用量如何演变、某个阈值常量从哪来）。

- **产品分析 event。** `your_warehouse.events.analytics_track_event`（原始表）以及 `<your_analytics_db>.<schema>.<table>` 里按 event 归类、已去重的 typed dbt model。user 行为：feature 调用、点击、accept/reject、提交、客户端上报的错误。
- **用量与计费 event。** `your_warehouse.events.usage_event` / `<your_analytics_db>.<schema>.stg_usage_events`、`your_warehouse.events.raw_model_event` / `<your_analytics_db>.<schema>.stg_raw_model_events`。用于成本或量驱动的决定。
- **Experiment / feature-flag 数据。** exposure 与 outcome 表。**schema 各公司不同。** 假定表名之前先用 `SHOW TABLES` 探一下。
- **System table。** `system.query.history`、`system.compute.warehouses`、`system.billing.*`、`system.access.audit`。回答「这条查询贵不贵？」「到底有人多常跑它？」「warehouse 负载何时飙升？」
- **dbt 血缘。** `<your_analytics_db>.<schema>` 里的 model 揭示哪些 pipeline 依赖某个 table/field。上游变更常常促使消费方 code 一并改动。
- **Databricks notebook。** 工程师在改 code 之前所做的探索性分析。**无法通过 SQL MCP 查询。** 如果你怀疑理由就在某个 notebook 里，把它记为缺口。

## How to search it

使用 Databricks SQL MCP。主力工具：`execute_sql_read_only`。如果它返回 `statement_id`，用 `poll_sql_result` 轮询，而不是重跑。

**查询之前先定位。** schema 各公司不同。信任某个表名之前先探一下：

```sql
SHOW TABLES IN <your_analytics_db>.<schema> LIKE '*<keyword>*';
DESCRIBE TABLE <your_analytics_db>.<schema>.stg_<event>;
```

**每条查询都限定时间。** 这些表极大，无约束的扫描会超时。对 event 表按 `_timestamp`、对 `system.query.history` 按 `start_time` 过滤，窗口要括住 ship 日期，通常是前后各约 30 天，只有在理由充分时才放宽。

**优先用 typed dbt model 而不是原始表。** `<your_analytics_db>.<schema>.<table>` 已去重、有类型、并按 liquid 聚簇。`your_warehouse.events.analytics_track_event` 有重复，且 `properties_json` 无类型。model 命名 pattern：`stg_<source>_<event_name_with_underscores>`，其中 `<source>` 是 `app`、`backend`、`website` 或 `cli`。当单靠 pattern 定不下来时，用 `SHOW TABLES` 确认确切的 model 名。只有当尚无 dbt model，或你需要 dbt 刷新延迟期内的 event 时，才落到原始表。

**typed dbt model 上的列约定**（知道这些就能省掉一趟 `DESCRIBE`）：

- `_timestamp`、`_id`、`_auth_id`、`_request_id`、`event_name`。每个 model 上的标准列
- `properties_<name>`。有类型、下划线命名法的 event property（`properties_entrypoint`、`properties_size_bytes` 等）
- `context_team_id`、`context_client_version`、`context_country`、`context_client_os`。预先抽好的客户端上下文

### Investigation patterns that tend to pay off

挑与目标匹配的 table + column 组合：

1. **Event 用量轨迹。** 在 PR merge 前后 ±30 天的窗口里，对相关 `stg_*` model 做每日计数。merge 后一两天内从零跳到稳定量的阶梯函数，是「该 PR 上线了这个 feature」的有力旁证。衰减到零则提示一次 deprecation 或删除。
2. **护栏 / 防御性检查的由来。** PR *之前* 14 天里相关 `properties_<name>` 列的分布（median / p99 / max）。某个 p99 恰好等于目标里的阈值常量，提示这个数字是照着数据定的。
3. **Experiment / feature-flag 查找。** 用 `SHOW TABLES ... LIKE '*experiment*'` 找到 exposure 表，然后按 PR 日期附近、相关 flag key 拉取各变体的 exposure 计数。
4. **用于 migration、backfill 或 perf 重写的 query 历史证据。** 以 `statement_text ILIKE '%<table_or_symbol>%'` 加一个很紧的 `start_time` 窗口过滤 `system.query.history`，会浮现出很可能促成该改动的那些昂贵查询（按 `total_duration_ms` 排序，或聚合 `SUM(read_bytes)`、`COUNT(*)`）。
5. **dbt 血缘。** 如果目标从某个 `<your_analytics_db>.<schema>` model 读或向它写，该 model 自己的 git 历史（就在这个 repo 里）常常带有理由。把这条线索交回 git investigator，而不是自己去追。

## What good evidence looks like here

除了上面那些 pattern 形状之外：

- 某个用于错误分类的 event，其计数在防御性 code 的 PR 之后几天内降到接近零。提示该 PR 解决了这类错误
- exposure 表里有一行点名目标的 feature-flag key，并在 PR ship 日期前后给出 "shipped" / "concluded" 的决定

## Common pitfalls

- **埋了点不等于造成了它。** 某个 event 的存在，说明有人在意的程度足以去记录它，并不说明目标 code 是*因为*它才存在。在声称因果之前，先配上 git investigator 给出的 PR/commit 引用。
- **instrumentation 的静默变化。** event 量上的阶梯函数，可能是开始记录了一个新 event，而不是 user 行为变了。在把这段爬升读作 feature 上线的 signal 之前，先查同一窗口里有没有 instrumentation 相关的 PR。
- **schema 漂移。** event property 会演变。今天在 typed dbt model 上的某一列，在目标被写就时可能还不存在。更早的数据可能只在原始 `properties_json` 里带这个 property。
- **dbt 刷新延迟。** `<your_analytics_db>.<schema>.*` 按计划重建（常常每小时/每天）。对于最近几小时的 event，退回到 `your_warehouse.events.*` 并按 `_id` 去重。
- **各公司专属的表。** experiment、feature-flag、billing 和用量表各不相同。从一个你从未确认过存在的表里报出结果，是典型的失败模式。先用 `SHOW TABLES` / `DESCRIBE TABLE` 探一下。
- **保留期断崖。** 如果相关窗口早于该表的保留期或 dbt model 的创建日期，那是一个*缺口*，不是「没有」的结论。要明确点名它，免得 synthesizer 把「没有结果」读成「没有活动」。
- **Notebook 不可查询。** SQL MCP 看不到 Databricks notebook。如果你怀疑理由在某个 notebook 里，返回一个缺口。

## What to return

对每个相关 finding：
- 类型（product event / experiment exposure / usage 或 billing event / system-table row / dbt model）
- 完全限定的表名，以及你实际跑的那条查询
- 所查的时间窗
- 紧凑的数值摘要（计数、分位数、first/last-seen 时间戳）。**不要倾倒原始行。**
- 与目标 ship 日期的时间相关性（例如 "first row 2024-08-15, PR #49074 merged 2024-08-14"）
- 相关性 + 强度：direct / circumstantial / weak