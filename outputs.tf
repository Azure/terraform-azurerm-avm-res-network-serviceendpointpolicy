output "name" {
  description = "The name of the Service Endpoint Policy."
  value       = azapi_resource.service_endpoint_policy.name
}

output "resource_id" {
  description = "The Azure Resource ID of the Service Endpoint Policy."
  value       = azapi_resource.service_endpoint_policy.id
}

output "service_endpoint_policy_definitions" {
  description = "All policy definitions on the Service Endpoint Policy."
  value       = local.service_endpoint_policy_definitions_final
}
