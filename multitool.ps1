# ==============================
# MULTITOOL POWERSHELL
# ==============================

# --- VERIFICAÇÃO DE ADMINISTRADOR ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script precisa ser executado com privilégios de Administrador." -ForegroundColor Red
    Start-Sleep -Seconds 5
    exit
}

function Show-Menu {
    Clear-Host
    Write-Host "==== MULTITOOL IT ====" -ForegroundColor Cyan
    Write-Host "1. Teste de Rede (Ping)"
    Write-Host "2. Relatório de Bateria"
    Write-Host "3. Informações do Sistema (exportar TXT)"
    Write-Host "4. Teste Multimídia (Câmera, Microfone, Speaker)"
    Write-Host "5. Decrapifier (Limpeza e Otimização do Windows)"
    Write-Host "6. Atualização Silenciosa de Drivers (Lenovo Commercial Vantage)"
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

function Decrapifier {
    Clear-Host
    Write-Host "==== DECRAPIFIER (Limpeza e Otimização do Windows) ====" -ForegroundColor Cyan

    # DESINSTALAÇÃO DE APLICATIVOS INÚTEIS E LIMPEZA DA BARRA DE TAREFAS / TELEMETRIA & DO WINDOWS + REPLICAÇÃO PARA USUÁRIOS FUTUROS
    Write-Output "Iniciando desinstalacao de Bloatware"
    & ([scriptblock]::Create((irm "https://win11debloat.raphi.re/"))) -Silent -RunDefaults -RemoveW11Outlook -RemoveGamingApps -DisableDVR -DisableTelemetry -DisableBing -DisableSuggestions -DisableLockscreenTips -TaskbarAlignLeft -ShowSearchIconTb -HideTaskView -HideChat -DisableWidgets -DisableCopilot -DisableRecall -HideHome -HideGallery

    # POR ALGUMA RAZÃO O PARÂMETRO -Sysprep ACIMA FAZ COM QUE AS MUDANÇAS NA BARRA DE TAREFAS NÃO SE APLIQUEM EM TEMPO REAL, ISSO AQUI É PARA QUE TENHAM EFEITO
    Write-Output "Iniciando segundo run pro Task Bar"
    & ([scriptblock]::Create((irm "https://win11debloat.raphi.re/"))) -Silent -RemoveW11Outlook -RemoveGamingApps -DisableDVR -DisableTelemetry -DisableBing -DisableSuggestions -DisableLockscreenTips -TaskbarAlignLeft -ShowSearchIconTb -HideTaskView -HideChat -DisableWidgets -DisableCopilot -DisableRecall -HideHome -HideGallery
    

    write-host "Detecting McAfee"
    $mcafeeinstalled = "false"
    $InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    foreach($obj in $InstalledSoftware){
        $name = $obj.GetValue('DisplayName')
        if ($name -like "*McAfee*") {
            $mcafeeinstalled = "true"
        }
    }
    
    $InstalledSoftware32 = Get-ChildItem "HKLM:\Software\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall"
    foreach($obj32 in $InstalledSoftware32){
        $name32 = $obj32.GetValue('DisplayName')
        if ($name32 -like "*McAfee*") {
            $mcafeeinstalled = "true"
        }
    }
    
    if ($mcafeeinstalled -eq "true") {
        Write-Host "McAfee detected"
        
    # Baixa ferramenta de remoção
    Write-Host "Downloading McAfee Removal Tool"
    
    # Fonte do Download
    $URL = 'https://github.com/andrew-s-taylor/public/raw/main/De-Bloat/mcafeeclean.zip'
    $destination = 'C:\ProgramData\Debloat\mcafee.zip'
    Invoke-WebRequest -Uri $URL -OutFile $destination -Method Get
    Expand-Archive $destination -DestinationPath "C:\ProgramData\Debloat" -Force
    Write-host "Removing McAfee"
    
    # Encerra os Serviços
    Start-Process "C:\ProgramData\Debloat\Mccleanup.exe" -ArgumentList "-p StopServices,MFSY,PEF,MXD,CSP,Sustainability,MOCP,MFP,APPSTATS,Auth,EMproxy,FWdiver,HW,MAS,MAT,MBK,MCPR,McProxy,McSvcHost,VUL,MHN,MNA,MOBK,MPFP,MPFPCU,MPS,SHRED,MPSCU,MQC,MQCCU,MSAD,MSHR,MSK,MSKCU,MWL,NMC,RedirSvc,VS,REMEDIATION,MSC,YAP,TRUEKEY,LAM,PCB,Symlink,SafeConnect,MGS,WMIRemover,RESIDUE -v -s"
    Write-Host "McAfee Removal Tool has been run"
    
    }
    
    # REMOVE O OFFICE 365 PRÉ-INSTALADO
    Write-Output "Iniciando desinstalacao de O365 OEM"
    
    $registryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    $subkeys = Get-ChildItem -Path $registryPath
    
    foreach ($subkey in $subkeys) {
    
        $displayName = Get-ItemProperty -Path $subkey.PSPath -Name DisplayName -ErrorAction SilentlyContinue
        $uninstallString = Get-ItemProperty -Path $subkey.PSPath -Name UninstallString -ErrorAction SilentlyContinue
    
        if ($displayName -and $displayName.DisplayName -like "*OneNote*" -or $displayName.DisplayName -like "*365*" -and $uninstallString.UninstallString) {
            
            Write-Output "Found: $($displayName.DisplayName)"
            Write-Output "Uninstalling using: $($uninstallString.UninstallString)"
            & $uninstallString.UninstallString /quiet /norestart
            Write-Output "Deleting registry entry: $($subkey.PSPath)"
            Remove-Item -Path $subkey.PSPath -Recurse -Force
        }
    }
    
    
    # REMOVE O ONE DRIVE DE TODOS OS USUÁRIOS (Peguei do Git)
    Write-Output "Iniciando desinstalacao de OneDrive"
    
    Function Get-LogDir{
        Try
        {
            $TS = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
            If ($TS.Value("LogPath") -ne "")
            {
                $LogDir = $TS.Value("LogPath")
            }
            Else
            {
                $LogDir = $TS.Value("_SMSTSLogPath")
            }
        }
        Catch
        {
            $LogDir = $env:TEMP
        }
    
        Return $LogDir
    }
    
    Function Remove-OneDrive{
    
    reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
    
    New-PSDrive -name Default -Psprovider Registry -root HKEY_USERS\Default >> $null
    $Regkey  = "Default:\Software\Microsoft\Windows\CurrentVersion\Run"
    
    Remove-ItemProperty -Path $Regkey -Name OneDriveSetup
    Write-Information "OneDriveSetup.exe removed"
    Remove-PSDrive -Name Default >> $null
    
    reg unload "hku\Default"
    
    }
    
    $OSBuildNumber = Get-WmiObject -Class "Win32_OperatingSystem" | Select-Object -ExpandProperty BuildNumber
    if ($OSBuildNumber -le "17134") {
                Remove-Item -Path "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Onedrive.lnk" -Force
    }
    
    $LogDir = Get-LogDir
    Start-Transcript "$LogDir\OSD-Remove-OneDrive.log"
    Write-Information "$(Get-Date -UFormat %R)"
    Remove-OneDrive
    Write-Information "$(Get-Date -UFormat %R)"
    Stop-Transcript
    
    # Remove o atalho do Microsoft EDGE de todos as Áreas de Trabalho
    $publicDesktopPath = "C:\Users\Public\Desktop"
    $edgeShortcutName = "Microsoft Edge.lnk"
    $edgeShortcutPath = Join-Path -Path $publicDesktopPath -ChildPath $edgeShortcutName
    if (Test-Path -Path $edgeShortcutPath) {
        Remove-Item -Path $edgeShortcutPath -Force
        Write-Host "Icone do Edge removido do Desktop."
    } else {
        Write-Host "Icone do Edge não encontrado para remover."
    }
    
    # CONFIGURA BARRA DE TAREFAS PARA TODOS OS USUÁRIOS
    Write-Output "Iniciando padronização de Barra de tarefas..."
    If(Test-Path "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml") {
    Remove-Item "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"
    }
    
    $blankjson = @'
    <?xml version="1.0" encoding="utf-8"?>
    <LayoutModificationTemplate
        xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
        xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
        xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
        xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
        Version="1">
        <CustomTaskbarLayoutCollection PinListPlacement="Replace">
            <defaultlayout:TaskbarLayout>
                <taskbar:TaskbarPinList>
                    <taskbar:DesktopApp DesktopApplicationID="Microsoft.Windows.Explorer"/>
                    <taskbar:DesktopApp DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk"/>
                </taskbar:TaskbarPinList>
            </defaultlayout:TaskbarLayout>
        </CustomTaskbarLayoutCollection>
    </LayoutModificationTemplate>
    
    $blankjson | Out-File "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml" -Encoding utf8 -Force
    
    
    # AJUSTES ADICIONAIS
    # Desabilita algumas Tarefas no Gerenciador de Tarefas que são desnecessárias.
    Write-Host "Desabilitando tarefas desnecessárias..."
    
    $toDisableTasks = @(
        "XblGameSaveTaskLogon",
        "XblGameSaveTask",
        "Consolidator",
        "UsbCeip",
        "DmClient",
        "DmClientOnScenarioDownload"
    )
    
    foreach ($task in $toDisableTasks) {
        if ($null -ne $task){
            Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
        }
    }
    
    # Desabilita o serviço de diagnostico e rastreamento do Windows
    Write-Output "Desabilitando serviço de diagnostico do Windows"
    Stop-Service "DiagTrack"
    Set-Service "DiagTrack" -StartupType Disabled
    
    # DEFINE TODAS AS POLÍTICAS
    Invoke-Command -ScriptBlock {
        powershell -ExecutionPolicy Bypass -Command {
    
    function Install-PSModule {
        param(
            [Parameter(Position = 0, Mandatory = $true)]
            [String[]]$Modules
        )
    
        Write-Output "`nVerificando modulos de Powershell..."
        try {
            # Configura o PowerShell para TLS 1.2 (https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/)
            if ([Net.ServicePointManager]::SecurityProtocol -notcontains 'Tls12' -and [Net.ServicePointManager]::SecurityProtocol -notcontains 'Tls13') {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            }
    
            # Instala o NuGet
            if (!(Get-PackageProvider -ListAvailable -Name 'NuGet' -ErrorAction Ignore)) {
                Write-Output 'Instalando NuGet...'
                Install-PackageProvider -Name 'NuGet' -MinimumVersion 2.8.5.201 -Force
            }
    
            # Estabelece o PSGallery como confiável
            Register-PSRepository -Default -InstallationPolicy 'Trusted' -ErrorAction Ignore
            if (!(Get-PSRepository -Name 'PSGallery' -ErrorAction Ignore).InstallationPolicy -eq 'Trusted') {
                Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted' | Out-Null
            }
        
            # Instala e importa os módulos necessários
            ForEach ($Module in $Modules) {
                if (!(Get-Module -ListAvailable -Name $Module -ErrorAction Ignore)) {
                    Write-Output "`nInstalando $Module..."
                    Install-Module -Name $Module -Force
                    Import-Module $Module
                }
            }
    
            Write-Output 'Modulos instalado.'
        }
        catch {
            Write-Warning 'Incapaz de instalar modulos.'
            Write-Warning $_
            exit 1
        }
    }
    
    $Modules = @('PolicyFileEditor')
    $ComputerPolicyFile = ($env:SystemRoot + '\System32\GroupPolicy\Machine\registry.pol')
    $UserPolicyFile = ($env:SystemRoot + '\System32\GroupPolicy\User\registry.pol')
    Set-Location -Path $env:SystemRoot
    
    # Define políticas do OOBE, OneDrive e EDGE.
    If (!(Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE)) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "OOBE" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisablePrivacyExperience" -Value 1 -PropertyType DWORD -Force | Out-Null
    }
    If (!(Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\EdgeUpdate)) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Name "EdgeUpdate" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "CreateDesktopShortcutDefault" -Value 0 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate" -Name "RemoveDesktopShortcut" -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate" -Name "RemoveDesktopShortcutDefault" -Value 1 -PropertyType DWORD -Force | Out-Null
    }
    If (!(Test-Path HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer)) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "DisableEdgeDesktopShortcutCreation" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "DisableEdgeDesktopShortcutCreation" -Value 1 -PropertyType DWORD -Force | Out-Null
    }
    
    If (!(Test-Path HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\OneDrive)) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "OneDrive" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1 -PropertyType DWORD -Force | Out-Null
    }
    
    # Define as políticas
    $ComputerPolicies = @(
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\Communications'; ValueName = 'ConfigureChatAutoInstall'; Data = '0'; Type = 'Dword' } # Disable Teams (personal) auto install (W11)
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; ValueName = 'Enabled'; Data = '0'; Type = 'Dword' } # Disable Windows Feedback Exp. program
        [PSCustomObject]@{Key = 'Software\Microsoft\Siuf\Rules'; ValueName = 'PeriodInNanoSeconds'; Data = '0'; Type = 'Dword' } # Stops Windows Feedback Exp. program from sending anonymous data
        [PSCustomObject]@{Key = 'Software\Policies\Microsoft\Windows\Windows Chat'; ValueName = 'ChatIcon'; Data = '2'; Type = 'Dword' } # Hide Chat icon by default (W11)
        [PSCustomObject]@{Key = 'Software\Policies\Microsoft\Windows\Windows Search'; ValueName = 'AllowCortana'; Data = '0'; Type = 'Dword' } # Disable Cortana
        [PSCustomObject]@{Key = 'Software\Policies\Microsoft\Windows\Windows Feeds'; ValueName = 'EnableFeeds'; Data = '0'; Type = 'Dword' } # Disable news/interests on taskbar
        [PSCustomObject]@{Key = 'Software\Policies\Microsoft\Windows\Windows Search'; ValueName = 'DisableWebSearch'; Data = '1'; Type = 'Dword' } # Disable Web search in Start (This removes Edge trying to creep in as recommendation in Search Box)
        [PSCustomObject]@{Key = 'Software\Policies\Microsoft\Windows\Windows Search'; ValueName = 'AllowCloudSearch'; Data = '0'; Type = 'Dword' } # Disable Cloud search in Start (This removes the annoying Azure notification to verify account in Search Box)
        [PSCustomObject]@{Key = 'Software\Policies\Microsoft\Windows\Windows Search'; ValueName = 'EnableDynamicContentInWSB'; Data = '0'; Type = 'Dword' } # Disable Dynamic Content in Search Box (This removes the Weather prediction or cake recipees, whatever, from the Search Box)
        [PSCustomObject]@{Key = 'Software\Policies\Microsoft\Windows\CloudContent'; ValueName = 'DisableCloudOptimizedContent'; Data = '1'; Type = 'Dword' } # Disable cloud consumer content
        [PSCustomObject]@{Key = 'Software\Policies\Microsoft\Windows\CloudContent'; ValueName = 'DisableConsumerAccountStateContent'; Data = '1'; Type = 'Dword' } # Disable cloud consumer content
        [PSCustomObject]@{Key = 'Software\Policies\Microsoft\Windows\CloudContent'; ValueName = 'DisableWindowsConsumerFeatures'; Data = '1'; Type = 'Dword' } # Disable Consumer Experiences
        [PSCustomObject]@{Key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; ValueName = 'EnableFirstLogonAnimation'; Data = '0'; Type = 'Dword' } # Disable First Login Animation
        [PSCustomObject]@{Key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE'; ValueName = 'DisablePrivacyExperience'; Data = '1'; Type = 'Dword' } # Disable Privacy Exp. on OOBE
        [PSCustomObject]@{Key = 'SOFTWARE\Policies\Microsoft\Windows\OOBE'; ValueName = 'DisablePrivacyExperience'; Data = '1'; Type = 'Dword' } # Disable Privacy Exp. on OOBE
        [PSCustomObject]@{Key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE'; ValueName = 'PrivacySettingsSkipped'; Data = '1'; Type = 'Dword' } # Skips Privacy Settings in OOBE
        [PSCustomObject]@{Key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE'; ValueName = 'PrivacyConsentStatus'; Data = '0'; Type = 'Dword' } # Skips Privacy Consent Settings in OOBE
        [PSCustomObject]@{Key = 'SOFTWARE\Policies\Microsoft\Windows\DataCollection'; ValueName = 'AllowTelemetry'; Data = '0'; Type = 'Dword' } # Disable Telemetry
        [PSCustomObject]@{Key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'; ValueName = 'AllowTelemetry'; Data = '0'; Type = 'Dword' } # Disable Telemetry
        [PSCustomObject]@{Key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy'; ValueName = 'TailoredExperiencesWithDiagnosticDataEnabled'; Data = '0'; Type = 'Dword' } # Disable Diagnostics
        [PSCustomObject]@{Key = 'Software\Policies\Microsoft\Edge'; ValueName = 'HideFirstRunExperience'; Data = '1'; Type = 'Dword' } # Disable EDGE First Run Experience, and also First Logon popup
        )
    
    $UserPolicies = @(
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; ValueName = 'TaskbarMn'; Data = '0'; Type = 'Dword' } # Disable Chat Icon (Nobody cares about this)
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'; ValueName = 'HideSCAMeetNow'; Data = '1'; Type = 'Dword' } # Disable Meet Now icon (W10)
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\Search'; ValueName = 'SearchboxTaskbarMode'; Data = '1'; Type = 'Dword' } # Set Search in taskbar to show icon only  
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; ValueName = 'DisableWindowsSpotlightFeatures'; Data = '1'; Type = 'Dword' } # Disable Windows Spotlight (Spotlight is only useful with Azure)
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; ValueName = 'ContentDeliveryAllowed'; Data = '0'; Type = 'Dword' } # Disable Content Delivery
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; ValueName = 'OemPreInstalledAppsEnabled'; Data = '0'; Type = 'Dword' } # Disable OEM Apps
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; ValueName = 'PreInstalledAppsEnabled'; Data = '0'; Type = 'Dword' } # Disable Pre-Installed Apps
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; ValueName = 'SilentInstalledAppsEnabled'; Data = '0'; Type = 'Dword' } # Disable Silent Installed Apps
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; ValueName = 'SystemPaneSuggestionsEnabled'; Data = '0'; Type = 'Dword' } # Disable Pane Suggestion Apps
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; ValueName = 'SubscribedContent-310093Enabled'; Data = '0'; Type = 'Dword' } # This possibly disables Windows "Finish setting up Windows" screens after updating, which freezes kiosk VCs
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; ValueName = 'SubscribedContent-338389Enabled'; Data = '0'; Type = 'Dword' } # Disable Pane Suggestion Apps
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\Holographic'; ValueName = 'FirstRunSucceeded'; Data = '0'; Type = 'Dword' } # Disable Holographic
        [PSCustomObject]@{Key = 'Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement'; ValueName = 'ScoobeSystemSettingEnabled'; Data = '0'; Type = 'Dword' } # Disables that Get More Out of Windows irritating popup
        [PSCustomObject]@{Key = 'Software\Policies\Microsoft\Windows\Explorer'; ValueName = 'DisableSearchBoxSuggestions'; Data = '1'; Type = 'Dword' } # Disables suggested content from Expanded Search Bar
        [PSCustomObject]@{Key = 'Software\Microsoft\InputPersonalization'; ValueName = 'RestrictImplicitTextCollection'; Data = '1'; Type = 'Dword' } # Disables implicit text collection
        [PSCustomObject]@{Key = 'Software\Microsoft\InputPersonalization'; ValueName = 'RestrictImplicitInkCollection'; Data = '1'; Type = 'Dword' } # Disables ink text collection info
        [PSCustomObject]@{Key = 'Software\Microsoft\Personalization\Settings'; ValueName = 'AcceptedPrivacyPolicy'; Data = '0'; Type = 'Dword' } # Whether it was accepted or not (Possibly removes prompt from Welcome Screen)
        [PSCustomObject]@{Key = 'Software\Policies\Microsoft\Windows\OneDrive'; ValueName = 'AutoStartEnabled'; Data = '0'; Type = 'Dword' } # Prevent OneDrive from booting
        )
    
    # Aplica políticas em todos os contextos
    Install-PSModule $Modules
    try {
        Write-Output 'Definindo politica...'
        $ComputerPolicies | Set-PolicyFileEntry -Path $ComputerPolicyFile -ErrorAction Stop
        $UserPolicies | Set-PolicyFileEntry -Path $UserPolicyFile -ErrorAction Stop
        gpupdate /force /wait:0 | Out-Null
        Write-Output 'Group policies set.'
    }
    catch {
        Write-Warning 'Erro em aplicar politicas.'
        Write-Output $_
    }
        }
    }

    Write-Host "`nLimpeza concluída. Reinicie a máquina para que todas as mudanças entrem em vigor." -ForegroundColor Green
    Read-Host "Pressione Enter para voltar ao menu..." | Out-Null
}

function Update-LenovoDriversWithVantage {
    Clear-Host
    Write-Host "==== ATUALIZAÇÃO SILENCIOSA DE DRIVERS (LENOVO VANTAGE) ====" -ForegroundColor Cyan
    
    # URL e caminhos
    $url = "https://download.lenovo.com/pccbbs/thinkvantage_en/lenovo_commercial_vantage_10_2506_39_0.zip"
    $downloadDir = "$env:TEMP\LenovoVantageInstaller"
    $zipFile = "$downloadDir\VantageInstaller.zip"
    $vantageClientExe = "$($env:ProgramFiles)\Lenovo\Commercial Vantage\LgcsClient.exe"

    # Passo 1: Verifica se o Lenovo Commercial Vantage já está instalado
    if (-not (Test-Path $vantageClientExe)) {
        Write-Host "Lenovo Commercial Vantage não encontrado. Baixando o instalador..."
        
        if (-not (Test-Path $downloadDir)) {
            New-Item -Path $downloadDir -ItemType Directory | Out-Null
        }

        try {
            Invoke-WebRequest -Uri $url -OutFile $zipFile -Method Get
            Expand-Archive -Path $zipFile -DestinationPath $downloadDir -Force
            Write-Host "Download e extração concluídos." -ForegroundColor Green
            
            # O nome do script de instalação pode variar
            $installScript = "$downloadDir\Install.ps1"
            if (Test-Path $installScript) {
                Write-Host "Iniciando a instalação silenciosa do Lenovo Commercial Vantage..."
                Start-Process -FilePath powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$installScript`"" -Verb RunAs -Wait -NoNewWindow
                Write-Host "Instalação do Lenovo Commercial Vantage concluída." -ForegroundColor Green
            } else {
                Write-Host "Erro: O script de instalação 'Install.ps1' não foi encontrado no pacote. A instalação não pode continuar." -ForegroundColor Red
                Read-Host "Pressione Enter para voltar ao menu..." | Out-Null
                return
            }
        }
        catch {
            Write-Host "Erro ao baixar ou instalar o Lenovo Commercial Vantage." -ForegroundColor Red
            Write-Host "Mensagem de erro: $($_.Exception.Message)" -ForegroundColor Red
            Read-Host "Pressione Enter para voltar ao menu..." | Out-Null
            return
        } finally {
            # Limpeza dos arquivos temporários
            if (Test-Path $downloadDir) {
                Remove-Item -Path $downloadDir -Recurse -Force | Out-Null
            }
        }
    } else {
        Write-Host "Lenovo Commercial Vantage já está instalado. Prosseguindo..." -ForegroundColor Yellow
    }

    # Passo 2: Executa a atualização silenciosa dos drivers
    if (Test-Path $vantageClientExe) {
        Write-Host "Iniciando a busca e instalação silenciosa de drivers, firmware e BIOS." -ForegroundColor Yellow
        Write-Host "Aguarde, este processo pode demorar alguns minutos..."
        
        # O comando Scan e Install do LgcsClient.exe
        Start-Process -FilePath $vantageClientExe -ArgumentList "-Scan -Install" -Wait -NoNewWindow

        Write-Host "Atualização concluída. Verifique as atualizações instaladas no Lenovo Commercial Vantage." -ForegroundColor Green
    } else {
        Write-Host "O caminho para LgcsClient.exe não foi encontrado após a instalação. A atualização não pode ser executada." -ForegroundColor Red
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
        "4" { Teste-Multimidia }
        "5" { Decrapifier }
        "6" { Update-LenovoDriversWithVantage }
        "0" { break }
        default { Write-Host "Opção inválida!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($true)
