# ==============================
# MULTITOOL POWERSHELL
# ==============================

function Show-Menu {
    Clear-Host
    Write-Host "==== MULTITOOL IT ====" -ForegroundColor Cyan
    Write-Host "1. Teste de Rede (Ping)"
    Write-Host "2. Relatório de Bateria"
    Write-Host "3. Informações do Sistema (exportar TXT)"
    Write-Host "4. Lenovo System Update (modo silencioso)"
    Write-Host "5. Teste Multimídia (Câmera, Microfone, Speaker)"
    Write-Host "0. Sair"
    Write-Host "======================="
}

# ==============================
# Funções
# ==============================

function Teste-Rede {
    Clear-Host
    Write-Host "==== TESTE DE REDE ====" -ForegroundColor Cyan
    $hosts = @("8.8.8.8","1.1.1.1","www.google.com","www.microsoft.com")

    foreach ($h in $hosts) {
        Write-Host "`n--- Testando $h ---" -ForegroundColor Yellow
        Test-Connection -Count 4 -ComputerName $h | Format-Table Address, ResponseTime, IPV4Address -AutoSize
    }

    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host | Out-Null
}

function Relatorio-Bateria {
    Clear-Host
    Write-Host "==== RELATÓRIO DE BATERIA ====" -ForegroundColor Cyan
    $path = "$env:USERPROFILE\Desktop\relatorio_bateria.html"
    powercfg /batteryreport /output $path
    Write-Host "Relatório salvo em: $path" -ForegroundColor Green
    Start-Process $path
    Read-Host "Pressione Enter para voltar ao menu..." | Out-Null
}

function Info-Sistema {
    Clear-Host
    Write-Host "==== INFORMAÇÕES DO SISTEMA ====" -ForegroundColor Cyan
    $path = "$env:USERPROFILE\Desktop\info_sistema.txt"
    systeminfo | Out-File -FilePath $path -Encoding utf8
    Write-Host "Informações do sistema exportadas para: $path" -ForegroundColor Green
    Start-Process notepad.exe $path
    Read-Host "Pressione Enter para voltar ao menu..." | Out-Null
}

function Lenovo-Update {
    Clear-Host
    Write-Host "==== LENOVO SYSTEM UPDATE ====" -ForegroundColor Cyan
    $logPath = "$env:ProgramData\Lenovo\System Update\Logs\tvsu.log"
    $exePath = "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"

    if (Test-Path $exePath) {
        Write-Host "Executando Lenovo System Update em modo silencioso..." -ForegroundColor Green
        Write-Host "Uma nova janela do PowerShell será aberta para monitorar o progresso." -ForegroundColor Yellow
        Write-Host "Pressione Ctrl+C na janela de log para parar o monitoramento quando a instalação terminar." -ForegroundColor Yellow
        
        # Inicia o monitoramento do log em uma nova janela.
        Start-Process -FilePath powershell.exe -ArgumentList "-NoExit", "-Command", "Get-Content -Path '$logPath' -Wait"

        # Inicia a atualização e espera a conclusão.
        Start-Process -FilePath $exePath -ArgumentList "/CM -search A -action INSTALL -includerebootpackages 1 -noreboot" -Wait -NoNewWindow
        
        Write-Host "`nAtualizações concluídas!" -ForegroundColor Green
        
        # Pede para o usuário fechar a janela de log.
        Read-Host "`nA atualização foi concluída. Feche a janela de log para continuar." | Out-Null
    }
    else {
        Write-Host "Lenovo System Update não encontrado neste computador." -ForegroundColor Red
    }

    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host | Out-Null
}

function Teste-Multimidia {
    Clear-Host
    Write-Host "==== TESTE MULTIMÍDIA (Câmera, Microfone, Speaker) ====" -ForegroundColor Cyan

    # 1. CÂMERA
    Write-Host "`n[Câmeras detectadas]" -ForegroundColor Yellow
    Get-CimInstance Win32_PnPEntity | Where-Object { $_.Name -match "Camera|Video" } | Select-Object Name, Status
    Write-Host "Abrindo aplicativo de Câmera para teste..." -ForegroundColor Green
    Start-Process "microsoft.windows.camera:"

    # 2. MICROFONE
    Write-Host "`n[Microfones detectados]" -ForegroundColor Yellow
    Get-CimInstance Win32_SoundDevice | Where-Object { $_.ProductName -match "Microphone" -or $_.Name -match "Microphone" } | Select-Object Name, Status
    Write-Host "Abrindo configurações de microfone..." -ForegroundColor Green
    Start-Process ms-settings:privacy-microphone

    # 3. SPEAKER
    Write-Host "`n[Alto-falantes detectados]" -ForegroundColor Yellow
    Get-CimInstance Win32_SoundDevice | Select-Object Name, Status
    Write-Host "Tocando som de teste..." -ForegroundColor Green
    [console]::beep(800, 500)
    $sound = "$env:WINDIR\Media\Windows Notify.wav"
    if (Test-Path $sound) {
        (New-Object Media.SoundPlayer $sound).PlaySync()
    }

    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host | Out-Null
}

# ==============================
# Loop principal
# ==============================
do {
    Show-Menu
    $choice = Read-Host "Escolha uma opção"
    switch ($choice) {
        "1" { Teste-Rede }
        "2" { Relatorio-Bateria }
        "3" { Info-Sistema }
        "4" { Lenovo-Update }
        "5" { Teste-Multimidia }
        "0" { break }
        default { Write-Host "Opção inválida!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($true)
