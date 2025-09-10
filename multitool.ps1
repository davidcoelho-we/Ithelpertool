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
    $hosts = @()

    $manual = Read-Host "Deseja digitar um host/IP manualmente? (S/N)"
    if ($manual -match "^[sS]$") {
        while ($true) {
            $hostInput = Read-Host "Digite o endereço ou IP para teste de rede (ex: 8.8.8.8 ou www.google.com). Deixe vazio para parar"
            if ([string]::IsNullOrWhiteSpace($hostInput)) { break }
            $hosts += $hostInput
        }
    }
    else {
        $hosts = @("8.8.8.8","1.1.1.1","www.google.com","www.microsoft.com")
    }

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
    $log = "$env:USERPROFILE\Desktop\LenovoUpdate.log"
    $exePath = "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"

    if (Test-Path $exePath) {
        Start-Process -FilePath $exePath -ArgumentList "/CM -search A -action INSTALL -includerebootpackages 1 -noreboot" -Wait -NoNewWindow
        Write-Host "Atualizações concluídas. Log salvo em $log" -ForegroundColor Green
        Get-Content $log | Out-File $log -Encoding utf8
        Start-Process notepad.exe $log
    }
    else {
        Write-Host "Lenovo System Update não encontrado neste computador." -ForegroundColor Red
    }

    Read-Host "Pressione Enter para voltar ao menu..." | Out-Null
}

function Teste-Multimidia {
    Clear-Host
    Write-Host "==== TESTE MULTIMÍDIA (CÂMERA, MICROFONE, SPEAKER) ====" -ForegroundColor Cyan

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
