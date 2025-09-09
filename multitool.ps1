# ==========================
# MULTITOOL - POWERSHELL
# ==========================

function Info-Sistema {
    Clear-Host
    Write-Host "==== INFORMAÇÕES DO SISTEMA ====" -ForegroundColor Cyan

    $reportPath = "$env:USERPROFILE\Desktop\Info_Sistema.txt"

    systeminfo | Out-File -FilePath $reportPath -Encoding UTF8

    Write-Host "Relatório exportado para: $reportPath" -ForegroundColor Green
    Start-Process notepad.exe $reportPath

    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host
}

function Teste-Rede {
    Clear-Host
    Write-Host "==== TESTE DE REDE ====" -ForegroundColor Cyan
    $manual = Read-Host "Deseja digitar um host/IP manualmente? (S/N)"
    if ($manual -match "^[Ss]") {
        $hosts = @()
        do {
            $hostInput = Read-Host "Digite o endereço ou IP para teste de rede (ex: 8.8.8.8 ou www.google.com). Deixe vazio para parar"
            if ($hostInput) { $hosts += $hostInput }
        } while ($hostInput)
    } else {
        $hosts = @("8.8.8.8", "1.1.1.1", "www.google.com", "www.bing.com")
    }

    foreach ($h in $hosts) {
        Write-Host "`n--- Testando $h ---" -ForegroundColor Yellow
        Test-Connection -ComputerName $h -Count 4 -ErrorAction SilentlyContinue | Format-Table Address, ResponseTime, Status
    }

    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host
}

function Logs-Erros {
    Clear-Host
    Write-Host "==== LOGS DE ERROS (últimas 20 entradas) ====" -ForegroundColor Cyan
    Get-EventLog -LogName System -EntryType Error -Newest 20 | Format-Table TimeGenerated, Source, EventID, Message -AutoSize
    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host
}

function Flush-DNS {
    Clear-Host
    Write-Host "==== FLUSH DNS ====" -ForegroundColor Cyan
    ipconfig /flushdns
    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host
}

function Relatorio-Bateria {
    Clear-Host
    Write-Host "==== RELATÓRIO DE SAÚDE DA BATERIA ====" -ForegroundColor Cyan
    $batteryReport = "$env:USERPROFILE\Desktop\Relatorio_Bateria.html"
    powercfg /batteryreport /output $batteryReport
    Write-Host "Relatório de bateria gerado em: $batteryReport" -ForegroundColor Green
    Start-Process $batteryReport
    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host
}

function Windows-Dec {
    Clear-Host
    Write-Host "==== WINDOWS DECRAPIFIER ====" -ForegroundColor Cyan
    Write-Host "Abrindo repositório no navegador..." -ForegroundColor Yellow
    Start-Process "https://github.com/ChrisTitusTech/winutil"
    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host
}

function Atualizar-Lenovo {
    Clear-Host
    Write-Host "==== ATUALIZAR LENOVO (SYSTEM UPDATE) ====" -ForegroundColor Cyan

    $installerPath = "$env:TEMP\SystemUpdate.exe"
    $logPath = "$env:USERPROFILE\Desktop\LenovoUpdate_Log.txt"

    # Verifica se o Lenovo System Update está instalado
    $lsuPath = "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"
    if (!(Test-Path $lsuPath)) {
        Write-Host "Lenovo System Update não encontrado. Baixando instalador..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri "https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_5.07.0146.exe" -OutFile $installerPath
        Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT /NORESTART" -Wait
    }

    Write-Host "Executando Lenovo System Update em modo silencioso..." -ForegroundColor Yellow
    Start-Process -FilePath $lsuPath -ArgumentList "/CM -search A -action INSTALL -noicon -nolicense -noreboot" -Wait

    # Registrar resultado no log
    "Atualização Lenovo executada em $(Get-Date)" | Out-File -FilePath $logPath -Append
    Write-Host "Log salvo em: $logPath" -ForegroundColor Green
    Start-Process notepad.exe $logPath

    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host
}

# ==========================
# MENU PRINCIPAL
# ==========================
do {
    Clear-Host
    Write-Host "================= MULTITOOL =================" -ForegroundColor Cyan
    Write-Host "1. Informações do Sistema (gera TXT no Desktop)"
    Write-Host "2. Teste de Rede (Ping)"
    Write-Host "3. Logs de Erros"
    Write-Host "4. Flush DNS"
    Write-Host "5. Relatório de Saúde da Bateria"
    Write-Host "6. Windows Decrapifier"
    Write-Host "7. Atualizar Lenovo (System Update)"
    Write-Host "0. Sair"
    Write-Host "============================================"

    $opcao = Read-Host "Selecione uma opção"

    switch ($opcao) {
        1 { Info-Sistema }
        2 { Teste-Rede }
        3 { Logs-Erros }
        4 { Flush-DNS }
        5 { Relatorio-Bateria }
        6 { Windows-Dec }
        7 { Atualizar-Lenovo }
        0 { Write-Host "Saindo..." -ForegroundColor Yellow }
        default { Write-Host "Opção inválida, tente novamente!" -ForegroundColor Red; Start-Sleep -Seconds 2 }
    }
} until ($opcao -eq "0")
