# Path for the logfile to be output
$LogFilePath = "Path to store log file"

# Debugging: Check the current user and session name
Write-Output "Current Username: $env:USERNAME"
Write-Output "Current SESSIONNAME: $env:SESSIONNAME"

# Ensure the log directory exists
if (!(Test-Path "C:\Logs")) {
    Write-Output "Creating log directory..."
    New-Item -ItemType Directory -Path "Log directory path"
}

# Check if the log file exists, create it if not
if (!(Test-Path $LogFilePath)) {
    Write-Output "Log file not found. Creating a log file..."
    "[]" | Out-File -FilePath $LogFilePath -Encoding UTF8
}

# Get the current user and a timestamp
$User = $env:USERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Read current log data
Write-Output "Reading log data..."
$logData = Get-Content $LogFilePath -Raw -Encoding UTF8
if ($logData -eq "[]") {
    $logData = @()
} else {
    $logData = $logData | ConvertFrom-Json
}

# Ensure $logData is an array before appending
if ($logData -isnot [array]) {
    Write-Output "Log data was not an array. Converting to array."
    $logData = @($logData)
}

# Find the most recent login event for the current user
Write-Output "Finding last login event for $User..."
$lastLogin = $logData | 
    Where-Object { $PSItem.User -eq $User -and $PSItem.LogoutTime -eq "" } | 
    Sort-Object { [datetime]$PSItem.LoginTime } -Descending | 
    Select-Object -First 1

if ($lastLogin) {
    # If a login entry is found, then this must be a logout event
    Write-Output "Logout detected for user $User..."
    
    $lastLogin.LogoutTime = $TimeStamp
    $loginTime = [datetime]$lastLogin.LoginTime
    $logoutTime = [datetime]$TimeStamp
    $lastLogin.SessionDuration = ($logoutTime - $loginTime).ToString()

    # Write updated log data back to the JSON file with UTF-8 encoding
    Write-Output "Updating session duration and writing logout data..."
    $logData | ConvertTo-Json -Depth 3 | Out-File -FilePath $LogFilePath -Force -Encoding UTF8
}
else {
    # If no login entry is found, then this must be a login event
    Write-Output "Login detected for user $User..."
    
    # Log login event (append to the JSON file)
    $logEntry = @{
        User = $User
        LoginTime = $TimeStamp
        LogoutTime = ""
        SessionDuration = ""
    }

    # Append the new login entry
    Write-Output "Appending new login entry..."
    $logData += $logEntry

    # Write the updated data back to the JSON file with UTF-8 encoding
    Write-Output "Writing updated log data back to the file..."
    $logData | ConvertTo-Json -Depth 3 | Out-File -FilePath $LogFilePath -Force -Encoding UTF8
}
