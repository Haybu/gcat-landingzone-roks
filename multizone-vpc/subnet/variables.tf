##############################################################################
# Subnet Parameters
# Copyright 2020 IBM
##############################################################################

variable prefix {
  description = "Prefix to be added to the beginning of each subnet name"
  type        = string
  default     = "multizone-subnet"
}

variable vpc_id {
  description = "ID of VPC where subnets will be created"
  type        = string
}

variable region {
  description = "Region where VPC will be created"
  type        = string
  default     = "us-south"
}

variable subnets {
  description = "List of subnets for the vpc. For each item in each array, a subnet will be created. Items can be either CIDR blocks or total ipv4 addressess. Public gateways will be enabled only in zones where a gateway has been created"
  type        = object({
    zone-1 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
    }))
    zone-2 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
    }))
    zone-3 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
    }))
  })
  default = {
    zone-1 = [{
      name           = "subnet-a"
      cidr           = "10.10.10.0/24"
      public_gateway = true
    }],
    zone-2 = [{
      name           = "subnet-b"
      cidr           = "10.20.10.0/24"
      public_gateway = true
    }],
    zone-3 = [{
      name           = "subnet-c"
      cidr           = "10.30.10.0/24"
      public_gateway = true
    }]
  }

  validation {
      error_message = "Keys for `subnets` must be in the order `zone-1`, `zone-2`, `zone-3`."
      condition     = keys(var.subnets)[0] == "zone-1" && keys(var.subnets)[1] == "zone-2" && keys(var.subnets)[2] == "zone-3"
  }
}

##############################################################################


##############################################################################
# Optional Subnet Creation Variables
##############################################################################

variable resource_group_id {
  description = "Optional. Resource group ID"
  type        = string
  default     = null
}

variable public_gateways {
  description = "Optional. A map of public gateway IDs. To not use a gateway in a specific zone, leave string empty. If public gateway IDs are provided, they will be used by any subnet created in the zone."
  type        = object({
    zone-1 = string
    zone-2 = string
    zone-3 = string
  })
  default     = {
    zone-1 = ""
    zone-2 = ""
    zone-3 = ""
  }

  validation {
      error_message = "Keys for `subnets` must be in the order `zone-1`, `zone-2`, `zone-3`."
      condition     = keys(var.public_gateways)[0] == "zone-1" && keys(var.public_gateways)[1] == "zone-2" && keys(var.public_gateways)[2] == "zone-3"
  }
}

variable routing_table_id {
  description = "Optional. Routing Table ID"
  type        = string
  default     = null
}

variable acl_id {
  description = "Optional. ACL ID to use for subnet creation"
  type        = string
  default     = null
}


##############################################################################

# Haytham
variable vpn_cidr_block {
  description = "CIDR block for VPN"
  type        = string
}