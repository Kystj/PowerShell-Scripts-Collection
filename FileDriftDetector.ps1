param (
    [string]$ConfigPath = "F:\PowerShell\config.json",
    [switch]$GenerateBaseline,
    [string]$LogFile = "F:\PowerShell\drift.log"
)

function Write-LogMessage {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $LogFile
    Write-Host $Message
}

if ($GenerateBaseline) {
    $baseline = @{
        Files = Get-ChildItem -Path "F:\PowerShell" -File -Recurse | Where-Object { $_.FullName -ne $LogFile } | ForEach-Object {
            try {
                [PSCustomObject]@{
                    Timestamp = Get-Date
                    Path = $_.FullName
                    Hash = (Get-FileHash $_.FullName -ErrorAction Stop).Hash
                }
            } catch {
                Write-LogMessage "Warning: Unable to hash file $($_.FullName) - $_"
            }
        }
    }

    $baseline | ConvertTo-Json -Depth 3 | Set-Content -Path $ConfigPath
    Write-LogMessage "Baseline saved to $ConfigPath"
    exit
}

if (-Not (Test-Path $ConfigPath)) {
    Write-LogMessage "No config file found. Run with -GenerateBaseline to create one."
    exit 1
}

$baseline = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
$currentFiles = Get-ChildItem -Path "F:\PowerShell" -File -Recurse | Where-Object 
    { $PSItem.FullName -ne $LogFile } | Select-Object -ExpandProperty FullName
    
$baselinePaths = $baseline.Files.Path
$IsDrift = $false

foreach ($entry in $baseline.Files) {
    if ($entry.Path -eq $ConfigPath -or $entry.Path -eq $LogFile) { continue }
    if (Test-Path $entry.Path) {
        try {
            $currentHash = (Get-FileHash $entry.Path -ErrorAction Stop).Hash
            if ($currentHash -ne $entry.Hash) {
                Write-LogMessage "Drift detected: $($entry.Path) has changed!"
                $IsDrift = $true
            }
        } catch {
            Write-LogMessage "Warning: Unable to hash file $($entry.Path) - $_"
        }
    } else {
        Write-LogMessage "Drift detected: $($entry.Path) is missing!"
        $IsDrift = $true
    }
}

foreach ($file in $currentFiles) {
    if ($file -notin $baselinePaths -and $file -ne $LogFile) {
        Write-LogMessage "Drift detected: New file added - $file"
        $IsDrift = $true
    }
}

if (-Not $IsDrift) {
    Write-LogMessage "No drift detected."
}
