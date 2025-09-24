# ==============================
# MULTITOOL POWERSHELL
# ==============================

# ====== SUPORTE MULTILÍNGUE ======
$Idioma = Read-Host "Escolha o idioma / Choose language (PT/EN)"
if ($Idioma -ne "EN") { $Idioma = "PT" }

function Texto {
    param([string]$chave)
    $pt = @{
        menu = "==== 🛠️ MULTITOOL IT ===="
        sair = "0. Sair"
        voltar = "🔙 Pressione Enter para voltar ao menu..."
        opcao_invalida = "❌ Opção inválida!"
        admin = "⚠️ Este script precisa ser executado com privilégios de Administrador."
        rede = "==== 🔧 TESTE DE REDE ===="
        log_salvo = "📝 Log salvo em:"
        bateria = "==== 🔋 RELATÓRIO DE BATERIA ===="
        relatorio_salvo = "Relatório salvo em:"
        erro_bateria = "Erro ao gerar ou abrir o relatório de bateria:"
        sistema = "==== 💻 INFORMAÇÕES DO SISTEMA ===="
        info_exportada = "Informações do sistema exportadas para:"
        erro_sistema = "Erro ao exportar ou abrir as informações do sistema:"
        multimidia = "==== 🎤 TESTE MULTIMÍDIA (CÂMERA, MICROFONE, SPEAKER) ===="
        cameras = "[📷 Câmeras detectadas]"
        abrindo_camera = "Abrindo aplicativo de Câmera..."
        erro_camera = "Erro ao abrir a Câmera."
        microfones = "[🎙️ Microfones detectados]"
        abrindo_microfone = "Abrindo configurações de microfone..."
        erro_microfone = "Erro ao abrir configurações."
        altofalantes = "[🔊 Alto-falantes detectados]"
        tocando_som = "Tocando som de teste..."
        erro_som = "Erro ao tocar som:"
        arquivo_som = "Arquivo de som não encontrado."
        faststartup = "==== ⚡ GERENCIAR FAST STARTUP ===="
        ativar = "1. Ativar Fast Startup + Hibernação"
        desativar = "2. Desativar Fast Startup + Hibernação"
        voltar_menu = "0. Voltar ao menu"
        ativados = "✅ Fast Startup e Hibernação ATIVADOS."
        desativados = "✅ Fast Startup e Hibernação DESATIVADOS."
        erro_ativar = "❌ Erro ao ativar:"
        erro_desativar = "❌ Erro ao desativar:"
        thin = "==== 🚚 EXECUTAR THIN INSTALLER ===="
        thin_nao = "Thin Installer não encontrado. Instalando..."
        erro_thin = "Erro ao instalar Thin Installer:"
        executando_thin = "Executando Thin Installer com repositório:"
        thin_ok = "Atualizações aplicadas com sucesso."
        erro_exec_thin = "Erro ao executar Thin Installer:"
        portcode = "==== 🔑 INSTALAR PORTCODE LENOVO ===="
        baixando_portcode = "Baixando instalador Portcode..."
        executando_portcode = "Instalando Portcode em modo silencioso..."
        erro_portcode = "Erro ao instalar Portcode:"
        escolha = "Escolha uma opção"
    }
    $en = @{
        menu = "==== 🛠️ MULTITOOL IT ===="
        sair = "0. Exit"
        voltar = "🔙 Press Enter to return to menu..."
        opcao_invalida = "❌ Invalid option!"
        admin = "⚠️ This script must be run as Administrator."
        rede = "==== 🔧 NETWORK TEST ===="
        log_salvo = "📝 Log saved at:"
        bateria = "==== 🔋 BATTERY REPORT ===="
        relatorio_salvo = "Report saved at:"
        erro_bateria = "Error generating or opening battery report:"
        sistema = "==== 💻 SYSTEM INFORMATION ===="
        info_exportada = "System information exported to:"
        erro_sistema = "Error exporting or opening system information:"
        multimidia = "==== 🎤 MULTIMEDIA TEST (CAMERA, MICROPHONE, SPEAKER) ===="
        cameras = "[📷 Detected Cameras]"
        abrindo_camera = "Opening Camera app..."
        erro_camera = "Error opening Camera."
        microfones = "[🎙️ Detected Microphones]"
        abrindo_microfone = "Opening microphone settings..."
        erro_microfone = "Error opening microphone settings."
        altofalantes = "[🔊 Detected Speakers]"
        tocando_som = "Playing test sound..."
        erro_som = "Error playing sound:"
        arquivo_som = "Test sound file not found."
        faststartup = "==== ⚡ MANAGE FAST STARTUP ===="
        ativar = "1. Enable Fast Startup + Hibernation"
        desativar = "2. Disable Fast Startup + Hibernation"
        voltar_menu = "0. Return to menu"
        ativados = "✅ Fast Startup and Hibernation ENABLED."
        desativados = "✅ Fast Startup and Hibernation DISABLED."
        erro_ativar = "❌ Error enabling:"
        erro_desativar = "❌ Error disabling:"
        thin = "==== 🚚 RUN THIN INSTALLER ===="
        thin_nao = "Thin Installer not found. Installing..."
        erro_thin = "Error installing Thin Installer:"
        executando_thin = "Running Thin Installer with repository:"
        thin_ok = "Updates applied successfully."
        erro_exec_thin = "Error running Thin Installer:"
        portcode = "==== 🔑 INSTALL LENOVO PORTCODE ===="
        baixando_portcode = "Downloading Portcode installer..."
        executando_portcode = "Installing Portcode silently..."
        erro_portcode = "Error installing Portcode:"
        escolha = "Choose an option"
    }
    if ($global:Idioma -eq "EN") { return $en[$chave] } else { return $pt[$chave] }
}

# --- VERIFICAÇÃO DE ADMINISTRADOR ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host (Texto "admin") -ForegroundColor Red
    Start-Sleep -Seconds 5
    exit
}

function Show-Menu {
    Clear-Host
    Write-Host (Texto "menu") -ForegroundColor Cyan
    Write-Host "1. 🔧 Teste de Rede (Ping) / Network Test"
    Write-Host "2. 🔋 Relatório de Bateria / Battery Report"
    Write-Host "3. 💻 Informações do Sistema / System Info"
    Write-Host "4. 🎤 Teste Multimídia / Multimedia Test"
    Write-Host "5. ⚡ Gerenciar Fast Startup / Manage Fast Startup"
    Write-Host "6. 🚚 Executar Thin Installer (Lenovo)"
    Write-Host "7. 🔑 Instalar Portcode Lenovo"
    Write-Host (Texto "sair")
    Write-Host "======================="
}

function Animacao-Carregando {
    param([string]$msg)
    Write-Host -NoNewline $msg
    for ($i = 0; $i -lt 3; $i++) {
        Write-Host -NoNewline "."
        Start-Sleep -Milliseconds 400
    }
    Write-Host ""
}

# --- 1. Teste de Rede (fixo com lista padrão) ---
function Teste-Rede {
    Clear-Host
    Write-Host (Texto "rede") -ForegroundColor Cyan
    $hosts = @("8.8.8.8","1.1.1.1","www.google.com","www.microsoft.com")
    $logPath = "$env:USERPROFILE\Desktop\log_ping.txt"
    Remove-Item -Path $logPath -ErrorAction SilentlyContinue

    foreach ($h in $hosts) {
        Write-Host "`n--- Testando $h ---" -ForegroundColor Yellow
        Animacao-Carregando "Ping"
        $result = Test-Connection -Count 4 -ComputerName $h
        $result | Format-Table Address, ResponseTime, IPV4Address -AutoSize
        $result | Out-File -Append -FilePath $logPath
    }

    Write-Host "`n" (Texto "log_salvo") " $logPath" -ForegroundColor Green
    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# --- 2. Relatório de Bateria ---
function Relatorio-Bateria {
    Clear-Host
    Write-Host (Texto "bateria") -ForegroundColor Cyan
    $path = "$env:USERPROFILE\Desktop\relatorio_bateria.html"
    try {
        Animacao-Carregando "Gerando relatório"
        powercfg /batteryreport /output $path
        Write-Host (Texto "relatorio_salvo") " $path" -ForegroundColor Green
        Start-Process $path
    } catch {
        Write-Host (Texto "erro_bateria") " $($_.Exception.Message)" -ForegroundColor Red
    }
    Read-Host (Texto "voltar") | Out-Null
}

# --- 3. Informações do Sistema ---
function Info-Sistema {
    Clear-Host
    Write-Host (Texto "sistema") -ForegroundColor Cyan
    $path = "$env:USERPROFILE\Desktop\info_sistema.txt"
    try {
        Animacao-Carregando "Exportando informações"
        systeminfo | Out-File -FilePath $path -Encoding utf8
        Write-Host (Texto "info_exportada") " $path" -ForegroundColor Green
        Start-Process notepad.exe $path
    } catch {
        Write-Host (Texto "erro_sistema") " $($_.Exception.Message)" -ForegroundColor Red
    }
    Read-Host (Texto "voltar") | Out-Null
}

# --- 4. Teste Multimídia ---
function Teste-Multimidia {
    Clear-Host
    Write-Host (Texto "multimidia") -ForegroundColor Cyan

    Write-Host "`n" (Texto "cameras") -ForegroundColor Yellow
    Get-CimInstance Win32_PnPEntity | Where-Object { $_.Name -match "Camera|Video" } | Select-Object Name, Status
    Write-Host (Texto "abrindo_camera") -ForegroundColor Green
    try { Start-Process "microsoft.windows.camera:" } catch { Write-Host (Texto "erro_camera") -ForegroundColor Red }

    Write-Host "`n" (Texto "microfones") -ForegroundColor Yellow
    Get-CimInstance Win32_SoundDevice | Where-Object { $_.ProductName -match "Microphone" -or $_.Name -match "Microphone" } | Select-Object Name, Status
    Write-Host (Texto "abrindo_microfone") -ForegroundColor Green
    try { Start-Process ms-settings:privacy-microphone } catch { Write-Host (Texto "erro_microfone") -ForegroundColor Red }

    Write-Host "`n" (Texto "altofalantes") -ForegroundColor Yellow
    Get-CimInstance Win32_SoundDevice | Select-Object Name, Status
    Write-Host (Texto "tocando_som") -ForegroundColor Green
    try {
        [console]::beep(800, 500)
        $sound = "$env:WINDIR\Media\Windows Notify.wav"
        if (Test-Path $sound) {
            (New-Object Media.SoundPlayer $sound).PlaySync()
        } else {
            Write-Host (Texto "arquivo_som") -ForegroundColor Yellow
        }
    } catch {
        Write-Host (Texto "erro_som") " $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# --- 5. Gerenciar Fast Startup ---
function Gerenciar-FastStartup {
    Clear-Host
    Write-Host (Texto "faststartup") -ForegroundColor Cyan
    Write-Host (Texto "ativar")
    Write-Host (Texto "desativar")
    Write-Host (Texto "voltar_menu")
    $opt = Read-Host (Texto "escolha")

    switch ($opt) {
        "1" {
            try {
                Animacao-Carregando "Ativando"
                powercfg -h on
                Write-Host "`n" (Texto "ativados") -ForegroundColor Green
            } catch {
                Write-Host "`n" (Texto "erro_ativar") " $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "2" {
            try {
                Animacao-Carregando "Desativando"
                powercfg -h off
                Write-Host "`n" (Texto "desativados") -ForegroundColor Yellow
            } catch {
                Write-Host "`n" (Texto "erro_desativar") " $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        default { return }
    }

    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# --- 6. Thin Installer (com checagem antes/depois) ---
function Executar-ThinInstaller {
    Clear-Host
    Write-Host (Texto "thin") -ForegroundColor Cyan

    $ThinUrl = "https://github.com/davidcoelho-we/Ithelpertool/raw/main/lenovo_thininstaller_1.04.02.00024%20(1).exe"
    $ThinInstaller = "$env:TEMP\ThinInstallerSetup.exe"
    $ThinPath = "C:\Program Files (x86)\Lenovo\ThinInstaller\ThinInstaller.exe"

    function Testa-ThinInstaller {
        return (Test-Path $ThinPath)
    }

    if (Testa-ThinInstaller) {
        Write-Host "⚠️ O Thin Installer já está instalado neste computador." -ForegroundColor Yellow
    }
    else {
        try {
            Write-Host "⬇️ Baixando instalador Thin Installer..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri $ThinUrl -OutFile $ThinInstaller

            Write-Host "▶️ Instalando Thin Installer em modo silencioso..." -ForegroundColor Green
            try {
                Start-Process -FilePath $ThinInstaller -ArgumentList "/S" -Wait -ErrorAction Stop
            } catch {
                Start-Process -FilePath $ThinInstaller -ArgumentList "/quiet" -Wait
            }

            if (Testa-ThinInstaller) {
                Write-Host "✅ Thin Installer instalado com sucesso." -ForegroundColor Green
            } else {
                Write-Host "❌ A instalação foi executada, mas o Thin Installer não foi detectado." -ForegroundColor Red
                return
            }
        } catch {
            Write-Host "❌ Erro ao instalar o Thin Installer: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    }

    try {
        Write-Host "🔄 Executando atualização automática com Thin Installer..." -ForegroundColor Yellow
        Start-Process -FilePath $ThinPath -ArgumentList "/CM -search R -action INSTALL -noreboot" -Wait
        Write-Host "✅ Atualizações Lenovo aplicadas." -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro ao executar o Thin Installer: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# --- 7. Portcode Lenovo (com checagem antes/depois) ---
function Instalar-Portcode {
    Clear-Host
    Write-Host (Texto "portcode") -ForegroundColor Cyan

    $PortUrl = "https://github.com/davidcoelho-we/Ithelpertool/raw/main/portcoderev2%20(4).exe"
    $PortInstaller = "$env:TEMP\PortcodeLenovo.exe"
    $PortName = "Portcode"

    function Testa-Portcode {
        $check = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*$PortName*" }
        if (-not $check) {
            $check = Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*$PortName*" }
        }
        return $check
    }

    if (Testa-Portcode) {
        Write-Host "⚠️ O Portcode já está instalado neste computador." -ForegroundColor Yellow
    }
    else {
        try {
            Write-Host (Texto "baixando_portcode") -ForegroundColor Yellow
            Invoke-WebRequest -Uri $PortUrl -OutFile $PortInstaller

            Write-Host (Texto "executando_portcode") -ForegroundColor Green
            try {
                Start-Process -FilePath $PortInstaller -ArgumentList "/S" -Wait -PassThru | Out-Null
            } catch {
                Start-Process -FilePath $PortInstaller -ArgumentList "/quiet" -Wait -PassThru | Out-Null
            }

            if (Testa-Portcode) {
                Write-Host "✅ Portcode instalado com sucesso em modo silencioso." -ForegroundColor Green
            }
            else {
                Write-Host "❌ A instalação foi executada, mas o Portcode não foi detectado." -ForegroundColor Red
            }

        } catch {
            Write-Host (Texto "erro_portcode") " $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

# ==============================
# Loop principal
# ==============================
do {
    Show-Menu
    $choice = Read-Host (Texto "escolha")
    switch ($choice) {
        "1" { Teste-Rede }
        "2" { Relatorio-Bateria }
        "3" { Info-Sistema }
        "4" { Teste-Multimidia }
        "5" { Gerenciar-FastStartup }
        "6" { Executar-ThinInstaller }
        "7" { Instalar-Portcode }
        "0" { break }
        default { Write-Host (Texto "opcao_invalida") -ForegroundColor Red; Start-Sleep -Seconds 2 }
    }
} while ($true)
