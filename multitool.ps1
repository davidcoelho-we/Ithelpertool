```powershell
# ================= MULTITOOL POWERSHELL =================

function Show-Menu {
    Clear-Host
    Write-Host "================ MULTITOOL ================="
    Write-Host "1. Informações do Sistema"
    Write-Host "2. Teste de Rede"
    Write-Host "3. Logs de Erros"
    Write-Host "4. Flush DNS"
    Write-Host "5. Relatório de Saúde da Bateria"
    Write-Host "6. Windows Decrapifier"
    Write-Host "7. Atualizar Lenovo (System Update)"
    Write-Host "0. Sair"
    Write-Host "============================================"
}

# ==== FUNÇÕES ====

function Get-SystemInfo {
    Get-ComputerInfo | Select-Object CsName, WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer
    Pause
}

function Test-Network {
    Test-Connection -ComputerName 8.8.8.8 -Count 4
    Pause
}

function Get-ErrorLogs {
    Get-EventLog -LogName System -Newest 20 | Format-Table TimeGenerated, EntryType, Source, EventID, Message -AutoSize
    Pause
}

function Flush-DNS {
    Clear-DnsClientCache
    Write-Host "Cache DNS limpo com sucesso."
    Pause
}

function Get-BatteryReport {
    powercfg /batteryreport /output "$env:USERPROFILE\Desktop\battery_report.html"
    Write-Host "Relatório gerado na área de trabalho."
    Pause
}

function Run-WindowsDecrapifier {
    Write-Output "Iniciando Windows Decrapifier..."
    & ([scriptblock]::Create((irm "https://win11debloat.raphi.re/"))) -Silent -RunDefaults -RemoveW11Outlook -RemoveGamingApps -DisableDVR -DisableTelemetry -DisableBing -DisableSuggestions -DisableLockscreenTips -TaskbarAlignLeft -ShowSearchIconTb -HideTaskView -HideChat -DisableWidgets -DisableCopilot -DisableRecall -HideHome -HideGallery
    Write-Host "Windows Decrapifier concluído."
    Pause
}

function Atualizar-LenovoSystemUpdate {
    $logPath = "$env:USERPROFILE\Desktop\Lenovo_Update_Log.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logPath -Value "[$timestamp] Iniciando verificação e atualização do Lenovo System Update..."

    $path1 = "C:\\Program Files (x86)\\Lenovo\\System Update\\tvsu.exe"
    $path2 = "C:\\Program Files\\Lenovo\\System Update\\tvsu.exe"

    if (!(Test-Path $path1) -and !(Test-Path $path2)) {
        Write-Host "Lenovo System Update não encontrado. Baixando e instalando..."
        Add-Content -Path $logPath -Value "[$timestamp] Lenovo System Update não encontrado. Baixando instalador."

        $installer = "$env:TEMP\\SystemUpdateSetup.exe"
        Invoke-WebRequest -Uri "https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_5.08.02.25.exe" -OutFile $installer
        Start-Process $installer -ArgumentList "/VERYSILENT /NORESTART" -Wait

        Add-Content -Path $logPath -Value "[$timestamp] Lenovo System Update instalado com sucesso."
    }

    $suExe = if (Test-Path $path1) { $path1 } elseif (Test-Path $path2) { $path2 } else { $null }

    if ($suExe) {
        $tempLog = "$env:TEMP\\LenovoSilentUpdate.log"
        if (Test-Path $tempLog) { Remove-Item $tempLog -Force }

        Start-Process $suExe -ArgumentList "/CM -search A -action INSTALL -includerebootpackages 3 -noreboot -exportlog $tempLog" -Wait

        $updatesInstalled = 0
        if (Test-Path $tempLog) {
            $updatesInstalled = (Select-String -Path $tempLog -Pattern "Install complete").Count
        }

        $timestampEnd = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $logPath -Value "[$timestampEnd] Atualização concluída. Pacotes instalados: $updatesInstalled"
        Write-Host "Atualização concluída. $updatesInstalled pacotes aplicados. Log salvo em: $logPath"

        # Abrir o log automaticamente
        Start-Process notepad.exe $logPath
    } else {
        Write-Host "Erro: Lenovo System Update não encontrado após instalação."
        Add-Content -Path $logPath -Value "[$timestamp] Erro: Lenovo System Update não encontrado após tentativa de instalação."
        Start-Process notepad.exe $logPath
    }

    Pause
}

# ==== EXECUÇÃO ====

do {
    Show-Menu
    $choice = Read-Host "Selecione uma opção"

    switch ($choice) {
        "1" { Get-SystemInfo }
        "2" { Test-Network }
        "3" { Get-ErrorLogs }
        "4" { Flush-DNS }
        "5" { Get-BatteryReport }
        "6" { Run-WindowsDecrapifier }
        "7" { Atualizar-LenovoSystemUpdate }
        "0" { Write-Host "Saindo..." }
        default { Write-Host "Opção inválida."; Pause }
    }
} while ($choice -ne "0")
```
