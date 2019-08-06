

# Get the id of the service principal configured for AKS
CLIENT_ID=$(az aks show --resource-group $TF_VAR_terraform_azure_resource_group --name $TF_VAR_terraform_azure_aks_account_name --query "servicePrincipalProfile.clientId" --output tsv)

# Get the ACR registry resource id
ACR_ID=$(az acr show --name $TF_VAR_terraform_azure_acr_account_name --resource-group $TF_VAR_terraform_azure_resource_group --query "id" --output tsv)

# Create role assignment
az role assignment create --assignee $CLIENT_ID --role Reader --scope $ACR_ID