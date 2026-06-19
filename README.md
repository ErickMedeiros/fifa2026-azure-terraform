# FIFA 2026 Tickets — Azure Terraform

Infraestrutura Terraform para o cenário **FIFA 2026 Tickets em 3 VMs**, seguindo o guia do evento TFTEC.

## Arquitetura provisionada

- Resource Group: `rg-prd-tik-cin-001`
- Região aplicação: **Central India**
- Região banco: **Australia East**
- 2 VNets:
  - `vnet-prd-inf-cin-001` — `10.20.0.0/16`
  - `vnet-prd-inf-aes-001` — `10.30.0.0/16`
- 3 subnets:
  - Frontend: `10.20.1.0/24`
  - Backend: `10.20.2.0/24`
  - Banco: `10.30.1.0/24`
- Peering global entre as VNets
- 2 NSGs associados às subnets
- 3 VMs `Standard_B2s` com IP público inicial:
  - `vm-prd-tk-fend-cin-001` — Windows Server 2022 + IIS/ARR
  - `vm-prd-tk-bend-cin-001` — Windows Server 2022 + IIS/iisnode/Node
  - `vm-prd-tk-data-aes-001` — SQL Server 2022 Developer on Windows Server 2022

## Estrutura do repositório

```text
.
├── versions.tf
├── variables.tf
├── locals.tf
├── main.tf
├── nsg.tf
├── compute.tf
├── extensions.tf
├── outputs.tf
├── terraform.tfvars.example
├── scripts/
│   ├── setup-backend.ps1
│   ├── setup-frontend.ps1
│   ├── setup-sql.ps1
│   └── hardening-remove-public-ip.ps1
└── .gitignore
```

## Como usar

### 1. Autenticar no Azure

```powershell
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

### 2. Preparar variáveis

Copie o exemplo:

```powershell
copy terraform.tfvars.example terraform.tfvars
```

Edite:

```hcl
admin_password      = "TroquePorUmaSenhaForte@2026"
sql_admin_password  = "Partiunuvem@2026"
my_public_ip_cidr   = "SEU_IP_PUBLICO/32"
jwt_secret          = "troque-por-uma-string-longa-aleatoria"

enable_vm_extensions = false
```

> Recomendado para primeira execução: manter `enable_vm_extensions = false` e configurar a aplicação via RDP, conforme o guia. Para usar as extensões, publique os scripts deste repositório no GitHub e ajuste as URLs `raw.githubusercontent.com` em `extensions.tf`.

### 3. Deploy

```powershell
terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

### 4. Ver outputs

```powershell
terraform output
```

Use os IPs públicos para RDP inicial e o `frontend_public_ip` para acessar a aplicação após a configuração.

## Observações importantes

1. O backend e o banco sobem com IP público no início para facilitar o laboratório.
2. Após validar a aplicação, remova o IP público do backend e do banco usando o script `scripts/hardening-remove-public-ip.ps1` ou ajustando o Terraform.
3. O arquivo `.env` da API fica na VM backend. Em produção, recomenda-se migrar segredos para Azure Key Vault com Managed Identity.
4. O import do `.bacpac` foi deixado como etapa assistida, pois normalmente é validado via SSMS/SqlPackage após a VM SQL estar pronta.

## Smoke test esperado

Após configurar frontend, backend e banco:

```powershell
$FRONT_IP = "<IP_FRONT>"
Invoke-WebRequest "http://$FRONT_IP" -UseBasicParsing | Select-Object StatusCode
Invoke-RestMethod "http://$FRONT_IP/api/health"
```

## Destroy

Para remover tudo:

```powershell
terraform destroy
```
