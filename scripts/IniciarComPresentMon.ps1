param(
    [Parameter(Mandatory = $true)]
    [string]$ProcessName,

    [int]$X = 20,
    [int]$Y = 20
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$runtime = Join-Path $root ".runtime"
$presentMon = Join-Path $root "tools\PresentMon.exe"
$csv = Join-Path $runtime "presentmon.csv"

New-Item -ItemType Directory -Force -Path $runtime | Out-Null

if (-not (Test-Path -LiteralPath $presentMon)) {
    throw "PresentMon nao foi encontrado. Rode scripts\BaixarPresentMon.ps1 primeiro."
}

Remove-Item -LiteralPath $csv -ErrorAction SilentlyContinue

$pmArgs = @(
    "--process_name", $ProcessName,
    "--output_file", $csv,
    "--stop_existing_session",
    "--restart_as_admin"
)

Start-Process -FilePath $presentMon -ArgumentList $pmArgs -WindowStyle Minimized

Start-Sleep -Seconds 2

powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File (Join-Path $root "src\OverlayLeve.ps1") -X $X -Y $Y -PresentMonCsv $csv
