param(
  [Parameter(Mandatory=$true)][string]$FrontendZipUrl,
  [Parameter(Mandatory=$true)][string]$BackendUrl
)

$ErrorActionPreference = 'Stop'
$LogFile = 'C:\Deploy-FIFA2026-Frontend.log'
Start-Transcript -Path $LogFile -Append

try {
  Install-WindowsFeature -Name Web-Server,Web-WebSockets,Web-Stat-Compression,Web-Dyn-Compression -IncludeManagementTools
  New-NetFirewallRule -DisplayName 'HTTP Frontend' -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow -ErrorAction SilentlyContinue
  New-NetFirewallRule -DisplayName 'HTTPS Frontend' -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow -ErrorAction SilentlyContinue

  $temp = 'C:\Temp\fifa2026'
  New-Item -ItemType Directory -Force -Path $temp | Out-Null

  $rewriteMsi = Join-Path $temp 'rewrite.msi'
  Invoke-WebRequest -Uri 'https://download.microsoft.com/download/D/D/9/DD9A82B0-52EF-40DB-8DAB-0D8BC6F1CF6B/rewrite_amd64_en-US.msi' -OutFile $rewriteMsi
  Start-Process msiexec.exe -ArgumentList "/i `"$rewriteMsi`" /qn /norestart" -Wait

  $arrMsi = Join-Path $temp 'arr.msi'
  Invoke-WebRequest -Uri 'https://download.microsoft.com/download/1/E/7/1E7B5BBA-3762-4A1D-B9B7-5BE2B9FBD901/requestRouter_amd64.msi' -OutFile $arrMsi
  Start-Process msiexec.exe -ArgumentList "/i `"$arrMsi`" /qn /norestart" -Wait

  Import-Module WebAdministration
  Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter 'system.webServer/proxy' -Name 'enabled' -Value 'True'

  $zip = Join-Path $temp 'fifa2026-web.zip'
  Invoke-WebRequest -Uri $FrontendZipUrl -OutFile $zip
  Expand-Archive -Path $zip -DestinationPath 'C:\inetpub\wwwroot' -Force

  $appPath = 'C:\inetpub\wwwroot\fifa2026-web'
  $webConfig = Join-Path $appPath 'web.config'
  (Get-Content $webConfig) -replace '__BACKEND_URL__', $BackendUrl | Set-Content $webConfig

  if (Test-Path 'IIS:\Sites\Default Web Site') { Stop-Website -Name 'Default Web Site' -ErrorAction SilentlyContinue }
  if (-not (Test-Path 'IIS:\Sites\FIFA2026-Web')) {
    New-Website -Name 'FIFA2026-Web' -PhysicalPath $appPath -Port 80 -Force | Out-Null
  }
  Set-ItemProperty 'IIS:\AppPools\FIFA2026-Web' -Name managedRuntimeVersion -Value ''
  iisreset

  Write-Host 'Frontend configurado com sucesso.' -ForegroundColor Green
}
finally {
  Stop-Transcript
}
