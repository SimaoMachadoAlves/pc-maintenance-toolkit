# 💾 Módulo de Diagnóstico de Discos (`Disks`)

Esta pasta contém o script `Check-DiskHealth.ps1` e o guia explicativo dos comandos de PowerShell e utilitários de diagnóstico de discos rígidos (HDDs) e unidades de estado sólido (SSDs).

Para correr a script, dentro da pasta principal (pc-maintenance-toolkit), executa o comando: .\Disks\Check-DiskHealth.ps1

---

## 📋 Explicação Completa dos Comandos

### 🔷 Informação Física e Fiabilidade (PowerShell)

- **`Get-PhysicalDisk`**
  Lista todos os discos físicos detetados pelo sistema operativo com informações de estado de saúde (`OperationalStatus`), tipo de barramento e tamanho.
- **`Get-PhysicalDisk | Get-StorageReliabilityCounter`**
  Obtém métricas detalhadas de fiabilidade diretamente da camada de armazenamento (ex.: temperatura, horas de funcionamento, taxa de erros de leitura/escrita e setores defeituosos).

- **`Get-PhysicalDisk | Select FriendlyName, BusType, MediaType, Size`**
  Filtra os dados dos discos físicos para mostrar apenas o modelo (`FriendlyName`), interface (`BusType`: SATA, NVMe, USB), tipo de suporte (`MediaType`: HDD, SSD) e capacidade bruta (`Size`).

---

### 🔷 Gestão de Discos e Volumes (PowerShell)

- **`Get-Disk`**
  Devolve informações sobre os discos lógicos reconhecidos pelo Windows (número do disco, estilo de partição MBR/GPT, estado online/offline e tamanho total).

- **`Get-Volume`**
  Lista todas as partições/volumes montados com letras de unidade (ex.: C:, D:), sistema de ficheiros (NTFS, FAT32), tipo de unidade e espaço livre.

---

### 🔷 Diagnóstico SMART Profundo (`smartctl` / Smartmontools)

- **`smartctl --scan`**
  Procura e lista todos os dispositivos de armazenamento compatíveis com SMART detetados no sistema (no Windows, tipicamente `/dev/pd0`, `/dev/pd1`, etc.).

- **`smartctl -H /dev/sda`**
  Realiza um teste rápido à saúde geral do disco (`Health Status`) indicado. Devolve `PASSED` se o disco estiver saudável ou `FAILED` se houver avaria iminente.

- **`smartctl -a /dev/sda | Select-String "Critical Warning|Temperature:|Available Space:|Percentage Used|Power on|Unsafe|Integrity"`**
  Executa uma leitura completa aos atributos SMART da unidade e filtra apenas os parâmetros críticos (especialmente relevantes para SSDs NVMe), tais como avisos críticos, temperatura atual, vida útil restante (`Percentage Used`) e contagem de encerramentos incorretos.

---

### 🔷 Integridade do Sistema de Ficheiros e Registos de Eventos

- **`Repair-Volume -DriveLetter C -Scan`**
  Analisa a estrutura do sistema de ficheiros do volume `C:` em busca de erros ou corrupção de dados (sem interromper o funcionamento do sistema).

- **`Get-WinEvent -FilterHashtable @{LogName='System' ; ProviderName='disk'} -MaxEvents 10`**
  Consulta o Visualizador de Eventos do Windows (Log de Sistema) e extrai os últimos 10 registos gerados pelo controlador de disco.

- **`$e = Get-WinEvent -FilterHashtable @{LogName='System' ; ProviderName='disk'} -MaxEvents 50 -ErrorAction SilentlyContinue | Where-Object Message -match 'Harddisk0'`**
  Filtra os últimos 50 eventos do fornecedor `disk` para encontrar erros ou avisos direcionados especificamente à unidade principal (`Harddisk0`) e guarda os resultados na variável `$e` para análise posterior.
