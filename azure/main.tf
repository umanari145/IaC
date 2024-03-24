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
# 仮想ネットワークの定義(サービスCIDR)
#----------------------------------------
resource "azurerm_virtual_network" "sample-nw" {
  name                = "sample-network"
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.sample-rs.location
  resource_group_name = azurerm_resource_group.sample-rs.name
}

#----------------------------------------
# サブネットの定義(サブネットCIDR)
# kubernetesでサブネットを設定する場合、16以上で設定することが求められる
#----------------------------------------
resource "azurerm_subnet" "sample-sn" {
  name                 = "sample-subnet"
  resource_group_name  = azurerm_resource_group.sample-rs.name
  virtual_network_name = azurerm_virtual_network.sample-nw.name
  address_prefixes     = ["10.240.0.0/16"]
}

#----------------------------------------
# パブリックIP
#----------------------------------------
resource "azurerm_public_ip" "sample_public_ip" {
  name                = "sample-public-IP"
  location            = azurerm_resource_group.sample-rs.location
  resource_group_name = azurerm_resource_group.sample-rs.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#----------------------------------------
# application-gateway
#----------------------------------------
resource "azurerm_application_gateway" "sample-gw" {
  name                = "sample-application-gateway"
  location            = azurerm_resource_group.sample-rs.location
  resource_group_name = azurerm_resource_group.sample-rs.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.sample-sn.id
  }

  frontend_port {
    name = "appgw-frontend-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgw-public-frontend-ip"
    public_ip_address_id = azurerm_public_ip.sample_public_ip.id
  }

  backend_address_pool {
    name = "appgw-backend-pool"
  }

  backend_http_settings {
    name                  = "appgw-backend-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
  }

  http_listener {
    name                           = "appgw-http-listener"
    frontend_ip_configuration_name = "appgw-public-frontend-Ip"
    frontend_port_name             = "appgw-frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "appgw-rule1"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "appgw-http-listener"
    backend_address_pool_name  = "appgw-backend-pool"
    backend_http_settings_name = "appgw-backend-http-settings"
  }
}