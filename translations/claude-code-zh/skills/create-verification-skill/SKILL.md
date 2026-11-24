---
name: create-verification-skill
description: "生成一个项目内 verification skill，像 user 那样驱动你的 app——任何语言、框架或平台。用于 /create-verification-skill、\"make a control skill for this repo\"，或当某个项目没有任何脚本化方式去证明 UI/CLI/service 的行为时。"
disable-model-invocation: true
---

# Create a verification skill

在 Claude Code 中，遵循本 skill 之前，每个 session 先读一次 [Claude Code 适配说明](../../docs/harness/claude-code.md)。它把 pstack skill 里的 Cursor 名字映射到 Claude Code。

每一个认真的项目都需要一种脚本化的方式去驱动真实 app 并证明行为：启动它、像 user 那样演练一个 feature，并采集证据。这个 skill 把这件事生成为一个按 repo 定制的项目内 skill（`.cursor/skills/verify-<app>/`）。你写的生成器输出是给下一个 agent 的，不是给人看的：它会由一个从没见过这个 app 的 agent 冷启动、在任务途中读到。

## 1. 访谈 repo，而不是 user

从 codebase 回答这些问题，只问 user 那些你观察不到的东西：

- **Surface：** user 实际接触的是什么？web UI、CLI/TUI、桌面 app、API、移动 app、库？一个 repo 可能有多种；选主要的那个，其余记下来。
- **Run：** app 在本地如何启动？优先用 repo 自己记录的 dev command（package script、Makefile、README quickstart）。记下 port、env var、seed data、auth。
- **Drive：** agent 如何以编程方式与它交互？先找已有的 harness——Playwright/Cypress spec、expect script、PTY helper、可用 curl 的 endpoint、debug port。之后才选一个通用 recipe：web 和 Electron 用 browser/CDP，CLI/TUI 用 tmux/PTY harness，service 用纯 HTTP。
- **Observe：** 能采集什么证据？screenshot、terminal transcript、response body、log、exit code、DB state。
- **Isolate：** 能否两个实例并行运行（port、data dir、profile）？如果不能，就在生成的 skill 里说明：拒绝双重驱动一个共享实例，胜过破坏 user 的 session。

如果 checkout 无法按原样 build 或启动，先把它修好（或精确报告），再生成；一个针对破损基线写出来的 skill 会教出错误的步骤。当某个与任务无关的缺失资源阻塞了启动（API 从不会去 serve 的一个 static 目录、一份示例 config），生成的 skill 可以创建它，但要清楚标为 verification scaffolding，并在 cleanup 时删除。

## 2. 生成 skill

写 `.cursor/skills/verify-<app>/SKILL.md`，带 YAML frontmatter（`name: verify-<app>`，以及一个点名 app、surface 和何时该动用它的 `description`——没有 frontmatter，skill 永远不会注册），并包含以下各节，每节都落在访谈实际发现的内容上（不留 placeholder）：

- **Launch：** 为验证而启动 app 的确切 command，以及如何判断它已就绪（一行 log、一个 prompt）。Launch 必须能从空 data dir 到达可用状态，包括任何 migration 和 seed data。Ready 指的是可用，而不只是某个进程在应答。一个 database health check 可能在通过，而它的 init script 还在跑。要包含 teardown。对于短命的 CLI 或 TUI，没有需要常驻的 server：launch 指的是把 binary build 一次（或装好依赖），然后每次 drive 都在它自己隔离的 PTY 或 tmux session 里启动。
- **Doctor：** 一个 read-only 检查，回答「这个实例还值得驱动吗」——进程在跑、版本/build 正确、port 是我们的、auth 有效。agent 一看到哪里不对就先跑它。
- **Drive：** harness recipe，用这个 repo 里真实的 selector/command，而不是示例。优先用稳定的句柄（ARIA label、data attribute、prompt string、route path），而不是坐标和 tab 顺序。
- **Evidence：** 为一次 proof 采集什么、放在哪里。写明 proof 标准：演练真实的 user 路径，而不是 internal setter 或仅供 test 的 endpoint；采集动作与结果状态，而不只是最终屏幕；在可见内容之外同时验证副作用（写出的文件、插入的行、发出的 message）；只在 production boundary 已经隔离了外部系统的地方才用 mock。当安全路径是 dry-run 或 test mode 时，通过观察（file、network、git ref）来核实它实际跳过了什么，而不是相信它的名字：有些 dry-run 仍会访问网络或打开浏览器。
- **Cleanup：** 如何拆掉本次运行创建的实例。绝不按进程名 kill；kill 你自己启动的东西。Cleanup 清除实例和 scratch state，绝不清除证据：proof artifact 要在 teardown 后存活，放在 skill 点名的位置。
- **Helpers：** skill 附带的任何 script 都必须可执行，其调用方式在 skill body 中展示。需要读者反向工程才能用的 helper 不算 helper。

## 3. 播种 feature map

创建 `.cursor/skills/verify-<app>/features/README.md`，外加每个你能识别出的面向 user 的 feature 一个文件（起步瞄准前 3-5 个，从 route、command、menu 或 doc 中找）。遵循 [`references/feature-map-example/`](references/feature-map-example/) 里的形状，带一个 README 索引和每个 feature 一个文件。每个文件都从 user 的视角回答：这个 feature 是什么、如何到达、如何用 harness 驱动它、以及什么可观察的 end state 能证明它可用。四个 H2 是 `Sub-features`、`How to get to it (user POV)`、`Driving it with <harness>` 和 `Gotchas`。如果 seed data 缺少某段旅程所需的前置条件，该旅程就报 failure，原因写进该 feature 的 `Gotchas`。绝不为了让旅程通过而弱化它。map 是这个 repo 维护的 verification 来源；当一个 map 列出了多个入口点时，只驱动其中一个便利入口的 proof 是不完整的。

## 4. 交接之前先证明生成的 skill

把它的说明完整跑一遍：launch、doctor、驱动**一个**已 map 的 feature（一个就够；map 的存在是为了让后续运行能覆盖其余部分）、采集证据、清理。清理之后，确认证据仍在被点名的位置——吃掉证据的 cleanup 会判这一步失败。修掉失败之处，并且每次失败的迭代之后也要跑生成的 cleanup，免得失败尝试留下进程和 port 的残骸。一个从未被执行过的生成 skill 只是草稿，不是交付物。如果你是在真实目标的替身上证明的（用 container 代替全新 VM、用本地 stack 代替远程的），就把替身做过、而真实目标不会做的每一个 setup 步骤列出来。这些步骤在真实目标上跑过一次覆盖之前，都算未验证。

## 5. 提供维护 loop

指引 user 去看 `/maintain-verification-skill`，以便在 app 变化时让 map 保持诚实。只有他们问起，才建议频率。