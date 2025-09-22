
# ==============================
# MULTITOOL POWERSHELL (ENGLISH)
# ==============================

# --- ADMIN CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script must be run as Administrator." -ForegroundColor Red
    Start-Sleep -Seconds 5
    exit
}

function Show-Menu {
    Clear-Host
    Write-Host "🛠️ ==== MULTITOOL IT MENU ==== 🛠️" -ForegroundColor Cyan
    Write-Host "🔧 1. Network Test (Ping)"
    Write-Host "🔋 2. Battery Report"
    Write-Host "💻 3. System Information (Export TXT)"
    Write-Host "🎙️ 4. Multimedia Test (Camera, Microphone, Speaker)"
    Write-Host "⚡ 5. Manage Fast Startup (Enable/Disable)"
    Write-Host "📦 6. Run Lenovo System Update (Silent)"
    Write-Host "❌ 0. Exit"
    Write-Host "==============================="
}

# ==============================
# Functions
# ==============================

function Network-Test {
    Clear-Host
    Write-Host "🔧 NETWORK TEST 🔧" -ForegroundColor Cyan
    $hosts = @()
    $logPath = "$env:USERPROFILE\Desktop\ping_log.txt"
    Remove-Item -Path $logPath -ErrorAction SilentlyContinue

    $manual = Read-Host "Do you want to enter host/IP manually? (Y/N)"
    if ($manual -match "^[yY]$") {
        while ($true) {
            $hostInput = Read-Host "Enter address or IP (e.g. 8.8.8.8 or www.google.com). Leave blank to stop"
            if ([string]::IsNullOrWhiteSpace($hostInput)) { break }
            $hosts += $hostInput
        }
    } else {
        $hosts = @("8.8.8.8","1.1.1.1","www.google.com","www.microsoft.com")
    }

    foreach ($h in $hosts) {
        Write-Host "`n--- Testing $h ---" -ForegroundColor Yellow
        $result = Test-Connection -Count 4 -ComputerName $h
        $result | Format-Table Address, ResponseTime, IPV4Address -AutoSize
        $result | Out-File -Append -FilePath $logPath
    }

    Write-Host "`nLog saved to: $logPath" -ForegroundColor Green
    Write-Host "`nPress Enter to return to menu..."
    Read-Host | Out-Null
}

function Battery-Report {
    Clear-Host
    Write-Host "🔋 BATTERY REPORT 🔋" -ForegroundColor Cyan
    $path = "$env:USERPROFILE\Desktop\battery_report.html"
    try {
        powercfg /batteryreport /output $path
        Write-Host "Report saved to: $path" -ForegroundColor Green
        Start-Process $path
    } catch {
        Write-Host "Error generating or opening battery report: $($_.Exception.Message)" -ForegroundColor Red
    }
    Read-Host "Press Enter to return to menu..." | Out-Null
}

function System-Info {
    Clear-Host
    Write-Host "💻 SYSTEM INFORMATION 💻" -ForegroundColor Cyan
    $path = "$env:USERPROFILE\Desktop\system_info.txt"
    try {
        systeminfo | Out-File -FilePath $path -Encoding utf8
        Write-Host "System info exported to: $path" -ForegroundColor Green
        Start-Process notepad.exe $path
    } catch {
        Write-Host "Error exporting or opening system info: $($_.Exception.Message)" -ForegroundColor Red
    }
    Read-Host "Press Enter to return to menu..." | Out-Null
}

function Multimedia-Test {
    Clear-Host
    Write-Host "🎙️ MULTIMEDIA TEST 🎙️" -ForegroundColor Cyan

    Write-Host "`n📷 [Detected Cameras]" -ForegroundColor Yellow
    Get-CimInstance Win32_PnPEntity | Where-Object { $_.Name -match "Camera|Video" } | Select-Object Name, Status
    Write-Host "Opening Camera app..." -ForegroundColor Green
    try { Start-Process "microsoft.windows.camera:" } catch { Write-Host "Camera app not found." -ForegroundColor Red }

    Write-Host "`n🎤 [Detected Microphones]" -ForegroundColor Yellow
    Get-CimInstance Win32_SoundDevice | Where-Object { $_.ProductName -match "Microphone" -or $_.Name -match "Microphone" } | Select-Object Name, Status
    Write-Host "Opening microphone settings..." -ForegroundColor Green
    try { Start-Process ms-settings:privacy-microphone } catch { Write-Host "Microphone settings not accessible." -ForegroundColor Red }

    Write-Host "`n🔊 [Detected Speakers]" -ForegroundColor Yellow
    Get-CimInstance Win32_SoundDevice | Select-Object Name, Status
    Write-Host "Playing test sound..." -ForegroundColor Green
    try {
        [console]::beep(800, 500)
        $sound = "$env:WINDIR\Media\Windows Notify.wav"
        if (Test-Path $sound) {
            (New-Object Media.SoundPlayer $sound).PlaySync()
        } else {
            Write-Host "Test sound file not found." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error playing sound: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "`nPress Enter to return to menu..."
    Read-Host | Out-Null
}

function Manage-FastStartup {
    Clear-Host
    Write-Host "⚡ MANAGE FAST STARTUP ⚡" -ForegroundColor Cyan
    Write-Host "1. Enable Fast Startup + Hibernate"
    Write-Host "2. Disable Fast Startup + Hibernate"
    Write-Host "0. Return to menu"
    $opt = Read-Host "Choose an option"

    switch ($opt) {
        "1" {
            try {
                powercfg -h on
                Write-Host "`n✅ Fast Startup and Hibernate ENABLED." -ForegroundColor Green
            } catch {
                Write-Host "`n❌ Error enabling Fast Startup: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "2" {
            try {
                powercfg -h off
                Write-Host "`n✅ Fast Startup and Hibernate DISABLED." -ForegroundColor Yellow
            } catch {
                Write-Host "`n❌ Error disabling Fast Startup: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        default { return }
    }

    Write-Host "`nPress Enter to return to menu..."
    Read-Host | Out-Null
}

function Run-SystemUpdate {
    Clear-Host
    Write-Host "📦 RUN LENOVO SYSTEM UPDATE 📦" -ForegroundColor Cyan

    $SystemUpdatePath = "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"

    if (-not (Test-Path $SystemUpdatePath)) {
        Write-Host "System Update not found. Please install Lenovo System Update first." -ForegroundColor Red
        return
    }

    Write-Host "Running System Update silently..." -ForegroundColor Green
    try {
        Start-Process -FilePath $SystemUpdatePath -ArgumentList "/CM -search R -action INSTALL -includerebootpackages 1,3,4 -nolicense -noicon" -Wait
        Write-Host "✅ Updates applied successfully." -ForegroundColor Green
    } catch {
        Write-Host "❌ Error running System Update: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "`nPress Enter to return to menu..."
    Read-Host | Out-Null
}

# ==============================
# Main Loop
# ==============================
do {
    Show-Menu
    $choice = Read-Host "Choose an option"
    switch ($choice) {
        "1" { Network-Test }
        "2" { Battery-Report }
        "3" { System-Info }
        "4" { Multimedia-Test }
        "5" { Manage-FastStartup }
        "6" { Run-SystemUpdate }
        "0" { break }
        default { Write-Host "Invalid option!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($true)
