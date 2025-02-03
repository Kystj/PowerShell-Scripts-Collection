param (
    [string]$ConfigPath = "F:\PowerShell\config.json",
    [switch]$GenerateBaseline
)

# If GenerateBaseline then generate the baseline file
if ($GenerateBaseline) {
    $baseline = @{
        Timestamp = Get-Date
        Files = Get-ChildItem -Path "F:\PowerShell" -File -Recurse | ForEach-Object {
            @{
                Path = $_.FullName
                Hash = (Get-FileHash $_.FullName).Hash
            }
        }
    }

    $baseline | ConvertTo-Json -Depth 3 | Set-Content -Path $ConfigPath
    Write-Host "Baseline saved to $ConfigPath"
    exit
}

# Read the configuration file
if (-Not (Test-Path $ConfigPath)) {
    Write-Host "No config file found. Run with -GenerateBaseline to create one."
    exit 1
}
$baseline = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json

# Detect drift
$IsDrift = $false
foreach ($entry in $baseline.Files) {
    # Skip the config file itself from drift detection
    if ($entry.Path -eq $ConfigPath) {
        continue
    }

    if (Test-Path $entry.Path) {
        # File exists, check hash
        $currentHash = (Get-FileHash $entry.Path).Hash
        if ($currentHash -ne $entry.Hash) {
            Write-Host "Drift detected: $($entry.Path) has changed!"
            $IsDrift = $true
        }
    } else {
        # File is missing
        Write-Host "Drift detected: $($entry.Path) is missing!"
        $IsDrift = $true
    }
}

if (-Not $IsDrift) {
    Write-Host "No drift detected."
}
