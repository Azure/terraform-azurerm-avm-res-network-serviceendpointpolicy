variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the Service Endpoint Policy resource."

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9._-]{0,78}[a-zA-Z0-9_])?$", var.name))
    error_message = "The name must be between 1 and 80 characters long, begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, and hyphens."
  }
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "policy_definitions" {
  type = list(object({
    name              = string
    service           = optional(string, "Microsoft.Storage")
    service_resources = list(string)
  }))
  default     = []
  description = <<DESCRIPTION
A map of policy definitions for the Service Endpoint Policy. Each definition specifies which Azure service resources are allowed. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `service` - (Optional) The service for the policy definition. Defaults to `Microsoft.Storage`. 
- `service_resources` - (Required) A list of Azure Resource Manager IDs of the resources that this policy applies to. Can specify:
  - Individual storage accounts: `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Storage/storageAccounts/{storageAccountName}`
  - All storage accounts in a resource group: `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}`
  - All storage accounts in a subscription: `/subscriptions/{subscriptionId}`

Example:
```terraform
policy_definitions = {
  allow-prod-storage = {
    service     = "Microsoft.Storage"
    service_resources = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm/providers/Microsoft.Storage/storageAccounts/mystorageaccount"
    ]
  }
}
```
DESCRIPTION
  nullable    = false
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.
- `delegated_managed_identity_resource_id` - The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
- `principal_type` - The type of the principal_id. Possible values are `User`, `Group` and `ServicePrincipal`. Changing this forces a new resource to be created. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "service_alias" {
  type        = list(string)
  default     = []
  description = <<DESCRIPTION
A list of service aliases indicating if the policy belongs to managed services.

Common service aliases:
- `/services/Azure/ManagedInstance` - For Azure SQL Managed Instance
- `/services/Azure/MachineLearning` - For Azure Machine Learning
- `/services/Azure/Databricks` - For Azure Databricks

Example:
```terraform
service_alias = ["/services/Azure/ManagedInstance", "/services/Azure/MachineLearning"]
```

DESCRIPTION
  nullable    = false
}

variable "subscription_id" {
  type        = string
  default     = null
  description = "(Optional) This specifies a subscription ID which is used to construct the parent ID for the maintenance configuration."

  validation {
    condition     = var.subscription_id == null || can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id))
    error_message = "The subscription_id must be a valid GUID in the format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
