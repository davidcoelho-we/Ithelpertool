# ==============================
# Multitool IT Helper
# ==============================

function Show-Menu {
    Clear-Host
    Write-Host "==== MULTITOOL IT HELPER ====" -ForegroundColor Cyan
    Write-Host "1. Informações do Sistema"
    Write-Host "2. Teste de Rede"
    Write-Host "3. Relatório de Bateria"
    Write-Host "4. Testar Áudio/Vídeo"
    Write-Host "5. Atualizar Lenovo (System Update)"
    Write-Host "0. Sair"
}

# 1 - Informações do Sistema (exporta txt)
function System-Info {
    Clear-Host
    $file = "$env:USERPROFILE\Desktop\SystemInfo.txt"
    systeminfo | Out-File -FilePath $file -Encoding UTF8
    Write-Host "Informações exportadas para: $file" -ForegroundColor Green
    Start-Process notepad.exe $file
    Pause
}

# 2 - Teste de Rede
function Network-Test {
    Clear-Host
    $hosts = @("8.8.8.8","1.1.1.1","www.google.com","www.microsoft.com")
    $file = "$env:USERPROFILE\Desktop\NetworkTest.txt"
    foreach ($h in $hosts) {
        Write-Host "`n=== Testando $h ===" -ForegroundColor Cyan
        $r = Test-Connection -ComputerName $h -Count 4 -ErrorAction SilentlyContinue
        if ($r) {
            $out = "$h - OK"
            Write-Host $out -ForegroundColor Green
            $out | Out-File -Append -FilePath $file
        } else {
            $out = "$h - FALHA"
            Write-Host $out -ForegroundColor Red
            $out | Out-File -Append -FilePath $file
        }
    }
    Write-Host "`nResultado salvo em: $file" -ForegroundColor Yellow
    Start-Process notepad.exe $file
    Pause
}

# 3 - Relatório de Bateria
function Battery-Report {
    Clear-Host
    $file = "$env:USERPROFILE\Desktop\BatteryReport.html"
    powercfg /batteryreport /output $file
    Write-Host "Relatório de bateria exportado para: $file" -ForegroundColor Green
    Start-Process $file
    Pause
}

# 4 - Teste Áudio/Vídeo
function AV-Test {
    Clear-Host
    Write-Host "Abrindo configurações de câmera..." -ForegroundColor Cyan
    Start-Process ms-settings:camera
    Write-Host "Abrindo configurações de microfone..." -ForegroundColor Cyan
    Start-Process ms-settings:privacy-microphone
    Write-Host "Abrindo ferramenta de teste de som..." -ForegroundColor Cyan
    Start-Process ms-settings:sound
    Pause
}

# 5 - Lenovo Update (modo de instalação semi-silencioso por padrão)
function Lenovo-Update {
    Clear-Host
    Write-Host "==== LENOVO SYSTEM UPDATE ====" -ForegroundColor Cyan

    # Define os argumentos para a instalação semi-silenciosa (com barra de progresso) como padrão
    $installerArgs = '/s /v"/qb"'

    $exePath = "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"
    $downloadPath = "$env:TEMP\SystemUpdateInstaller.exe"
    $downloadURL = "https://raw.githubusercontent.com/davidcoelho-we/Ithelpertool/main/system_update_5.08.03.59.exe"

    $lenovoLogsDir = "C:\ProgramData\Lenovo\SystemUpdate\Logs"
    $desktopLogsDir = "$env:USERPROFILE\Desktop\LenovoSystemUpdate_Logs"

    function Copy-LenovoLogs {
        param ([string]$SourceDir, [string]$DestDir)
        if (Test-Path $SourceDir) {
            New-Item -ItemType Directory -Path $DestDir -ErrorAction SilentlyContinue | Out-Null
            $logsToCopy = Get-ChildItem -Path $SourceDir -File | Sort-Object LastWriteTime -Descending | Select-Object -First 5
            if ($logsToCopy) {
                $logsToCopy | Copy-Item -Destination $DestDir -Force -Recurse -ErrorAction SilentlyContinue
                Write-Host "Logs copiados para: $DestDir" -ForegroundColor Yellow
                Start-Process notepad.exe "$DestDir\$($logsToCopy[0].Name)"
            }
        } else {
            Write-Host "Pasta de logs não encontrada: $SourceDir" -ForegroundColor Yellow
        }
    }

    if (Test-Path $exePath) {
        Write-Host "System Update encontrado. Iniciando busca por atualizações..." -ForegroundColor Green
        try {
            Start-Process -FilePath $exePath -ArgumentList "/CM -search A -action INSTALL -includerebootpackages 3 -noicon" -Wait -NoNewWindow
            Copy-LenovoLogs -SourceDir $lenovoLogsDir -DestDir $desktopLogsDir
        } catch {
            Write-Host "Erro ao executar atualização: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "System Update não instalado. Baixando e instalando (modo semi-silencioso)..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $downloadURL -OutFile $downloadPath -UseBasicParsing -ErrorAction Stop
            # Usa a variável com os argumentos de instalação definidos
            Start-Process -FilePath $downloadPath -ArgumentList $installerArgs -Wait -NoNewWindow
            
            if (Test-Path $exePath) {
                Write-Host "Instalação concluída. Executando busca por atualizações..." -ForegroundColor Green
                Start-Process -FilePath $exePath -ArgumentList "/CM -search A -action INSTALL -includerebootpackages 3 -noicon" -Wait -NoNewWindow
                Copy-LenovoLogs -SourceDir $lenovoLogsDir -DestDir $desktopLogsDir
            } else {
                Write-Host "A instalação parece ter falhado, o arquivo tvsu.exe não foi encontrado." -ForegroundColor Red
            }
        } catch {
            Write-Host "Falha ao baixar ou instalar: $($_.Exception.Message)" -ForegroundColor Red
        } finally {
            Remove-Item $downloadPath -ErrorAction SilentlyContinue
        }
    }
    Pause
}


# Loop principal
do {
    Show-Menu
    $opt = Read-Host "Selecione uma opção"
    switch ($opt) {
        1 { System-Info }
        2 { Network-Test }
        3 { Battery-Report }
        4 { AV-Test }
        5 { Lenovo-Update }
        0 { break }
        default { Write-Host "Opção inválida" -ForegroundColor Red; Pause }
    }
} while ($opt -ne 0)
