# Quick push helper — dipanggil agent setelah commit
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
git push origin main
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Pushed to origin/main"
