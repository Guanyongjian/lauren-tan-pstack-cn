# Bugbot triage

当 Babysit playbook（`../playbooks/babysit.md`）处理 Bugbot 或 review-automation comment 时，使用本 reference。目标不是默认忽略 Bugbot，而是不再把每条 comment 都当作必须修改 code 的要求。

## 决策 rubric

在采取行动前，将每个 Bugbot thread 分类：

- `fix`：该 comment 指出了可信的 correctness、security、privacy、data loss、auth、billing、migration、idempotency、race 或 shipped-behavior 问题。在拥有该 code 的最低层 PR 中修复，然后回复 commit SHA 并 resolve 该 thread。
- `dismiss`：该 comment 符合已记录的低风险噪声 pattern，且当前 code/context 证明该 concern 无需修改 code。回复简短理由并 resolve 该 thread。
- `ask`：该 comment 是新颖、高严重度、涉及 security/privacy/data，或含义不明。询问用户，不要猜测。

有疑问时，询问用户。跳过一条噪声 code-quality comment 代价很低；漏掉真正的 data 或 security bug 则不然。

## 已习得 pattern 的格式

按以下形状添加未来的 pattern：

```markdown
### <short pattern name>

- Confidence: candidate | recurring | strong
- Skip when: <conditions that must be true>
- Do not skip when: <risk boundaries>
- Example signal: <phrases or code context that identify the pattern>
- Source: <PR/comment URL or short historical note>
```

一两个示例用 `candidate`。多次真实 dismiss 后用 `recurring`。只有 pattern 范围窄、经过反复验证且低风险时才用 `strong`。

## 反复出现的 skip 候选

### 有意的 UI 或 design-system 视觉变更

- 置信度：candidate
- 可 skip 的条件：PR description、screenshot、design review 或附近 code 明确表明这是有意的视觉变更，且 Bugbot comment 只是在复述某个共享视觉默认值发生了变化。
- 不要 skip 的条件：该 comment 指向 accessibility、focus visibility、keyboard navigation、color contrast，或 PR 并未有意变更的 component API contract。
- 示例 signal：关于 focus outline、按钮尺寸、间距或共享 component 视觉默认值的 comment，且 owner 回复 "intentional" 或 "intended"。

### Bugbot 看不到的 upstack 或 stack-local 用法

- 置信度：candidate
- 可 skip 的条件：Bugbot 将某个 export、component、helper 或 file 标为未使用，而 active forge 的 PR 列表和 diff、upper-stack diff 或 PR context 显示它被 stack 中较后的 PR 使用。
- 不要 skip 的条件：当前 PR 不属于 stack、该 symbol 是 public API，或无法验证所谓的 upstack 使用。
- 示例 signal："Exported component is never used"，并附有人类回复，例如 "used upstack"。

### 并行实现期间的临时重复

- 置信度：candidate
- 可 skip 的条件：PR 有意重复少量 code，使新 path 与正在删除、替换或验证的旧 path 保持并行。
- 不要 skip 的条件：重复 code 改变 security、billing、data access 或 API 行为，或长寿命的共享抽象显然会降低风险。
- 示例 signal："Significant duplication" 或 "duplicated validation logic"，且 owner 解释旧 path 将被删除，或重复逻辑是有意保留在局部的。

### 现有 framework 或 component invariant 已覆盖该警告

- 置信度：candidate
- 可 skip 的条件：当前 diff 或附近 code 可见的共享 component、framework contract、type invariant 或 single source of truth 已经保证该 concern 不成立。
- 不要 skip 的条件：invariant 只是假设存在而未强制执行、依赖 timing，或跨越 async/state 边界而值可能分叉。
- 示例 signal：关于内部 popover 缺少 max-height 的 comment，但共享 popover 已强制 viewport 边界；或 nullable 值场景，其中本地已检查值与传入值来自同一 source。

### owner 声明的 follow-up 或延后 cleanup

- 置信度：candidate
- 可 skip 的条件：PR owner 明确表示该 issue 是已知 follow-up、当前 PR 没有使行为变差，且 comment 不涉及高风险领域。
- 不要 skip 的条件：agent 在没有 owner 意见的情况下行动、该 issue 是中/高严重度的产品行为，或延后会 merge 新 regression。
- 示例 signal："I'll worry about that later" 或 "we'll delete this eventually"。

### 自行撤回或明确的 false-positive 规则 comment

- 置信度：recurring
- 可 skip 的条件：comment 正文或后续 Bugbot 回复明确表示该 finding 已撤回、合规或是 false positive，且 agent 能在本地验证相关 rule。
- 不要 skip 的条件：唯一证据只是有人对高风险 issue 说 "false positive"，却没有解释。
- 示例 signal：一条 file-naming rule comment，其正文说明该 file 已符合规则。

## 默认 ask

即使之前的 PR 曾 dismiss 类似事项，也不要自动 skip 以下类别：

- security、privacy、auth、billing、data retention、training-data 和 permission-boundary finding。
- 高严重度 finding。
- migration、schema、idempotency、concurrency 和 cross-system 行为 finding。
- 建议的 fix 很小、明显降低风险且不改变产品意图的 comment。

历史数据表明，人有时会 dismiss security/data-flow comment。把这些视为 owner 的判断，而不是团队范围的 skip 规则。

## 近期 babysit 得到的候选经验

在 babysit 期间或之后，如果新的候选经验看似对团队有用但尚不成熟，就追加到这里。多个 PR 确认该 pattern 后，优先把反复出现的候选提升到上一节。

### 手工重新实现 native browser 行为

- 置信度：candidate
- 可 skip 的条件：实际上几乎永不。当 diff 用手工等价实现替代 native browser 行为（native sticky → JS-positioned clones、native scroll targeting → 转发的 wheel/touch event、paint-order occlusion → masks/clip-path）时，Bugbot 针对这类 code 提出的 logic-bug finding 一直被证明是成立的。
- 不要 skip 的条件：finding 涉及 event-forwarding 缺口（wheel deltaMode、touch pan、边缘处的 scroll-chaining、tap slop）、mask/clip hit-testing 分歧，或这类 code 中 observer 与 React state 的 timing race。默认 fix。
- 示例 signal："masks do not affect hit-testing"、"overlay blocks wheel scroll"、"ignores deltaMode"、"runs in the IntersectionObserver callback before React applies state"。
- 来源：一个 sticky-occlusion PR：六轮 Bugbot pass，约十八个 finding，每一个都 fix 而非 dismiss。

### contract-test drift claim 的验证成本很低——先跑 test

- 置信度：candidate
- 可 skip 的条件：绝不跳过 verification 本身；它只需一条 command。当 PR
  随附一个用于锁定 protocol 或 documentation 散文的 contract test（针对
  某个 SKILL.md 的 regex、doc 措辞的 snapshot），而 Bugbot 声称「test 不再
  与 doc 匹配」（或反之）时，先在 PR tip 上运行该 test，再
  分类。红色运行结果以实证确认该 claim；绿色运行结果则是
  dismiss 回复所需的具体反证。
- 不要 skip 的条件：n/a——这是 verification 捷径，不是 dismiss
  pattern。注意，repeat-pass 的 lean-dismiss 启发式在这里会误触发：
  锁定散文的 test 之所以 drift，正是因为前几轮 fix 修改了散文。
- 示例 signal：在某个 PR 上出现 "Contract test omits the pre-fix wait"，其早期
  fix commit 改写了被锁定的段落；在 tip 上运行 test 时，
  失败的恰好是被引用的 assertion。
- 来源：一个锁定散文的 PR，经历八轮 Bugbot pass；尽管之前每轮都已
  fix 并 resolve，该 claim 在第 7 轮仍属实。

### 同一 PR 后续已修复的过期 security-review finding

- 置信度：candidate
- 可 skip 的条件：agentic security review（或类似审查）声称缺少 authz/validation 调用，而当前 PR tip 明确包含那个确切的 gate（含 test）；通常是在审查运行后，由后续 hardening commit 添加。
- 不要 skip 的条件：所引用 helper 对讨论中的 principal 是 no-op、检查发生在其守护的 side effect 之后，或缺少所声称 principal 的 coverage。
- 示例 signal：一条 HIGH 的 "missing authorization check" finding，而 tip 上那个确切的 guard 已在 side effect 之前调用。
- 来源：一个 webhook-endpoint PR，其 hardening commit 晚于审查运行。

### 扩大刻意收窄的 error condition 会掩盖真正的 error

- 置信度：candidate
- 可 skip 的条件：finding 要求把狭窄的 error condition（特定
  `errno`、error code 或 status class）扩大为 catch-all，而这种狭窄性
  表达了真实的区别。典型形态是以 `ENOENT` 为 gate 的 dependency
  fallback：「binary 未安装」与「command 已运行但失败」是不同情况。
  对任何非零 exit 都 retry，会把正当失败（not found、expired auth、
  network）拿到 fallback 上重跑，然后报告 fallback 的 error，
  从而掩盖真正的 error。
- 不要 skip 的条件：狭窄条件漏掉了同一类别中的情况
  （另一个「binary 不可用」的 errno，例如 `EACCES`，另一个 transport-level
  failure）、未处理 path 会丢失 data 或留下 partial state，或 retry
  具有 idempotency 且 original error 仍会被 surfaced。
- 示例 signal："only retries when X fails with ENOENT … never tries the
  fallback even when a working Y exists"，指向的 code 中 fallback
  是为 dependency 缺失而不是 operation 失败准备的。
- 来源：一个 CLI-rename PR，其 fallback 是为 binary 缺失而不是
  command 失败准备的。
