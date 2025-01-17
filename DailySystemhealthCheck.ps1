# Production-Ready System Health Check and Report Generator

# Configuration
$reportPath = "<Enter_Your_Report_File_Path>"
$logFile = "<Enter_Your_Log_File_Path>"

# Logging helper function
function Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append
}

# Ensure report and log directories exist
try {
    $reportDir = Split-Path $reportPath
    if (-not (Test-Path $reportDir)) {
        New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    }
    if (-not (Test-Path (Split-Path $logFile))) {
        New-Item -ItemType Directory -Path (Split-Path $logFile) -Force | Out-Null
    }
    Log "Directories verified or created successfully."
} catch {
    Log "Failed to create necessary directories: $_"
    exit 1
}

# Collect System Metrics
try {
    $cpuUsage = (Get-Counter -Counter "\Processor(_Total)\% Processor Time").CounterSamples[0].CookedValue
    Log "Collected CPU usage successfully."
} catch {
    $cpuUsage = "Error"
    Log "Failed to collect CPU usage: $_"
}

try {
    $memory = Get-CimInstance -ClassName Win32_OperatingSystem
    Log "Collected memory information successfully."
} catch {
    $memory = $null
    Log "Failed to collect memory information: $_"
}

try {
    $diskSpace = Get-PSDrive -PSProvider FileSystem | Select-Object Name,
        @{Name='FreeSpace(GB)'; Expression={[math]::Round($_.Free / 1GB, 2)}},
        @{Name='UsedSpace(GB)'; Expression={[math]::Round($_.Used / 1GB, 2)}}
    Log "Collected disk space information successfully."
} catch {
    $diskSpace = $null
    Log "Failed to collect disk space information: $_"
}

try {
    $uptime = (Get-Uptime).ToString("g")
    Log "Collected system uptime successfully."
} catch {
    $uptime = "Error"
    Log "Failed to collect system uptime: $_"
}

# Generate the HTML Report
try {
    $reportContent = @"
<html>
<head>
    <title>System Health Report</title>
    <style>
        body { font-family: Arial, sans-serif; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid black; padding: 8px; text-align: left; }
    </style>
</head>
<body>
    <h1>System Health Report</h1>
    <p>Generated on: $(Get-Date)</p>
    <p>System Uptime: $uptime</p>
    <table>
        <tr><th>Metric</th><th>Value</th></tr>
        <tr><td>CPU Usage (%)</td><td>$([math]::Round($cpuUsage, 2))</td></tr>
        <tr><td>Memory Usage</td><td>Used: $([math]::Round(($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / 1MB, 2)) MB / Total: $([math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)) MB</td></tr>
        <tr><td>Disk Space</td><td>
            $(if ($diskSpace) { foreach ($disk in $diskSpace) { "$($disk.Name): Free $($disk.'FreeSpace(GB)') GB, Used $($disk.'UsedSpace(GB)') GB<br>" } })
        </td></tr>
    </table>
</body>
</html>
"@

    $reportContent | Out-File -FilePath $reportPath -Encoding utf8
    Log "System Health Report saved to $reportPath successfully."
} catch {
    Log "Failed to generate or save the HTML report: $_"
    exit 1
}
