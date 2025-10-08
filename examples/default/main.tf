terraform {
  required_version = "~> 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.1"

  is_recommended = true
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# Create a storage account to use in the policy definition
resource "azurerm_storage_account" "this" {
  account_replication_type  = "LRS"
  account_tier              = "Standard"
  location                  = azurerm_resource_group.this.location
  name                      = module.naming.storage_account.name_unique
  resource_group_name       = azurerm_resource_group.this.name
  shared_access_key_enabled = true
}

module "test" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = "se-${module.naming.subnet.name_unique}"
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry
  lock = {
    kind = "CanNotDelete"
  }
  policy_definitions = [
    {
      name = "SubscriptionScopeDefinition"
      service_resources = [
        "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
      ]
    },
    # {
    #   name = "ResourceGroupScopeDefinition"
    #   service_resources = [
    #     azurerm_resource_group.this.id
    #   ]
    # },
    # {
    #   name = "StorageAccountScopeDefinition"
    #   service_resources = [
    #     azurerm_storage_account.this.id
    #   ]
    # },
  ]
  role_assignments = {
    reader = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Reader"
    }
  }
  service_alias = [
    "/services/Azure",
    "/services/Azure/Batch",
    "/services/Azure/Databricks",
    "/services/Azure/DataFactory",
    "/services/Azure/MachineLearning",
    "/services/Azure/ManagedInstance",
    "/services/Azure/WebPI",
  ]
  tags = {
    environment = "production"
  }
}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

