#!/usr/bin/env pwsh
# 派生 Claude Code 中文树 -> translations/claude-code-zh/
# 源 A: upstream/cursor-plugins/harness/pstack/claude-code （英文，已适配 Claude Code）
# 源 B: translations/skills-zh                            （中文，源自 Cursor 版 pstack）
# 规则:
#   1) 上游每个 .md: 若有对应中文则用中文, 否则用上游英文并记录
#   2) 中文若缺 claude-code 的 adapter 段落, 插入中文 adapter 段落
#   3) 非 .md 资源原样复制
#   4) docs/guide 文件名本地化映射
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..')
$srcCc = Join-Path $repo 'upstream\cursor-plugins\harness\pstack\claude-code'
$srcZh = Join-Path $repo 'translations\skills-zh'
$out   = Join-Path $repo 'translations\claude-code-zh'

$adapterEn = 'In Claude Code, read [the Claude Code adapter](../../docs/harness/claude-code.md) once per session before you follow this skill. It maps the Cursor names in pstack skills to Claude Code.'
$adapterZh = '在 Claude Code 中，遵循本 skill 之前，每个 session 先读一次 [Claude Code 适配说明](../../docs/harness/claude-code.md)。它把 pstack skill 里的 Cursor 名字映射到 Claude Code。'

# docs/guide 文件名映射（上游英文 -> 中文）
$guideMap = @{
  'README.md'               = '指南目录.md'
  '01-setup.md'             = '01-安装与配置.md'
  '02-poteto-mode.md'       = '02-Poteto模式任务路由.md'
  '03-understand.md'        = '03-代码理解.md'
  '04-design.md'            = '04-架构设计.md'
  '05-build-and-clean.md'   = '05-功能实现与代码清理.md'
  '06-verify-and-ship.md'   = '06-验证与交付.md'
  '07-overnight.md'         = '07-自主运行与自动化.md'
  '08-principles.md'        = '08-工程原则.md'
  '09-make-it-yours.md'     = '09-定制工作流.md'
  '10-recipes-and-pitfalls.md' = '10-实践配方与常见陷阱.md'
}

$stat = @{ Zh=0; En=0; Res=0; AdapterInserted=0; AdapterAlready=0 }

function Ensure-Dir($p){ if(-not (Test-Path -LiteralPath $p)){ New-Item -ItemType Directory -Path $p -Force | Out-Null } }

function Write-File($path,$text){
  if($DryRun){ return }
  Ensure-Dir (Split-Path $path)
  [IO.File]::WriteAllText($path,$text,(New-Object Text.UTF8Encoding $false))
}

function Copy-Res($from,$to){
  if($DryRun){ return }
  Ensure-Dir (Split-Path $to)
  Copy-Item -LiteralPath $from -Destination $to -Force
}

# 仅当上游该文件含 adapter 段落时，给中文补上对应的中文 adapter 段落
function Add-Adapter($zhText, [bool]$upstreamHasAdapter){
  if(-not $upstreamHasAdapter){ return $zhText }
  if($zhText.Contains('docs/harness/claude-code.md')){ $script:stat.AdapterAlready++; return $zhText }
  $m = [regex]::Match($zhText, '(?m)^# .+\n')
  if(-not $m.Success){ $script:stat.AdapterInserted++; return $zhText }
  $pos = $m.Index + $m.Length
  $script:stat.AdapterInserted++
  return $zhText.Substring(0,$pos) + "`n" + $adapterZh + "`n" + $zhText.Substring($pos)
}

Write-Host "src claude-code : $srcCc"
Write-Host "src zh          : $srcZh"
Write-Host "out             : $out"
Write-Host "dry-run         : $($DryRun.IsPresent)"
Write-Host ''

Get-ChildItem -LiteralPath $srcCc -Recurse -File | Sort-Object FullName | ForEach-Object {
  $rel = $_.FullName.Substring($srcCc.Length + 1)
  $isMd = $_.Extension -eq '.md'

  if(-not $isMd){
    Copy-Res $_.FullName (Join-Path $out $rel)
    $script:stat.Res++
    return
  }

  # 找对应中文。skills-zh 下的布局是 skills 内容的根（无 skills/ 前缀），
  # 而 agents/ 也直接位于其下；docs 走 translations/guide。
  $zhCandidate = $null
  if($rel -like 'skills\*'){
    $sub = $rel.Substring('skills\'.Length)
    $zhCandidate = Join-Path $srcZh $sub
  } elseif($rel -like 'agents\*'){
    $sub = $rel.Substring('agents\'.Length)
    $zhCandidate = Join-Path (Join-Path $srcZh 'agents') $sub
  } elseif($rel -like 'docs\guide\*'){
    $fn = Split-Path $rel -Leaf
    $zhName = if($guideMap.ContainsKey($fn)){ $guideMap[$fn] } else { $fn }
    $zhCandidate = Join-Path $repo ('translations\guide-zh\' + $zhName)
  } elseif($rel -like 'docs\*'){
    # docs 下的其它文档（如 docs/harness/claude-code.md）映射到 translations/skills-zh/docs/
    $zhCandidate = Join-Path $srcZh $rel
  } elseif($rel -eq 'README.md'){
    # 根 README 暂无译文；若将来补译，放在 translations/README.zh.md
    $cand = Join-Path $repo 'translations\README.zh.md'
    if(Test-Path -LiteralPath $cand){ $zhCandidate = $cand }
  }

  if($zhCandidate -and (Test-Path -LiteralPath $zhCandidate)){
    $text = [IO.File]::ReadAllText($zhCandidate,[Text.Encoding]::UTF8)
    # 严格以上游为准：上游该文件有 adapter 段落，中文才补
    $upText = [IO.File]::ReadAllText($_.FullName,[Text.Encoding]::UTF8)
    $hasAdapter = $upText.Contains('docs/harness/claude-code.md')
    $text = Add-Adapter $text $hasAdapter
    Write-File (Join-Path $out $rel) $text
    $script:stat.Zh++
  } else {
    Copy-Res $_.FullName (Join-Path $out $rel)
    $script:stat.En++
    Write-Host "  [EN fallback] $rel" -ForegroundColor Yellow
  }
}

Write-Host ''
Write-Host "zh .md        : $($stat.Zh)"
Write-Host "en .md (回退) : $($stat.En)"
Write-Host "resources     : $($stat.Res)"
Write-Host "adapter 插入  : $($stat.AdapterInserted)"
Write-Host "adapter 已存在: $($stat.AdapterAlready)"

# plugin.json 的 description 本地化（其余字段保持上游原样）
$pluginPath = Join-Path $out '.claude-plugin\plugin.json'
if(-not $DryRun -and (Test-Path -LiteralPath $pluginPath)){
  $pj = [IO.File]::ReadAllText($pluginPath,[Text.Encoding]::UTF8)
  $enDesc = 'if you want to go fast, go deep first. pstack helps you write less, but higher quality code. rigorous agent workflows you can parallelize with confidence.'
  $zhDesc = '如果你想走得快，先往深里走。pstack 帮你写得更少，但质量更高。这是一套你可以放心并行的严格 agent workflow。'
  if($pj.Contains($enDesc)){
    [IO.File]::WriteAllText($pluginPath,$pj.Replace($enDesc,$zhDesc),(New-Object Text.UTF8Encoding $false))
    Write-Host "plugin.json description: 已本地化"
  }
}