
# ============================================================
# DISK HEALTH DIAGNOSTIC TOOL
# ============================================================

$OutputFile = Join-Path $PSScriptRoot "Disk_Diagnostic_Report.txt"
$ReportWidth = 220

# ------------------------------------------------------------
# REPORT HEADER
# ------------------------------------------------------------

$Report = @()

$Report += "======================================================================"
$Report += "                     DISK HEALTH DIAGNOSTIC REPORT"
$Report += "======================================================================"
$Report += ""
$Report += " Date       : $(Get-Date -Format 'dd/MM/yyyy')"
$Report += " Time       : $(Get-Date -Format 'HH:mm:ss')"
$Report += " Computer   : $env:COMPUTERNAME"
$Report += " User       : $env:USERNAME"
$Report += ""
$Report += "======================================================================"
$Report += ""

# ------------------------------------------------------------
# SECTION EXECUTION FUNCTION
# ------------------------------------------------------------

function Run-Section {
    param (
        [string]$Title,
        [scriptblock]$Command
    )

    $Separator = "-" * 70

    Write-Host ""
    Write-Host "  $Title" -ForegroundColor Cyan

    $script:Report += $Separator
    $script:Report += "  $Title"
    $script:Report += $Separator
    $script:Report += ""

    try {
        # Execute command and capture formatted output
        $Result = (& $Command 2>&1 | Out-String -Width $ReportWidth).TrimEnd()

        if (-not [string]::IsNullOrWhiteSpace($Result)) {
            $script:Report += $Result
            $script:Report += ""

            Write-Host $Result -ForegroundColor Gray
        }
        else {
            $script:Report += "  No results returned."
            $script:Report += ""

            Write-Host "  No results returned." -ForegroundColor DarkGray
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message

        $script:Report += "  [ERROR] $ErrorMessage"
        $script:Report += ""

        Write-Host "  ERROR: $ErrorMessage" -ForegroundColor Red
    }
}

# ============================================================
# 01 - PHYSICAL DISK INFORMATION
# ============================================================

Run-Section "01. PHYSICAL DISKS" {
    Get-PhysicalDisk
}

Run-Section "02. STORAGE RELIABILITY COUNTERS" {
    Get-PhysicalDisk | Get-StorageReliabilityCounter
}

Run-Section "03. PHYSICAL DISK SUMMARY" {
    Get-PhysicalDisk | Select-Object FriendlyName, BusType, MediaType, Size
}

# ============================================================
# 02 - DISK AND VOLUME INFORMATION
# ============================================================

Run-Section "04. DISK INFORMATION" {
    Get-Disk
}

Run-Section "05. VOLUME INFORMATION" {
    Get-Volume
}

# ============================================================
# 03 - SMART DIAGNOSTICS
# ============================================================

Run-Section "06. SMART DEVICE SCAN" {
    smartctl --scan
}

Run-Section "07. SMART HEALTH STATUS" {
    smartctl -H /dev/sda
}

Run-Section "08. SMART CRITICAL ATTRIBUTES" {
    smartctl -a /dev/sda | Select-String "Critical Warning|Temperature:|Available Space:|Percentage Used|Power on|Unsafe|Integrity"
}

# ============================================================
# 04 - FILE SYSTEM INTEGRITY
# ============================================================

Run-Section "09. FILE SYSTEM SCAN (C:)" {
    Repair-Volume -DriveLetter C -Scan
}

# ============================================================
# 05 - WINDOWS DISK EVENTS
# ============================================================

Run-Section "10. LAST 10 DISK EVENTS" {
    Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ProviderName = 'disk'
    } -MaxEvents 10
}

Run-Section "11. HARDDISK0 EVENTS (LAST 50)" {
    $e = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ProviderName = 'disk'
    } -MaxEvents 50 -ErrorAction SilentlyContinue |
    Where-Object Message -match 'Harddisk0'

    $e
}

# ============================================================
# REPORT FOOTER
# ============================================================

$Report += ""
$Report += "======================================================================"
$Report += "                       END OF DIAGNOSTIC REPORT"
$Report += "======================================================================"
$Report += ""
$Report += " Generated on : $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
$Report += " Computer     : $env:COMPUTERNAME"
$Report += ""
$Report += "======================================================================"

# ------------------------------------------------------------
# SAVE REPORT
# ------------------------------------------------------------

$Report | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "  DIAGNOSTIC COMPLETED SUCCESSFULLY" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Report saved to:" -ForegroundColor Yellow
Write-Host "  $OutputFile" -ForegroundColor White
Write-Host ""
