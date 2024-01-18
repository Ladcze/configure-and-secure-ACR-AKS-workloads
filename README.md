# Configure-and-Secure-ACR-AKS-workloads
Configuring and Securing Containers and Kubernetes  

---

## Introduction
This depicts the deployment of a proof of concept using Azure Container Registry and Azure Kubernetes Service.  
This POC will demonstrate the following:  
- Building an image using Dockerfile  
- Storing images using Azure Container Regsitry  
- Kubernetes configuration of using AKS  
- Configuring applicable security protocols to access container applications both internally and externally.  

---

## Services deployed
- There are the 2 primary services required for this project

![](kubernetesService.jpeg)   
![](containerRegistry.png)  


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
## 1a ABC ##
* ### 1a DEF 

#create a res group
*<ins>az group create --name rg-a5-ACRAKS --location uksouth<ins>*

#create a new Azure Container Registry (ACR) instance
*<ins>az acr create --resource-group rg-a5-ACRAKS --name w2cA5ACR --sku Basic<ins>*  

The above syntax initiates the deployment of a new instance of a container Resgistry.  
 

*** 
***

## 2. Create a Dockerfile, build a container and push it to Azure Container Registry.    
## 2a create a Dockerfile, build an image from the Dockerfile, and deploy the image to the ACR. ##
* ### create a Dockerfile  
-Create a Dockerfile to create an Nginx-based image

*<ins>echo FROM nginx > Dockerfile<ins>*


* ### build an image from the Dockerfile
-build an image from the Dockerfile and push the image to the new ACR.
 ACRNAME=$(az acr list --resource-group rg-a5-ACRAKS --query '[].{Name:name}' --output tsv)

-push the image to the new ACR
 az acr build --resource-group rg-a5-ACRAKS --image sample/nginx:v1 --registry $ACRNAME --file Dockerfile .

photos
photos
photos

<br>

*** 
***

## 3. Create an Azure Kubernetes Service clustery.  
-in this task, you will create an Azure Kubernetes service and review the deployed resources.  
--See json template
--monitoring disabled in setup but this is recommendaed inproduction scenarios.
--an additional RG is created autmoatically to hold components of the AKS Nodes (--shown screenshot)


## 1a ABC ##
* connect to the Kubernetes cluster:
*az aks get-credentials --resource-group rg-a5-ACRAKS --name w2cKubernetesCluster*
The above sequence will initiate the deployment of the Azure VM and Azure SQL Database required for this proof of concept.

--list nodes of the Kubenetes cluster:
*kubectl get nodes*

see photo

*** 
***

## 4. Configure the AKS cluster permissions to access the ACR.  
## 4a Grant the AKS cluster permission (acrpull) to access the ACR and manage its virtual network ## 
* ### 1a DEF 

 ACRNAME=$(az acr list --resource-group rg-a5-ACRAKS --query '[].{Name:name}' --output tsv)

 az aks update -n w2cKubernetesCluster -g rg-a5-ACRAKS --attach-acr $ACRNAME

#This grants the ‘acrpull’ role assignment to the ACR.  


## 4b grant the AKS cluster the Contributor role to its virtual network ##
 RG_AKS=rg-a5-ACRAKS

 RG_VNET=MC_rg-a5-ACRAKS_w2cKubernetesCluster_uksouth	

 AKS_VNET_NAME=aks-vnet-14927705
    
 AKS_CLUSTER_NAME=w2cKubernetesCluster
    
 AKS_VNET_ID=$(az network vnet show --name $AKS_VNET_NAME --resource-group $RG_VNET --query id -o tsv)
    
 AKS_MANAGED_ID=$(az aks show --name $AKS_CLUSTER_NAME --resource-group $RG_AKS --query identity.principalId -o tsv)
    
 az role assignment create --assignee $AKS_MANAGED_ID --role "Contributor" --scope $AKS_VNET_ID

---show photo/result

<br> 

*** 
***

## 5. Deploy an external service to AKS.    
## 1a ABC ##
* ### 5a upload yaml files

* ### 5b Open and the nginxexternal.yaml file - to referecne the correct ACR instanceName.  
*code ./nginxexternal.yaml*

* ### 5c Apply the change to the cluster
 *kubectl apply -f nginxexternal.yaml*

* ### 5d review the output of the command you run in the previous task to verify that the deployment and the corresponding service have been created. 
*kubectl apply -f nginxexternal.yaml* 
---to show state of deployments (see - Screenshot from 2024-01-09 01-01-04.png)  


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