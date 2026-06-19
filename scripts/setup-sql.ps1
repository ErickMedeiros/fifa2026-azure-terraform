param(
  [Parameter(Mandatory=$true)][string]$BacpacUrl
)

$ErrorActionPreference = 'Stop'
$LogFile = 'C:\Deploy-FIFA2026-SQL.log'
Start-Transcript -Path $LogFile -Append

try {
  New-NetFirewallRule -DisplayName 'SQL Server 1433' -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow -ErrorAction SilentlyContinue
  $temp = 'C:\Temp\fifa2026'
  New-Item -ItemType Directory -Force -Path $temp | Out-Null
  Invoke-WebRequest -Uri $BacpacUrl -OutFile 'C:\FIFA2026Tickets.bacpac'
  Write-Host 'Bacpac baixado em C:\FIFA2026Tickets.bacpac. Importe via SSMS ou SqlPackage.' -ForegroundColor Green
}
finally {
  Stop-Transcript
}
