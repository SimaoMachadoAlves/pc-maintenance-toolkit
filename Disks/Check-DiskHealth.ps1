
# ============================================================
# DISK HEALTH DIAGNOSTIC SCRIPT
# ============================================================

$OutputFile = Join-Path $PSScriptRoot "Disk_Diagnostic_Report.txt"

# Start report
"============================================================" | Out-File $OutputFile
"             DISK HEALTH DIAGNOSTIC REPORT" | Out-File $OutputFile -Append
"Date: $(Get-Date)" | Out-File $OutputFile -Append
"============================================================`n" | Out-File $OutputFile -Append

function Run-Section {
    param (
        [string]$Title,
        [scriptblock]$Command
    )

    Write-Host "`n[$Title]" -ForegroundColor Cyan

    "============================================================" | Out-File $OutputFile -Append
    "[$Title]" | Out-File $OutputFile -Append
    "============================================================" | Out-File $OutputFile -Append

    try {
        $Result = & $Command 2>&1

        if ($null -ne $Result) {
            $Result | Out-String -Width 250 | Out-File $OutputFile -Append
            $Result | Format-Table -AutoSize | Out-String -Width 250 | Write-Host
        }
        else {
            "No results returned." | Out-File $OutputFile -Append
        }
    }
    catch {
        "ERROR: $($_.Exception.Message)" | Out-File $OutputFile -Append
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# POWERSHELL STORAGE INFORMATION
# ------------------------------------------------------------

Run-Section "Get-PhysicalDisk" {
    Get-PhysicalDisk
}

Run-Section "Get-PhysicalDisk | Get-StorageReliabilityCounter" {
    Get-PhysicalDisk | Get-StorageReliabilityCounter
}

Run-Section "Get-Disk" {
    Get-Disk
}

Run-Section "Get-Volume" {
    Get-Volume
}

Run-Section "Physical Disk Summary" {
    Get-PhysicalDisk | Select-Object FriendlyName, BusType, MediaType, Size
}

# ------------------------------------------------------------
# SMARTCTL INFORMATION
# ------------------------------------------------------------

Run-Section "smartctl --scan" {
    smartctl --scan
}

Run-Section "smartctl -H /dev/sda" {
    smartctl -H /dev/sda
}

Run-Section "smartctl -a /dev/sda (Selected Parameters)" {
    smartctl -a /dev/sda | Select-String "Critical Warnig|Temperature:|Available Space:|Percentage Used|Power on|Unsafe|Integrity"
}

# ------------------------------------------------------------
# VOLUME SCAN
# ------------------------------------------------------------

Run-Section "Repair-Volume C: -Scan" {
    Repair-Volume -DriveLetter C -Scan
}

# ------------------------------------------------------------
# WINDOWS DISK EVENTS
# ------------------------------------------------------------

Run-Section "Last 10 Disk Events" {
    Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ProviderName = 'disk'
    } -MaxEvents 10
}

Run-Section "Harddisk0 Events (Last 50)" {
    $e = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ProviderName = 'disk'
    } -MaxEvents 50 -ErrorAction SilentlyContinue |
    Where-Object Message -match 'Harddisk0'

    $e
}

# ------------------------------------------------------------
# FINISH
# ------------------------------------------------------------

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "Diagnostic completed!" -ForegroundColor Green
Write-Host "Report saved to: $OutputFile" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Green
