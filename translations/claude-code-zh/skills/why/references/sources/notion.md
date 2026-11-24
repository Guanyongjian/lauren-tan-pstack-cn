# Notion Docs

## What this source contains

- PRD（product requirement document）
- 技术 spec 与 RFC
- architecture decision record（ADR）
- design review 的会议记录
- 带领域上下文的团队页面
- 事故之后的 postmortem
- 可能解释防御性 code 的 runbook
- 设定优先级的战略文档

Notion 常常是「why」在变成 code 之前以长文存在的地方。一个重要的 feature 通常都有一份 doc。

## How to search it

使用 Notion MCP。

1. **用 `notion-search` 做关键词检索。** 试这些：
   - feature 名
   - 目标 code 里的关键 symbol / class 名
   - 作者 handle（design doc 常常在 code 落地之前就已写好）
   - 错误字符串或 user 可见的术语
   - 如果你知道 code 何时 ship，就用带时间范围的查询
2. **用 `notion-fetch` 取回候选页面。** 读完整内容，不要只读预览。理由常常埋在文档中段。
3. **沿 backlink 和子页面走。** design doc 常有子页面，记录被考虑过的备选、附录或实现说明。
4. **查相关 database。** `notion-query-data-sources` 和 `notion-query-meeting-notes` 能翻出讨论过该决定的会议记录。
5. **检索作者专属的空间。** 如果 PR 作者有个人 notebook（某些公司很常见），里面可能有先于 code 的探索性思考。

## What good evidence looks like here

- 一份 PRD，其 "Problem statement" 或 "Motivation" 一节与目标 code 的用途吻合
- 一节 "Alternatives considered" 或 "Rejected approaches"
- 一份 postmortem，其中点名目标 code 是某个具体事故的修复
- 会议记录里写着 "we decided X because Y"，且与 PR 的作者/日期范围对得上
- 一份被非敷衍地填好的 ADR 模板（status、context、decision、consequences）

## Common pitfalls

- **过时的 doc。** spec 常常在实现之前写好、之后没再更新。doc 描述的可能是某个后来变过的计划。要对照实际 PR 核查。
- **doc 与现实的漂移。** spec 可能说「我们将来会做 X」，而 code 实际做的是 Y。把这个分歧标出来。synthesizer 会把矛盾摆出来。
- **套版模板。** 有些组织强制要求某节「Why」，结果填的是空话。要看有没有具体性。
- **未被链接的 doc。** 最相关的那份 doc 可能哪里都没链。广泛的关键词检索会有帮助。
- **多份草稿。** 如果某个主题有多份 doc，找出已定稿或最近更新的那份。核对日期。
- **受限页面。** 如果你访问不了某个页面，就把它记为缺口。

## What to return

对每份相关的 doc：
- 标题与 URL
- 作者与最后更新日期
- 动机文字（逐字引用），附页码/章节位置
- 相关的被链接页面（好让 synthesizer 能引用）
- 该 doc 是已定稿还是草稿