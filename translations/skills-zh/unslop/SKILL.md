---
name: unslop
description: "去掉任何 writing 里的 AI 痕迹。"
disable-model-invocation: true
---

# Unslop

编辑文本，去掉 AI 腔。扫一遍下面的 pattern，然后重写。保持原意，并匹配原本的 tone。

## 要识别并修掉的 pattern

规则编号是稳定的 id，其他 skill 会引用它们。删掉一条规则会留下空号，不要重排。

### Content

3. **Superficial -ing 短语。** "highlighting..."、"ensuring..."、"reflecting..."、"showcasing..."、"fostering..."。删掉，或用真实来源展开。

5. **含糊的归因。** "Experts believe"、"Industry reports suggest"、"Some critics argue"。点名来源，或者删掉。

### Language

7. **AI 词汇。** Additionally、crucial、delve、enduring、enhance、fostering、garner、interplay、intricate、landscape（抽象义）、pivotal、showcase、tapestry（抽象义）、testament、underscore、vibrant。换成朴素词。

8. **花哨的「is」。** "serves as"、"stands as"、"boasts"、"features"。就说 "is" 或 "has"。

9. **"Not just X, but Y."** 直接说出那个点。

10. **三件套。** 不要把想法硬凑成三个一组。该几个就几个。

11. **同义词轮换。** 一整段里 protagonist、main character、central figure、hero 轮着用。挑一个，重复用它。

12. **假区间。** "from X to Y"，而 X 和 Y 并不在同一个有意义的 scale 上。直接列 topic。

### Style

13. **em dash 滥用。** 完全避开 em dash。只用句号或逗号（不要括号、不要 en dash、不要用连字符冒充破折号）。如果一句话需要分隔，就断句或用逗号。

14. **colon 滥用。** colon 用在 list 或 example 之前没问题，但不要拿它当句中连接词。"If you're coming from traditional automation: instead of registering event handlers, you describe conditions" 里的 colon 什么也没加。重写成让这个点自己立住、不靠对比框架："Describing when the scheduler should fire works best as plain English." 意思一样，不需要拐杖式的标点。

15. **粗体滥用。** 不要给每个专有名词或缩写都加粗。

16. **inline-header list。** 特征是「粗体标签 + colon」把这一行又复述一遍："**Performance:** Performance improved..."。改成 prose。如果粗体引子以句号结尾、点明了这个 item、后面接的确实是新信息（"**Schema in TypeScript.** Tables live in one file."），那是可以的，不算 tell。

17. **标题用 Title Case。** 改用 sentence case。

18. **装饰性 emoji。** 从标题和 bullet 里去掉。

19. **弯引号。** 用直引号。

### Communication artifacts

20. **chatbot 套话。** "I hope this helps!"、"Let me know if..."、"Of course!"、"Certainly!"、"Found the smoking gun!"。删掉。

22. **谄媚语气。** "Great question! You're absolutely right!" 直接回应。

### Filler

23. **填充短语。** "In order to" 改成 "To"。"Due to the fact that" 改成 "Because"。删掉 "It is important to note that"。

24. **过度对冲。** "could potentially possibly be argued that it might" 改成 "may"。

25. **泛泛的结论。** "The future looks bright." 说出具体的计划或事实。

### Jargon

26. **抽象隐喻名词。** Substrate（base）、wedge、wedge in（add）、vector（way、method）、locus、vantage、nexus、当名词用的 primitive、当隐喻用的 harness、"API surface" 里的 surface、bedrock、当隐喻用的 scaffolding、modality、paradigm、gold-plating（超过活儿所需）、当隐喻用的 ratchet（该说机制的真名，或说「只会逐步收紧的 limit」）、指移动代码的 evacuate（用 move out）、endgame（最后阶段）、north star、flywheel。这些读起来很技术，但通常都有更朴素的实词。挑那个实词。

### Plain speech

27. **说你做什么，而不是说它感觉如何。** "the database stays close at hand"、"SQL you can read"、"types that follow your schema" 都在描述一种感觉。改法是点名机制或给出数字："`.toSQL()` returns the exact string sent to the database"、"a column rename fails the build"。问自己：这句话让读者去做什么或知道什么？然后把这个写出来。如果你没法把它复述成一条具体指令、事实或数字，就删掉。再检查一次：如果这句话原封不动出现在另一个项目的 doc 里也说得通，那它对当前项目什么也没说。删掉。

28. **拆短或拆分密句。** 如果读者得回读才能解析一句，就拆成两句或去掉从句。一句一个意思。

29. **主动语态。** 优先用它。抓 "is/are/was/were + 过去分词"，并点出施动者："queries are validated" 改成 "the compiler validates queries"，"the file is parsed by the loader" 改成 "the loader parses the file"。只有在施动者未知、或确实无关紧要时，被动才没问题。

30. **删掉副词，或换个更强的动词。** "runs quickly" 改成 "is fast" 或给出数字，"significantly improves" 改成实测的 delta。靠副词撑着的弱动词，说明动词本身错了。

31. **优先用朴素词。** "utilize" 和 "leverage" 改成 "use"，"facilitate" 改成 "help"，"numerous" 改成 "many"，"in the event that" 改成 "if"。更花哨的同义词很少更清楚。

32. **拿腔的 prose。** 明明有字面说法却用隐喻或修饰：格言腔（"wire it or delete it"）、为效果而用的修辞性片段、把 code 拟人（"the plan holds it"）、比喻性动词（"rides along"、"stands on"）、套式框架短语。"A dial worth turning" 改成 "a parameter worth varying"。说你的意思。隐喻名词归规则 26 管。

33. **过度压缩。** 省掉冠词、无动词的片段、符号化表达、让读者得先解码才能读的缩写。"Parser rejects bad date → exit 2, no write" 改成 "The parser rejects a bad date, exits with code 2, and writes nothing."。写完整句子，带冠词和动词，把箭头和缩写都展开。
