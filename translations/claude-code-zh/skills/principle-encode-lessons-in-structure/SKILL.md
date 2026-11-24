---
name: principle-encode-lessons-in-structure
description: "当你发现自己第二次写下同一条 instruction，或注意到某个 correction 反复出现时适用。把这条 rule 固化成 lint、metadata flag、runtime check 或 script，而不是更多文字。"
disable-model-invocation: true
---

# Encode Lessons in Structure（把教训固化进结构）

如果这条 lesson 需要 judgment、无法 encode，就把 instruction 写得更醒目，并补一个 failure mode 的例子。

**Corollary:** 如果 fix 是结构性的，就只用结构性 fix。instruction 只是 symptom。
