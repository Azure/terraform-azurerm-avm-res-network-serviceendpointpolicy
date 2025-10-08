locals {
  # combine standard definitions with alias definitions to construct a single list
  combined_policy_definitions        = concat(var.policy_definitions, local.service_alias_definition)
  parent_id                          = provider::azapi::subscription_resource_id(local.subscription_id, "Microsoft.Resources/resourceGroups", [var.resource_group_name])
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  # If service alias' are provided, create corresponding definition.
  service_alias_definition = length(var.service_alias) > 0 ? [
    {
      name              = "GlobalServiceAliasDefinition"
      service           = "Global"
      service_resources = var.service_alias
    }
  ] : []
  service_endpoint_policy_definitions_final = [for definition in local.combined_policy_definitions :
    {
      name = definition.name
      properties = {
        service          = try(definition.service, "Microsoft.Storage") # default to Microsoft.Storage
        serviceResources = definition.service_resources
      }
    }
  ]
  subscription_id = coalesce(var.subscription_id, data.azapi_client_config.current.subscription_id)
}
