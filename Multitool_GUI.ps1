
# ==============================
# MULTITOOL POWERSHELL COM GUI
# ==============================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Internacionalização ---
$Idioma = Read-Host "Escolha o idioma / Choose language (PT/EN)"

function Texto {
    param([string]$chave)
    $pt = @{
        titulo = "🛠️ MULTITOOL IT"
        ping = "🌐 Teste de Rede"
        bateria = "🔋 Relatório de Bateria"
        sistema = "💻 Informações do Sistema"
        multimidia = "🎙️ Teste Multimídia"
        fast = "⚡ Gerenciar Fast Startup"
        thin = "📦 Executar Thin Installer"
        sair = "❌ Sair"
    }
    $en = @{
        titulo = "🛠️ MULTITOOL IT"
        ping = "🌐 Network Test"
        bateria = "🔋 Battery Report"
        sistema = "💻 System Info"
        multimidia = "🎙️ Multimedia Test"
        fast = "⚡ Manage Fast Startup"
        thin = "📦 Run Thin Installer"
        sair = "❌ Exit"
    }
    if ($Idioma -eq "EN") { return $en[$chave] } else { return $pt[$chave] }
}

# --- Funções ---
function Teste-Rede {
    [System.Windows.Forms.MessageBox]::Show("Executando Teste de Rede...", "Ping")
}

function Relatorio-Bateria {
    $path = "$env:USERPROFILE\Desktop\relatorio_bateria.html"
    powercfg /batteryreport /output $path
    Start-Process $path
}

function Info-Sistema {
    $path = "$env:USERPROFILE\Desktop\info_sistema.txt"
    systeminfo | Out-File -FilePath $path -Encoding utf8
    Start-Process notepad.exe $path
}

function Teste-Multimidia {
    Start-Process "microsoft.windows.camera:"
    Start-Process ms-settings:privacy-microphone
    [console]::beep(800, 500)
}

function Gerenciar-FastStartup {
    $opt = [System.Windows.Forms.MessageBox]::Show("Ativar Fast Startup?", "Fast Startup", "YesNo")
    if ($opt -eq "Yes") {
        powercfg -h on
    } else {
        powercfg -h off
    }
}

function Executar-ThinInstaller {
    $ThinInstallerPath = "C:\Program Files (x86)\Lenovo\ThinInstaller\Thininstaller.exe"
    $RepositoryPath = "C:\ProgramData\Lenovo\ThinInstaller\Repository"
    if (-not (Test-Path $ThinInstallerPath)) {
        winget install Lenovo.ThinInstaller --silent --accept-package-agreements --accept-source-agreements
        Start-Sleep -Seconds 10
    }
    Start-Process -FilePath $ThinInstallerPath -ArgumentList "/CM -repository $RepositoryPath -search R -action INSTALL -noreboot" -Wait
}

# --- Interface Gráfica ---
$form = New-Object System.Windows.Forms.Form
$form.Text = (Texto "titulo")
$form.Size = New-Object System.Drawing.Size(400,400)
$form.StartPosition = "CenterScreen"

$buttons = @(
    @{text=(Texto "ping"); action={Teste-Rede}},
    @{text=(Texto "bateria"); action={Relatorio-Bateria}},
    @{text=(Texto "sistema"); action={Info-Sistema}},
    @{text=(Texto "multimidia"); action={Teste-Multimidia}},
    @{text=(Texto "fast"); action={Gerenciar-FastStartup}},
    @{text=(Texto "thin"); action={Executar-ThinInstaller}},
    @{text=(Texto "sair"); action={$form.Close()}}
)

$y = 20
foreach ($btn in $buttons) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $btn.text
    $button.Size = New-Object System.Drawing.Size(300,40)
    $button.Location = New-Object System.Drawing.Point(50,$y)
    $button.Add_Click($btn.action)
    $form.Controls.Add($button)
    $y += 50
}

$form.ShowDialog()
