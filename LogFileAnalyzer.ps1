function Get-LogFileContent {
    param (
        [string]$FilePath,
        [datetime]$StartDate,
        [datetime]$EndDate,
        [string]$Severity,
        [string]$Keyword
    )

    # Confirm the file path
    if (-not (Test-Path $FilePath)) {
        Write-Host "Error: File path does not exist or is not accessible." -ForegroundColor Red
        return $null
    }

    # Read content from the log file
    Write-Host "Reading and parsing the log file..." -ForegroundColor Green
    $Logs = Get-Content $FilePath -Encoding UTF8

    # Ensure the log file contains at least one valid log entry
    if (-not ($Logs -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[\w+\] .+')) {
        Write-Host "Error: Log file does not contain valid log entries." -ForegroundColor Red
        return $null
    }

    # Store the filtered logs in an array
    $FilteredLogs = @()

    foreach ($Line in $Logs) {
        # Match the log entry format
        if ($Line -match '^(?<Date>\d{4}-\d{2}-\d{2}) (?<Time>\d{2}:\d{2}:\d{2}) \[(?<Severity>\w+)\] (?<Message>.+)$') {
            $LogDate = [datetime]::ParseExact($matches.Date + " " + $matches.Time, "yyyy-MM-dd HH:mm:ss", $null)
            $LogSeverity = $matches.Severity
            $LogMessage = $matches.Message

            # Apply filters
            if ($StartDate -and ($LogDate -lt $StartDate)) { continue }
            if ($EndDate -and ($LogDate -gt $EndDate)) { continue }
            if ($Severity -and ($LogSeverity -notlike $Severity)) { continue }

            # Keyword filter with case-insensitive matching with * for partial match
            if ($Keyword -and ($LogMessage -notlike "*$Keyword*")) { continue }
       

            # Add a log entry to filtered logs
            $FilteredLogs += [PSCustomObject]@{
                Date     = $matches.Date
                Time     = $matches.Time
                Severity = $matches.Severity
                Message  = $matches.Message
            }
        } else {
            Write-Host "Skipping invalid log line: $Line" -ForegroundColor DarkYellow
        }
    }

    Write-Host "Filtering complete. Logs matching criteria: $($FilteredLogs.Count)" -ForegroundColor Cyan

    # Print filtered logs
    Write-Host "Filtered Logs: " -ForegroundColor Yellow
    $FilteredLogs | ForEach-Object {
        Write-Host "$($_.Date) $($_.Time) [$($_.Severity)] $($_.Message)"
    }

    return $FilteredLogs
}


function Main {
    $LogFilePath = ""
    $Logs = @()

    while (-not $LogFilePath) {
        $LogFilePath = Read-Host "Enter the full path to the log file"
        $Logs = Get-LogFileContent -FilePath $LogFilePath

        if (-not $Logs) {
            Write-Host "Error: Failed to process the log file. Please try again with a valid log file." -ForegroundColor Red
            $LogFilePath = ""
        }
    }

    while ($true) {
        Write-Host "`n=================== LOG FILE ANALYZER ===================" -ForegroundColor Cyan
        Write-Host "Options:"
        Write-Host "1. Filter by Date Range"
        Write-Host "2. Filter by Severity: [ERROR | WARNING | INFO]"
        Write-Host "3. Filter by Keyword"
        Write-Host "4. Export Results: [CSV or JSON]"
        Write-Host "5. Exit"
        Write-Host "========================================================"
        $Choice = Read-Host "Enter your choice (1-5)"

        switch ($Choice) {
            1 {
                # Date Range Filtering
                $StartDate = Read-Host "Enter start date (YYYY-MM-DD)"
                $EndDate = Read-Host "Enter end date (YYYY-MM-DD)"
                $Logs = Get-LogFileContent -FilePath $LogFilePath -StartDate $StartDate -EndDate $EndDate
                
            }
            2 {
                # Severity Filtering
                $Severity = Read-Host "Enter severity level (ERROR, WARNING, INFO)"
                $Logs = Get-LogFileContent -FilePath $LogFilePath -Severity $Severity
               
            }
            3 {
                # Keyword Filtering
                $Keyword = Read-Host "Enter a keyword to filter by"
                $Logs = Get-LogFileContent -FilePath $LogFilePath -Keyword $Keyword
        
            }
            4 {
                # Export Results
                $ExportFormat = Read-Host "Enter export format (CSV or JSON)"
                if ($ExportFormat -eq "CSV") {
                    $Logs | Export-Csv "FilteredLogs.csv" -NoTypeInformation
                    Write-Host "Logs exported to FilteredLogs.csv" -ForegroundColor Green
                } elseif ($ExportFormat -eq "JSON") {
                    $Logs | ConvertTo-Json | Set-Content "FilteredLogs.json"
                    Write-Host "Logs exported to FilteredLogs.json" -ForegroundColor Green
                } else {
                    Write-Host "Invalid format. Please choose either CSV or JSON." -ForegroundColor Red
                }
            }
            5 {
                # Exit
                Write-Host "Exiting Log File Analyzer. Goodbye!" -ForegroundColor Green
                break
            }
            default {
                Write-Host "Invalid choice. Please select a valid option." -ForegroundColor Red
            }
        }
    }
}

# Run the Main Function
Main
