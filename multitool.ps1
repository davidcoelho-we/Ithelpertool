# ==============================
# MULTITOOL POWERSHELL
# ==============================

function Show-Menu {
    Clear-Host
    Write-Host "==== MULTITOOL IT ====" -ForegroundColor Cyan
    Write-Host "1. Teste de Rede (Ping)"
    Write-Host "2. Relatório de Bateria"
    Write-Host "3. Informações do Sistema (exportar TXT)"
    Write-Host "4. Lenovo System Update (instala e atualiza)"
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

function Lenovo-Update {
    Clear-Host
    Write-Host "==== LENOVO SYSTEM UPDATE ====" -ForegroundColor Cyan

    $exePath = "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"
    $downloadPath = "$env:TEMP\SystemUpdateInstaller.exe" # Local temporário para o instalador
    # Usando a URL RAW do GitHub para download direto do executável
    $downloadURL = "https://raw.githubusercontent.com/davidcoelho-we/Ithelpertool/main/system_update_5.08.03.59.exe" 

    # --- 1. Verificar se o Lenovo System Update já está instalado ---
    if (Test-Path $exePath) {
        Write-Host "Lenovo System Update já está instalado. Iniciando o processo de atualização..." -ForegroundColor Green
        Start-Process -FilePath $exePath -ArgumentList "/CM -search A -action INSTALL -includerebootpackages 1 -noreboot" -Wait -NoNewWindow
        
        Write-Host "Comando Lenovo System Update executado." -ForegroundColor Green
        Write-Host "Verifique os logs detalhados do System Update em: C:\ProgramData\Lenovo\SystemUpdate\Logs" -ForegroundColor Yellow
    }
    else {
        Write-Host "Lenovo System Update não encontrado neste computador." -ForegroundColor Red
        Write-Host "Tentando baixar e instalar o Lenovo System Update..." -ForegroundColor Yellow

        # --- 2. Baixar o instalador ---
        try {
            Write-Host "Baixando o instalador do Lenovo System Update de: $downloadURL" -ForegroundColor Yellow
            Invoke-WebRequest -Uri $downloadURL -OutFile $downloadPath -UseBasicParsing -ErrorAction Stop

            if (Test-Path $downloadPath) {
                Write-Host "Download concluído. Iniciando a instalação..." -ForegroundColor Green

                # --- 3. Instalar em modo silencioso ---
                # A maioria dos instaladores .exe pode ser executada com "/S" para instalação silenciosa
                # É importante testar qual argumento funciona para este instalador específico.
                Start-Process -FilePath $downloadPath -ArgumentList "/S" -Wait -NoNewWindow
                
                # Após a instalação, verificar novamente se o tvsu.exe agora existe
                if (Test-Path $exePath) {
                    Write-Host "Lenovo System Update instalado com sucesso!" -ForegroundColor Green
                    Write-Host "Iniciando o processo de atualização após a instalação..." -ForegroundColor Green
                    Start-Process -FilePath $exePath -ArgumentList "/CM -search A -action INSTALL -includerebootpackages 1 -noreboot" -Wait -NoNewWindow
                    Write-Host "Comando Lenovo System Update executado." -ForegroundColor Green
                    Write-Host "Verifique os logs detalhados do System Update em: C:\ProgramData\Lenovo\SystemUpdate\Logs" -ForegroundColor Yellow
                }
                else {
                    Write-Host "Instalação do Lenovo System Update foi concluída, mas o executável 'tvsu.exe' não foi encontrado no caminho esperado." -ForegroundColor Red
                    Write-Host "Pode ser necessário verificar o caminho de instalação ou instalar manualmente." -ForegroundColor Yellow
                }

                # Opcional: Remover o instalador após a instalação
                Remove-Item $downloadPath -ErrorAction SilentlyContinue
            }
            else {
                Write-Host "Falha no download: O arquivo $downloadPath não foi criado." -ForegroundColor Red
            }
        }
        catch {
            Write-Host "Erro durante o download ou instalação: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Verifique a URL de download (raw do GitHub) ou tente instalar manualmente." -ForegroundColor Yellow
        }
    }

    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host | Out-Null
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
