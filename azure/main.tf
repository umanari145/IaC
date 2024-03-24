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
resource "azurerm_virtual_network" "sample-nw" {
  name                = "sample-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sample-rs.location
  resource_group_name = azurerm_resource_group.sample-rs.name
}

#----------------------------------------
# サブネットの定義
#----------------------------------------
resource "azurerm_subnet" "sample-sn" {
  name                 = "sample-subnet"
  resource_group_name  = azurerm_resource_group.sample-rs.name
  virtual_network_name = azurerm_virtual_network.sample-nw.name
  address_prefixes     = ["10.0.1.0/24"]
}

#----------------------------------------
# パブリックIP
#----------------------------------------
resource "azurerm_public_ip" "sample_public_ip" {
  name                = "sample-publicIP"
  location            = azurerm_resource_group.sample-rs.location
  resource_group_name = azurerm_resource_group.sample-rs.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#----------------------------------------
# application-gateway
#----------------------------------------
resource "azurerm_application_gateway" "sample-gw" {
  name                = "sample-ApplicationGateway"
  location            = azurerm_resource_group.sample-rs.location
  resource_group_name = azurerm_resource_group.sample-rs.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgwIpConfig"
    subnet_id = azurerm_subnet.sample-sn.id
  }

  frontend_port {
    name = "appgwFrontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIp"
    public_ip_address_id = azurerm_public_ip.sample_public_ip.id
  }

  backend_address_pool {
    name = "appGwBackendPool"
  }

  backend_http_settings {
    name                  = "appGwBackendHttpSettings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
  }

  http_listener {
    name                           = "appGwHttpListener"
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "appgwFrontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "appGwRule1"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "appGwHttpListener"
    backend_address_pool_name  = "appGwBackendPool"
    backend_http_settings_name = "appGwBackendHttpSettings"
  }
}