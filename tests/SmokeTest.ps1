$ErrorActionPreference = "Stop"

# Paths used by the test. Runtime files are intentionally ignored by Git.
$root = Split-Path -Parent $PSScriptRoot
$script = Join-Path $root "src\OverlayLeve.ps1"
$runtime = Join-Path $root ".runtime"
$pidFile = Join-Path $runtime "overlay.pid"
$logFile = Join-Path $runtime "overlay.log"
$fpsFile = Join-Path $env:TEMP "overlay_fps.txt"

# Parse both PowerShell entry points before attempting to launch the overlay.
Write-Host "Checking syntax..."
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($script, [ref]$tokens, [ref]$errors) | Out-Null
if ($errors.Count -gt 0) {
    $errors | Format-List | Out-String | Write-Host
    throw "Syntax check failed."
}

$configScript = Join-Path $root "src\ConfigurarOverlay.ps1"
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($configScript, [ref]$tokens, [ref]$errors) | Out-Null
if ($errors.Count -gt 0) {
    $errors | Format-List | Out-String | Write-Host
    throw "Config syntax check failed."
}

# Start from a clean runtime state and feed a fake FPS value.
New-Item -ItemType Directory -Force -Path $runtime | Out-Null
Remove-Item -LiteralPath $pidFile -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $logFile -ErrorAction SilentlyContinue
Set-Content -LiteralPath $fpsFile -Value "144" -Encoding ASCII

# Launch through the same hidden VBS entry point users run.
Write-Host "Starting overlay..."
Start-Process -FilePath "wscript.exe" -ArgumentList "`"$root\scripts\IniciarOverlay.vbs`""
Start-Sleep -Seconds 4

if (-not (Test-Path -LiteralPath $pidFile)) {
    if (Test-Path -LiteralPath $logFile) { Get-Content -LiteralPath $logFile | Write-Host }
    throw "PID file was not created."
}

$overlayPid = [int](Get-Content -LiteralPath $pidFile -Raw).Trim()
$process = Get-CimInstance Win32_Process -Filter "ProcessId=$overlayPid"
if (-not $process) {
    if (Test-Path -LiteralPath $logFile) { Get-Content -LiteralPath $logFile | Write-Host }
    throw "Overlay process is not running."
}

Write-Host "Overlay process is running. PID=$overlayPid"

# Stop through the project script to verify normal shutdown.
Write-Host "Stopping overlay..."
& (Join-Path $root "scripts\PararOverlay.bat")
Start-Sleep -Seconds 1

$stillRunning = Get-CimInstance Win32_Process -Filter "ProcessId=$overlayPid"
if ($stillRunning) {
    throw "Overlay process did not stop."
}

Write-Host "Smoke test passed."
