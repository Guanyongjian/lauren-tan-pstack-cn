---
name: principle-experience-first
description: "出现 product、UX 或功能范围取舍时适用。选择用户愉悦度而不是实现便利；宁可少发几处打磨好的功能，也不多发一堆粗糙的。"
disable-model-invocation: true
---

# Experience First（体验优先）

当实现便利与用户愉悦冲突时，选愉悦。

- 每个 feature、control、option 都必须能被justify
- 少发一点，发好一点（三个打磨过的功能胜过十个粗糙的）
- 定下来之前先做 prototype（设计决策在一次性 HTML 里比在生产代码里便宜）
- 把细节做对（transitions、alignment、spacing、feedback、error states）
- 收紧核心回路（每个 feature 要么服务于中心 workflow，要么让开路）

「用户」指任何消费这份工作成果的人。对 UI 而言是终端用户；对 library 或 internal API 而言是 import 它的同事。下一个维护这段代码的工程师也是用户。用同样的方式衡量他们的体验，并从他们的视角解释影响。

基础应当服务于体验。Foundational thinking 管的是工作的*顺序*，本原则管的是*目标*。
