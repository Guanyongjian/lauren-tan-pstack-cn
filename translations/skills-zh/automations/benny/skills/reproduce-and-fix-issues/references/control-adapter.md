# Control-adapter contract

Benny 并不知道怎么启动或驱动每一个 app。user 必须配置一个 control skill 或 adapter，为目标 app 实现这份 contract。

把它的 skill 名设进 `control.skill_name`。

把填好的、面向 user 的 feature map 路径设进 `control.feature_map_path`。要把 [`feature-map.example.md`](./feature-map.example.md) 复制到 `.cursor/automations/benny/` 之外再填，而不是直接编辑被复制的那份示例。

如果该 skill、feature map 或某项必需能力缺失、含糊或不完整，repro and fix 工作必须 fail closed。

## Required capabilities

### Bring up

在指定的 test environment 里启动请求的 app revision。

Input：

- repository 与 revision
- build 或 start mode
- workspace、account、fixture 与 feature-state 方面的要求
- artifact 目录
- 填好的 feature-map 路径

Return：

- session identifier
- adapter 是如何确认 app 与环境正确的
- 稳定的 app marker
- 后续调用所需的、正在运行的进程或目标详情
- 任何缺失的能力

adapter 必须把目标 app 与一个相似的 window、shell 或生产实例区分开。

### Drive UI

执行真实的 user 动作：

- 点击
- 输入
- 按键
- 滚动
- 拖拽
- 调整大小
- 通过 app 控件进行导航

优先用 role、label 和稳定的 selector。只有在截取新 screenshot 之后才用坐标。

返回每个动作以及观察到的 state 变化。

不要为了制造该 symptom 而设置内部 state、调用隐藏的 app method、直接写 storage，或注入 DOM 改动。

### Drive mapped features and states

驱动 app 之前先读相关的 feature-map 章节。

adapter 必须提供途径来：

- 沿 user 可见的路径导航到每一个被映射的 feature。
- 调用为该 feature 列出的 adapter action 名。
- 在适用时，与 default、hover、focus-visible、active、disabled、loading、empty、error、selected、open、expanded 以及该 feature 专属的 state 交互。
- 通过安全的 fixture 数据、权限、flag、service 响应或受支持的 test control 来布置某个 state。
- 为第二次独立的 repro 尝试而重置该 feature。
- 抓取 feature map 所点名的 screenshot、video 和 read-only 交叉核对。

使用 role、accessible name、ARIA 关系、稳定的 component marker，以及按用途命名的 data attribute。绝不使用生成的 CSS 或 StyleX class、动态 hash、子节点索引，或脆弱的 DOM 位置。

布置一个前置条件，不等于获准注入所报告的 symptom。repro 本身仍必须来自真实的 user 交互。

### Inspect state

读取 state 以确认 UI 显示了什么。

示例：

- accessibility tree
- DOM 或 view 层级
- 进程状态
- 本地 log
- 网络请求状态
- app 暴露的 debug state

检查是 read-only 的。如果某个查询会改变 state，它属于 `drive UI`，且必须代表一次真实的 user 动作。

### Screenshot

把当前 app state 抓取到请求的路径。

Return：

- file 路径
- 抓取时间
- app marker 或 window 标题
- 简短说明本该可见什么

screenshot 必须包含足够的 app chrome，以证明被测的是正确的 app。

### Recording

围绕完整的 repro 路径开始并停止一段屏幕录制。

Return：

- file 路径
- 开始与停止时间
- 所抓取的 window 或区域
- 是否已略去音频或敏感浮层

录制必须展示那个区分性的最终 state，而不只是 setup 或一个加载屏。

### Cleanup

停止 adapter 创建的进程与 session。

清除可丢弃的：

- browser 或 app profile
- 临时 workspace
- 由 adapter 创建的 test account 或 fixture
- debug 端口与 tunnel
- 超过保留期的抓取物

返回哪些被停止、移除、保留，或留给人处理。

cleanup 绝不能删除 user 的工作。

## Adapter behavior

adapter 必须：

- 在 repro 开始之前报告能力。
- 报告它能驱动哪些 feature-map 章节、哪些被阻塞。
- 对 baseline 与打补丁后的 build 使用同一套 environment 输入。
- 把启动失败当作失败上报。
- 对重试设上界。
- 让密钥不出现在 log 与 artifact 里。
- 把抓取物放在 repository 之外。
- 在两次 repro 尝试之间支持全新或重置的 state。
- 避免生产改动，除非 user 明确配置了一个安全的 test 动作。

## Environment translation

在宣布某个 environment 阻塞之前，先在不含平台专属名词的情况下重述该缺陷，并问同样的行为能否在可用的 environment 里安全测试。

示例：

- 某个具名 browser 可能指的是任何外部 browser。
- 某个具名键可能指的是配置好的快捷键。
- 某个具名远程 host 可能指的是一个延迟或断连的远程目标。

只有当翻译后的尝试测的是同一个底层行为时，才使用它。把它标为 translated evidence。当缺失的 environment 本身就是缺陷的一部分时，不要称它为 exact repro。

硬件提示、操作系统权限对话框、仅设备可用的 API，以及不可用的 account state，可能是真正的阻塞。

## Setup check

在启用 repro automation 之前，跑一次无害的 adapter 检查：

1. 启动 app。
2. 确认稳定的 app marker。
3. 加载一个填好的 feature-map 章节。
4. 沿其 user 路径导航到该 feature。
5. 通过映射的 adapter action 演练一个可丢弃的 state。
6. 检查由此得到的 state。
7. 抓取一张 screenshot。
8. 录一小段 clip。
9. 清理。

只有当这九步全部成功、且不涉及任何 source-channel Slack 发帖时，才启用 repro 工作。