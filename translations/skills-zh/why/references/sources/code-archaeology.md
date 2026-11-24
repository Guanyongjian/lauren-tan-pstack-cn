# Code Archaeology (git + in-repo)

## What this source contains

- commit 历史（message、日期、作者、diff）
- PR description、review comment 和讨论 thread（经 `gh`）
- 行内 code comment、TODO、FIXME、deprecation 说明
- ADR（architecture decision record），若该 repo 有维护
- test：其名称与 assertion 常常编码了促成某次改动的边界 case
- 同一批 commit 里一并改动的相关 file（co-change signal）
- repo 里的 CHANGELOG 条目与 release note
- commit message 和 PR body 里的 issue/ticket ID

最可信的来源，直接与 code 绑定，也最完整。凡经过这个 repo 的东西都应该在这里。

## How to search it

扩展种子 commit 清单：

```bash
# History through renames
git log --follow --oneline -- <file>

# Pickaxe: commits that added or removed this exact text
git log -S '<exact_string_from_code>' -- <file>

# Or for patterns:
git log -G '<regex>' -- <file>

# Who wrote each line and when
git blame -L <start>,<end> <file>

# One commit's full diff
git show <hash>

# Commits between two points affecting this file
git log <old>..<new> -p -- <file>
```

寻找 out-of-band 的 doc：

```bash
# ADRs often live in docs/adr/ or similar
rg -l -i 'architecture.decision' --glob '*.md'

# TODOs and FIXMEs near the target
rg -n -C2 '(TODO|FIXME|HACK|XXX|NOTE)' <target_file>

# Related tests
rg -l '<symbol>' --glob '*test*'
```