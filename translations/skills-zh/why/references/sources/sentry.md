# Sentry Error History

## How to search it

使用 Sentry MCP。

1. **定位。** 如果你不知道 project slug 和 organization：

   ```
   find_organizations
   find_projects
   ```

2. **检索与目标相关的 issue。**

   ```
   search_issues (natural language, e.g., "errors in PaymentService timeout", "unhandled exceptions in uploadFile")
   ```

   用目标所处理的 exception class 名、它的 function 或 class 名、它所检查的错误 message 字符串，以及它的 file 路径来构造查询。

3. **按 release 与时间窗收窄。**

   ```
   search_issue_events (filter by release, time, environment, trace ID, tags)
   get_issue_tag_values (for an issue, see distribution across versions, users, environments)
   ```

   对某个疑似 issue，查 **first seen** 与 **last seen**（消失的时间点与目标的 ship 日期对得上吗？）、**affected releases**（哪些版本出现过，哪个版本是那个修复？），以及 **frequency trajectory**（是否先飙升、然后被解决？）。

4. **拉取完整 event 以取得上下文。**

   ```
   get_sentry_resource (pass a Sentry URL or type+ID)
   ```

   这个 stack trace 是否经过目标 code？tags 和 breadcrumbs 是否与目标所防范的条件相符？

5. **查看在目标附近落地的 release。**

   ```
   find_releases (around the commit date of the target)
   ```

   把 release 版本与 PR 的 merge 日期交叉比对。

6. **谨慎使用 Seer。**

   ```
   analyze_issue_with_seer
   ```

   Seer 的 AI 根因分析是一个假设生成器。把它当作推断，而不是权威。真实的 event 和 stack trace 才是主要证据。

## What to return

对每个相关的 issue：
- Issue ID 与标题
- Project 与 organization
- first seen / last seen 时间戳
- event 计数（若已知，附采样率）
- affected releases
- 一段能体现与目标相关性的代表性 stack trace（逐字摘录，不要 summary）
- first/last-seen 与目标 ship 日期的相关性
- issue 链接
- 任何作者 comment 或 resolution note