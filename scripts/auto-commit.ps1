<#
.SYNOPSIS
    Skrip otomatis untuk menambahkan catatan sinkronisasi kontribusi dan commit Git.
.DESCRIPTION
    Menambahkan timestamp UTC terkini ke file contributions.txt sesuai format repositori.
    Mendukung opsi commit otomatis dan push.
.PARAMETER Commit
    Lakukan git commit otomatis setelah menambahkan timestamp.
.PARAMETER Push
    Lakukan git commit dan git push ke origin main.
.EXAMPLE
    .\scripts\auto-commit.ps1
    (Hanya menambahkan baris timestamp ke contributions.txt tanpa commit)
.EXAMPLE
    .\scripts\auto-commit.ps1 -Commit
    (Menambahkan timestamp dan melakukan git commit lokal)
.EXAMPLE
    .\scripts\auto-commit.ps1 -Push
    (Menambahkan timestamp, melakukan git commit, lalu git push ke remote)
#>
[CmdletBinding()]
param (
    [switch]$Commit,
    [switch]$Push
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$contributionFile = Join-Path $repoRoot "contributions.txt"

if (-not (Test-Path $contributionFile)) {
    Write-Error "File contributions.txt tidak ditemukan di: $contributionFile"
    exit 1
}

$timestamp = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ss")
$entry = "Contribution sync: $timestamp"

# Menambahkan entri baru ke contributions.txt
Add-Content -Path $contributionFile -Value $entry
Write-Host "✅ Berhasil menambahkan ke contributions.txt: $entry" -ForegroundColor Green

if ($Commit -or $Push) {
    git -C $repoRoot add contributions.txt
    $commitMsg = "docs: system contribution sync $timestamp"
    git -C $repoRoot commit -m $commitMsg
    Write-Host "✅ Berhasil commit: $commitMsg" -ForegroundColor Green

    if ($Push) {
        Write-Host "🚀 Mengirim ke remote (git push origin main)..." -ForegroundColor Cyan
        git -C $repoRoot push origin main
        Write-Host "✅ Push berhasil diselesaikan." -ForegroundColor Green
    }
}
