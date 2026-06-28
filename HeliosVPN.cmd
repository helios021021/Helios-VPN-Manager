@echo off
title FLY WITH Helios VPN
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    powershell -WindowStyle Hidden -Command "Start-Process -FilePath '%~dpnx0' -Verb RunAs"
    exit /B
)
cd /d "%~dp0"
set "KLASOR=%~dp0"

powershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command "$lines = Get-Content '%~f0'; $start = $lines.IndexOf('# --- POWERSHELL KODU BASLANGICI ---'); $code = $lines[($start+1)..($lines.Count-1)] -join [Environment]::NewLine; Invoke-Expression $code"
exit /B

# --- POWERSHELL KODU BASLANGICI ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==========================================================
# --- OTOMATIK GUNCELLEME MOTORU (AUTO-UPDATER) ---
# ==========================================================
# 1. ADIM: Asagidaki rakam programin KENDI icindeki surumudur.
$MevcutSurum = "1.2" 
$VersionURL = "https://raw.githubusercontent.com/helios021021/Helios-VPN-Manager/main/version.txt"
$ScriptURL = "https://raw.githubusercontent.com/helios021021/Helios-VPN-Manager/main/HeliosVPN.cmd"

try {
    # GitHub'daki version.txt dosyasini oku
    $GitHubSurum = (Invoke-RestMethod -Uri $VersionURL -UseBasicParsing).Trim()
    
    # Eger GitHub'daki surum, programin icindeki surumden buyukse guncellemeyi tetikle
    if ([version]$GitHubSurum -gt [version]$MevcutSurum) {
        $Cevap = [System.Windows.Forms.MessageBox]::Show("Helios VPN icin yeni bir guncelleme bulundu! (v$GitHubSurum)`n`nSorunlarin cozulmesi icin simdi otomatik olarak indirilip kurulsun mu?", "Yeni Guncelleme", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Information)
        
        if ($Cevap -eq "Yes") {
            # Yeni dosyayi gecici bir isimle indir
            Invoke-WebRequest -Uri $ScriptURL -OutFile "$env:KLASOR\HeliosVPN_yeni.cmd" -UseBasicParsing
            
            # Programin acikken kendi kendini silemeyecegi icin, bu islemi yapacak bir taseron (bat) dosyasi olustur
            $UpdaterBat = "$env:KLASOR\guncelle.bat"
            $BatIcerik = "@echo off`ntimeout /t 2 /nobreak >nul`nmove /y `"$env:KLASOR\HeliosVPN_yeni.cmd`" `"$env:KLASOR\HeliosVPN.cmd`"`nstart `"`" `"$env:KLASOR\HeliosVPN.cmd`"`ndel `"%~f0`""
            Set-Content -Path $UpdaterBat -Value $BatIcerik
            
            # Guncelleyiciyi calistir ve eski programi aninda kapat
            Start-Process -FilePath $UpdaterBat -WindowStyle Hidden
            exit
        }
    }
} catch {
    # Internet yoksa veya GitHub'a ulasilamiyorsa hata verme, programi normal sekilde ac
}
# ==========================================================
# --- GUNCELLEME MOTORU BITISI ---
# ==========================================================

$form = New-Object System.Windows.Forms.Form
$form.Text = "FLY WITH Helios VPN"
$form.Size = New-Object System.Drawing.Size(460, 520)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::Black
$form.FormBorderStyle = "FixedDialog"

$colorYellow = [System.Drawing.Color]::Yellow
$colorGray = [System.Drawing.Color]::DimGray  
$fontBtn = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "FLY WITH HELIOS"
$lblTitle.Font = New-Object System.Drawing.Font("Consolas", 20, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = $colorYellow
$lblTitle.AutoSize = $true
$lblTitle.Location = New-Object System.Drawing.Point(90, 20)
$form.Controls.Add($lblTitle)

$lblDev = New-Object System.Windows.Forms.Label
$lblDev.Text = "GELISTIRICI: HELIOS"
$lblDev.Font = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
$lblDev.ForeColor = $colorYellow
$lblDev.AutoSize = $true
$lblDev.Location = New-Object System.Drawing.Point(130, 60)
$form.Controls.Add($lblDev)

$cmbServer = New-Object System.Windows.Forms.ComboBox
$cmbServer.Size = New-Object System.Drawing.Size(220, 30)
$cmbServer.Location = New-Object System.Drawing.Point(110, 100)
$cmbServer.BackColor = [System.Drawing.Color]::FromArgb(40,40,40)
$cmbServer.ForeColor = $colorYellow
$cmbServer.Items.AddRange(@("Romanya1", "Romanya2", "Hollanda1", "Hollanda2"))
$cmbServer.SelectedIndex = 0
$form.Controls.Add($cmbServer)

$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Text = "VPN AC"
$btnStart.Size = New-Object System.Drawing.Size(220, 50)
$btnStart.Location = New-Object System.Drawing.Point(110, 150)
$btnStart.BackColor = $colorGray
$btnStart.ForeColor = $colorYellow
$btnStart.Font = $fontBtn
$form.Controls.Add($btnStart)

$btnStop = New-Object System.Windows.Forms.Button
$btnStop.Text = "VPN BAGLANTI KES"
$btnStop.Size = New-Object System.Drawing.Size(220, 50)
$btnStop.Location = New-Object System.Drawing.Point(110, 220)
$btnStop.BackColor = $colorGray
$btnStop.ForeColor = $colorYellow
$btnStop.Font = $fontBtn
$form.Controls.Add($btnStop)

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "VPN CIKIS"
$btnExit.Size = New-Object System.Drawing.Size(220, 50)
$btnExit.Location = New-Object System.Drawing.Point(110, 290)
$btnExit.BackColor = $colorGray
$btnExit.ForeColor = $colorYellow
$btnExit.Font = $fontBtn
$form.Controls.Add($btnExit)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Size = New-Object System.Drawing.Size(400, 50)
$lblStatus.Location = New-Object System.Drawing.Point(30, 380)
$lblStatus.ForeColor = $colorYellow
$form.Controls.Add($lblStatus)

$btnStart.Add_Click({
    $baseDir = $env:KLASOR
    $exePath = Join-Path $baseDir "Engine\wireguard.exe"
    $confPath = Join-Path $baseDir "Engine\$($cmbServer.SelectedItem.ToString()).conf"
    
    $lblStatus.Text = "Baglaniyor..."
    $form.Refresh()
    
    taskkill /F /IM wireguard.exe /T >$null 2>&1
    Start-Process -FilePath $exePath -ArgumentList "/installtunnelservice `"$confPath`"" -WindowStyle Hidden
    
    Start-Sleep -Seconds 2
    $lblStatus.Text = "Durum: Baglandi"
})

$btnStop.Add_Click({
    taskkill /F /IM wireguard.exe /T >$null 2>&1
    
    $exePath = Join-Path $env:KLASOR "Engine\wireguard.exe"
    Start-Process -FilePath $exePath -ArgumentList "/uninstalltunnelservice" -WindowStyle Hidden -Wait
    
    ipconfig /flushdns >$null 2>&1
    $lblStatus.Text = "Durum: Baglanti Kesildi ve Servis Kaldirildi."
})

$btnExit.Add_Click({ $form.Close() })

$form.ShowDialog() | Out-Null
