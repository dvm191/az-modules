# How to use this module

Here you can find instructions about how to use this module in two variations.

## Variation A

This variation enables provisioning of the module with all requiered and optional inputs from dependend modules or resources inside of the same root module.
E.g. the resource groups is created with the same lifecycle.

```bash
# module call
module "resource_group" {
  source   = "../../azuf-dep-p-terraform-modules/azurerm/resource_group"
  for_each = { for s in local.inputs.resourceGroup : s.index => s }
  resourceGroup = merge(
    {
      values   = each.value
      instance = local.inputs.instance
      workload = local.inputs.workload
      region   = local.inputs.region
      level2   = local.inputs.level2
      level3   = local.inputs.level3
      ccoe     = local.inputs.ccoe
      tags     = try(merge(try(each.value.tags, {}), try(local.inputs.tags, {})), {})
    }
  )
}

# tfvars call
inputs = {
  values = {
     # naming
    instance = "001"
    workload = "resolver"
    region   = "euw"
    level2   = "gxp"
    level3   = "dev"
    ccoe     = true
    # tags for all resources
    tags = {
      requiered = "tags-to-populate-to-all-resources"
    }
    resourceGroup = [
      {
        # terraform graph keys
        index         = "01"
        # naming
        applicationID = "001"        
      },
    ]
  }
}

```

## Variation B

This variation enables usage of the module even if the resource groups was created outsite of this lifecylce.

```bash
# module call
module "resource_group" {
  source   = "../../azuf-dep-p-terraform-modules/azurerm/resource_group"
  for_each = { for s in local.inputs.resourceGroup : s.index => s }
  resourceGroup = merge(
    {
      values   = each.value
      instance = local.inputs.instance
      workload = local.inputs.workload
      region   = local.inputs.region
      level2   = local.inputs.level2
      level3   = local.inputs.level3
      ccoe     = local.inputs.ccoe
      tags     = try(merge(try(each.value.tags, {}), try(local.inputs.tags, {})), {})
    }
  )
}

# tfvars call
inputs = {
  values = {
     # naming
    instance = "001"
    workload = "resolver"
    region   = "euw"
    level2   = "gxp"
    level3   = "dev"
    ccoe     = true
    # tags for all resources
    tags = {
      requiered = "tags-to-populate-to-all-resources"
    }
    resourceGroup = [
      {
        index = "01"
        name  = "rg-def-euw-g-abc-001"
      },
    ]
  }
}

```
