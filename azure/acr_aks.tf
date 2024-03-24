resource "azurerm_container_registry" "acr" {
  name                = "sampleacr20240324"
  resource_group_name = azurerm_resource_group.sample-rs.name
  location            = azurerm_resource_group.sample-rs.location
  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "my-aks-cluster"
  location            = azurerm_resource_group.sample-rs.location
  resource_group_name = azurerm_resource_group.sample-rs.name
  dns_prefix          = "my-aks-cluster-dns-prefix"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.sample-sn.id
  }

  identity {
    type = "SystemAssigned"
  }
}