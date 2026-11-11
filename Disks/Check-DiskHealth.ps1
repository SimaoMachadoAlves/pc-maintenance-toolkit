<#
.SYNOPSIS
    Script de diagnóstico de saúde e estado de discos para Windows PowerShell.
.DESCRIPTION
    Este script executa uma bateria de testes e comandos do PowerShell e da ferramenta smartctl
    para avaliar a fiabilidade do armazenamento, volumes, SMART e logs do sistema.
.NOTES
    Nota: Deve ser executado numa janela de PowerShell aberta como Administrador.
#>

# ----------------------------------------------------------------------
# 0. Verificação de Privilégios de Administrador
# ----------------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Este script necessita de privilégios de Administrador para aceder a determinados dados do sistema e SMART."
    Write-Warning "Por favor, volte a abrir a PowerShell como Administrador e execute-o novamente."
    Exit
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    RELATÓRIO DE DIAGNÓSTICO E SAÚDE DO DISCO (POWERSHELL) " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# ----------------------------------------------------------------------
# 1. Informação Geral dos Discos Físicos (Get-PhysicalDisk)
# ----------------------------------------------------------------------
Write-Host "[1/7] A obter lista de discos físicos (Get-PhysicalDisk)..." -ForegroundColor Yellow
Get-PhysicalDisk

Write-Host "`n-- Resumo Formatado dos Discos Físicos --" -ForegroundColor Yellow
Get-PhysicalDisk | Select-Object FriendlyName, BusType, MediaType, @{Name="Size (GB)"; Expression={"{0:N2}" -f ($_.Size / 1GB)}}

Write-Host "`n----------------------------------------------------------" -ForegroundColor DarkGray

# ----------------------------------------------------------------------
# 2. Contadores de Fiabilidade do Armazenamento
# ----------------------------------------------------------------------
Write-Host "`n[2/7] A verificar contadores de fiabilidade (StorageReliabilityCounter)..." -ForegroundColor Yellow
Get-PhysicalDisk | Get-StorageReliabilityCounter

Write-Host "`n----------------------------------------------------------" -ForegroundColor DarkGray

# ----------------------------------------------------------------------
# 3. Estado de Discos e Volumes
# ----------------------------------------------------------------------
Write-Host "`n[3/7] A obter informação de Discos e Volumes do Sistema..." -ForegroundColor Yellow
Write-Host "`n--- Discos (Get-Disk) ---" -ForegroundColor Directory
Get-Disk

Write-Host "`n--- Volumes (Get-Volume) ---" -ForegroundColor Directory
Get-Volume

Write-Host "`n----------------------------------------------------------" -ForegroundColor DarkGray

# ----------------------------------------------------------------------
# 4. Diagnóstico SMART via smartctl (Smartmontools)
# ----------------------------------------------------------------------
Write-Host "`n[4/7] A executar verificação SMART (smartctl)..." -ForegroundColor Yellow

if (Get-Command "smartctl" -ErrorAction SilentlyContinue) {
    Write-Host "`n--- Deteção de Discos (--scan) ---" -ForegroundColor Gray
    smartctl --scan

    # Nota: No Windows, as unidades físicas costumam ser identificadas como /dev/pd0, /dev/pd1, etc.
    # Se a sintaxe /dev/sda não for reconhecida, o smartctl redireciona automaticamente para o disco primário.
    $targetDevice = "/dev/sda"
    
    Write-Host "`n--- Estado de Saúde SMART ($targetDevice) ---" -ForegroundColor Gray
    smartctl -H $targetDevice

    Write-Host "`n--- Atributos Críticos SMART ($targetDevice) ---" -ForegroundColor Gray
    smartctl -a $targetDevice | Select-String "Critical Warning|Temperature:|Available Space:|Percentage Used|Power on|Unsafe|Integrity"
} else {
    Write-Warning "A ferramenta 'smartctl' não foi encontrada no sistema. Certifique-se de que o Smartmontools está instalado e no PATH."
}

Write-Host "`n----------------------------------------------------------" -ForegroundColor DarkGray

# ----------------------------------------------------------------------
# 5. Verificação da Integridade do Volume C: (Repair-Volume)
# ----------------------------------------------------------------------
Write-Host "`n[5/7] A analisar o volume C: (Repair-Volume -Scan)..." -ForegroundColor Yellow
Repair-Volume -DriveLetter C -Scan

Write-Host "`n----------------------------------------------------------" -ForegroundColor DarkGray

# ----------------------------------------------------------------------
# 6. Registos do Sistema Recentes do Fornecedor 'disk'
# ----------------------------------------------------------------------
Write-Host "`n[6/7] A obter os últimos 10 eventos de sistema do fornecedor 'disk'..." -ForegroundColor Yellow
Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='disk'} -MaxEvents 10 -ErrorAction SilentlyContinue | 
    Select-Object TimeCreated, Id, LevelDisplayName, Message

Write-Host "`n----------------------------------------------------------" -ForegroundColor DarkGray

# ----------------------------------------------------------------------
# 7. Pesquisa Específica de Erros no Harddisk0
# ----------------------------------------------------------------------
Write-Host "`n[7/7] A verificar registos de eventos associados ao 'Harddisk0' (últimos 50 eventos)..." -ForegroundColor Yellow
$e = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='disk'} -MaxEvents 50 -ErrorAction SilentlyContinue | Where-Object Message -match 'Harddisk0'

if ($e) {
    Write-Host "Foram encontrados os seguintes eventos para o Harddisk0:" -ForegroundColor Red
    $e | Select-Object TimeCreated, Id, LevelDisplayName, Message
} else {
    Write-Host "Nenhum evento de erro recente registado para o Harddisk0." -ForegroundColor Green
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "                DIAGNÓSTICO CONCLUÍDO                      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
