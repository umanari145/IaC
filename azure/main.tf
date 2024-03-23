#----------------------------------------
# Terraformのプロバイダー設定
#----------------------------------------
provider "azurerm" {
  features {}
}

#----------------------------------------
# リソースグループの定義
#----------------------------------------
resource "azurerm_resource_group" "sample-rs" {
  name     = "sample-resources"
  location = "East US"
}

#----------------------------------------
# 仮想ネットワークの定義
#----------------------------------------
resource "azurerm_virtual_network" "sameple-nw" {
  name                = "sample-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sample-rs.location
  resource_group_name = azurerm_resource_group.sample-rs.name
}
