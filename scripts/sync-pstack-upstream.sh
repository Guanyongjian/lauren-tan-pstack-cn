#!/usr/bin/env bash
set -euo pipefail

# Mirror the exact P-Stack source paths from cursor/plugins into this repository.
# Usage: scripts/sync-pstack-upstream.sh [branch|tag|commit]
UPSTREAM_REF="${1:-3dbd22ff12742fb28c9700b9760baa29ed41dc13}"
UPSTREAM_URL="https://github.com/cursor/plugins.git"
REPO_ROOT="$(git rev-parse --show-toplevel)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

SRC="$TMP_DIR/cursor-plugins"
DEST="$REPO_ROOT/upstream/cursor-plugins"

git clone --filter=blob:none --no-checkout "$UPSTREAM_URL" "$SRC"
git -C "$SRC" sparse-checkout init --cone
git -C "$SRC" sparse-checkout set \
  pstack \
  harness/pstack \
  scripts/check-pstack-docs.mjs \
  scripts/generate-pstack-harness-trees.mjs

git -C "$SRC" fetch --depth=1 origin "$UPSTREAM_REF"
git -C "$SRC" checkout --detach FETCH_HEAD

UPSTREAM_COMMIT="$(git -C "$SRC" rev-parse HEAD)"
UPSTREAM_TREE="$(git -C "$SRC" rev-parse HEAD^{tree})"
PSTACK_VERSION="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$SRC/pstack/plugin.json" | head -n 1)"

mkdir -p "$DEST/pstack" "$DEST/harness/pstack" "$DEST/scripts" "$REPO_ROOT/upstream"
rsync -a --delete "$SRC/pstack/" "$DEST/pstack/"
rsync -a --delete "$SRC/harness/pstack/" "$DEST/harness/pstack/"
mkdir -p "$DEST/scripts"
cp -p "$SRC/scripts/check-pstack-docs.mjs" "$DEST/scripts/"
cp -p "$SRC/scripts/generate-pstack-harness-trees.mjs" "$DEST/scripts/"

PSTACK_COUNT="$(find "$DEST/pstack" -type f | wc -l | tr -d ' ')"
HARNESS_COUNT="$(find "$DEST/harness/pstack" -type f | wc -l | tr -d ' ')"
SCRIPT_COUNT="$(find "$DEST/scripts" -maxdepth 1 -type f \( -name 'check-pstack-docs.mjs' -o -name 'generate-pstack-harness-trees.mjs' \) | wc -l | tr -d ' ')"
TOTAL_COUNT=$((PSTACK_COUNT + HARNESS_COUNT + SCRIPT_COUNT))

cat > "$REPO_ROOT/upstream/来源与版本说明.md" <<EOF
# P-Stack 上游快照说明

本目录保存上游 `cursor/plugins` 仓库中与 P-Stack 直接相关的原始文件。

- 上游仓库：$UPSTREAM_URL
- 上游 Commit：`$UPSTREAM_COMMIT`
- 上游 Git tree：`$UPSTREAM_TREE`
- P-Stack 版本：`$PSTACK_VERSION`
- 同步日期：$(date -u +%F)
- P-Stack 原始文件：$PSTACK_COUNT
- Claude Code Harness 文件：$HARNESS_COUNT
- 配套维护脚本：$SCRIPT_COUNT
- 文件总数：$TOTAL_COUNT

## 目录对应关系

| 上游路径 | 本仓库路径 | 文件数 |
|---|---|---:|
| `pstack/` | `upstream/cursor-plugins/pstack/` | $PSTACK_COUNT |
| `harness/pstack/` | `upstream/cursor-plugins/harness/pstack/` | $HARNESS_COUNT |
| 两个 P-Stack 检查 / 生成脚本 | `upstream/cursor-plugins/scripts/` | $SCRIPT_COUNT |

## 许可证与版权

P-Stack 的 `pstack/plugin.json` 声明许可证为 MIT。原始 `pstack/LICENSE` 和 Harness 内的 LICENSE 均随快照保留。上游版权声明为 Lauren Tan（2026）。再分发或修改时请保留原始许可与版权声明。

本仓库是独立中文研究与解读项目，不代表 Lauren Tan、Cursor 或其关联组织。

## 更新方式

在本仓库根目录运行：

```bash
scripts/sync-pstack-upstream.sh <branch|tag|commit>
```

也可以在 GitHub Actions 中手动运行“同步 P-Stack 上游快照”工作流。同步只更新 `upstream/cursor-plugins/` 和本说明文件，不覆盖 `translations/`、`docs/` 或根目录研究成果。
EOF

echo "Synced cursor/plugins@$UPSTREAM_COMMIT (P-Stack $PSTACK_VERSION; $TOTAL_COUNT files)."
