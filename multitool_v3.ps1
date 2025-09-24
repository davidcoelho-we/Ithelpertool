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
        testando = "--- Testando"
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
        abrindo_microfone = "Abrindo Gravador de Som..."
        erro_microfone = "Erro ao abrir o Gravador de Som."
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
        thin_baixando = "Baixando Thin Installer do GitHub..."
        erro_thin = "Erro ao instalar Thin Installer:"
        executando_thin = "Executando Thin Installer..."
        thin_ok = "Atualizações aplicadas com sucesso."
        erro_exec_thin = "Erro ao executar Thin Installer:"
        portcode = "==== 📦 INSTALAR PORTCODE LENOVO ===="
        baixando_portcode = "Baixando Portcode da Lenovo..."
        executando_portcode = "Executando instalador do Portcode..."
        erro_portcode = "Erro ao instalar Portcode:"
        escolha = "Escolha uma opção"
    }
    if ($global:Idioma -eq "EN") { return $pt[$chave] } else { return $pt[$chave] }
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
    Write-Host "7. 📦 Instalar Portcode Lenovo"
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

function Teste-Rede {
    Clear-Host
    Write-Host (Texto "rede") -ForegroundColor Cyan
    $hosts = @("8.8.8.8","1.1.1.1","www.google.com","www.microsoft.com")
    $logPath = "$env:USERPROFILE\Desktop\log_ping.txt"
    Remove-Item -Path $logPath -ErrorAction SilentlyContinue

    foreach ($h in $hosts) {
        Write-Host "`n" (Texto "testando") " $h ---" -ForegroundColor Yellow
        Animacao-Carregando "Ping"
        $result = Test-Connection -Count 4 -ComputerName $h
        $result | Format-Table Address, ResponseTime, IPV4Address -AutoSize
        $result | Out-File -Append -FilePath $logPath
    }

    Write-Host "`n" (Texto "log_salvo") " $logPath" -ForegroundColor Green
    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

function Teste-Multimidia {
    Clear-Host
    Write-Host (Texto "multimidia") -ForegroundColor Cyan

    Write-Host "`n" (Texto "cameras") -ForegroundColor Yellow
    Get-CimInstance Win32_PnPEntity | Where-Object { $_.Name -match "Camera|Video" } | Select-Object Name, Status
    Write-Host (Texto "abrindo_camera") -ForegroundColor Green
    try { Start-Process "microsoft.windows.camera:" } catch { Write-Host (Texto "erro_camera") -ForegroundColor Red }

    Write-Host "`n" (Texto "microfones") -ForegroundColor Yellow
    Get-CimInstance Win32_SoundDevice | Where-Object { $_.Name -match "Microphone" } | Select-Object Name, Status
    Write-Host (Texto "abrindo_microfone") -ForegroundColor Green
    try { Start-Process "soundrecorder:" } catch { Write-Host (Texto "erro_microfone") -ForegroundColor Red }

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

function Executar-ThinInstaller {
    Clear-Host
    Write-Host (Texto "thin") -ForegroundColor Cyan

    $ThinUrl = "https://github.com/davidcoelho-we/Ithelpertool/raw/main/lenovo_thininstaller_1.04.02.00024%20(1).exe"
    $InstallerPath = "$env:TEMP\LenovoThinInstaller.exe"

    try {
        Write-Host (Texto "thin_baixando") -ForegroundColor Yellow
        Invoke-WebRequest -Uri $ThinUrl -OutFile $InstallerPath
        Start-Process -FilePath $InstallerPath -ArgumentList "/S" -Wait
    } catch {
        Write-Host (Texto "erro_thin") " $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    Write-Host (Texto "executando_thin") -ForegroundColor Green
    try {
        Start-Process "C:\Program Files (x86)\Lenovo\ThinInstaller\Thininstaller.exe" -ArgumentList "/CM -search R -action INSTALL -noreboot" -Wait
        Write-Host (Texto "thin_ok") -ForegroundColor Green
    } catch {
        Write-Host (Texto "erro_exec_thin") " $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "`n" (Texto "voltar")
    Read-Host | Out-Null
}

function Instalar-Portcode {
    Clear-Host
    Write-Host (Texto "portcode") -ForegroundColor Cyan

    $PortUrl = "https://github.com/davidcoelho-we/Ithelpertool/raw/main/portcoderev2%20(4).exe"
    $PortInstaller = "$env:TEMP\PortcodeLenovo.exe"

    try {
        Write-Host (Texto "baixando_portcode") -ForegroundColor Yellow
        Invoke-WebRequest -Uri $PortUrl -OutFile $PortInstaller
        Write-Host (Texto "executando_portcode") -ForegroundColor Green
        Start-Process -FilePath $PortInstaller -ArgumentList "/S" -Wait
    } catch {
        Write-Host (Texto "erro_portcode") " $($_.Exception.Message)" -ForegroundColor Red
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
        default { Write-Host (Texto "opcao_invalida") -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($true)
