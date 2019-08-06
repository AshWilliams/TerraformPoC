#Parameters
#- Service Principal appId.
#- Service Principal password.
#- Service Principal tenant.

#   - Componente:
  #  Grupo       = "rg"
  #  Storage     = "sa"
  #  App         = "ap"
  #  Kubernetes  = "aks"
  #  APIMan      = "api"
  #  ServicePlan = "sp"
#   - Tipo:
   #  Aplicacion      = "app"
   #  Infraestructura = "infra"
#   - Application Code (4 digits)
#   - Ambiente
#   - Version

#!/bin/bash

echo "-------------------How to use it---------------------------"
echo "appId  -> Service Principal ID"
echo "appPsw -> Service Principal Password"
echo "tenId  -> Service Principal Tenant ID"
echo "subId  -> Service Principal Subscription ID"
echo "app    -> Tipo"
echo "report   -> Application Code"
echo "dev      -> Ambiente"
echo "01     -> Version"
echo "-----------------------------------------------------------"



#Read bash parameters
echo "Initializing global variables"
SpAppId="xxxxxxxx-xxxx-xxxx-xxxx-daaee5ecfd1e"
SpPassword="xxxxxxxx-xxxx-xxxx-xxxx-252a3982fe12"
SpTenantId="xxxxxxxx-xxxx-xxxx-xxxx-9c6d2f62095b"
SpSubscriptionId="xxxxxxxx-xxxx-xxxx-xxxx-23a4340abf61"
tipo="app"
appcode="report"
ambiente="dev"
version="01"

az="az"

unameOut="$(uname -s)"
case "${unameOut}" in
    MINGW*)     az="az.cmd";;
esac

#####################################################################################
#Hardcoded region values
bacpregion="eu2"
azregion="eastus2"

#0. Login with Service Principal
echo "Step0. Login to Service Principal"
$az login --service-principal -u $SpAppId -p $SpPassword --tenant $SpTenantId

#1. Create Resource Group
componente="rg"
rgcompname="$componente""_AKS_""$bacpregion""_""$ambiente"
rgcompname=`echo "$rgcompname" | tr '[a-z]' '[A-Z]'`
echo "Checking resource group $rgcompname"
flagrg=$($az group exists -n $rgcompname)

if [ "$flagrg" = false ]
then
      echo "Step1. Creating resource group $rgcompname"
      $az group create -n $rgcompname -l $azregion
else
      echo "Resource group $rgcompname already exist...skip"
fi


# #2. Create Storage Account - Blob Storage for Terraform State
componente="sa"
sacompname="$componente$bcpregion$tipo$appcode$ambiente$version"
flagstor=$($az storage account check-name -n $sacompname --query nameAvailable)

if [ "$flagstor" = true ]
then
      echo "Step2. Creating storage account for terraform state $sacompname"
      tfstate="tfstate"
      $az storage account create -l "$azregion" --sku "Standard_LRS" -g "$rgcompname" -n "$sacompname" 

      echo "Step3. Creating storage container $tfstate"
      $az storage container create -n "$tfstate" --account-name "$sacompname" --fail-on-exist
else
      echo "Storage account $sacompname already exist...skip"
fi

# #3 Get Subnet ID
#echo "Step3. Get Subnet ID to be used by terraform for our AKS cluster"
#subid=$("$az" network vnet subnet show -g RG_DICA -n DEVELOPMENT_DOCKERS --vnet-name DICA_VNet --query id)

# #4. Get Storage key access to be used by terraform
echo "Step4. Get Storage key access to be used by terraform"
key1=$("$az" storage account keys list \
    --resource-group "$rgcompname" \
    --account-name $sacompname \
    --query "[0].value" | tr -d '"')


# #5. Registering and creating Key Vault
# #echo "Step5. Registering key vault provider"
# #componente="kv"
# #kvcompname="$componente$bcpregion$tipo$appcode$ambiente$version"
# #$az provider register -n Microsoft.KeyVault
# #$az keyvault create --name $kvcompname --resource-group $rgcompname --location $azregion

# #5. Generate public and provate key for AKS cluster
echo "Step6. Generate public and private key for AKS cluster"
ssk_key_name="id-ssh-aks-$ambiente$version"
ssh_key_password=`openssl rand -base64 32`
rm ~/.ssh/$ssk_key_name
rm ~/.ssh/$ssk_key_name.pub
ssh-keygen -t rsa -b 2048 -f ~/.ssh/$ssk_key_name -N "$ssh_key_password"

# #7. Registering secrets values to Azure KeyVault
# #echo "Step7. Registering secrets values to Azure KeyVault"
# #$az keyvault secret set --name $ssk_key_name --vault-name $kvcompname --file ~/.ssh/$ssk_key_name
# #az keyvault secret download --name shui --vault-name shui --file ~/.ssh/id_rsa
# #az keyvault secret show --vault-name myvault --name 'secret-name' | jq -r .value > ~/.ssh/mykey


# #6. Export Terraform variables
# echo "Step7. Export Terraform variables"
# #Subnet id
#TF_VAR_terraform_aks_subnet_id=$(echo $subid | tr '"' "'" )

# #Storage account variables
export TF_VAR_terraform_azure_resource_group=$rgcompname
export TF_VAR_terraform_azure_region=$azregion
export TF_VAR_terraform_azure_storage_account_name=$sacompname
export TF_VAR_terraform_azure_storage_account_key1=$key1
export TF_VAR_terraform_azure_storage_container_name=$tfstate

# #AKS variables
export TF_VAR_terraform_azure_service_principal_client_id="$SpAppId"
export TF_VAR_terraform_azure_service_principal_client_secret="$SpPassword"
export TF_VAR_terraform_azure_service_principal_tenant_id="$SpTenantId"
export TF_VAR_terraform_azure_service_principal_subscription_id="$SpSubscriptionId"
export TF_VAR_terraform_azure_ssh_key=~/.ssh/$ssk_key_name.pub

# #AKS and ACR variables
export TF_VAR_terraform_azure_aks_account_name="aks$bacpregion$tipo$appcode$ambiente$version"
export TF_VAR_terraform_azure_acr_account_name="acr$bacpregion$tipo$appcode$ambiente$version"



# #7. Execute Terraform init, plan and apply
echo "Step8. Execute Terraform to create the infrastructure"
cd ..
cd terraform

terraform init \
    -backend-config "storage_account_name=$TF_VAR_terraform_azure_storage_account_name" \
    -backend-config "container_name=$TF_VAR_terraform_azure_storage_container_name" \
    -backend-config "key=terraform.tfstate" \
    -backend-config "access_key=$TF_VAR_terraform_azure_storage_account_key1"

terraform validate 

terraform plan -out tfdeployment.plan

terraform apply -input=false -auto-approve


#8. Configure AKS with ACR
echo "Step9. Configure AKS with ACR"
# Get the id of the service principal configured for AKS
#CLIENT_ID=$("$az" aks show --resource-group $TF_VAR_terraform_azure_resource_group --name $TF_VAR_terraform_azure_aks_account_name --query "servicePrincipalProfile.clientId" --output tsv)

# Get the ACR registry resource id
#ACR_ID=$("$az" acr show --name $TF_VAR_terraform_azure_acr_account_name --resource-group $TF_VAR_terraform_azure_resource_group --query "id" --output tsv)

# Create role assignment
#$az role assignment create --assignee $CLIENT_ID --role Reader --scope $ACR_ID

#Se comenta terraform destroy
#terraform destroy