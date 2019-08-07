/*
we recommend using
partial configuration with the "-backend-config" flag to "terraform init"
*/
terraform {
  backend "azurerm" { }
}

data "terraform_remote_state" "state" {
  backend = "azurerm"
  config = {
    storage_account_name = "${var.terraform_azure_storage_account_name}"
    container_name       = "${var.terraform_azure_storage_container_name}"
    key                  = "terraform.tfstate"
    access_key           = "${var.terraform_azure_storage_account_key1}"    
  }
}


# Vnet datasource
data "azurerm_subnet" "subnet" {
  name                 = "${var.terraform_aks_subnet_name}"
  virtual_network_name = "${var.terraform_aks_vnet_name}"
  resource_group_name  = "${var.terraform_aks_vnet_rgname}"
}

# Configure the Azure Provider
provider "azurerm" {
  subscription_id = "${var.terraform_azure_service_principal_subscription_id}"
  client_id       = "${var.terraform_azure_service_principal_client_id}"
  client_secret   = "${var.terraform_azure_service_principal_client_secret}"
  tenant_id       = "${var.terraform_azure_service_principal_tenant_id}"
  version = "~> 1.31"
}

# ACR
resource "azurerm_container_registry" "acr01" {
  name                = "acr${var.Region}${var.Tipo["Aplicacion"]}${var.Codigo}${var.Ambiente["Desarrollo"]}${var.Version}"
  resource_group_name = "${var.terraform_azure_resource_group}"
  location            = "${var.terraform_azure_region}"
  admin_enabled       = true
  sku                 = "Standard"
  provisioner "local-exec" {
        command = "cd ..  && cd scripts && source copy-containers.sh"
        environment = {
            ACR_NAME = "acr${var.Region}${var.Tipo["Aplicacion"]}${var.Codigo}${var.Ambiente["Desarrollo"]}${var.Version}"
            ACR_RG   = "${var.terraform_azure_resource_group}"
        }
  } 

  tags = {
    environment = "${var.Ambiente["Desarrollo"]}"
  }
}

# # VNET
# resource "azurerm_virtual_network" "vnet" {
#   name                = "aks-vnet"
#   location            = "${var.terraform_azure_region}"
#   resource_group_name = "${var.terraform_azure_resource_group}"
#   address_space       = ["10.1.0.0/16"]

#   tags = {
#     environment = "${var.Ambiente["Desarrollo"]}"
#   }
# }

# # SUBNET
# resource "azurerm_subnet" "subnet" {
#   name                 = "aksnodesubnet"
#   resource_group_name  = "${var.terraform_azure_resource_group}"
#   address_prefix       = "10.1.0.0/24"
#   virtual_network_name = "${azurerm_virtual_network.vnet.name}"  
# }

resource "azurerm_log_analytics_workspace" "test" {
    name                = "${var.log_analytics_workspace_name}"
    location            = "${var.terraform_azure_region}"
    resource_group_name = "${var.terraform_azure_resource_group}"
    sku                 = "${var.log_analytics_workspace_sku}"

    tags = {
      environment = "${var.Ambiente["Desarrollo"]}"
    }
}

resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = "${azurerm_log_analytics_workspace.test.location}"
    resource_group_name   = "${var.terraform_azure_resource_group}"
    workspace_resource_id = "${azurerm_log_analytics_workspace.test.id}"
    workspace_name        = "${azurerm_log_analytics_workspace.test.name}"

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}



# AKS
resource "azurerm_kubernetes_cluster" "test" {
  name                = "${var.Componente["Kubernetes"]}${var.Region}${var.Tipo["Aplicacion"]}${var.Codigo}${var.Ambiente["Desarrollo"]}${var.Version}"
  location            = "${var.terraform_azure_region}"
  resource_group_name = "${var.terraform_azure_resource_group}"
  dns_prefix          = "PREFIX"
  #kubernetes_version  = "${var.terraform_aks_kubernetes_version}"

  
  linux_profile {
    admin_username = "${var.terraform_azure_admin_name}"

    ssh_key {
      #key_data = "${var.terraform_azure_ssh_key}"
      key_data = "${file("${var.terraform_azure_ssh_key}")}"
    }
  }

  agent_pool_profile {
    name    = "agentpool"
    count   = "${var.terraform_aks_agent_vm_count}"
    vm_size = "${var.terraform_aks_vm_size}"
    os_type = "Linux"
    os_disk_size_gb = 30
    vnet_subnet_id = "${data.azurerm_subnet.subnet.id}"
  }

  addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = "${azurerm_log_analytics_workspace.test.id}"
        }
    }

  service_principal {
    client_id     = "${var.terraform_azure_service_principal_client_id}"
    client_secret = "${var.terraform_azure_service_principal_client_secret}"
  }

  network_profile {
        network_plugin = "${var.network_plugin}"
  }

  role_based_access_control {
        enabled = true
  }

  provisioner "local-exec" {
        command = "cd ..  && cd scripts && source helm-install.sh"
        environment = {
            AKS_NAME = "${var.Componente["Kubernetes"]}${var.Region}${var.Tipo["Aplicacion"]}${var.Codigo}${var.Ambiente["Desarrollo"]}${var.Version}"
            AKS_RG   = "${var.terraform_azure_resource_group}"
        }
  } 

  tags = {
    environment = "${var.Ambiente["Desarrollo"]}"
  }
}


#Azure Api Management 
resource "azurerm_api_management" "test" {
  name                = "asu-apim"
  resource_group_name = "${var.terraform_azure_resource_group}"
  location            = "${var.terraform_azure_region}"
  publisher_email     = "test@test.com"
  publisher_name      = "ArizonaStateUni"
  sku {
    name     = "Developer"
    capacity = 1
  }

  tags = {
     environment = "${var.Ambiente["Desarrollo"]}"
  }
}