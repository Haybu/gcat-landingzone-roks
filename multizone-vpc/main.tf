##############################################################################
# Create a VPC
##############################################################################

resource ibm_is_vpc vpc {
  name           = "${var.prefix}-vpc"
  resource_group = var.resource_group_id
  classic_access = var.classic_access
}

##############################################################################


##############################################################################
# Update default security group
##############################################################################

locals {
  # Convert to object
  security_group_rule_object = {
    for rule in var.security_group_rules:
    rule.name => rule
  }
}

resource ibm_is_security_group_rule default_vpc_rule {
  for_each  = local.security_group_rule_object
  group     = ibm_is_vpc.vpc.default_security_group
  direction = each.value.direction
  remote    = each.value.remote

  dynamic tcp { 
    for_each = each.value.tcp == null ? [] : [each.value]
    content {
      port_min = each.value.tcp.port_min
      port_max = each.value.tcp.port_max
    }
  }

  dynamic udp { 
    for_each = each.value.udp == null ? [] : [each.value]
    content {
      port_min = each.value.udp.port_min
      port_max = each.value.udp.port_max
    }
  } 

  dynamic icmp { 
    for_each = each.value.icmp == null ? [] : [each.value]
    content {
      type = each.value.icmp.type
      code = each.value.icmp.code
    }
  } 
}

##############################################################################


##############################################################################
# Public Gateways (Optional)
##############################################################################

locals {
  # create object that only contains gateways that will be created
  gateway_object = {
    for zone in keys(var.use_public_gateways):
      zone => "${var.region}-${index(keys(var.use_public_gateways), zone) + 1}" if var.use_public_gateways[zone]
  }
}

resource ibm_is_public_gateway gateway {
  for_each       = local.gateway_object
  name           = "${var.prefix}-public-gateway-${each.key}"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
  zone           = each.value
}

##############################################################################
# Haytham: Zones IP Address Prefixes
##############################################################################

resource "ibm_is_vpc_address_prefix" "address_prefix" {
    for_each = var.ip_prefixes
    name = "${var.prefix}-${each.key}"
    zone = each.value.prefixzone
    vpc  = ibm_is_vpc.vpc.id
    cidr = each.value.prefixcidr
    depends_on = [ibm_is_vpc.vpc]
    #lifecycle { prevent_destroy = true }
}

##############################################################################


##############################################################################
# Multizone subnets
##############################################################################

locals {
  # Object to reference gateways
  public_gateways = {
    for zone in ["zone-1", "zone-2", "zone-3"]:
    # If gateway is created, set to id, otherwise set to empty string
    zone => contains(keys(local.gateway_object), zone) ? ibm_is_public_gateway.gateway[zone].id : ""
  }
}

module subnets {
  source            = "./subnet" 
  region            = var.region 
  prefix            = var.prefix                  
  acl_id            = ibm_is_network_acl.multizone_acl.id
  subnets           = var.subnets
  vpc_id            = ibm_is_vpc.vpc.id
  resource_group_id = var.resource_group_id
  public_gateways   = local.public_gateways
  vpn_cidr_block = var.vpn_cidr_block
}

##############################################################################

