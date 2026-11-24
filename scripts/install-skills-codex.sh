#!/usr/bin/env bash
# 安装 pstack 中文 skill 到 Codex（$CODEX_HOME/skills 或 --dest）
# 规则：译文 .md 优先；译文缺失的 .md 与非 md 资源从上游英文补齐。
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-}"
DEST="${1:-${CODEX_HOME:-$HOME/.codex}/skills}"
UP="$REPO_ROOT/upstream/cursor-plugins/pstack/skills"
ZH="$REPO_ROOT/translations/skills-zh"
DRY=0
[ "${2:-}" = "--dry-run" ] && DRY=1

echo "upstream : $UP"
echo "zh       : $ZH"
echo "dest     : $DEST"
echo "dry-run  : $DRY"
echo

[ -d "$UP" ] || { echo "ERROR: upstream not found: $UP"; exit 1; }
[ -d "$ZH" ] || { echo "ERROR: translations not found: $ZH"; exit 1; }

installed=0; zh_md=0; fallback_md=0; res=0

# 枚举译文里所有含 SKILL.md 的目录（排除 automations）
while IFS= read -r skill_md; do
  rel="${skill_md#$ZH/}"          # e.g. ketchup/SKILL.md
  rel_dir="$(dirname "$rel")"     # e.g. ketchup
  case "$rel_dir" in automations*) continue;; esac
  name="$(basename "$rel_dir")"
  src_up="$UP/$rel_dir"
  src_zh="$ZH/$rel_dir"
  out="$DEST/$name"

  [ -d "$src_up" ] || { echo "SKIP (no upstream): $rel_dir"; continue; }
  echo "install: $name"

  if [ "$DRY" = "1" ]; then
    # 报告将要做什么
    while IFS= read -r f; do
      r="${f#$src_up/}"
      if [ -f "$src_zh/$r" ]; then echo "    md  <zh>   $r"; else echo "    md  <up>   $r"; fi
    done < <(find "$src_up" -type f -name '*.md' | sort)
    while IFS= read -r f; do
      r="${f#$src_up/}"
      echo "    res <up>   $r"
    done < <(find "$src_up" -type f ! -name '*.md' | sort)
    installed=$((installed+1))
    continue
  fi

  mkdir -p "$out"
  # 1) 上游全部 .md：译文存在则用译文，否则用上游
  while IFS= read -r f; do
    r="${f#$src_up/}"
    mkdir -p "$out/$(dirname "$r")"
    if [ -f "$src_zh/$r" ]; then cp "$src_zh/$r" "$out/$r"; zh_md=$((zh_md+1));
    else cp "$f" "$out/$r"; fallback_md=$((fallback_md+1)); fi
  done < <(find "$src_up" -type f -name '*.md' | sort)
  # 2) 上游全部非 md 资源（脚本、配置、语料）原样复制
  while IFS= read -r f; do
    r="${f#$src_up/}"
    mkdir -p "$out/$(dirname "$r")"
    cp "$f" "$out/$r"; res=$((res+1))
  done < <(find "$src_up" -type f ! -name '*.md' | sort)
  installed=$((installed+1))
done < <(find "$ZH" -type f -name 'SKILL.md' | sort)

echo
if [ "$DRY" = "1" ]; then
  echo "DRY-RUN: would install $installed skills"
else
  echo "installed skills : $installed"
  echo "  zh .md copied  : $zh_md"
  echo "  upstream .md   : $fallback_md"
  echo "  resources      : $res"
fi