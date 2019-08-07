#Windows %USERPROFILE%\.aws\credentials
#Linux $HOME/.aws/credentials

#Create a new user with the following permissions
# AmazonEC2FullAccess: required.
# AmazonS3FullAccess: required.
# AmazonDynamoDBFullAccess: required.
# AmazonRDSFullAccess: required.
# CloudWatchFullAccess: required.
# IAMFullAccess: required.

#Read bash parameters
echo "Initializing global variables"

#export AWS_ACCESS_KEY_ID=(your access key id)
#export AWS_SECRET_ACCESS_KEY=(your secret access key)
export AWS_DEFAULT_REGION="us-east-2"
export TF_VAR_terraform_aws_sg_cidr_blocks="0.0.0.0/0"
# Execute Terraform init, plan and apply
echo "Step8. Execute Terraform to create the infrastructure"
cd ..
cd terraform

terraform init

# terraform init \
#     -backend-config "storage_account_name=$TF_VAR_terraform_azure_storage_account_name" \
#     -backend-config "container_name=$TF_VAR_terraform_azure_storage_container_name" \
#     -backend-config "key=terraform.tfstate" \
#     -backend-config "access_key=$TF_VAR_terraform_azure_storage_account_key1"

terraform validate 

terraform plan -out tfdeployment.plan

#terraform apply -input=false -auto-approve

#Se comenta terraform destroy
#terraform destroy