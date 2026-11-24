# Routing map example

把这个 file 复制到 `.cursor/automations/benny/` 之外，例如 `.cursor/benny/routing.md`，并替换掉每个 placeholder。把 `routing.map_path` 指向这份副本。pack 刷新时绝不能覆盖它。

triage skill 把这份东西当作数据。一条 route 需要来自 report 或 cause trace 的证据。仅有关键词匹配是不够的。

```yaml
routes:
  - name: "billing-example"
    match:
      product_areas:
        - "billing-area-placeholder"
      code_paths:
        - "billing-code-path-placeholder"
      error_signatures:
        - "billing-error-placeholder"
    destination:
      slack_channel: "billing-channel-placeholder"
      tracker_team: "billing-team-placeholder"
    owners:
      - "billing-owner-placeholder"
    allow_feature_owner_ping: false

  - name: "desktop-example"
    match:
      product_areas:
        - "desktop-area-placeholder"
      code_paths:
        - "desktop-code-path-placeholder"
      error_signatures:
        - "desktop-error-placeholder"
    destination:
      slack_channel: "desktop-channel-placeholder"
      tracker_team: "desktop-team-placeholder"
    owners:
      - "desktop-owner-placeholder"
    allow_feature_owner_ping: false

fallback:
  destination: ""
  owners: []
  allow_feature_owner_ping: false

ping_policy:
  default: "off"
  allow:
    - "configured-feature-owner"
    - "confirmed-regression-author"
  deny:
    - "broad-on-call-group"
    - "unverified-owner"
```

## Rules

- 除非某个团队接收所有未匹配的 report，否则让 `fallback.destination` 保持为空。
- 使用稳定的 product area、code path 和 error signature。
- 不要在公开的副本里包含私有数据。
- 不要把你原始的 user 或 channel ID 粘进一份将来会公开的示例。
- 在目标团队同意之前，保持 feature-owner ping 处于关闭状态。
- reroute 只是告诉报告者该去哪儿。automation 绝不跨频道发帖。