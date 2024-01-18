# Configure-and-Secure-ACR-AKS-workloads
Configuring and Securing Containers and Kubernetes  

---

## Introduction
This depicts the deployment of a proof of concept using Azure Container Registry and Azure Kubernetes Service.  
This POC demonstrates the following:  
- Building an image using Dockerfile  
- Storing images using Azure Container Regsitry  
- Kubernetes configuration of using AKS  
- Configuring applicable security protocols to access container applications both internally and externally.  

---

## Services deployed  
There are the 2 primary services required for this project

![](/icons/kubernetesServices.jpeg)    ![](/icons/containerRegistry.png)  

---

## Steps (in summary)
1. Create an Azure Container Registry
2. Create a Dockerfile, build a container and push it to Azure Container Registry
3. Create an Azure Kubernetes Service cluster
4. Grant the AKS cluster permissions to access the ACR
5. Deploy an external service to AKS
6. Verify the you can access an external AKS-hosted service
7. Deploy an internal service to AKS
8. Verify the you can access an internal AKS-hosted service


*** 
***

## 1. Create an Azure Container Registry.    
* Create a res group <br>
az group create --name rg-a5-ACRAKS --location uksouth  <br>

* Create a new Azure Container Registry (ACR) instance <br>
az acr create --resource-group rg-a5-ACRAKS --name w2cA5ACR --sku Basic  

The above syntax initiates the deployment of a new instance of a container Resgistry.  
 
![](/img/Screenshotfrom2024-01-0823-36-11.png)  
<br>
![](/img/Screenshotfrom2024-01-0823-43-25.png)

*** 
***

## 2. Create a Dockerfile, build a container and push it to Azure Container Registry.    
Create a Dockerfile, build an image from the Dockerfile, and deploy the image to the ACR.  
- Create a Dockerfile (to create an Nginx-based image)  
echo FROM nginx > Dockerfile <br>
- Build an image from the Dockerfile
-build an image from the Dockerfile and push the image to the new ACR.  <br>
 ACRNAME=$(az acr list --resource-group rg-a5-ACRAKS --query '[].{Name:name}' --output tsv)  <br>

- Push the image to the new ACR  <br>
 az acr build --resource-group rg-a5-ACRAKS --image sample/nginx:v1 --registry $ACRNAME --file Dockerfile .

![](/img/Screenshotfrom2024-01-0823-55-19.png)  
<br>
![](/img/Screenshotfrom2024-01-0900-02-23.png)  
<br>
![](/img/Screenshotfrom2024-01-0900-02-59.png)

<br>

*** 
***

## 3. Create an Azure Kubernetes Service clustery.  
- Create an Azure Kubernetes service and review the deployed resources.  
See ![create AKS.json](https://github.com/Ladcze/configure-and-secure-ACR-AKS-workloads/blob/b595a519dd1f95fa4741a722353bcffecd0e125c/create%20AKS.json)  
"Note that monitoring is disabled in setup but this is recommendaed inproduction scenarios".
  
An additional RG is created autmoatically to hold components of the AKS Nodes (as referenced in screenshot below)  <br>
![](/img/Screenshotfrom2024-01-0900-19-31.png)


<br>

- Connect to the Kubernetes cluster: <br>
az aks get-credentials --resource-group rg-a5-ACRAKS --name w2cKubernetesCluster
<br>  
List nodes of the Kubenetes cluster:  <br>
kubectl get nodes

![](/img/Screenshotfrom2024-01-0900-31-49.png)

*** 
***

## 4. Configure the AKS cluster permissions to access the ACR.  
* Grant the AKS cluster permission (acrpull) to access the ACR and manage its virtual network  
This grants the ‘acrpull’ role assignment to the ACR.  
![](/img/Screenshotfrom2024-01-0900-35-47.png)

* Grant the AKS cluster the Contributor role to its virtual network
  See ![AKS ContibutorADRole.sh](https://github.com/Ladcze/configure-and-secure-ACR-AKS-workloads/blob/b595a519dd1f95fa4741a722353bcffecd0e125c/AKS%20ContibutorADRole.sh)
<br>

*** 
***

## 5. Deploy an external service to AKS.    
* Upload yaml files  
See ![nginxexternal.yaml](https://github.com/Ladcze/configure-and-secure-ACR-AKS-workloads/blob/b595a519dd1f95fa4741a722353bcffecd0e125c/nginxexternal.yaml)  
See ![nginxinternal.yaml](https://github.com/Ladcze/configure-and-secure-ACR-AKS-workloads/blob/b595a519dd1f95fa4741a722353bcffecd0e125c/nginxinternal.yaml)   

* Open and the nginxexternal.yaml file - to referecne the correct ACR instanceName.  
code ./nginxexternal.yaml

* Apply the change to the cluster
 kubectl apply -f nginxexternal.yaml
![](/img/Screenshotfrom2024-01-0901-05-00.png)

* Review the output of the command you run in the previous task to verify that the deployment and the corresponding service have been created.  
kubectl apply -f nginxexternal.yaml
![](/img/Screenshotfrom2024-01-0901-08-09.png)
Screenshotfrom2024-01-0901-05-00

*** 
***

## 6. Test access to an external AKS-hosted service.    
## Verify the container can be accessed externally using the public IP address. ##
* ### 6a - Retrieve information about the nginxexternal service including name, type, IP addresses, and ports.
*kubectl get service nginxexternal*

result: - see welcome page on browser. 

*** 
***

## 7. Deploy an internal service to AKS  
## 1a ABC ##
* ### 5b Open and the nginxexternal.yaml file - to referecne the correct ACR instanceName.  
*code ./nginxinternal.yaml*


*** 
***


## 8. Testing access to access an internal AKS-hosted service.    
## 1a ABC ##
* ### 8a list the pods in the default namespace on the AKS cluster 
*kubectl get pods*

NAME                             READY   STATUS    RESTARTS   AGE
nginxexternal-7df887d65b-ph52b   1/1     Running   0          21m
nginxinternal-64869b4c5d-m4c42   1/1     Running   0          5m6s

*kubectl exec -it nginxexternal-7df887d65b-ph52b -- /bin/bash*

*curl http://10.0.131.251*

*** 
***

---

## Summary   
You have configured and secured ACR and AKS.

---

## Reference
http://www.microsoft.com/learning
