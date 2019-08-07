variable "terraform_azure_resource_group" {}

variable "terraform_azure_region" {}

variable "terraform_aks_subnet_name" {
  type        = "string"
  default     = "DEVELOPMENT_DOCKERS"
}

variable "terraform_aks_vnet_name" {
  type        = "string"
  default     = "DICA_VNet"
}

variable "terraform_aks_vnet_rgname" {
  type        = "string"
  default     = "RG_DICA"
}

variable "terraform_azure_storage_account_name" {
  type = "string"
  default=""
}

variable "terraform_azure_storage_account_key1" {
  type = "string"
  default=""
}

variable "terraform_azure_storage_container_name" {
  type = "string"
  default=""
}

variable network_plugin {
    default = "kubenet"
}

variable "log_analytics_workspace_name"{
  type = "string"
  default="credomaticakslogmetrics"
}

variable "log_analytics_workspace_sku"{
  type = "string"
  default="PerGB2018"
}

variable "terraform_aks_dns_prefix" {
  type        = "string"
  description = "Master DNS Prefix"
  default     = "akstest"
}

variable "terraform_aks_agent_vm_count" {
  description = "AKS Agent VM count"
  default     = 2
}

variable "terraform_aks_vm_size" {
  type        = "string"
  description = "Azure VM size"
  default     = "Standard_D2_v2"
}

variable "terraform_azure_admin_name" {
  type        = "string"
  description = "Admin username"
  default     = "bacadmin"
}

variable "terraform_azure_ssh_key" {
  type        = "string"
  description = "SSH Key"
  default     = ""
}

variable "terraform_azure_service_principal_client_id" {
  type        = "string"
  description = "Service Principal Client ID"
  default     = ""
}

variable "terraform_azure_service_principal_client_secret" {
  type        = "string"
  description = "Service Principal Client Secret"
  default     = ""
}

variable "terraform_azure_service_principal_tenant_id" {
  type        = "string"
  description = "Service Principal Tenant Id"
  default     = ""
}

variable "terraform_azure_service_principal_subscription_id" {
  type        = "string"
  description = "Service Principal Subscription Id"
  default     = ""
}

variable "terraform_aks_kubernetes_version" {
  type        = "string"
  description = "Kubernetes Version"
  default     = "1.11.4"
}

variable "Componente" {
  type        = "map"
  default     = {
    Grupo       = "rg"
    Storage     = "sa"
    App         = "ap"
    Kubernetes  = "aks"
    APIMan      = "api"
    ServicePlan = "sp"
  }  
}

variable "Tipo" {
  type            = "map"
  default         = {
      Aplicacion      = "app"
      Infraestructura = "infra"
  }
}


variable "Ambiente" {
  type          = "map"
  default       = {
        Produccion    = "p"
        Certificacion = "c"
        Desarrollo    = "dev"
        Integracion   = "i"
  }
}
variable "Region" {
  type    = "string"
  default = "eu2"
}

variable "Codigo" {
  type    = "string"
  default = "report0"
}

variable "Version" {
  type    = "string"
  default = "01"
}

variable "RgState" {
  type    = "string"
  default = "RGEU2APPREP0C01"
}

variable "StateStorage" {
  type    = "string"
  default = "sa01cli"
}

variable "StateAccessKey" {
  type    = "string"
  default = "dGVzdDEyMw=="
}

