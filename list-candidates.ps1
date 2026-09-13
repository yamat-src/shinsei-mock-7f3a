<#
.SYNOPSIS
  現在公開中の候補者URLと、これまでの発行履歴を表示します。
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

$root    = $PSScriptRoot
$docs    = Join-Path $root 'docs'
$ledger  = Join-Path $root 'candidates.tsv'
$baseUrl = 'https://yamat-src.github.io/shinsei-mock-7f3a'

$labels = @{}
if (Test-Path $ledger) {
    foreach ($line in (Get-Content -Path $ledger | Select-Object -Skip 1)) {
        $cols = $line -split "`t"
        if ($cols.Count -ge 2 -and -not $labels.ContainsKey($cols[0])) {
            $labels[$cols[0]] = $cols[1]
        }
    }
}

$live = Get-ChildItem -Path $docs -Directory |
    Where-Object { $_.Name -ne 'files' } |
    Sort-Object Name

Write-Output ''
if ($live.Count -eq 0) {
    Write-Output '公開中の候補者URLはありません。'
} else {
    Write-Output "公開中の候補者URL（$($live.Count)件）"
    foreach ($d in $live) {
        $memo = ''
        if ($labels.ContainsKey($d.Name)) { $memo = $labels[$d.Name] }
        Write-Output "  $baseUrl/$($d.Name)/   $memo"
    }
}

if (Test-Path $ledger) {
    Write-Output ''
    Write-Output '発行履歴 (candidates.tsv)'
    Import-Csv -Path $ledger -Delimiter "`t" | Format-Table -AutoSize | Out-String | Write-Output
}
