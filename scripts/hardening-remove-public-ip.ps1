param(
  [string]$ResourceGroupName = 'rg-prd-tik-cin-001'
)

$ErrorActionPreference = 'Stop'

$targets = @(
  'nic-vm-prd-tk-bend-cin-001',
  'nic-vm-prd-tk-data-aes-001'
)

foreach ($nicName in $targets) {
  $nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $nicName
  $nic.IpConfigurations[0].PublicIpAddress = $null
  Set-AzNetworkInterface -NetworkInterface $nic | Out-Null
  Write-Host "IP público removido da NIC $nicName" -ForegroundColor Green
}

Write-Host 'Ajuste também as regras de RDP nos NSGs para permitir acesso via jump host.' -ForegroundColor Yellow
