$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$toolsDir = Join-Path $root "tools"
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

$release = Invoke-RestMethod -Uri "https://api.github.com/repos/GameTechDev/PresentMon/releases/latest" -Headers @{ "User-Agent" = "OverlayLeve" }
$asset = $release.assets |
    Where-Object { $_.name -match "PresentMon.*x64.*\.exe$" } |
    Select-Object -First 1

if (-not $asset) {
    throw "Nao encontrei um executavel x64 do PresentMon na ultima release."
}

$target = Join-Path $toolsDir $asset.name
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $target

$stablePath = Join-Path $toolsDir "PresentMon.exe"
Copy-Item -LiteralPath $target -Destination $stablePath -Force

Write-Host "PresentMon baixado em: $stablePath"
