# Set your threshold (the default is set low for testing purposes)
$threshold = 1

# Specify where to save the log file
$logFile = "Specfy your log folder and desired file name here"

# Get current CPU usage
$cpuUsage = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue, 2)

# Log the current CPU usage and time
$logMessage = "$(Get-Date): CPU usage is at $cpuUsage%"
Add-Content -Path $logFile -Value $logMessage

# Check if CPU usage exceeds threshold
if ($cpuUsage -ge $threshold) {

    # Alert by log
    $alertMessage = "$(Get-Date): ALERT! CPU usage is at $cpuUsage%, which is above the threshold."
    Add-Content -Path $logFile -Value $alertMessage
    
    # Optional: Trigger a sound (beep)
    [console]::beep(1000, 500)

    # Retrieve the process with the highest CPU usage
    $topCpuProcess = Get-Process | Sort-Object CPU -Descending | Select-Object -First 1

    # Log the process with highest CPU usage
    $processMessage = "$(Get-Date): Process with the highest CPU usage: $($topCpuProcess.Name)"
    Add-Content -Path $logFile -Value $processMessage

    # Optionally, you can also use a balloon notification here
    # $balloon = New-Object -ComObject WScript.Shell
    # $balloon.Popup($alertMessage, 0, "CPU Alert", 0x30) 

} else {
    # Log normal CPU usage state
    Add-Content -Path $logFile -Value "$(Get-Date): CPU usage is within acceptable range."
}
# Exit once the task is done
Exit