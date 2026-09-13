<#
.SYNOPSIS
  候補者用の公開URLを削除します（面接終了後に実行）。
.EXAMPLE
  .\remove-candidate.ps1 -Id a7f3k2x9
  .\remove-candidate.ps1 -All          # 全候補者ぶんをまとめて削除
#>
[CmdletBinding(DefaultParameterSetName = 'One')]
param(
    [Parameter(ParameterSetName = 'One', Mandatory = $true, Position = 0)]
    [string]$Id,
    [Parameter(ParameterSetName = 'All', Mandatory = $true)]
    [switch]$All
)
$ErrorActionPreference = 'Stop'

$root   = $PSScriptRoot
$docs   = Join-Path $root 'docs'
$ledger = Join-Path $root 'candidates.tsv'
$stamp  = Get-Date -Format 'yyyy-MM-dd HH:mm'

# docs 直下のうち、候補者ディレクトリだけを対象にする（files/ と共有物は除外）
$reserved = @('files')
if ($All) {
    $targets = Get-ChildItem -Path $docs -Directory |
        Where-Object { $reserved -notcontains $_.Name } |
        ForEach-Object { $_.Name }
    if ($targets.Count -eq 0) { Write-Output '削除対象の候補者URLはありません。'; return }
} else {
    if ($reserved -contains $Id) { throw "共有フォルダは削除できません: $Id" }
    $targets = @($Id)
}

foreach ($t in $targets) {
    $dir = Join-Path $docs $t
    if (-not (Test-Path $dir)) {
        Write-Output "見つかりませんでした（スキップ）: $t"
        continue
    }
    Remove-Item -Path $dir -Recurse -Force -Confirm:$false
    Write-Output "削除しました: $t"
}

# 台帳の removed 列を埋める
if (Test-Path $ledger) {
    $lines = Get-Content -Path $ledger
    $out = foreach ($line in $lines) {
        $cols = $line -split "`t"
        if ($cols.Count -ge 4 -and ($targets -contains $cols[0]) -and $cols[3] -eq '') {
            ($cols[0], $cols[1], $cols[2], $stamp) -join "`t"
        } else {
            $line
        }
    }
    $out | Out-File -FilePath $ledger -Encoding utf8
}

Write-Output ''
Write-Output '公開に反映するには:  git add -A docs; git commit -m "remove candidate"; git push'
