variable "project" {
  description = "Identificador do projeto/carga."
  type        = string
  default     = "tik"
}

variable "environment" {
  description = "Ambiente do deploy."
  type        = string
  default     = "prd"
}

variable "location_app" {
  description = "Região da camada de aplicação."
  type        = string
  default     = "Central India"
}

variable "location_data" {
  description = "Região da camada de banco de dados."
  type        = string
  default     = "Australia East"
}

variable "admin_username" {
  description = "Usuário administrador das VMs frontend/backend."
  type        = string
  default     = "tftecadmin"
}

variable "admin_password" {
  description = "Senha administrador das VMs frontend/backend."
  type        = string
  sensitive   = true
}

variable "sql_admin_username" {
  description = "Usuário administrador da VM SQL e login SQL."
  type        = string
  default     = "adminsql"
}

variable "sql_admin_password" {
  description = "Senha do usuário adminsql da VM SQL e login SQL."
  type        = string
  sensitive   = true
}

variable "my_public_ip_cidr" {
  description = "Seu IP público em CIDR para liberar RDP. Exemplo: 200.200.200.200/32."
  type        = string
}

variable "vm_size" {
  description = "Tamanho das VMs. O guia usa Standard_B2s."
  type        = string
  default     = "Standard_B2s"
}

variable "enable_vm_extensions" {
  description = "Instala IIS/ARR/Node e baixa pacotes via Custom Script Extension. Deixe false se quiser configurar manualmente por RDP."
  type        = bool
  default     = false
}

variable "backend_zip_url" {
  description = "URL do pacote backend."
  type        = string
  default     = "https://stotfteccopaazure.blob.core.windows.net/copa2026/fifa2026-api.zip"
}

variable "frontend_zip_url" {
  description = "URL do pacote frontend."
  type        = string
  default     = "https://stotfteccopaazure.blob.core.windows.net/copa2026/fifa2026-web.zip"
}

variable "bacpac_url" {
  description = "URL do bacpac do banco."
  type        = string
  default     = "https://stotfteccopaazure.blob.core.windows.net/copa2026/FIFA2026Tickets.bacpac"
}

variable "jwt_secret" {
  description = "Segredo JWT usado no .env da API."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
  default = {
    workload    = "fifa2026-tickets"
    environment = "prd"
    managed_by  = "terraform"
  }
}
