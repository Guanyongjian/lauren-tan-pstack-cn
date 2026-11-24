# Feature-map example

把 Benny 可能复现的每一个面向 user 的 feature 都映射出来。驱动 app 之前先读相关章节。这份 map 保持在 user 视角。内部实现与当前 code 路径在运行时去发现，不要在这里把它们冻住。

把这个 file 复制到 `.cursor/automations/benny/` 之外，例如 `.cursor/benny/feature-map.md`，并把 `control.feature_map_path` 指向这份副本。pack 刷新绝不能覆盖它。

## Per-feature template

### `<feature name>`

`<one-line user-visible purpose>`

#### How a user gets there

- 点击路径：`<screen> -> <menu, tab, or panel> -> <control>`
- 键盘快捷键：`<shortcut or none>`

#### How the control adapter drives it

- `<adapter action>` 配 `<inputs>` 应当 `<visible result>`。
- Reset：`<how the adapter returns to a fresh state>`。

#### Stable selectors

- `<role and accessible name>`
- `<ARIA relationship>`
- `<data-component or purpose-named data attribute>`

绝不使用生成的 CSS 或 StyleX class、动态 hash、子节点索引，或脆弱的 DOM 位置。

#### States to exercise

- Default、hover、focus-visible、active、disabled
- Loading、empty、error
- Selected、open、expanded
- `<relevant feature-specific variants>`

把不适用的 state 标出来。

#### Preconditions and setup

- Auth：`<account state>`
- Data：`<fixture>`
- Permissions：`<role>`
- Flags：`<flag or none>`
- Services：`<required availability>`

#### Evidence and cross-check

- Screenshot：`<app identity, feature, and discriminating state>`
- Video：`<entry path, interaction, and final state>`
- Cross-check：`<read-only state or value that confirms the UI>`

#### Gotchas

- `<known dead end or wrong surface>`
- `<safe environment translation>`

## Fictional example

这些 feature 属于一个虚构的 task app。它们是示例，不是 Benny 必须有的 feature。

### Sign in

让 user 进入这个 task app。

#### How a user gets there

- 打开 app 并选择 `Sign in`。无快捷键。

#### How the control adapter drives it

- `open_app`、`click Sign in`、`fill credentials`，然后 `click Continue` 应当打开条目列表。
- 通过登出并清掉这个可丢弃的 session 来 reset。

#### Stable selectors

- Button `Sign in`、textbox `Email` 与 `Password`、`data-component="sign-in-form"`

#### States to exercise

- Default、focus-visible、submitting、disabled、loading、error

#### Preconditions and setup

- 可丢弃的 account，以及可用的 authentication service

#### Evidence and cross-check

- 录下从落地页到条目列表的过程。检查 read-only 的 session state。

#### Gotchas

- 一个营销页面是错的 surface。缺 authentication service 是一个阻塞。

### Item list and detail

让 user 浏览条目并打开其中一个。

#### How a user gets there

- 打开 `Items` tab，然后选择一行。

#### How the control adapter drives it

- `select_tab Items` 加 `click <fixture item>` 应当打开它的详情。
- 通过关闭详情并清除选中来 reset。

#### Stable selectors

- 名为 `Items` 的 tab 与 list、以 fixture 命名的行、`data-component="item-detail"`

#### States to exercise

- Loading、empty、error、selected、open、expanded

#### Preconditions and setup

- 具名的 fixture 条目、read 权限、可用的 item service

#### Evidence and cross-check

- 展示选中态与匹配的详情标题。检查 selected-item ID。

#### Gotchas

- 搜索结果可能看起来相似，但走的是另一条路径。

### Item editor

让 user 创建或编辑一个条目。

#### How a user gets there

- 从详情里选择 `Edit`，或从列表里选择 `New item`。

#### How the control adapter drives it

- `click Edit`、`fill <field>`，然后 `click Save` 应当更新详情。
- 通过恢复 fixture 来 reset。

#### Stable selectors

- Button `Edit`、`New item`、`Save`，form `Item editor`，与 label 关联的 field

#### States to exercise

- Default、focus-visible、dirty、validating、disabled、saving、error、success

#### Preconditions and setup

- 可编辑的 fixture、write 权限、可用的 save service

#### Evidence and cross-check

- 展示 field 的改动到更新后的详情。以 read-only 方式检查已存储的条目值。

#### Gotchas

- 不要注入 form state。一个 read-only 的详情 field 不是 editor。

### Settings

让 user 更改个人偏好。

#### How a user gets there

- 打开 profile 菜单，然后选择 `Settings`。

#### How the control adapter drives it

- `open_menu Profile`、`click Settings`，然后 `toggle <preference>` 应当更新该控件。
- 通过恢复起始偏好来 reset。

#### Stable selectors

- Button `Profile`、menu item `Settings`、region `Settings`、按用途命名的 preference attribute

#### States to exercise

- Closed、open、selected、focus-visible、disabled、loading、error

#### Preconditions and setup

- 已登录的 test account、已知的偏好、可用的 preference service

#### Evidence and cross-check

- 展示菜单路径与最终控件 state。以 read-only 方式检查该偏好的值。

#### Gotchas

- 操作系统的设置是另一个 surface。

## Completeness checklist

- 每一个可复现的、面向 user 的 feature 都有一节。
- 每一节都点明了一条 user 路径、adapter action 和 reset。
- selector 使用 role、name、ARIA、稳定的 component marker，或按用途命名的 attribute。
- 没有 selector 使用生成的 class 或 DOM 位置。
- 覆盖了相关的 interaction、loading、empty、error、selected 和 expanded state。
- Auth、fixture、权限、flag 和 service 都写明确。
- screenshot、video 与底层交叉核对的要求都写明确。
- 列出了错误的 surface、死路，以及安全的环境翻译。
- 实现细节保持为运行时发现。