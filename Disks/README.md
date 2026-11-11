
# 💾 Módulo de Diagnóstico de Discos (`Disks`)

Esta pasta contém o script `Check-DiskHealth.ps1` e o guia explicativo dos comandos de PowerShell e utilitários de diagnóstico de discos rígidos (HDDs) e unidades de estado sólido (SSDs).

> [!IMPORTANT]
> **Como executar o script:**
>
> Abre o PowerShell na pasta principal do projeto (`pc-maintenance-toolkit`) e executa:
>
> ```powershell
> .\Disks\Check-DiskHealth.ps1
> ```
>
> Caso o script não funcione, podes executar individualmente os comandos apresentados neste guia, copiando-os diretamente para o PowerShell.

---

## 📋 Explicação Completa dos Comandos

### 🔷 Informação Física e Fiabilidade (PowerShell)

**1. Listar discos físicos**
```powershell
Get-PhysicalDisk
```
Lista todos os discos físicos detetados pelo sistema operativo, incluindo informações sobre o estado de saúde (`OperationalStatus`), tipo de barramento e tamanho.

**2. Consultar métricas de fiabilidade**
```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter
```
Obtém métricas detalhadas de fiabilidade diretamente da camada de armazenamento, como temperatura, horas de funcionamento, taxas de erros de leitura/escrita e setores defeituosos.

**3. Consultar informações resumidas dos discos físicos**
```powershell
Get-PhysicalDisk | Select-Object FriendlyName, BusType, MediaType, Size
```
Apresenta apenas o modelo (`FriendlyName`), interface (`BusType`: SATA, NVMe, USB), tipo de suporte (`MediaType`: HDD, SSD) e capacidade bruta (`Size`).

---

### 🔷 Gestão de Discos e Volumes (PowerShell)

**4. Consultar discos lógicos**
```powershell
Get-Disk
```
Devolve informações sobre os discos reconhecidos pelo Windows, incluindo número do disco, estilo de partição (MBR/GPT), estado online/offline e tamanho total.

**5. Consultar volumes e partições**
```powershell
Get-Volume
```
Lista os volumes montados com letras de unidade (ex.: C:, D:), sistema de ficheiros (NTFS, FAT32), tipo de unidade e espaço livre.

---

### 🔷 Diagnóstico SMART Profundo (`smartctl` / Smartmontools)

**6. Procurar dispositivos compatíveis com SMART**
```powershell
smartctl --scan
```
Procura e lista os dispositivos de armazenamento compatíveis com SMART detetados no sistema. No Windows, podem surgir identificadores como `/dev/pd0`, `/dev/pd1`, etc.

**7. Verificar o estado geral de saúde SMART**
```powershell
smartctl -H /dev/sda
```
Realiza uma consulta ao estado geral de saúde do disco indicado. Devolve normalmente `PASSED` se não forem detetados problemas segundo os critérios SMART ou `FAILED` se existir uma condição crítica.

**8. Consultar atributos SMART específicos**
```powershell
smartctl -a /dev/sda | Select-String "Critical Warning|Temperature:|Available Space:|Percentage Used|Power on|Unsafe|Integrity"
```
Executa uma leitura dos atributos SMART da unidade e filtra parâmetros relevantes, especialmente para SSDs NVMe, como avisos críticos, temperatura, vida útil utilizada (`Percentage Used`) e encerramentos incorretos.

> [!WARNING]
> O identificador `/dev/sda` pode não corresponder a um disco disponível no Windows. Executa primeiro `smartctl --scan` e substitui-o pelo identificador correto apresentado. O utilitário Smartmontools também tem de estar instalado.

---

### 🔷 Integridade do Sistema de Ficheiros e Registos de Eventos

**9. Analisar a integridade do volume C:**
```powershell
Repair-Volume -DriveLetter C -Scan
```
Analisa a estrutura do sistema de ficheiros do volume `C:` em busca de erros ou corrupção, sem realizar reparações automáticas.

**10. Consultar os últimos 10 eventos de disco**
```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='disk'} -MaxEvents 10
```
Consulta o Visualizador de Eventos do Windows (Log de Sistema) e apresenta os últimos 10 registos gerados pelo fornecedor `disk`.

**11. Filtrar eventos associados ao Harddisk0**
```powershell
$e = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='disk'} -MaxEvents 50 -ErrorAction SilentlyContinue | Where-Object Message -match 'Harddisk0'
```
Filtra os últimos 50 eventos do fornecedor `disk` para encontrar erros ou avisos direcionados especificamente à unidade `Harddisk0`. Guarda os resultados na variável `$e`, permitindo uma análise posterior.

Para visualizar os resultados:
```powershell
$e
```
