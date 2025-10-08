# terraform-azurerm-avm-res-network-serviceendpointpolicy

This is an Azure Verified Module for Azure Service Endpoint Policies.

## Overview

Service Endpoint Policies provide granular control over virtual network traffic to Azure services. This module creates and manages Azure Service Endpoint Policies using the AzAPI provider for direct ARM API access.

## Key Features

- **Dynamic Service Support**: Configure policies for multiple Azure services (Storage, SQL, Cosmos DB, Key Vault, Service Bus, Event Hub)
- **Service Aliases**: Support for managed service aliases (Managed Instance, Machine Learning, Databricks)
- **Contextual Policies**: Link policies to other resources for advanced scenarios
- **Transparent Body Construction**: The `computed_body` output shows exactly what JSON is sent to Azure
- **AVM Compliant**: Follows all Azure Verified Module standards

## Inspecting the Policy Body

To see the exact JSON body being sent to the Azure API, use the `computed_body` output:

```hcl
output "policy_body" {
  value = module.service_endpoint_policy.computed_body
}
```

This output decodes the internal JSON structure and shows:
- All policy definitions with their services and service resources
- Service alias (if configured)
- Contextual service endpoint policies (if configured)

This transparency helps with debugging, auditing, and understanding exactly what the module creates.
