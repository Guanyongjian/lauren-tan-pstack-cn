#!/usr/bin/env bash
# 安装 Claude Code 中文版 pstack。
#
#   bash scripts/install-claude-code-zh.sh plugin [目标]   装为 plugin（默认 ~/.claude/plugins/pstack）
#   bash scripts/install-claude-code-zh.sh skills [目标]   只装 skills（默认 ~/.claude/skills）
#   加 --dry-run 只打印计划
set -euo pipefail

MODE="${1:-plugin}"
shift || true
DRY=0
DEST=""
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    *) DEST="$a" ;;
  esac
done

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
SRC="$REPO_ROOT/translations/claude-code-zh"

[ -d "$SRC" ] || { echo "ERROR: 缺少派生树 $SRC"; echo "先运行: pwsh scripts/derive-claude-code-zh.ps1"; exit 1; }

case "$MODE" in
  plugin) DEST="${DEST:-$HOME/.claude/plugins/pstack}" ;;
  skills) DEST="${DEST:-$HOME/.claude/skills}" ;;
  *) echo "ERROR: 模式须为 plugin 或 skills，收到: $MODE"; exit 1 ;;
esac

echo "模式   : $MODE"
echo "源     : $SRC"
echo "目标   : $DEST"
echo "dry-run: $DRY"
echo

if [ "$MODE" = "plugin" ]; then
  # 整棵树，保留 .claude-plugin/plugin.json 与 docs
  n=$(find "$SRC" -type f | wc -l)
  echo "将复制整棵 plugin 树: $n 个文件"
  if [ "$DRY" = "1" ]; then
    echo "  .claude-plugin/plugin.json  (plugin 清单)"
    echo "  skills/                     $(find "$SRC/skills" -maxdepth 1 -mindepth 1 -type d | wc -l) 个 skill"
    echo "  agents/                     $(find "$SRC/agents" -type f | wc -l) 个 subagent"
    echo "  docs/                       $(find "$SRC/docs" -type f | wc -l) 个文件"
    echo; echo "DRY-RUN: 未写入"; exit 0
  fi
  mkdir -p "$DEST"
  cp -a "$SRC/." "$DEST/"
  echo "已安装 $n 个文件 -> $DEST"
else
  # 只装 skills
  n=0
  for d in "$SRC"/skills/*/; do
    name="$(basename "$d")"
    cnt=$(find "$d" -type f | wc -l)
    if [ "$DRY" = "1" ]; then echo "  $name ($cnt files)"; fi
    n=$((n+1))
  done
  echo "将安装 $n 个 skill"
  if [ "$DRY" = "1" ]; then echo; echo "DRY-RUN: 未写入"; exit 0; fi
  mkdir -p "$DEST"
  for d in "$SRC"/skills/*/; do
    name="$(basename "$d")"
    mkdir -p "$DEST/$name"
    cp -a "$d." "$DEST/$name/"
  done
  echo "已安装 $n 个 skill -> $DEST"
fi