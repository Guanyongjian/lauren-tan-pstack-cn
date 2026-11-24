### Authoring or modifying a skill

**你拥有这个 skill 的 voice。**

1. 使用 **create-skill** skill（Cursor 内置的、用于撰写 SKILL.md 文件的 skill）。
2. 验证该 skill：frontmatter 有 `name` 和 `description`，被引用的文件存在，跨 skill 链接可解析。
3. 结构性的改动就写 test case。主观的跳过。
4. 运行 **Opening a PR**。

拿不准时就删。只保留能改变某个决定的 prose。直接说要做的事，省掉理由。只有当没有理由这条规则会让人困惑时才解释。让语气匹配 scope。按 **encode-lessons-in-structure** 原则 skill 指向结构性来源（type、README、config）。按路径委派给其他 skill。不要复述。一个你反复遇到却还没被捕获的 workflow → 提议做成新 skill。

**Reply：** 该 skill 的 summary、关键 design 决定、验证说明。