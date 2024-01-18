RG_AKS=rg-a5-ACRAKS

 RG_VNET=MC_rg-a5-ACRAKS_w2cKubernetesCluster_uksouth	

AKS_VNET_NAME=aks-vnet-14927705
    
 AKS_CLUSTER_NAME=w2cKubernetesCluster
    
 AKS_VNET_ID=$(az network vnet show --name $AKS_VNET_NAME --resource-group $RG_VNET --query id -o tsv)
    
 AKS_MANAGED_ID=$(az aks show --name $AKS_CLUSTER_NAME --resource-group $RG_AKS --query identity.principalId -o tsv)
    
 az role assignment create --assignee $AKS_MANAGED_ID --role "Contributor" --scope $AKS_VNET_ID
