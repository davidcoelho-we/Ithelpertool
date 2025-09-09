# ============================
#   MULTITOOL POWERSHELL
# ============================

function Info-Sistema {
    Clear-Host
    Write-Host "==== INFORMAÇÕES DO SISTEMA ====" -ForegroundColor Cyan

    $reportPath = "$env:USERPROFILE\Desktop\Info_Sistema.txt"
    systeminfo | Out-File -FilePath $reportPath -Encoding UTF8

    Write-Host "Relatório exportado para: $reportPath" -ForegroundColor Green
    Start-Process notepad.exe $reportPath

    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host | Out-Null
}

function Teste-Rede {
    Clear-Host
    Write-Host "==== TESTE DE REDE ====" -ForegroundColor Cyan

    $manual = Read-Host "Deseja digitar host(s)/IP(s) manualmente? (S/N) - se S digite 1 por linha; vazio/enter, 'done' ou 'n' termina a lista"

    if ($manual -match '^[sS]') {
        $hosts = @()
        while ($true) {
            $input = Read-Host "Digite o endereço ou IP (ex: 8.8.8.8 ou www.google.com). Deixe vazio ou 'done' para terminar"
            if ([string]::IsNullOrWhiteSpace($input) -or $input -match '^(done|stop|sair|n|no)$') { break }
            $hosts += $input.Trim()
        }
        if ($hosts.Count -eq 0) {
            Write-Host "Nenhum host informado. Usando lista padrão..." -ForegroundColor Yellow
            $hosts = @("8.8.8.8", "1.1.1.1", "www.google.com", "www.microsoft.com", "www.cloudflare.com")
        }
    } else {
        $hosts = @("8.8.8.8", "1.1.1.1", "www.google.com", "www.microsoft.com", "www.cloudflare.com")
    }

    foreach ($h in $hosts) {
        Write-Host "`n==== Testando: $h ====" -ForegroundColor Yellow

        try {
            $resolved = Resolve-DnsName -Name $h -ErrorAction Stop | Where-Object { $_.IPAddress } | Select-Object -ExpandProperty IPAddress -ErrorAction SilentlyContinue
            if ($resolved) {
                Write-Host "DNS: $h -> $($resolved -join ', ')"
            } else {
                Write-Host "Sem resolução DNS ou entrada inválida."
            }
        } catch {
            Write-Host "Resolve-DnsName não pôde resolver. Tentando ping direto..." -ForegroundColor DarkYellow
        }

        try {
            $resp = Test-Connection -ComputerName $h -Count 4 -ErrorAction Stop
            $resp | Select-Object Address, ResponseTime, IPV4Address | Format-Table -AutoSize
        } catch {
            Write-Host "Falha no ping para $h" -ForegroundColor Red
            try {
                Write-Host "`n>> Resultado nslookup:" -ForegroundColor DarkGray
                nslookup $h
            } catch {}
            try {
                Write-Host "`n>> Resultado tracert (limite 10):" -ForegroundColor DarkGray
                tracert -h 10 $h
            } catch {}
        }
    }

    Write-Host "`nTeste concluído. Pressione Enter para voltar ao menu..."
    Read-Host | Out-Null
}

function Logs-Erros {
    Clear-Host
    Write-Host "==== LOGS DE ERROS ====" -ForegroundColor Cyan
    Get-EventLog -LogName System -EntryType Error -Newest 20 | Format-Table TimeGenerated, Source, EventID, Message -AutoSize
    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host | Out-Null
}

function Flush-DNS {
    Clear-Host
    Write-Host "==== FLUSH DNS ====" -ForegroundColor Cyan
    ipconfig /flushdns
    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host | Out-Null
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

[1] Tempo ligado:
    - Desde: $uptime
    - Duração: $([math]::Round($uptimeDuration.TotalHours,2)) horas

[2] Saúde da bateria:
    - $batteryStatus

[3] Relatório detalhado:
    - Gerado em: $batteryReportPath

"@ | Out-File -FilePath $reportTextPath -Encoding UTF8

    Start-Process notepad.exe $reportTextPath
    Start-Process $batteryReportPath

    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host | Out-Null
}

function Lenovo-Update {
    Clear-Host
    Write-Host "==== ATUALIZAÇÃO LENOVO (SYSTEM UPDATE) ====" -ForegroundColor Cyan

    $logPath = "$env:USERPROFILE\Desktop\Lenovo_Update_Log.txt"
    $suPath = "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"

    if (-Not (Test-Path $suPath)) {
        Write-Host "Lenovo System Update não encontrado. Baixando e instalando..." -ForegroundColor Yellow
        $installer = "$env:TEMP\system_update.exe"
        Invoke-WebRequest -Uri "https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_5.08.02.exe" -OutFile $installer
        Start-Process -FilePath $installer -ArgumentList "/VERYSILENT" -Wait
    }

    Write-Host "Executando atualização silenciosa..." -ForegroundColor Green
    Start-Process -FilePath $suPath -ArgumentList "/CM -search A -action INSTALL -noicon" -Wait

    $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm"
    Add-Content -Path $logPath -Value "[$timestamp] Atualizações Lenovo aplicadas com sucesso."

    Start-Process notepad.exe $logPath
    Write-Host "`nPressione Enter para voltar ao menu..."
    Read-Host | Out-Null
}

function Show-Menu {
    Clear-Host
    Write-Host "================= MULTITOOL =================" -ForegroundColor Cyan
    Write-Host "1. Informações do Sistema"
    Write-Host "2. Teste de Rede"
    Write-Host "3. Logs de Erros"
    Write-Host "4. Flush DNS"
    Write-Host "5. Relatório de Saúde da Bateria"
    Write-Host "6. Atualizar Lenovo (System Update)"
    Write-Host "0. Sair"
    Write-Host "============================================="
}

do {
    Show-Menu
    $option = Read-Host "Selecione uma opção"

    switch ($option) {
        1 { Info-Sistema }
        2 { Teste-Rede }
        3 { Logs-Erros }
        4 { Flush-DNS }
        5 { Relatorio-Bateria }
        6 { Lenovo-Update }
        0 { Write-Host "Saindo..." }
        default { Write-Host "Opção inválida!" }
    }
} until ($option -eq 0)
