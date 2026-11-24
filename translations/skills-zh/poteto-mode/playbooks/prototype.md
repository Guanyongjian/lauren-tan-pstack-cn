### Prototype

**你负责这个 design 决定，不负责 code。prototype 是一次性的工具。真正的构建随后由 Feature 接手。**

这是唯一一个 playbook，Laziness Protocol 的「最小改动」与验证门槛在这里是反过来用的。速度优先于打磨，code 质量不重要，不做规划。rigor 体现在以低成本选对 design。提出 user 没要求的变体，把一个方案丢掉再试另一个。

1. 界定这个 prototype 存在的目的——要做哪个决定：哪种 layout、哪种交互、哪种密度；对于实证分叉，则是哪种行为、时序或做法。没有决定就没有 prototype。路由到 Feature。
2. design 空间还开放时先收集参考。搜一下已有的做法，归纳一份由主题、配色和 layout 组成的 moodboard，让 user 在建之前先挑方向。方向已定就跳过。
3. 在一个隔离的 scratch dir 里做一次性实现，与产品 source 分开。视觉决定就用原生 HTML/CSS/JS，或用最轻的能把这个想法渲染出来的 stack、CDN 依赖、带热重载的 dev server。行为或时序决定就用能演练该问题的最小 script。不用产品框架、不写 test、不做 abstraction。
4. 比较备选时，把它们做在同一个切换器后面（button 或按键），每个变体都带 label。这就是把 **exhaust-the-design-space** 原则 skill 做便宜。
5. 在对应的 surface 上验证。视觉决定就通过 control skill 给每个变体截图并驱动交互。行为或时序决定就靠记录 timing、打印 output 或观察 render 来观察你正在决定的那件事。这里的观察就是 test，不是 assertion。
6. 呈现备选、tradeoff 和一个建议。产出是这个决定加那件一次性 artifact，不是可 ship 的 code。把选定的方向交给 **Feature**（或交给 `architect` 定形状）去做真正的构建。

**Reply：** 探索过的变体、证据（视觉决定给截图，行为决定给观察到的 output 或 timing）、tradeoff、你的建议，以及 scratch 路径。明确说明这个 prototype 是一次性的。