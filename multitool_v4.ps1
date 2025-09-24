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
                "6 - Lenovo Thin Installer"
                "7 - Lenovo Portcode"
                "0 - Sair"
            )
            "EN" = @(
                "1 - Network Test"
                "2 - Battery Report"
                "3 - System Information"
                "4 - Multimedia Test"
                "5 - Manage Fast Startup"
                "6 - Lenovo Thin Installer"
                "7 - Lenovo Portcode"
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
        "portcode" = @{
            "PT" = "📥 Instalando Lenovo Portcode..."
            "EN" = "📥 Installing Lenovo Portcode..."
        }
        "baixando_portcode" = @{
            "PT" = "⬇️ Baixando Portcode..."
            "EN" = "⬇️ Downloading Portcode..."
        }
        "executando_portcode" = @{
            "PT" = "▶️ Executando instalador do Portcode (silent)..."
            "EN" = "▶️ Running Portcode installer (silent)..."
        }
        "erro_portcode" = @{
            "PT" = "Erro ao instalar Portcode:"
            "EN" = "Error installing Portcode:"
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
    Get-CimInstance Win32_SoundDevice | Where-Object { $_.Name -match "Microphone" } | Select-Object Name
    Write-Host "⚠️ Para teste prático de gravação, use o Gravador de Voz do Windows." -ForegroundColor Magenta

    # Alto-falantes
    Write-Host "🔊 Verificando alto-falantes..." -ForegroundColor Yellow
    Get-CimInstance Win32_SoundDevice | Where-Object { $_.Name -match "Audio" } | Select-Object Name
    [console]::beep(1000,300)

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

# 6 - Thin Installer
function Executar-ThinInstaller {
    Clear-Host
    Write-Host (Texto "thin") -ForegroundColor Cyan
    $ThinUrl = "https://github.com/davidcoelho-we/Ithelpertool/raw/main/lenovo_thininstaller_1.04.02.00024%20(1).exe"
    $ThinExe = "$env:TEMP\ThinInstaller.exe"
    Invoke-WebRequest -Uri $ThinUrl -OutFile $ThinExe
    Start-Process -FilePath $ThinExe -ArgumentList "/S" -Wait
    Write-Host "✅ Thin Installer executado." -ForegroundColor Green
    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# 7 - Portcode Lenovo
function Instalar-Portcode {
    Clear-Host
    Write-Host (Texto "portcode") -ForegroundColor Cyan

    $PortUrl = "https://github.com/davidcoelho-we/Ithelpertool/raw/main/portcoderev2%20(4).exe"
    $PortInstaller = "$env:TEMP\PortcodeLenovo.exe"
    $PortName = "Portcode"

    function Testa-Portcode {
        $check = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*$PortName*" }
        if (-not $check) {
            $check = Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -like "*$PortName*" }
        }
        return $check
    }

    if (Testa-Portcode) {
        Write-Host "⚠️ O Portcode já está instalado." -ForegroundColor Yellow
    } else {
        try {
            Write-Host (Texto "baixando_portcode") -ForegroundColor Yellow
            Invoke-WebRequest -Uri $PortUrl -OutFile $PortInstaller

            Write-Host (Texto "executando_portcode") -ForegroundColor Green
            try {
                Start-Process -FilePath $PortInstaller -ArgumentList "/S" -Wait
            } catch {
                Start-Process -FilePath $PortInstaller -ArgumentList "/quiet" -Wait
            }

            if (Testa-Portcode) {
                Write-Host "✅ Portcode instalado com sucesso." -ForegroundColor Green
            } else {
                Write-Host "❌ Instalador executado, mas Portcode não detectado." -ForegroundColor Red
            }

        } catch {
            Write-Host (Texto "erro_portcode") $_.Exception.Message -ForegroundColor Red
        }
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
        "6" { Executar-ThinInstaller }
        "7" { Instalar-Portcode }
        "0" { break }
        default { Write-Host "Opção inválida" -ForegroundColor Red }
    }
} while ($true)
