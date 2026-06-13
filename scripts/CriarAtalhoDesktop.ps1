$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$target = Join-Path $root "scripts\IniciarOverlay.vbs"
$shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "Overlay Leve.lnk"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "wscript.exe"
$shortcut.Arguments = "`"$target`""
$shortcut.WorkingDirectory = $root
$shortcut.Description = "Inicia o Overlay Leve"
$shortcut.IconLocation = "$env:SystemRoot\System32\perfmon.exe,0"
$shortcut.Save()

Write-Host "Atalho criado em: $shortcutPath"
