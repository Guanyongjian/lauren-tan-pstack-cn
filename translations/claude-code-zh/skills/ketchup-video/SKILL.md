---
name: ketchup-video
description: "像 /ketchup 那样把 user 追上来，但用一段带字幕的短视频呈现发生了什么，等待 user 决定的事则以文字放在视频下方。用于 /ketchup-video。"
disable-model-invocation: true
---

# Ketchup video

遵循 [`/ketchup`](../ketchup/SKILL.md)，但把「发生了什么」用一段带字幕的短视频呈现，来取代它的 summary 和 visual。它的时间窗起点是 user 在 `/ketchup-video` 之前写的那条 message，而不是更早某次 `/ketchup` 之前。写并渲染视频这件事在 repo 之外进行，是它那条 read-only 规则唯一的例外。reply 的内容是：ketchup 的开场句、嵌入的视频、一行点明你自己还能做完的剩余工作，以及 action item。当视频展示了某个 call 的多个 option 时，用视频给出的名字来称呼每个 option。如果渲染失败，用一行说明，然后只给 call。

## Slides

用工作产出的 screenshot、recording、diff 和数据，而不是 chat 里关于它们的 prose。在动手画之前，先写出 user 应当带走的那一句话，以及每张 slide 一行。凡是不能改变 user 认知的 slide，删掉。最多 10 张 slide，越少越好。这两处 note 都不放进 reply。

每张 slide 只讲一个点。所有 slide 都建立在同一张图上、在 slide 之间对它做改动，而不是切到一张毫不相干的图。同一种颜色或形状在每张 slide 上含义相同。用图来展示工作，例如一个系统如何运作、一个 PR stack 及各 PR 的状态、一次 fix 的前后对比，或并排展示 option。用箭头、高亮和动效指出哪里变了。slide 绝不是 bullet list、status list、table，也不是彼此毫无连接的方块。

把文字压到最少。每个 label 直接放在它命名的那个东西上，用一个人会说的平实词，而不是 "Tests: pass" 这类标签。绝不给图配文字说明它展示了什么，也绝不重复同一个事实——无论在 slide 之间，还是在它们下方的文字里。

展示 user 所要求的每一件事各自的结果，以及它是 done、仍在运行、失败还是未检查。绝不把仍在等 user 的事情展示成已完成。把途中发现并修掉的 bug 展示出来。如果某个可见变化没有 screenshot，就在它那张 slide 上说明，并点明屏幕上变了什么。只用你手上有的事实来画。绝不编造数字，绝不画一个你没有截到的屏幕。

## Subtitles

给每张 slide 一句简短的字幕，约十个词，用你会对 user 讲话的方式说出它的要点，且只依据那张 slide 展示的内容。说出图的意思，而不是念它的 label。把字幕放在 slide 下方的一条字幕带里，每张 slide 高度相同，除字幕外留空，这样它永远不会挡住 slide。字要小，但在以 chat 尺寸播放时仍可读。

## Render

渲染一段无声的横屏视频，例如 mp4，slide 之间有动效。每一帧就是 slide 本身，铺满到边缘，位于字幕带上方。帧要从 slide 生成，绝不要通过录屏得到；把每条字幕烧进它所在 slide 的帧里，让它在整个 hold 期间都留在屏幕上。hold 是指一张 slide 完全呈现在屏幕上的时间，不把进入或离开它的动效算进去。每张 slide 的 hold 要长到足以读完它新增的字，每三个词至少一秒。一张 slide 新增的内容是它的字幕，加上此前不在它上面的每一个词，包括它所改动的 label。第一张 slide 新增它的全部词。screenshot 内部的字不计入。

在嵌入视频之前，检查渲染出来的文件。以 chat 尺寸查看每张 slide 的一帧，确认它的字幕可读、且没有遮挡任何东西。通过把文件的帧与 slide 对应来测量每个 hold，而不是用静止帧检测器——后者会把 fade 的淡出尾段也算作静止。把每张 slide 新增的词数与实测 hold 相对照。凡是无法在那么长时间内读清的 slide，都修掉，重新渲染，再检查一遍。