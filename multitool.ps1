# ==============================
# MULTITOOL POWERSHELL
# ==============================

function Show-Menu {
    Clear-Host
    Write-Host "==== MULTITOOL IT ====" -ForegroundColor Cyan
    Write-Host "1. Teste de Rede (Ping)"
    Write-Host "2. Relatório de Bateria"
    Write-Host "3. Informações do Sistema (exportar TXT)"
    Write-Host "4. Lenovo System Update (instala e atualiza silenciosamente)"
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
    Write-Host "==== Tentando instalação/atualização TOTALMENTE silenciosa ====" -ForegroundColor Yellow
    Write-Host "Referência: Lenovo Deployment Guide (DG-SystemUpdateSuite.pdf)" -ForegroundColor DarkGray

    $exePath = "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"
    $downloadPath = "$env:TEMP\SystemUpdateInstaller.exe"
    # URL RAW do GitHub para download direto do executável
    $downloadURL = "https://raw.githubusercontent.com/davidcoelho-we/Ithelpertool/main/system_update_5.08.03.59.exe"
    
    $lenovoLogsDir = "C:\ProgramData\Lenovo\SystemUpdate\Logs" # Pasta padrão dos logs da Lenovo
    $desktopLogsDir = "$env:USERPROFILE\Desktop\LenovoSystemUpdate_Logs" # Pasta na Área de Trabalho

    # --- Função auxiliar para copiar logs ---
    function Copy-LenovoLogs {
        param (
            [string]$SourceDir,
            [string]$DestDir
        )
        if (Test-Path $SourceDir) {
            # Cria a pasta de destino se não existir
            New-Item -ItemType Directory -Path $DestDir -ErrorAction SilentlyContinue | Out-Null
            
            # Copia os logs mais recentes (ex: últimos 5 minutos de modificação)
            # A lógica é pegar os logs mais prováveis de serem da execução atual.
            $last5Minutes = (Get-Date).AddMinutes(-5)
            $logsToCopy = Get-ChildItem -Path $SourceDir -File | Where-Object { $_.LastWriteTime -ge $last5Minutes }
            
            if ($logsToCopy.Count -eq 0) {
                # Se nenhum log muito recente for encontrado, tenta logs da última hora
                $lastHour = (Get-Date).AddHours(-1)
                $logsToCopy = Get-ChildItem -Path $SourceDir -File | Where-Object { $_.LastWriteTime -ge $lastHour }
                if ($logsToCopy.Count -eq 0) {
                    # Como último recurso, pega os 5 logs mais recentes (sem garantia de serem da execução atual)
                    $logsToCopy = Get-ChildItem -Path $SourceDir -File | Sort-Object LastWriteTime -Descending | Select-Object -First 5
                }
            }

            if ($logsToCopy.Count -gt 0) {
                Write-Host "Copiando logs do Lenovo System Update para: $DestDir" -ForegroundColor Yellow
                $logsToCopy | Copy-Item -Destination $DestDir -Force -Recurse -ErrorAction SilentlyContinue
            } else {
                Write-Host "Nenhum log recente do Lenovo System Update encontrado para copiar." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Pasta de logs padrão da Lenovo não encontrada em '$SourceDir'." -ForegroundColor Yellow
        }
    }

    # --- 1. Verificar se o Lenovo System Update já está instalado ---
    if (Test-Path $exePath) {
        Write-Host "Lenovo System Update já está instalado." -ForegroundColor Green
        
        try {
            Write-Host "Iniciando a atualização no modo agendado silencioso (/SCHEDULENOW)..." -ForegroundColor Green
            # O argumento /SCHEDULENOW é projetado para instalar todas as atualizações sem UI.
            Start-Process -FilePath $exePath -ArgumentList "/SCHEDULENOW" -Wait -NoNewWindow
            
            Write-Host "Comando Lenovo System Update executado." -ForegroundColor Green
            Copy-LenovoLogs -SourceDir $lenovoLogsDir -DestDir $desktopLogsDir
            Write-Host "Os logs foram copiados para: $desktopLogsDir" -ForegroundColor Yellow
        }
        catch {
            Write-Host "Erro ao executar a atualização do Lenovo System Update: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Verifique a documentação para argumentos de automação específicos da sua versão do System Update." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "Lenovo System Update não encontrado neste computador." -ForegroundColor Red
        Write-Host "Tentando baixar e instalar a versão silenciosa do instalador tvsu.exe..." -ForegroundColor Yellow

        # --- 2. Baixar o instalador ---
        try {
            Write-Host "Baixando o instalador de: $downloadURL" -ForegroundColor Yellow
            Invoke-WebRequest -Uri $downloadURL -OutFile $downloadPath -UseBasicParsing -ErrorAction Stop

            if (Test-Path $downloadPath) {
                Write-Host "Download concluído. Iniciando a instalação silenciosa do tvsu.exe..." -ForegroundColor Green
                # Tentativa de instalação super silenciosa para o EXE wrapper de MSI
                # /s para o wrapper, e /v"/qn" para o MSI interno.
                # Esta é a combinação mais provável para instaladores da Lenovo para ser 100% silenciosa.
                Start-Process -FilePath $downloadPath -ArgumentList "/s /v`"/qn`"" -Wait -NoNewWindow
                
                if (Test-Path $exePath) {
                    Write-Host "Lenovo System Update instalado com sucesso!" -ForegroundColor Green
                    Write-Host "Prosseguindo com a atualização no modo agendado silencioso..." -ForegroundColor Green
                    
                    try {
                        Start-Process -FilePath $exePath -ArgumentList "/SCHEDULENOW" -Wait -NoNewWindow
                        
                        Write-Host "Comando de atualização executado." -ForegroundColor Green
                        Copy-LenovoLogs -SourceDir $lenovoLogsDir -DestDir $desktopLogsDir
                        Write-Host "Os logs foram copiados para: $desktopLogsDir" -ForegroundColor Yellow
                    }
                    catch {
                        Write-Host "Erro ao executar a atualização após a instalação: $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
                else {
                    Write-Host "Instalação do System Update falhou ou o executável não foi encontrado no caminho esperado." -ForegroundColor Red
                    Write-Host "O argumento de instalação silenciosa '/s /v\"/qn\"' pode não ser o correto para este instalador. Tente instalar manualmente para verificar o comportamento." -ForegroundColor Yellow
                }
            }
            else {
                Write-Host "Falha no download: O arquivo $downloadPath não foi criado." -ForegroundColor Red
            }
        }
        catch {
            Write-Host "Erro durante o download ou a tentativa de instalação: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Verifique a URL de download (raw do GitHub) ou a permissão de rede." -ForegroundColor Yellow
        }
        finally {
            Remove-Item $downloadPath -ErrorAction SilentlyContinue
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
