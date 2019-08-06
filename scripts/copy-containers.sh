
echo "#1. Set Variables from Azure Container Registry Origin"
docker_origin_url="cloud.docker.com"

echo "#2. Set Variables from Azure Container Registry Destiny"
acr_destiny_name=$ACR_NAME
acr_destiny_url="$acr_destiny_name.azurecr.io"

echo "#3. Set Variables of Docker base images"
container_report="kvncont/report-service:latest"


echo "#4. Get Credentiales username and password Origin Azure Container Registry"
docker_origin_username="dockeruser"
docker_origin_password="dockerpass"

echo "#5. Login to Origin Container Registry"
docker login $docker_origin_url -u $ $docker_origin_username -p $docker_origin_password

echo "#6. Pull Images"
docker pull $container_report

echo "#7. Tag images to destiny container registry"
docker tag $container_report $acr_destiny_url/$container_report


echo "#8. Get Credentiales username and password Origin Azure Container Registry"
acr_destiny_username=`az acr credential show -n $acr_destiny_name --query username`
acr_destiny_password=`az acr credential show -n $acr_destiny_name --query passwords[0].value`

echo "#9. Login to Destiny Container Registry"
docker login $acr_destiny_url -u $ $acr_destiny_username -p $acr_destiny_password

echo "#10. Push new images"
docker push $acr_destiny_url/$container_report


echo "$acr_destiny_url/$container_report"