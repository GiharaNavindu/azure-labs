# 1. Create a Resource Group
resource "azurerm_resource_group" "k8s_rg" {
  name     = "gitops-platform-rg"
  location = "East US" 
}

# 2. Create the AKS Cluster
resource "azurerm_kubernetes_cluster" "k8s_cluster" {
  name                = "gitops-aks-cluster"
  location            = azurerm_resource_group.k8s_rg.location
  resource_group_name = azurerm_resource_group.k8s_rg.name
  dns_prefix          = "gitops-aks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2as_v7" 
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

# 3. Output the raw kubeconfig so we can connect to it later
output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s_cluster.kube_config_raw
  sensitive = true
}