$DiscordWebHookURL ="Discord WebHook Link"

$CPUThreshold = 70 # as a percentage
$DiskLimit = 10 # as a percentage
$CheckInterval = 30 # in seconds
$ProccessesToWatch = @("Discord", "Chrome", "Firefox") # Examples, add your own process to monitor

function Send-DiscordAlert
{
    param ($Message)
    $PayLoad = @{'content' = $Message} | ConvertTo-Json
    Invoke-RestMethod -Uri $DiscordWebHookURL -Method Post -Body $PayLoad -ContentType "application/json"
}

while ($true)
{
    # Check CPU Usage
    $CpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    if ($CpuUsage -ge $CPUThreshold)
    {
        $Message = "High CPU Usage! Usage: $CpuUsage% usage detected!"
        Send-DiscordAlert -Message $Message
    }

    # Check Disk Space
    $LowDisks = Get-PSDrive -PSProvider FileSystem | Where-Object { 
        $PSItem.Free -gt 0 -and ($PSItem.Free / $PSItem.Used) * 100 -lt $DiskLimit}
    foreach ($disk in $LowDisks)

    {
        $Message = "Low Disk Space Alert! Drives: $($disk.Name) has only $([math]::Round(($disk.Free / 1GB), 2))GB left!"
        Send-DiscordAlert -Message $Message
    }

    # Check for proccess failure
    foreach ($proccess in $ProccessesToWatch)
    {
        if (-not (Get-Process -Name $proccess -ErrorAction SilentlyContinue))
        {
            $Message = "Process Crash Alert! Processes: $proccess has crashed!"
            Send-DiscordAlert -Message $Message
        }
    }

    # Check the Windows Event Log
    $Events = Get-EventLog -LogName System -EntryType Error -Newest 5 | Where-Object {
        $PSItem.TimeGenerated -gt (Get-Date).AddMinutes(-5)}
    
    foreach ($event in $Events)
    {
        $Message = "Windows Error Alert! Error: [$($event.Source)] - $($event.Message)"
        Send-DiscordAlert -Message $Message
    }

    Start-Sleep -Seconds $CheckInterval
    Write-Host "Working...."
}