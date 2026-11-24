#!/usr/bin/env pwsh
# pstack 中文翻译 验收脚本
# 用法：
#   pwsh docs/翻译/verify.ps1                 # 跑全部检查
#   pwsh docs/翻译/verify.ps1 -Check CodeBlocks
# 检查项：CodeBlocks | Placeholders | Enums | Encoding | Skeleton | SkeletonE2E | Frontmatter

param(
    [ValidateSet('All','CodeBlocks','Placeholders','Enums','Encoding','Skeleton','SkeletonE2E','Frontmatter')]
    [string]$Check = 'All'
)

$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$up   = Join-Path $repo 'upstream\cursor-plugins\pstack'
$zh   = Join-Path $repo 'translations\skills-zh'

$script:fail = 0
$script:pass = 0

function Ok($msg)   { Write-Host "  PASS  $msg" -ForegroundColor Green; $script:pass++ }
function Bad($msg)  { Write-Host "  FAIL  $msg" -ForegroundColor Red;   $script:fail++ }
function Head($msg) { Write-Host ""; Write-Host "== $msg ==" -ForegroundColor Cyan }

# 把 upstream 的相对路径映射到译文路径
function ZhPath($rel) {
    if ($rel -like 'skills/*') {
        return Join-Path $zh ($rel.Substring(7) -replace '/', '\')
    }
    return Join-Path $zh ($rel -replace '/', '\')
}

function ReadTxt($p) { [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8) }

# 提取全部围栏代码块（含 3 空格缩进块），原样返回
function GetBlocks($text) {
    $out = New-Object System.Collections.ArrayList
    $rx = [regex]'(?ms)^(?<indent>[ \t]*)```[^\n]*\n.*?^\k<indent>```'
    foreach ($m in $rx.Matches($text)) { [void]$out.Add($m.Value) }
    return ,$out
}

# 收集所有待比对文件对
function GetPairs {
    $pairs = New-Object System.Collections.ArrayList
    $srcRoot = Join-Path $up 'skills'
    Get-ChildItem -LiteralPath $srcRoot -Recurse -File -Filter '*.md' | ForEach-Object {
        $rel = 'skills/' + $_.FullName.Substring($srcRoot.Length + 1) -replace '\\', '/'
        if ($rel -match '^skills/statechart/scripts/test/corpus/[^/]+/report\.md$') { return }
        $z = ZhPath $rel
        if (Test-Path -LiteralPath $z) {
            [void]$pairs.Add([pscustomobject]@{ Rel = $rel; Up = $_.FullName; Zh = $z })
        }
    }
    $auto = Join-Path $up 'automations'
    Get-ChildItem -LiteralPath $auto -Recurse -File -Filter '*.md' | ForEach-Object {
        $rel = 'automations/' + $_.FullName.Substring($auto.Length + 1) -replace '\\', '/'
        $z = ZhPath $rel
        if (Test-Path -LiteralPath $z) {
            [void]$pairs.Add([pscustomobject]@{ Rel = $rel; Up = $_.FullName; Zh = $z })
        }
    }
    return ,$pairs
}

$pairs = GetPairs

# ---------- CodeBlocks ----------
if ($Check -in 'All','CodeBlocks') {
    Head 'CodeBlocks：代码块逐字比对'
    $n = 0; $tot = 0
    foreach ($p in $pairs) {
        $ub = GetBlocks (ReadTxt $p.Up)
        $zb = GetBlocks (ReadTxt $p.Zh)
        if ($ub.Count -ne $zb.Count) {
            Bad "$($p.Rel)：代码块数量 UP=$($ub.Count) ZH=$($zb.Count)"; $n++; continue
        }
        for ($i = 0; $i -lt $ub.Count; $i++) {
            $tot++
            if ($ub[$i] -cne $zb[$i]) { Bad "$($p.Rel)：第 $i 个代码块不一致"; $n++ }
        }
    }
    if ($n -eq 0) { Ok "全部 $tot 个代码块逐字一致（$($pairs.Count) 个文件）" }
}

# ---------- Placeholders ----------
if ($Check -in 'All','Placeholders') {
    Head 'Placeholders：占位符完整性'
    $n = 0; $tot = 0
    foreach ($p in $pairs) {
        $u = ReadTxt $p.Up; $z = ReadTxt $p.Zh
        $set = @(
            [regex]'\{\{[A-Z0-9_]+\}\}'
            [regex]'\{[A-Z][A-Z0-9_]+\}'
        )
        $uAll = New-Object System.Collections.Generic.HashSet[string]
        $zAll = New-Object System.Collections.Generic.HashSet[string]
        foreach ($rx in $set) {
            foreach ($m in $rx.Matches($u)) { [void]$uAll.Add($m.Value) }
            foreach ($m in $rx.Matches($z)) { [void]$zAll.Add($m.Value) }
        }
        foreach ($t in $uAll) {
            $tot++
            if (-not $zAll.Contains($t)) { Bad "$($p.Rel)：缺少占位符 $t"; $n++ }
        }
    }
    if ($n -eq 0) { Ok "全部 $tot 个占位符均保留" }
}

# ---------- Enums ----------
if ($Check -in 'All','Enums') {
    Head 'Enums：字符串枚举值（下游精确匹配用）'
    $expect = @(
        @{ File = 'automations/benny/templates/triage-automation-prompt.md'; Vals = @('[benny:bug]','[benny:performance]','[benny:other]') }
        @{ File = 'automations/benny/templates/reproduce-automation-prompt.md'; Vals = @('[benny:bug]','[benny:performance]') }
        @{ File = 'automations/benny/skills/triage-issue-reports/SKILL.md'; Vals = @('[benny:bug]','[benny:performance]','[benny:other]') }
        @{ File = 'automations/benny/skills/reproduce-and-fix-issues/SKILL.md'; Vals = @('Reproducing','Could not reproduce','Blocked','Reproduced','Verifying existing fix','Attempting bounded fix','Draft pull request opened','Fix did not land') }
        @{ File = 'reflect/references/synthesizer.md'; Vals = @('durability','specificity','existing-skill-first','convergence','decision-changing','structural','duplicate','skill-not-used','already-covered') }
        @{ File = 'why/references/epistemics.md'; Vals = @('Direct','Supported','Inferred','Speculative','Unknown') }
    )
    $n = 0
    foreach ($e in $expect) {
        $zp = ZhPath $e.File
        if (-not (Test-Path -LiteralPath $zp)) { Bad "文件不存在：$($e.File)"; $n++; continue }
        $t = ReadTxt $zp
        foreach ($v in $e.Vals) {
            if (-not $t.Contains($v)) { Bad "$($e.File)：缺少枚举 `"$v`""; $n++ }
        }
    }
    if ($n -eq 0) { Ok "全部 $($expect.Count) 个文件的枚举值完整" }
}

# ---------- Encoding ----------
if ($Check -in 'All','Encoding') {
    Head 'Encoding：UTF-8 无 BOM、LF 换行'
    $n = 0
    Get-ChildItem -LiteralPath $zh -Recurse -File -Filter '*.md' | ForEach-Object {
        $b = [IO.File]::ReadAllBytes($_.FullName)
        if ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) {
            Bad "$($_.Name)：含 UTF-8 BOM"; $n++
        }
        if ($b -contains 0x0D) { Bad "$($_.Name)：含 CRLF"; $n++ }
    }
    if ($n -eq 0) { Ok '全部文件为 UTF-8 无 BOM、LF 换行' }
}

# ---------- Skeleton ----------
if ($Check -in 'All','Skeleton','SkeletonE2E') {
    Head 'Skeleton：multi-phase-plan 内嵌骨架须与上游逐字节一致'
    $rel = 'poteto-mode/playbooks/multi-phase-plan.md'
    $upF = Join-Path $up ('skills\' + ($rel -replace '/', '\'))
    $zhF = ZhPath ('skills/' + $rel)
    if (-not (Test-Path -LiteralPath $upF)) { Bad "上游不存在：$rel" }
    elseif (-not (Test-Path -LiteralPath $zhF)) { Bad "译文不存在：$rel" }
    else {
        $fence = '````markdown'
        $u = ReadTxt $upF; $z = ReadTxt $zhF
        $ui = $u.IndexOf($fence); $zi = $z.IndexOf($fence)
        if ($ui -lt 0)      { Bad '上游未找到 ````markdown 骨架' }
        elseif ($zi -lt 0)  { Bad '译文未找到 ````markdown 骨架' }
        else {
            $ue = $u.IndexOf('````', $ui + $fence.Length) + 4
            $ze = $z.IndexOf('````', $zi + $fence.Length) + 4
            $ub = $u.Substring($ui, $ue - $ui)
            $zb = $z.Substring($zi, $ze - $zi)
            if ($ub -ceq $zb) { Ok "骨架逐字节一致（$($ub.Length) 字节）" }
            else { Bad "骨架被改动：UP=$($ub.Length)B ZH=$($zb.Length)B" }

            if ($Check -eq 'SkeletonE2E') {
                Head 'SkeletonE2E：用上游 check-plan.mjs 端到端验证骨架'
                $checker = Join-Path $up 'skills\poteto-mode\scripts\check-plan.mjs'
                if (-not (Test-Path -LiteralPath $checker)) { Bad '找不到 check-plan.mjs' }
                else {
                    $inner = $zb -replace '^````markdown\r?\n', '' -replace '\r?\n````$', ''
                    $inner = $inner.Replace('<swarm workers model>', 'grok-4.7-xhigh-fast')
                    $tmp = Join-Path ([IO.Path]::GetTempPath()) ('plan-e2e-' + [guid]::NewGuid().ToString('N') + '.md')
                    [IO.File]::WriteAllText($tmp, $inner, (New-Object Text.UTF8Encoding $false))
                    $out = & node $checker $tmp 2>&1 | Out-String
                    $code = $LASTEXITCODE
                    Remove-Item -LiteralPath $tmp -Force
                    if ($code -eq 0) { Ok 'check-plan.mjs 通过（0 problems）' }
                    else { Bad "check-plan.mjs 失败（exit=$code）：`n$out" }
                }
            }
        }
    }
}

# ---------- Frontmatter ----------
if ($Check -in 'All','Frontmatter') {
    Head 'Frontmatter：仅 SKILL.md 需要，name 须与目录名一致'
    $n = 0; $c = 0
    Get-ChildItem -LiteralPath $zh -Recurse -File -Filter 'SKILL.md' | ForEach-Object {
        $c++
        $t = ReadTxt $_.FullName
        if (-not $t.StartsWith('---')) { Bad "$($_.Name)：无 frontmatter（$($_.Directory.Name)）"; $n++; return }
        $end = $t.IndexOf("`n---", 4)
        if ($end -lt 0) { Bad "$($_.Name)：frontmatter 未闭合"; $n++; return }
        $fm = $t.Substring(0, $end)
        if ($fm -notmatch '(?m)^name:\s*(\S+)') { Bad "$($_.Name)：缺 name"; $n++; return }
        $name = $Matches[1].Trim()
        $dir  = $_.Directory.Name
        if ($name -ne $dir) { Bad "$($_.Name)：name=`"$name`" 与目录 `"$dir`" 不一致"; $n++ }
    }
    if ($n -eq 0) { Ok "全部 $c 个 SKILL.md 的 frontmatter 正确" }
}

Head '汇总'
Write-Host "  通过 $($script:pass) 项，失败 $($script:fail) 项" -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 } else { exit 0 }