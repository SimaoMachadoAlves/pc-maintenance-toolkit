# 🛠️ PC Maintenance Toolkit

Este repositório é um conjunto de ferramentas, scripts e comandos para a **PowerShell do Windows**, desenvolvido durante a formação de **Montagem e Manutenção de PCs**. O objetivo é facilitar o diagnóstico, a verificação de saúde e a resolução de problemas em hardware e no sistema operativo.

---

## 📂 Estrutura do Repositório

O projeto encontra-se organizado por módulos de componentes:

- `Disks/`: Scripts e documentação para diagnóstico de saúde, integridade SMART, volumes e logs de erro de discos (HDDs/SSDs).
- _(Mais pastas serão adicionadas conforme a evolução do módulo: RAM, CPU, Redes, etc.)_

---

## ⚙️ Requirements (Pré-requisitos por Módulo)

Para que os scripts funcionem na totalidade, cada módulo pode exigir ferramentas externas ou dependências específicas:

### 💾 Módulo de Discos (`Disks`)
* **Dependência:** `smartctl` (Smartmontools)
* **Para que serve:** Necessário para efetuar leituras e testes SMART avançados aos discos rígidos e SSDs.
* **Link de instalação:** [Baixar Smartmontools](https://sourceforge.net/projects/smartmontools/) *(certifica-te de adicionar o executável ao PATH do sistema durante a instalação)*

### 🧠 Módulo de RAM *(Brevemente)*
* *Requisitos e dependências serão adicionados aqui quando o módulo for criado.*

### ⚡ Módulo de CPU *(Brevemente)*
* *Requisitos e dependências serão adicionados aqui quando o módulo for criado.*

---

## 🚀 Como Executar os Scripts

1. Abre a **Windows PowerShell como Administrador**.
2. Se necessário, permite a execução temporária de scripts na sessão atual:
   ```powershell
   Set-ExecutionPolicy Unrestricted -Scope Process
