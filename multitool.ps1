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
    Write-Host "==== Usando modo Sideload para instalação/atualização silenciosa ====" -ForegroundColor Yellow

    $exePath = "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"
    $downloadPath = "$env:TEMP\SystemUpdateInstaller.exe"
    $downloadURL = "https://raw.githubusercontent.com/davidcoelho-we/Ithelpertool/main/system_update_5.08.03.59.exe"
    $sideloadXmlPath = "$env:TEMP\sideload.xml"

    # Conteúdo do arquivo XML para atualização silenciosa
    # Este XML instrui o System Update a buscar e instalar todas as atualizações.
    $xmlContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<Manifest>
  <Commands>
    <Command>
      <ApplicationName>System Update</ApplicationName>
      <Parameters>
        /CM -search A -action INSTALL -includerebootpackages 1 -noreboot -packagetype 1 -packagename ALL
      </Parameters>
    </Command>
  </Commands>
</Manifest>
"@

    # --- 1. Verificar se o Lenovo System Update já está instalado ---
    if (Test-Path $exePath) {
        Write-Host "Lenovo System Update já está instalado." -ForegroundColor Green
        
        try {
            # Cria o arquivo XML de sideload
            $xmlContent | Out-File -FilePath $sideloadXmlPath -Encoding utf8 -Force
            
            Write-Host "Iniciando a atualização no modo Sideload (totalmente silencioso)..." -ForegroundColor Green
            Start-Process -FilePath $exePath -ArgumentList "/Sideload $sideloadXmlPath" -Wait -NoNewWindow
            
            Write-Host "Comando Lenovo System Update executado." -ForegroundColor Green
            Write-Host "Verifique os logs detalhados do System Update em: C:\ProgramData\Lenovo\SystemUpdate\Logs" -ForegroundColor Yellow
        }
        catch {
            Write-Host "Erro ao executar a atualização do Lenovo System Update: $($_.Exception.Message)" -ForegroundColor Red
        }
        finally {
            # Opcional: Remover o XML após a execução (mesmo em caso de erro)
            Remove-Item $sideloadXmlPath -ErrorAction SilentlyContinue
        }
    }
    else {
        Write-Host "Lenovo System Update não encontrado neste computador." -ForegroundColor Red
        Write-Host "Tentando baixar e instalar a versão silenciosa..." -ForegroundColor Yellow

        # --- 2. Baixar o instalador (instalação do System Update também deve ser silenciosa) ---
        try {
            Write-Host "Baixando o instalador de: $downloadURL" -ForegroundColor Yellow
            Invoke-WebRequest -Uri $downloadURL -OutFile $downloadPath -UseBasicParsing -ErrorAction Stop

            if (Test-Path $downloadPath) {
                Write-Host "Download concluído. Iniciando a instalação silenciosa..." -ForegroundColor Green
                # O argumento /S é para a instalação silenciosa do tvsu.exe (o instalador em si)
                Start-Process -FilePath $downloadPath -ArgumentList "/S" -Wait -NoNewWindow
                
                if (Test-Path $exePath) {
                    Write-Host "Lenovo System Update instalado com sucesso!" -ForegroundColor Green
                    Write-Host "Prosseguindo com a atualização no modo Sideload..." -ForegroundColor Green
                    
                    try {
                        # Cria e executa o sideload.xml após a instalação
                        $xmlContent | Out-File -FilePath $sideloadXmlPath -Encoding utf8 -Force
                        Start-Process -FilePath $exePath -ArgumentList "/Sideload $sideloadXmlPath" -Wait -NoNewWindow
                        
                        Write-Host "Comando de atualização executado. Verifique os logs." -ForegroundColor Green
                        Write-Host "Logs do System Update em: C:\ProgramData\Lenovo\SystemUpdate\Logs" -ForegroundColor Yellow
                    }
                    catch {
                        Write-Host "Erro ao executar a atualização após a instalação: $($_.Exception.Message)" -ForegroundColor Red
                    }
                    finally {
                        Remove-Item $sideloadXmlPath -ErrorAction SilentlyContinue
                    }
                }
                else {
                    Write-Host "Instalação do System Update falhou ou o executável não foi encontrado no caminho esperado." -ForegroundColor Red
                    Write-Host "Por favor, tente instalar manualmente ou verifique o log para mais detalhes." -ForegroundColor Yellow
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
            # Sempre tentar remover o instalador baixado
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
