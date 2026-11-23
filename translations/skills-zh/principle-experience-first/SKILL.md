---
name: principle-experience-first
description: "出现 product、UX 或 feature-scope 取舍时适用。选择 user delight 而不是 implementation convenience；宁可少发几个 polished feature，也不多发一堆粗糙的。"
disable-model-invocation: true
---

# Experience First（体验优先）

当 implementation convenience 与 user delight 冲突时，选 delight。

- 每个 feature、control、option 都必须能被 justify
- 少发一点，发好一点（三个 polished feature 胜过十个粗糙的）
- 定下来之前先做 prototype（design decision 在一次性 HTML 里比在 production code 里便宜）
- 把细节做对（transition、alignment、spacing、feedback、error state）
- 收紧 core loop（每个 feature 要么服务于中心 workflow，要么让开路）

「user」指任何消费这份 work 的人。对 UI 而言是 end user；对 library 或 internal API 而言是 import 它的 colleague。下一个维护这段 code 的 engineer 也是 user。用同样的方式衡量他们的 experience，并从他们的视角解释 impact。

foundation 应当服务于 experience。Foundational thinking 管的是工作的 *sequence*，本原则管的是 *target*。
