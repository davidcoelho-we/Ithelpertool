# ==============================
# MULTITOOL POWERSHELL
# ==============================

# --- VERIFICAÇÃO DE ADMINISTRADOR ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script precisa ser executado com privilégios de Administrador." -ForegroundColor Red
    Start-Sleep -Seconds 5
    exit
}

function Show-Menu {
    Clear-Host
    Write-Host "==== MULTITOOL IT ====" -ForegroundColor Cyan
    Write-Host "1. Teste de Rede (Ping)"
    Write-Host "2. Relatório de Bateria"
    Write-Host "3. Informações do Sistema (exportar TXT)"
    Write-Host "4. Teste Multimídia (Câmera, Microfone, Speaker)"
    Write-Host "5. Lenovo Commercial Vantage (SU Helper – recomendado)"
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
    
    try {
        powercfg /batteryreport /output $path
        Write-Host "Relatório salvo em: $path" -ForegroundColor Green
        Start-Process $path
    }
    catch {
        Write-Host "Erro ao gerar ou abrir o relatório de bateria: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Read-Host "Pressione Enter para voltar ao menu..." | Out-Null
}

function Info-Sistema {
    Clear-Host
    Write-Host "==== INFORMAÇÕES DO SISTEMA ====" -ForegroundColor Cyan
    $path = "$env:USERPROFILE\Desktop\info_sistema.txt"
    
    try {
        systeminfo | Out-File -FilePath $path -Encoding utf8
        Write-Host "Informações do sistema exportadas para: $path" -ForegroundColor Green
        Start-Process notepad.exe $path
    }
    catch {
        Write-Host "Erro ao exportar ou abrir as informações do sistema: $($_.Exception.Message)" -ForegroundColor Red
    }

    Read-Host "Pressione Enter para voltar ao menu..." | Out-Null
}

function Teste-Multimidia {
    Clear-Host
    Write-Host "==== TESTE MULTIMÍDIA (CÂMERA, MICROFONE, SPEAKER) ====" -ForegroundColor Cyan

    # 1. CÂMERA
    Write-Host "`n[Câmeras detectadas]" -ForegroundColor Yellow
    Get-CimInstance Win32_PnPEntity | Where-Object { $_.Name -match "Camera|Video" } | Select-Object Name, Status
    Write-Host "Abrindo aplicativo de Câmera para teste (verifique a funcionalidade manualmente)..." -ForegroundColor Green
    try {
        Start-Process "microsoft.windows.camera:"
    }
    catch {
        Write-Host "Não foi possível abrir o aplicativo de Câmera. Verifique se ele está instalado." -ForegroundColor Red
    }

    # 2. MICROFONE
    Write-Host "`n[Microfones detectados]" -ForegroundColor Yellow
    Get-CimInstance Win32_SoundDevice | Where-Object { $_.ProductName -match "Microphone" -or $_.Name -match "Microphone" } | Select-Object Name, Status
    Write-Host "Abrindo configurações de microfone (verifique a funcionalidade manualmente)..." -ForegroundColor Green
    try {
        Start-Process ms-settings:privacy-microphone
    }
    catch {
        Write-Host "Não foi possível abrir as configurações de microfone." -ForegroundColor Red
    }

    # 3. SPEAKER
    Write-Host "`n[Alto-falantes detectados]" -ForegroundColor Yellow
    Get-CimInstance Win32_SoundDevice | Select-Object Name, Status
    Write-Host "Tocando som de teste..." -ForegroundColor Green
    try {
        [console]::beep(800, 500)
        $sound = "$env:WINDIR\Media\Windows Notify.wav"
        if (Test-Path $sound) {
            (New-Object Media.SoundPlayer $sound).PlaySync()
        } else {
            Write-Host "Arquivo de som de teste 'Windows Notify.wav' não encontrado." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Erro ao tentar tocar som de teste: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host | Out-Null
}

function Lenovo-UpdateCV {
    Clear-Host
    Write-Host "==== ATUALIZAÇÃO via Commercial Vantage (SU Helper) ====" -ForegroundColor Cyan

    $suHelper = "C:\Program Files (x86)\Lenovo\System Update Helper\SUHelper.exe"
    $logDest = "$env:USERPROFILE\Desktop\Vantage_UpdateLogs"
    New-Item -Path $logDest -ItemType Directory -Force | Out-Null

    if (!(Test-Path $suHelper)) {
        Write-Host "SU Helper não encontrado. É necessário instalar o Lenovo Commercial Vantage + SU Helper." -ForegroundColor Yellow
        Write-Host "Baixe e instale o pacote oficial em: https://support.lenovo.com" -ForegroundColor Yellow
        Read-Host "Pressione Enter para voltar ao menu..." | Out-Null
        return
    }

    try {
        Write-Host "Executando atualização via SU Helper..." -ForegroundColor Green
        Start-Process -FilePath $suHelper -ArgumentList "update" -Wait -NoNewWindow

        Write-Host "Atualização concluída. Capturando histórico via WMI..." -ForegroundColor Green
        $updates = Get-CimInstance -Namespace root\lenovo -Class Lenovo_Updates -ErrorAction SilentlyContinue

        if ($updates) {
            $updates | Select-Object Severity, Status, Title, Version | Out-File "$logDest\UpdatesHistory.txt" -Encoding UTF8
            Write-Host "Histórico salvo em: $logDest\UpdatesHistory.txt" -ForegroundColor Green
            Start-Process notepad.exe "$logDest\UpdatesHistory.txt"
        } else {
            Write-Host "Não foi possível acessar os dados de histórico via WMI." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Erro ao executar o SU Helper: $($_.Exception.Message)" -ForegroundColor Red
    }

    Read-Host "Pressione Enter para voltar ao menu..." | Out-Null
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
        "4" { Teste-Multimidia }
        "5" { Lenovo-UpdateCV }
        "0" { break }
        default { Write-Host "Opção inválida!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($true)
