# Datadog Telemetry

## What this source contains

Datadog 保存的是运行时记录，即生产环境里实际发生了什么，而不是原本计划或讨论过什么。

- **Metric。** 团队埋点的 counter、gauge、histogram。某个 metric 的*存在*本身就是证据：有人认为这个数字值得盯着。
- **Monitor 与 alert。** 团队认定值得把人叫醒的那些条件。`rate_limit_hit > 10/min` 上触发的 monitor，就是团队在意这个阈值的直接证据。
- **Dashboard。** 团队认为某个 subsystem 重要的那些视角的精选视图。
- **APM trace 与 span。** 请求级的运行时数据，用于回答「为什么这里慢」「为什么这里会 timeout」这类问题。
- **Log。** 高容量的事件记录，常常包含促成防御性 code 的那些错误条件。
- **Incident。** 带有时间线和关联 postmortem 的正式事故记录。
- **Notebook。** 团队的探索性调查，常带假设与分析。

## How to search it

使用 Datadog MCP。先广后窄。

1. **确定所属 service。**

   ```
   search_datadog_services (filter by name or team)
   search_datadog_service_dependencies (see upstream/downstream)
   ```

2. **先看 dashboard 和 monitor。**

   ```
   search_datadog_dashboards (query: feature name, service name, symbol)
   search_datadog_monitors   (same queries)
   ```

   当某个 dashboard 或 monitor 覆盖了目标时，记下它的 query 和被监视的阈值。那个阈值常常就是「为什么这里被卡在 N」的答案。

3. **目标周边的 metric。**

   ```
   search_datadog_metrics (by name pattern, e.g., the feature or symbol)
   get_datadog_metric_context (metadata: description, units, tags)
   get_datadog_metric (timeseries; "was there a spike around the PR date?")
   ```

   把某个 metric 的轨迹与目标的加入/改动日期相关联，是很有力的支持性证据："the `payment_timeout` metric spiked 2023-11-03, and the retry logic merged 2023-11-06."

4. **Log。收窄，不要倾倒。**

   ```
   search_datadog_logs (raw log patterns near the target, set use_log_patterns=true)
   analyze_datadog_logs (SQL-style aggregations, only when you need counts)
   ```

   用 symbol、错误字符串或 feature 名来搜。**强烈偏向带时间范围的查询**（例如改动前后各 30 天）。

5. **APM span 与 trace。**

   ```
   aggregate_spans    (stats: "how often does this endpoint fail?")
   search_datadog_spans (inspect individual spans)
   get_datadog_trace  (a specific trace ID)
   ```

   对 timeout、retry、慢路径和跨 service 行为很有用。

6. **Incident。**

   ```
   search_datadog_incidents (by title, team, date range)
   get_datadog_incident     (full detail for a specific incident)
   ```

   如果目标看起来是防御性的，就搜它被加入前后的事故。一份时间线里写着 "added defensive check for X" 的 incident，几乎是直接证据。

## What good evidence looks like here

- 某个 monitor 的 query 与阈值，恰好匹配 code 所强制的约束（code 卡在 100，monitor 在请求超过 100/min 时告警）
- 一份由目标作者创建的 dashboard，其 widget 与 code 所度量或防范的内容对应
- 某个 metric 在 code 被 merge 之前紧接着出现生产飙升，之后趋于平稳
- 一份 incident 记录，引用了目标 code、相同的 symbol 或相同的错误字符串
- log 显示出防御性 code 本会阻止的某个特定错误 pattern，时间戳落在改动之前的那个窗口里

## Common pitfalls

- **相关不等于因果。** PR 之前有飙升、之后趋稳，这只是提示性的，并不确凿，因为同一窗口里可能有别的改动落地。查一下邻近的 PR。
- **对你找到的那张图过拟合。** 一张图反映的是制图者的框法。一张叫 "retry success rate" 的图，是团队在意 retry 成功率的证据，不是某一行 code 因它而存在的证据。
- **telemetry 会消失。** metric 可能被改名、删除，或保留期很短。如果你找不到相关窗口的数据，那是缺口，不是「没有」的结论。
- **规模化下的噪声。** 用 service、tag 和时间窗激进地收窄 log 检索。用 `analyze_datadog_logs` 做聚合，而不是倾倒原始 log。
- **埋了点并不等于造成了它。** 某个 metric 说明有人在意的程度足以去度量某件事，并不说明 code 是*因为*它而被加入的。要与 commit/PR 日期交叉比对。

## What to return

对每个相关条目：
- 类型（dashboard / monitor / metric / log pattern / trace / incident / notebook）
- 标题或名称
- 链接或标识符（dashboard ID、monitor ID、metric 名、incident ID）
- owner/作者 与创建/修改日期
- 与该问题相关的那个具体条件、query 或引文（尽可能逐字）
- 相关性：这对目标 code 提示了什么，以及这个联系的强度如何