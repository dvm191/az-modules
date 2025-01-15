output "resourceGroupName" {   
  value = length(azurerm_resource_group.rg) == 0 ? try(local.resourceGroup.values.name, null) : azurerm_resource_group.rg["01"].name
}

output "id" {  
  value = length(azurerm_resource_group.rg) == 0 ? format("%s/%s/%s", data.azurerm_subscription.current.id, "resourceGroups", try(local.resourceGroup.values.name, "null")) : azurerm_resource_group.rg["01"].id
}