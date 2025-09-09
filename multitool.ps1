# =========================
#        MULTITOOL
# =========================

function Info-Sistema {
    Clear-Host
    Write-Host "==== INFORMAÇÕES DO SISTEMA ====" -ForegroundColor Cyan
    systeminfo | Out-String | more
    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host
}

function Teste-Rede {
    Clear-Host
    Write-Host "==== TESTE DE REDE ====" -ForegroundColor Cyan

    # Pergunta se o usuário quer digitar um host ou usar lista padrão
    $opcao = Read-Host "Deseja digitar um host/IP manualmente? (S/N)"

    if ($opcao -match '^[sS]$') {
        $host = Read-Host "Digite o endereço ou IP para teste de rede"
        $hosts = @($host)
    }
    else {
        # Lista padrão de hosts
        $hosts = @("8.8.8.8", "1.1.1.1", "www.google.com", "www.microsoft.com")
    }

    foreach ($host in $hosts) {
        Write-Host "`nPing em: $host" -ForegroundColor Yellow
        try {
            Test-Connection -ComputerName $host -Count 4 -ErrorAction Stop |
                Select-Object Address, ResponseTime, IPV4Address |
                Format-Table -AutoSize
        }
        catch {
            Write-Host "Falha ao pingar $host" -ForegroundColor Red
        }
    }

    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host
}

function Logs-Erros {
    Clear-Host
    Write-Host "==== LOGS DE ERROS ====" -ForegroundColor Cyan
    Get-EventLog -LogName System -EntryType Error -Newest 20 |
        Format-Table TimeGenerated, Source, EventID, Message -AutoSize
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
    Write-Host "==== RELATÓRIO DE BATERIA ====" -ForegroundColor Cyan

    $reportPath = "$env:USERPROFILE\Desktop\Relatorio_Bateria"
    New-Item -Path $reportPath -ItemType Directory -Force | Out-Null

    $uptime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $uptimeDuration = (Get-Date) - $uptime

    $batteryReportPath = "$reportPath\battery-report.html"
    powercfg /batteryreport /output $batteryReportPath | Out-Null

    $batteryInfo = Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity
    $designInfo  = Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData

    if ($batteryInfo -and $designInfo) {
        $fullCharge = $batteryInfo.FullChargedCapacity
        $designCap = $designInfo.DesignedCapacity
        $healthPercent = [math]::Round(($fullCharge / $designCap) * 100, 2)

        if ($healthPercent -lt 70) {
            $batteryStatus = "⚠️ A bateria está com $healthPercent% da capacidade original. Recomenda-se substituição."
        } else {
            $batteryStatus = "✅ A bateria está saudável, com $healthPercent% da capacidade original."
        }
    } else {
        $batteryStatus = "⚠️ Não foi possível determinar o estado da bateria."
    }

    $reportTextPath = "$reportPath\relatorio_bateria.txt"

@"
==== RELATÓRIO DE USO E SAÚDE DA BATERIA ====

[1] Tempo que o computador está ligado:
      - Desde: $uptime
      - Duração: $([math]::Round($uptimeDuration.TotalHours,2)) horas

[2] Saúde da bateria:
      - $batteryStatus

[3] Relatório de saúde detalhado:
      - Gerado em: $batteryReportPath
"@ | Out-File -FilePath $reportTextPath -Encoding UTF8

    Start-Process notepad.exe $reportTextPath
    Start-Process $batteryReportPath
}

function Lenovo-Update {
    Clear-Host
    Write-Host "==== ATUALIZAR LENOVO (SYSTEM UPDATE) ====" -ForegroundColor Cyan

    $path = "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"

    if (Test-Path $path) {
        Write-Host "Executando Lenovo System Update em modo silencioso..." -ForegroundColor Green
        Start-Process -FilePath $path -ArgumentList "/CM" -Wait
    }
    else {
        Write-Host "Lenovo System Update não encontrado. Instale o software primeiro." -ForegroundColor Red
    }

    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host
}

function Windows-Decrapifier {
    Clear-Host
    Write-Host "==== WINDOWS DECRAPIFIER ====" -ForegroundColor Cyan
    Write-Host "Essa função pode ser expandida para remover apps desnecessários." -ForegroundColor Yellow
    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host
}

# =========================
#        MENU
# =========================
do {
    Clear-Host
    Write-Host "================ MULTITOOL =================" -ForegroundColor Cyan
    Write-Host "1. Informações do Sistema"
    Write-Host "2. Teste de Rede"
    Write-Host "3. Logs de Erros"
    Write-Host "4. Flush DNS"
    Write-Host "5. Relatório de Saúde da Bateria"
    Write-Host "6. Windows Decrapifier"
    Write-Host "7. Atualizar Lenovo (System Update)"
    Write-Host "0. Sair"
    Write-Host "==========================================="
    $opcao = Read-Host "Selecione uma opção"

    switch ($opcao) {
        1 { Info-Sistema }
        2 { Teste-Rede }
        3 { Logs-Erros }
        4 { Flush-DNS }
        5 { Relatorio-Bateria }
        6 { Windows-Decrapifier }
        7 { Lenovo-Update }
        0 { break }
        default { Write-Host "Opção inválida. Pressione Enter para tentar novamente."; Read-Host }
    }
} while ($true)
