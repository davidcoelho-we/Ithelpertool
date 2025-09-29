# ================= Multitool TI =================
# Autor: David / Ajustado com suporte multilíngue
# ===============================================

# --------- Configuração Idioma ---------
$Idioma = Read-Host "Selecione o idioma / Select language (PT/EN)"
if ($Idioma -eq "EN") { $Lang = "EN" } else { $Lang = "PT" }

function Texto($chave) {
    $dic = @{
        "menu" = @{
            "PT" = "🔧 Multitool de Suporte TI"
            "EN" = "🔧 IT Support Multitool"
        }
        "opcoes" = @{
            "PT" = @(
                "1 - Teste de Rede"
                "2 - Relatório de Bateria"
                "3 - Informações do Sistema"
                "4 - Teste Multimídia"
                "5 - Gerenciar Fast Startup"
                "6 - Lenovo Commercial Vantage"
                "7 - Ativar Lenovo Portcode"
                "8 - Desativar Lenovo Portcode"
                "9 - Decrapifier (Remover Lixo)"
                "0 - Sair"
            )
            "EN" = @(
                "1 - Network Test"
                "2 - Battery Report"
                "3 - System Information"
                "4 - Multimedia Test"
                "5 - Manage Fast Startup"
                "6 - Lenovo Commercial Vantage"
                "7 - Enable Lenovo Portcode"
                "8 - Disable Lenovo Portcode"
                "9 - Decrapifier (Remove Bloatware)"
                "0 - Exit"
            )
        }
        "voltar" = @{
            "PT" = "Pressione Enter para voltar ao menu..."
            "EN" = "Press Enter to return to the menu..."
        }
        "teste_rede" = @{
            "PT" = "🌐 Testando rede..."
            "EN" = "🌐 Testing network..."
        }
        "relatorio_bateria" = @{
            "PT" = "🔋 Gerando relatório de bateria..."
            "EN" = "🔋 Generating battery report..."
        }
        "info_sistema" = @{
            "PT" = "💻 Coletando informações do sistema..."
            "EN" = "💻 Collecting system information..."
        }
        "teste_multimidia" = @{
            "PT" = "🎤🎥 Testando multimídia..."
            "EN" = "🎤🎥 Testing multimedia..."
        }
        "faststartup" = @{
            "PT" = "⚡ Gerenciar Fast Startup"
            "EN" = "⚡ Manage Fast Startup"
        }
        "thin" = @{
            "PT" = "📥 Executando Lenovo Thin Installer..."
            "EN" = "📥 Running Lenovo Thin Installer..."
        }
        "vantage" = @{
            "PT" = "📥 Instalando Lenovo Commercial Vantage..."
            "EN" = "📥 Installing Lenovo Commercial Vantage..."
        }
        "ativar_portcode" = @{
            "PT" = "📥 Ativando Lenovo Portcode..."
            "EN" = "📥 Enabling Lenovo Portcode..."
        }
        "desativar_portcode" = @{
            "PT" = "🗑️ Desativando Lenovo Portcode..."
            "EN" = "🗑️ Disabling Lenovo Portcode..."
        }
        "baixando_vantage" = @{
            "PT" = "⬇️ Baixando Lenovo Commercial Vantage..."
            "EN" = "⬇️ Downloading Lenovo Commercial Vantage..."
        }
        "executando_vantage" = @{
            "PT" = "▶️ Executando instalador do Vantage..."
            "EN" = "▶️ Running Vantage installer..."
        }
        "erro_vantage" = @{
            "PT" = "❌ Erro ao executar o Lenovo Commercial Vantage. Certifique-se de ter permissões de administrador."
            "EN" = "❌ Error running Lenovo Commercial Vantage. Make sure you have administrator permissions."
        }
        "erro_portcode" = @{
            "PT" = "❌ Erro ao modificar o registro."
            "EN" = "❌ Error modifying the registry."
        }
    }
    return $dic[$chave][$Lang]
}

# --------- Funções Utilitárias ---------
function Animacao-Carregando {
    param([string]$Texto)
    Write-Host $Texto -NoNewline
    for ($i=0; $i -lt 3; $i++) {
        Start-Sleep -Milliseconds 400
        Write-Host "." -NoNewline
    }
    Write-Host ""
}

# --------- Módulos ---------

# 1 - Teste de Rede (lista fixa)
function Teste-Rede {
    Clear-Host
    Write-Host (Texto "teste_rede") -ForegroundColor Cyan

    $Hosts = @("8.8.8.8","1.1.1.1","google.com","microsoft.com")
    $LogFile = "$env:USERPROFILE\Desktop\log_ping.txt"
    "" | Out-File $LogFile

    foreach ($h in $Hosts) {
        Animacao-Carregando "Ping $h"
        try {
            $r = Test-Connection -ComputerName $h -Count 2 -ErrorAction Stop
            Write-Host "✅ $h OK" -ForegroundColor Green
            $r | Out-File $LogFile -Append
        } catch {
            Write-Host "❌ $h Falhou" -ForegroundColor Red
            "Falha ao pingar $h" | Out-File $LogFile -Append
        }
    }
    Write-Host "`nResultados salvos em: $LogFile"
    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# 2 - Relatório de Bateria
function Relatorio-Bateria {
    Clear-Host
    Write-Host (Texto "relatorio_bateria") -ForegroundColor Cyan
    $BatFile = "$env:USERPROFILE\Desktop\relatorio_bateria.html"
    powercfg /batteryreport /output $BatFile | Out-Null
    Start-Process $BatFile
    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# 3 - Info Sistema
function Info-Sistema {
    Clear-Host
    Write-Host (Texto "info_sistema") -ForegroundColor Cyan
    $SysFile = "$env:USERPROFILE\Desktop\info_sistema.txt"
    systeminfo | Out-File $SysFile
    notepad $SysFile
}

# 4 - Teste Multimídia
function Teste-Multimidia {
    Clear-Host
    Write-Host (Texto "teste_multimidia") -ForegroundColor Cyan

    # Câmera
    Write-Host "📷 Verificando câmeras instaladas..." -ForegroundColor Yellow
    Get-CimInstance Win32_PnPEntity | Where-Object { $_.Name -match "Camera" } | Select-Object Name
    Start-Process "microsoft.windows.camera:" -ErrorAction SilentlyContinue

    # Microfone
    Write-Host "🎤 Verificando microfones..." -ForegroundColor Yellow
    $Microfone = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*microphone*" -and $_.Status -eq "OK" }
    if ($Microfone) {
        Write-Host "✅ Dispositivo de microfone detectado e funcionando." -ForegroundColor Green
        Write-Host "▶️ Abrindo configurações de áudio para teste..." -ForegroundColor Green
        Write-Host "⚠️ Fale em seu microfone para verificar as ondas de som na tela que se abriu." -ForegroundColor Magenta
        
        Start-Process "ms-settings:sound" -ErrorAction SilentlyContinue
    } else {
        Write-Host "❌ Nenhum dispositivo de microfone detectado ou funcionando." -ForegroundColor Red
    }
    
    # Alto-falantes
    Write-Host "🔊 Verificando alto-falantes..." -ForegroundColor Yellow
    $AltoFalantes = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*audio*" -and $_.Status -eq "OK" }
    if ($AltoFalantes) {
        Write-Host "✅ Dispositivo de áudio detectado e funcionando." -ForegroundColor Green
        Write-Host "▶️ Reproduzindo um som de teste..." -ForegroundColor Green
        [console]::beep(1000,300)
    } else {
        Write-Host "❌ Nenhum dispositivo de áudio detectado ou funcionando." -ForegroundColor Red
    }

    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# 5 - Fast Startup
function Gerenciar-FastStartup {
    Clear-Host
    Write-Host (Texto "faststartup") -ForegroundColor Cyan
    Write-Host "1 - Ativar"  
    Write-Host "2 - Desativar"
    $opt = Read-Host "Escolha"
    if ($opt -eq "1") { powercfg -h on; Write-Host "✅ Ativado" }
    if ($opt -eq "2") { powercfg -h off; Write-Host "❌ Desativado" }
    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# 6 - Instalar Lenovo Commercial Vantage
function Instalar-Vantage {
    Clear-Host
    Write-Host (Texto "vantage") -ForegroundColor Cyan
    
    $WingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    $WingetInstaller = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"

    Write-Host "🔍 Verificando se o Winget está instalado..." -ForegroundColor Yellow
    if (-not (Get-Command "winget.exe" -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Winget não encontrado. Instalando..." -ForegroundColor Red
        try {
            Invoke-WebRequest -Uri $WingetUrl -OutFile $WingetInstaller -ErrorAction Stop
            Add-AppxPackage -Path $WingetInstaller -ErrorAction Stop
            Write-Host "✅ Winget instalado com sucesso!" -ForegroundColor Green
        } catch {
            Write-Host "❌ Erro ao instalar o Winget. Certifique-se de que a execução de scripts está permitida." -ForegroundColor Red
            Write-Host "`n" (Texto "voltar")
            Read-Host | Out-Null
            return
        }
    } else {
        Write-Host "✅ Winget já está instalado." -ForegroundColor Green
    }
    
    Write-Host "📥 Tentando instalar o Lenovo Commercial Vantage (via Winget)..." -ForegroundColor Cyan
    try {
        winget install --id "9N9F2D991T26" --source "msstore" -e -h
        Write-Host "✅ Instalação do Lenovo Commercial Vantage concluída." -ForegroundColor Green
        Write-Host "▶️ Abrindo Lenovo Commercial Vantage..." -ForegroundColor Green
        Start-Process "lenovo-vantage://main/vantage" -ErrorAction SilentlyContinue
    } catch {
        Write-Host "❌ Erro ao instalar o Lenovo Commercial Vantage. Tente executar o script como administrador." -ForegroundColor Red
    }

    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# 7 - Ativar Portcode Lenovo
function Ativar-Portcode {
    Clear-Host
    Write-Host (Texto "ativar_portcode") -ForegroundColor Cyan
    
    # Valores de registro para ativar o Portcode  
    $regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
    $regKeyLayouts = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts"
    $regValue = "Scancode Map"
    $regData = [byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x73,0x00,0x1d,0xe0,0x00,0x00,0x00,0x00)
    
    try {
        Set-ItemProperty -Path $regKey -Name $regValue -Type Binary -Value $regData -ErrorAction Stop
        Set-ItemProperty -Path $regKeyLayouts -Name $regValue -Type Binary -Value $regData -ErrorAction Stop
        Write-Host "✅ Lenovo Portcode ativado com sucesso! Reinicie o computador para aplicar as alterações." -ForegroundColor Green
    } catch {
        Write-Host (Texto "erro_portcode") $_.Exception.Message -ForegroundColor Red
    }

    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# 8 - Desativar Portcode Lenovo
function Desativar-Portcode {
    Clear-Host
    Write-Host (Texto "desativar_portcode") -ForegroundColor Cyan

    $regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
    $regKeyLayouts = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts"
    $regValue = "Scancode Map"
    
    try {
        Remove-ItemProperty -Path $regKey -Name $regValue -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $regKeyLayouts -Name $regValue -ErrorAction SilentlyContinue
        Write-Host "✅ Lenovo Portcode desativado com sucesso! Reinicie o computador para aplicar as alterações." -ForegroundColor Green
    } catch {
        Write-Host (Texto "erro_portcode") $_.Exception.Message -ForegroundColor Red
    }

    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# 9 - Executar Decrapifier
function Executar-Decrapifier {
    Clear-Host
    Write-Host "🗑️ Baixando e executando Decrapifier..." -ForegroundColor Cyan

    $scriptUrl = "https://raw.githubusercontent.com/limadvd/Ithelpertool/main/decrapifier.ps1"
    $tempFile = "$env:TEMP\decrapifier.ps1"

    try {
        Animacao-Carregando "Baixando script..."
        Invoke-WebRequest -Uri $scriptUrl -OutFile $tempFile -ErrorAction Stop
        Write-Host "✅ Download concluído." -ForegroundColor Green

        Write-Host "▶️ Executando script Decrapifier..." -ForegroundColor Yellow
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$tempFile`"" -Wait -NoNewWindow -ErrorAction Stop
        Write-Host "✅ Execução do Decrapifier finalizada." -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro ao baixar ou executar o script. Certifique-se de ter conexão com a internet e permissões de administrador." -ForegroundColor Red
        Write-Host "Detalhes do erro: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# --------- Menu Principal ---------
function Show-Menu {
    Clear-Host
    Write-Host (Texto "menu") -ForegroundColor Cyan
    (Texto "opcoes") | ForEach-Object { Write-Host $_ }
}

# --------- Loop ---------
do {
    Show-Menu
    $choice = Read-Host "Escolha / Choose"
    switch ($choice) {
        "1" { Teste-Rede }
        "2" { Relatorio-Bateria }
        "3" { Info-Sistema }
        "4" { Teste-Multimidia }
        "5" { Gerenciar-FastStartup }
        "6" { Instalar-Vantage }
        "7" { Ativar-Portcode }
        "8" { Desativar-Portcode }
        "9" { Executar-Decrapifier }
        "0" { break }
        default { Write-Host "Opção inválida" -ForegroundColor Red }
    }
} while ($true)
