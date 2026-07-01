$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = Join-Path $ScriptDir "install.log"
$Tmp = Join-Path $ScriptDir "temp"

function Log {
    param([string]$Msg)
    $time = Get-Date -Format "HH:mm:ss"
    "$time | $Msg" | Out-File -FilePath $LogFile -Append
    Write-Host "[$time] $Msg"
}

# ==================== 1. Install Sunshine ====================
Log "=== 1/3: Install Sunshine ==="
try {
    $svc = Get-Service SunshineService -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq "Running") {
        Log "Sunshine already installed"
    } else {
        winget install "LizardByte.Sunshine" --accept-source-agreements --accept-package-agreements
        Log "Sunshine installed"
    }
} catch {
    Log "ERROR: $_"
    exit 1
}

# ==================== 2. Reset Password ====================
Log "=== Reset Password ==="
try {
    Stop-Service SunshineService -Force -ErrorAction SilentlyContinue
    Start-Sleep 2
    $s = "C:\Program Files\Sunshine\config\sunshine_state.json"
    if (Test-Path $s) { Remove-Item $s -Force }
    Set-Content "C:\Program Files\Sunshine\config\sunshine.conf" "" -Force
    Start-Service SunshineService
    Start-Sleep 3
    Log "Password: admin / admin"
} catch { Log "WARN: $_" }

# ==================== 3. Download + Install VDD ====================
Log "=== 3/3: Install Virtual Display Driver ==="
try {
    $installed = Get-PnpDevice -Class Display | Where-Object { $_.FriendlyName -match "Virtual Display" }
    if ($installed) {
        Log "Virtual Display already installed"
    } else {
        Stop-Service SunshineService -Force -ErrorAction SilentlyContinue

        New-Item -ItemType Directory -Path $Tmp -Force | Out-Null

        # Download nefcon
        Log "Downloading nefcon..."
        $nf = Join-Path $Tmp "nefcon.zip"
        Invoke-WebRequest -Uri "https://github.com/lordmulder/nefcon/releases/download/v2.1.0/nefcon_v2.1.0.zip" -OutFile $nf -UseBasicParsing
        Expand-Archive -Path $nf -DestinationPath (Join-Path $Tmp "nefcon") -Force

        # Download MttVDD driver-only
        Log "Downloading Virtual Display Driver..."
        $vd = Join-Path $Tmp "vdd.zip"
        Invoke-WebRequest -Uri "https://github.com/MountainTech/MTT-VDD/releases/download/v1.2.0/MttVDD_v1.2.0_x86_DriverOnly.zip" -OutFile $vd -UseBasicParsing
        Expand-Archive -Path $vd -DestinationPath (Join-Path $Tmp "vdd") -Force

        # Install driver
        $nefcon = Join-Path $Tmp "nefcon\x64\nefconw.exe"
        $inf = Join-Path $Tmp "vdd\MttVDD.inf"
        if ((Test-Path $nefcon) -and (Test-Path $inf)) {
            Log "Installing driver..."
            & $nefcon install $inf "Root\MttVDD"
            Start-Sleep 10
            Log "Virtual Display Driver installed"
        } else {
            Log "ERROR: nefcon or VDD file missing"
        }

        Start-Service SunshineService -ErrorAction SilentlyContinue
    }
} catch {
    Log "ERROR: $_"
    Start-Service SunshineService -ErrorAction SilentlyContinue
}

# ==================== Selesai ====================
$ip = "127.0.0.1"
try {
    $o = powershell -NoLogo -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { `$_.InterfaceAlias -ne 'Loopback' -and `$_.PrefixOrigin -ne 'WellKnown' } | Select-Object -ExpandProperty IPAddress"
    $ip = ($o.Trim() -split "`n")[0].Trim()
} catch {}

Log ""
Log "=========================================="
Log "  INSTALLATION DONE!"
Log "=========================================="
Log ""
Log "  PC IP     : $ip"
Log "  Web UI    : https://localhost:47990"
Log "  Login     : admin / admin"
Log ""

# Cleanup temp
Remove-Item $Tmp -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=== CARA PAKAI ==="
Write-Host "1. Buka https://localhost:47990 di browser"
Write-Host "   Login admin / admin"
Write-Host "2. Install Moonlight dari Play Store / App Store"
Write-Host "3. Buka Moonlight -> Tambah Host -> IP $ip"
Write-Host "4. Masukkan PIN dari HP ke tab PIN Sunshine"
Write-Host "5. Pilih Desktop -> Streaming!"
Write-Host ""
Write-Host "=== VIRTUAL DISPLAY ==="
Write-Host "Win+P -> Extend -> pilih VDD by MTT"
Write-Host ""

Read-Host "Press Enter to exit"
