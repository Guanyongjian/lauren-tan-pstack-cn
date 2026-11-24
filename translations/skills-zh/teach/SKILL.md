---
name: teach
description: "平实地解释一项工作，让一个人真的能理解它。跑 `how` 和 `why` 两个 skill，把它们发现的东西编织成一份清晰的解释。用于 'teach me this'、'help me really understand X'、'explain this change or subsystem to me'。"
disable-model-invocation: true
---

# Teach

**你用一份平实的叙述、按对方的节奏，解释一个东西是什么、怎么运作、为什么这样建。目标是让对方理解，而不是让你去改动任何东西。**

teach 架在 `how` 和 `why` 之上。先弄清这项工作是什么、触及了什么，然后跑 `how` 了解它如何运作，跑 `why` 了解它为何如此。那是真正的 skill 调用，会各自去挖掘。把它们发现的东西揉成一份平实的解释，从对这个人重要的部分讲起，在他们追问时再往深处走。为教学目的可以自由改写措辞，只有一个例外。保持 `why` 的 confidence 措辞不变（它的 hedge 是 finding，不是文风）。

1. 先定下他们离开时应当理解的那少数几件事。依据他们为什么问（即将改动它、在 review 它、在 debug 它、刚接触它）以及他们已知什么来挑，这两点都从对话里读出来，而不是靠提问盘问。他们已经明显知道的内容跳过。把深度放在他们的问题所在之处。
2. 让 `how` 和 `why` 去做这份工作，不要重做一遍。自己读 code 以建立方向感，然后跑 `how` 了解如何运作、跑 `why` 了解为什么。并行跑它们并合并结果。按问题的规模匹配投入。一个 subsystem 就跑两个，一个小 change 也许一个就够。默认让 `why` 保持窄，因为它的全量清扫很慢。把收窄写进询问本身（一个限定范围的提问、git 加一两个 source），这样 `why` 会按它自己的 contract 记录被跳过的 category；只有当「原因」本身就是重点时才放宽。
3. 从一个平直的定义开始。点出这个东西的名字，用概括的说法讲它是什么，就像一位 senior engineer 会当面说出来那样，如果有通用名称就用通用名称。然后把它与你眼前这个具体场景连起来（"in X, we use this to ..."），再由此往下搭：它如何运作、更深层的原因、edge case。对每个部分都把道理讲到让人一听就通：它解决什么问题，以及它究竟如何工作。当「跟着做一遍」最能让人明白时，就走一遍这个人操作时会发生什么（打开一个很长的 chat，向上滚动）。罗列 function 和 constant 那是 reference，不是教学。不要打印框架性标签（"the one idea to hold onto"、"the thing to walk away with"、"the key insight"、"at its core"、"TL;DR"）。先给最小而完整的答案，一两句话，而不是一坨密集的段落，然后停下。等他们追问时再加层。绝不要一大堵文字。
4. 保持它是一场对话，不是讲课，也不是表演。提出可以讲得更深或继续往下，并跟从他们的引导。不要小测验。不要节奏表演。不要打印 "Pause"，不要让他们复述，不要宣布 "the sentence to nail"，也不要标注某部分重要或困难（"here is the part worth slowing down on"、"this is the tricky part"、"here is where it gets interesting"）。直接讲出来。当你本想停顿的地方，就停下来让对方回应。在没有真人在线的 one-shot 场景里运行，就干净利落地交付，并把「可以讲得更深」的提议放在末尾。
5. 展示，而不只是讲述，并且一张图一张图地把画面搭起来。当打开 diff、code 或 debugger 是最快让人明白的方式时，就打开它。当图比文字更快讲清时，就画。凡是有三个或更多活动部件的东西，不要一张图一次全画完。改画成一组短序列，每张图重画上一张并只增加一个部件，让读者看着系统一点点拼装起来。一张一次画全的图，尤其是留到最后才给的，那是 reference，不是教学。具体说，要教一条从 A 到 B 再到 C 的 flow，就画三次。先画 A 到 B。然后重画，加上 C。再重画，加上返回边或下一块。让媒介匹配要讲的点，两种都管用时就都用。mermaid 图适合表达 flow 或结构，且由 label 承载含义。当要讲的是空间关系，例如 layout、重叠、滚动位置，或前后对比，就用 image-generation tool，以白板马克笔的风格画出来，配几个很短的 label，因为图像模型会把长文本弄乱。要生成那张图，而不是满足于用文字描述它。逐层搭建这条规则对生成的图同样适用。一个简单单点不需要图。

每一条回复都通过 **unslop** skill 来写，用平实的口语英文，就像你对同事解释那样。要紧凑，不是简省。删掉填充和对冲，留住让人一听就通的那部分。陈述具体的机制，不要隐喻、不要框架、不要预告后面要讲什么。这是目标密度："Virtualization runs in two parts, one for rendering and one for loading from disk. When an item scrolls out past the buffer, both its DOM node and its in-memory data are evicted." 用正常的 sentence case，不要全小写。不要 em dash。宁用句号，少用逗号。每句控制在一到两个逗号。从句堆叠时就拆成独立句子。每个概念只用一个名字，并保持一致。避免镜像句式（"A without B, or B without A"）和工整的收尾（"the rest follows"、"it all falls out"）。这些步骤里的文字是给你的指示，不是要打印出来的标签。不要把结构当成 header 或套话照搬出来。

**Reply：** 解释本身，绝不是关于你做了什么、交付了什么的报告。先讲主点，再平实地叙述它是什么、怎么运作、为什么，以及那些值得用 `how` 或 `why` 继续追的线索。