param(
  [Parameter(Mandatory=$true)][string]$BackendZipUrl,
  [Parameter(Mandatory=$true)][string]$DbServer,
  [Parameter(Mandatory=$true)][string]$DbUser,
  [Parameter(Mandatory=$true)][string]$DbPassword,
  [Parameter(Mandatory=$true)][string]$JwtSecret
)

$ErrorActionPreference = 'Stop'
$LogFile = 'C:\Deploy-FIFA2026-Backend.log'
Start-Transcript -Path $LogFile -Append

try {
  Install-WindowsFeature -Name Web-Server,Web-WebSockets,Web-Stat-Compression,Web-Dyn-Compression -IncludeManagementTools

  New-NetFirewallRule -DisplayName 'HTTP Backend' -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow -ErrorAction SilentlyContinue

  $temp = 'C:\Temp\fifa2026'
  New-Item -ItemType Directory -Force -Path $temp | Out-Null

  $nodeMsi = Join-Path $temp 'nodejs.msi'
  Invoke-WebRequest -Uri 'https://nodejs.org/dist/v20.15.1/node-v20.15.1-x64.msi' -OutFile $nodeMsi
  Start-Process msiexec.exe -ArgumentList "/i `"$nodeMsi`" /qn /norestart" -Wait

  $rewriteMsi = Join-Path $temp 'rewrite.msi'
  Invoke-WebRequest -Uri 'https://download.microsoft.com/download/D/D/9/DD9A82B0-52EF-40DB-8DAB-0D8BC6F1CF6B/rewrite_amd64_en-US.msi' -OutFile $rewriteMsi
  Start-Process msiexec.exe -ArgumentList "/i `"$rewriteMsi`" /qn /norestart" -Wait

  $iisnodeMsi = Join-Path $temp 'iisnode.msi'
  Invoke-WebRequest -Uri 'https://github.com/Azure/iisnode/releases/download/v0.2.26/iisnode-full-v0.2.26-x64.msi' -OutFile $iisnodeMsi
  Start-Process msiexec.exe -ArgumentList "/i `"$iisnodeMsi`" /qn /norestart" -Wait

  & "$env:windir\system32\inetsrv\appcmd.exe" unlock config -section:system.webServer/handlers
  & "$env:windir\system32\inetsrv\appcmd.exe" unlock config -section:system.webServer/modules

  $zip = Join-Path $temp 'fifa2026-api.zip'
  Invoke-WebRequest -Uri $BackendZipUrl -OutFile $zip
  Expand-Archive -Path $zip -DestinationPath 'C:\inetpub\wwwroot' -Force

  $appPath = 'C:\inetpub\wwwroot\fifa2026-api'
  Set-Location $appPath
  @"
DB_SERVER=$DbServer
DB_PORT=1433
DB_USER=$DbUser
DB_PASSWORD=$DbPassword
DB_NAME=FIFA2026Tickets
PORT=80
HOST=0.0.0.0
JWT_SECRET=$JwtSecret
JWT_EXPIRES_IN=7d
FRONTEND_URL=*
"@ | Set-Content -Path '.env' -Encoding ascii

  $acl = Get-Acl $appPath
  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule('IIS_IUSRS','FullControl','ContainerInherit,ObjectInherit','None','Allow')
  $acl.SetAccessRule($rule)
  Set-Acl $appPath $acl

  Import-Module WebAdministration
  if (Test-Path 'IIS:\Sites\Default Web Site') { Stop-Website -Name 'Default Web Site' -ErrorAction SilentlyContinue }
  if (-not (Test-Path 'IIS:\Sites\FIFA2026-API')) {
    New-Website -Name 'FIFA2026-API' -PhysicalPath $appPath -Port 80 -Force | Out-Null
  }
  Set-ItemProperty 'IIS:\AppPools\FIFA2026-API' -Name managedRuntimeVersion -Value ''
  iisreset

  Write-Host 'Backend configurado com sucesso.' -ForegroundColor Green
}
finally {
  Stop-Transcript
}
