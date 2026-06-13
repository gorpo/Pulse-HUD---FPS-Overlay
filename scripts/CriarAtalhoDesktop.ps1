$ErrorActionPreference = "Stop"

# Creates a Windows desktop shortcut that launches the hidden VBS entry point.
$root = Split-Path -Parent $PSScriptRoot
$target = Join-Path $root "scripts\IniciarOverlay.vbs"
$shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "Pulse HUD - FPS Overlay.lnk"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "wscript.exe"
$shortcut.Arguments = "`"$target`""
$shortcut.WorkingDirectory = $root
$shortcut.Description = "Inicia o Pulse HUD - FPS Overlay"
$icon = Join-Path $root "assets\logo.ico"
$shortcut.IconLocation = if (Test-Path -LiteralPath $icon) { $icon } else { "$env:SystemRoot\System32\perfmon.exe,0" }
$shortcut.Save()

Write-Host "Atalho criado em: $shortcutPath"
