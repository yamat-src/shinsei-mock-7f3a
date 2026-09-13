<#
.SYNOPSIS
  候補者ごとの公開URL（推測されにくいランダムID）を作成します。
.EXAMPLE
  .\new-candidate.ps1 -Label "9/20 午前 A氏"
  .\new-candidate.ps1 -Id kouho-test
#>
[CmdletBinding()]
param(
    [string]$Label = '',
    [string]$Id = ''
)
$ErrorActionPreference = 'Stop'

$root     = $PSScriptRoot
$template = Join-Path $root 'template\index.html'
$docs     = Join-Path $root 'docs'
$ledger   = Join-Path $root 'candidates.tsv'
$baseUrl  = 'https://yamat-src.github.io/shinsei-mock-7f3a'

if (-not (Test-Path $template)) { throw "テンプレートが見つかりません: $template" }
if (-not (Test-Path $docs))     { throw "公開フォルダが見つかりません: $docs" }

# 紛らわしい文字（0 o 1 l i）を除いた英数字から8文字
if ([string]::IsNullOrWhiteSpace($Id)) {
    $chars = '23456789abcdefghjkmnpqrstuvwxyz'.ToCharArray()
    do {
        $Id = -join (1..8 | ForEach-Object { Get-Random -InputObject $chars })
    } while (Test-Path (Join-Path $docs $Id))
}

if ($Id -notmatch '^[a-z0-9][a-z0-9-]{3,31}$') {
    throw "IDは英小文字・数字・ハイフンの4〜32文字にしてください: $Id"
}

$dir = Join-Path $docs $Id
if (Test-Path $dir) { throw "そのIDは既に使われています: $dir" }

New-Item -ItemType Directory -Path $dir | Out-Null
Copy-Item -Path $template -Destination (Join-Path $dir 'index.html')

if (-not (Test-Path $ledger)) {
    "id`tlabel`tcreated`tremoved" | Out-File -FilePath $ledger -Encoding utf8
}
"$Id`t$Label`t$(Get-Date -Format 'yyyy-MM-dd HH:mm')`t" |
    Out-File -FilePath $ledger -Encoding utf8 -Append

Write-Output ''
Write-Output '候補者URLを作成しました'
Write-Output "  ID  : $Id"
if ($Label -ne '') { Write-Output "  メモ: $Label" }
Write-Output "  URL : $baseUrl/$Id/"
Write-Output ''
Write-Output '公開するには:  git add docs; git commit -m "add candidate"; git push'
