param(
    [int]$X = 20,
    [int]$Y = 20,
    [int]$IntervalMs = 1000,
    [int]$Width = 198,
    [int]$Height = 142,
    [double]$Opacity = 0.86,
    [switch]$NoClickThrough,
    [string]$FpsFile = "$env:TEMP\overlay_fps.txt",
    [string]$PresentMonCsv = "",
    [string]$LogPath = ""
)

$ErrorActionPreference = "Continue"
$script:ProjectRoot = Split-Path -Parent $PSScriptRoot
$script:RuntimeDir = Join-Path $script:ProjectRoot ".runtime"
New-Item -ItemType Directory -Force -Path $script:RuntimeDir | Out-Null

if ([string]::IsNullOrWhiteSpace($LogPath)) {
    $LogPath = Join-Path $script:RuntimeDir "overlay.log"
}

$script:PidPath = Join-Path $script:RuntimeDir "overlay.pid"
Set-Content -LiteralPath $script:PidPath -Value $PID -Encoding ASCII

function Write-OverlayLog {
    param([string]$Message)

    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -LiteralPath $LogPath -Value "[$stamp] $Message" -Encoding UTF8
}

Write-OverlayLog "Starting OverlayLeve. PID=$PID"

Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName Microsoft.VisualBasic

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class OverlayNative {
    private const int GWL_EXSTYLE = -20;
    private const int WS_EX_TRANSPARENT = 0x00000020;
    private const int WS_EX_TOOLWINDOW = 0x00000080;

    [DllImport("user32.dll")]
    private static extern int GetWindowLong(IntPtr hWnd, int nIndex);

    [DllImport("user32.dll")]
    private static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

    public static void MakeClickThrough(IntPtr hwnd) {
        int style = GetWindowLong(hwnd, GWL_EXSTYLE);
        SetWindowLong(hwnd, GWL_EXSTYLE, style | WS_EX_TRANSPARENT | WS_EX_TOOLWINDOW);
    }
}
"@

$script:CpuCounter = $null
$script:GpuCounters = @()
$script:ComputerInfo = New-Object Microsoft.VisualBasic.Devices.ComputerInfo

try {
    $script:CpuCounter = New-Object System.Diagnostics.PerformanceCounter("Processor", "% Processor Time", "_Total")
    [void]$script:CpuCounter.NextValue()
} catch {
    Write-OverlayLog "CPU counter unavailable: $($_.Exception.Message)"
}

try {
    $gpuCategory = New-Object System.Diagnostics.PerformanceCounterCategory("GPU Engine")
    $gpuInstances = $gpuCategory.GetInstanceNames() | Where-Object { $_ -like "*engtype_3D*" }

    foreach ($instance in $gpuInstances) {
        $counter = New-Object System.Diagnostics.PerformanceCounter("GPU Engine", "Utilization Percentage", $instance)
        [void]$counter.NextValue()
        $script:GpuCounters += $counter
    }

    Write-OverlayLog "GPU 3D counters loaded: $($script:GpuCounters.Count)"
} catch {
    Write-OverlayLog "GPU counters unavailable: $($_.Exception.Message)"
}

function Format-Percent {
    param([double]$Value)

    return ("{0:N0}%" -f [Math]::Max(0, [Math]::Min(100, $Value)))
}

function Get-CpuText {
    if ($null -eq $script:CpuCounter) { return "--" }

    try {
        return Format-Percent $script:CpuCounter.NextValue()
    } catch {
        return "--"
    }
}

function Get-RamText {
    try {
        $total = [double]$script:ComputerInfo.TotalPhysicalMemory
        $available = [double]$script:ComputerInfo.AvailablePhysicalMemory
        if ($total -le 0) { return "--" }

        $used = $total - $available
        $usedPct = ($used / $total) * 100
        $usedGb = $used / 1GB
        return ("{0:N0}%  {1:N1} GB" -f $usedPct, $usedGb)
    } catch {
        return "--"
    }
}

function Get-GpuText {
    if ($script:GpuCounters.Count -eq 0) { return "--" }

    try {
        $sum = 0.0
        foreach ($counter in $script:GpuCounters) {
            $sum += $counter.NextValue()
        }
        return Format-Percent $sum
    } catch {
        return "--"
    }
}

function Read-LastNumericValue {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return $null }

    try {
        $line = Get-Content -LiteralPath $Path -Tail 1 -ErrorAction Stop
        if ($line -match "([0-9]+([\.,][0-9]+)?)") {
            return [double]($matches[1].Replace(",", "."))
        }
    } catch {
        return $null
    }

    return $null
}

function Convert-MsToFps {
    param([double[]]$Values)

    $valid = @($Values | Where-Object { $_ -gt 0 -and $_ -lt 10000 })
    if ($valid.Count -eq 0) { return $null }

    $avgMs = ($valid | Measure-Object -Average).Average
    if ($avgMs -le 0) { return $null }

    return 1000 / $avgMs
}

function Get-FpsFromPresentMonCsv {
    if ([string]::IsNullOrWhiteSpace($PresentMonCsv)) { return $null }
    if (-not (Test-Path -LiteralPath $PresentMonCsv)) { return $null }

    try {
        $lines = Get-Content -LiteralPath $PresentMonCsv -Tail 120 -ErrorAction Stop
        if ($lines.Count -lt 2) { return $null }

        $header = Get-Content -LiteralPath $PresentMonCsv -TotalCount 1 -ErrorAction Stop
        $rows = @($lines | Where-Object { $_ -and $_ -ne $header } | ConvertFrom-Csv -Header ($header -split ","))
        if ($rows.Count -eq 0) { return $null }

        $columns = @($rows[0].PSObject.Properties.Name)
        $fpsColumn = @("FPS", "FPS-Display", "FPS-Presents", "FPS-App") |
            Where-Object { $columns -contains $_ } |
            Select-Object -First 1

        if ($fpsColumn) {
            $fpsValues = foreach ($row in $rows) {
                $value = 0.0
                if ([double]::TryParse(([string]$row.$fpsColumn).Replace(",", "."), [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$value)) {
                    if ($value -gt 0 -and $value -lt 2000) { $value }
                }
            }

            if (@($fpsValues).Count -gt 0) {
                return ($fpsValues | Measure-Object -Average).Average
            }
        }

        $msColumn = @("MsBetweenPresents", "MsBetweenDisplayChange", "Displayed Frame Time", "Presented Frame Time", "MsUntilDisplayed") |
            Where-Object { $columns -contains $_ } |
            Select-Object -First 1

        if (-not $msColumn) {
            $msColumn = $columns |
                Where-Object { $_ -match "ms.*between.*present" -or $_ -match "display.*frame.*time" -or $_ -match "presented.*frame.*time" } |
                Select-Object -First 1
        }

        if (-not $msColumn) { return $null }

        $msValues = foreach ($row in $rows) {
            $value = 0.0
            if ([double]::TryParse(([string]$row.$msColumn).Replace(",", "."), [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$value)) {
                $value
            }
        }

        return Convert-MsToFps @($msValues)
    } catch {
        return $null
    }
}

function Get-FpsText {
    $fps = Get-FpsFromPresentMonCsv

    if ($null -eq $fps) {
        $fps = Read-LastNumericValue $FpsFile
    }

    if ($null -eq $fps) { return "--" }
    return ("{0:N0}" -f $fps)
}

function New-TextBlock {
    param(
        [string]$Text,
        [double]$Size,
        [string]$Weight,
        [string]$Color
    )

    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text = $Text
    $tb.FontFamily = "Segoe UI"
    $tb.FontSize = $Size
    $tb.FontWeight = $Weight
    $tb.Foreground = [System.Windows.Media.Brushes]::$Color
    return $tb
}

function Add-MetricRow {
    param(
        [System.Windows.Controls.Grid]$Grid,
        [int]$Row,
        [string]$Label,
        [System.Windows.Controls.TextBlock]$ValueBlock
    )

    $labelBlock = New-TextBlock $Label 12 "SemiBold" "Gainsboro"
    $labelBlock.Opacity = 0.82
    [System.Windows.Controls.Grid]::SetRow($labelBlock, $Row)
    [System.Windows.Controls.Grid]::SetColumn($labelBlock, 0)
    [void]$Grid.Children.Add($labelBlock)

    $ValueBlock.FontFamily = "Consolas"
    $ValueBlock.FontSize = 16
    $ValueBlock.FontWeight = "Bold"
    $ValueBlock.HorizontalAlignment = "Right"
    [System.Windows.Controls.Grid]::SetRow($ValueBlock, $Row)
    [System.Windows.Controls.Grid]::SetColumn($ValueBlock, 1)
    [void]$Grid.Children.Add($ValueBlock)
}

$window = New-Object System.Windows.Window
$window.Title = "Overlay Leve"
$window.WindowStyle = "None"
$window.ResizeMode = "NoResize"
$window.AllowsTransparency = $true
$window.Background = [System.Windows.Media.Brushes]::Transparent
$window.Topmost = $true
$window.ShowInTaskbar = $false
$window.Width = $Width
$window.Height = $Height
$window.Left = $X
$window.Top = $Y

$border = New-Object System.Windows.Controls.Border
$border.CornerRadius = 6
$border.Padding = "10,8,10,8"
$border.Background = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromArgb([byte](255 * $Opacity), 13, 15, 18)
$border.BorderBrush = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromArgb(120, 92, 100, 112)
$border.BorderThickness = 1

$root = New-Object System.Windows.Controls.StackPanel
$root.Orientation = "Vertical"

$title = New-TextBlock "OVERLAY LEVE" 11 "Bold" "LightGray"
$title.Opacity = 0.74
$title.Margin = "0,0,0,6"
[void]$root.Children.Add($title)

$grid = New-Object System.Windows.Controls.Grid
$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = "64" }))
$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = "*" }))

1..4 | ForEach-Object {
    $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{ Height = "25" }))
}

$fpsValue = New-TextBlock "--" 16 "Bold" "White"
$cpuValue = New-TextBlock "--" 16 "Bold" "White"
$gpuValue = New-TextBlock "--" 16 "Bold" "White"
$ramValue = New-TextBlock "--" 16 "Bold" "White"

Add-MetricRow $grid 0 "FPS" $fpsValue
Add-MetricRow $grid 1 "CPU" $cpuValue
Add-MetricRow $grid 2 "GPU" $gpuValue
Add-MetricRow $grid 3 "RAM" $ramValue

[void]$root.Children.Add($grid)
$border.Child = $root
$window.Content = $border

$window.Add_SourceInitialized({
    if (-not $NoClickThrough) {
        $helper = New-Object System.Windows.Interop.WindowInteropHelper($window)
        [OverlayNative]::MakeClickThrough($helper.Handle)
    }
})

$window.Add_Closed({
    Write-OverlayLog "Overlay closed."
    Remove-Item -LiteralPath $script:PidPath -ErrorAction SilentlyContinue
})

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds([Math]::Max(250, $IntervalMs))
$timer.Add_Tick({
    $fpsValue.Text = Get-FpsText
    $cpuValue.Text = Get-CpuText
    $gpuValue.Text = Get-GpuText
    $ramValue.Text = Get-RamText
})

$timer.Start()
$fpsValue.Text = Get-FpsText
$cpuValue.Text = Get-CpuText
$gpuValue.Text = Get-GpuText
$ramValue.Text = Get-RamText
[void]$window.ShowDialog()
