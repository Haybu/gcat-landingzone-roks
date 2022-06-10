##############################################################################
# Subnet Resource
# Copyright 2020 IBM
##############################################################################

locals {
  # Convert subnets into a single list
  subnet_list         = flatten([
    # For each key in the object create an array
    for zone in keys(var.subnets):
    # Each item in the list contains information about a single subnet
    [
      for value in var.subnets[zone]:
      {
        name           = value.name
        prefix_name    = "${var.prefix}-${value.name}"
        zone           = index(keys(var.subnets), zone) + 1                     # Zone 1, 2, or 3
        zone_name      = "${var.region}-${index(keys(var.subnets), zone) + 1}"  # Contains region and zone
        cidr           = value.cidr
        count          = index(var.subnets[zone], value) + 1                    # Count of the subnet within the zone
        public_gateway = value.public_gateway
      }
    ]
  ])

  # Create an object from the array for human readable reference
  subnet_object = {
    for subnet in local.subnet_list:
    "${var.prefix}-${subnet.name}" => subnet
  }

  # List of public gateways
  public_gateway_list = [
    for gateway in keys(var.public_gateways):
    var.public_gateways[gateway] == "" ? null : var.public_gateways[gateway]
  ]

}

##############################################################################


##############################################################################
# Create New Prefixes
##############################################################################

/** do not do this here, and do not set the VPC prefix to 
the same as the subnet prefix. Use the block below instead.
*/
/**
resource ibm_is_vpc_address_prefix subnet_prefix {
  for_each = local.subnet_object
  name     = each.value.prefix_name
  zone     = each.value.zone_name
  vpc      = var.vpc_id
  cidr     = each.value.cidr
}
*/

##############################################################################
# Haytham: Zones IP Address Prefixes
##############################################################################

resource "ibm_is_vpc_address_prefix" "subnet_prefix" {
    for_each = var.ip_prefixes
    name = "${var.prefix}-${each.key}"
    zone = each.value.prefixzone
    vpc  = var.vpc_id
    cidr = each.value.prefixcidr
    #depends_on = [ibm_is_vpc.vpc]
    #lifecycle { prevent_destroy = true }
}

##############################################################################


##############################################################################
# Create Subnets
##############################################################################

resource ibm_is_subnet subnet {
  for_each                 = local.subnet_object
  vpc                      = var.vpc_id
  name                     = each.key
  zone                     = each.value.zone_name
  resource_group           = var.resource_group_id
  ipv4_cidr_block          = each.value.cidr #ibm_is_vpc_address_prefix.subnet_prefix[each.value.prefix_name].cidr
  network_acl              = var.acl_id
  routing_table            = var.routing_table_id
  public_gateway           = local.public_gateway_list[each.value.zone - 1] == "" || each.value.public_gateway == false ? null : local.public_gateway_list[each.value.zone - 1]
 timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

}

##############################################################################

# Added by Haytham:

################################################
# Create VPN Subnet
################################################
resource "ibm_is_subnet" "vpn_subnet" {
    name            = "${var.prefix}-vpn-subnet1"
    resource_group  = var.resource_group_id
    vpc             = var.vpc_id
    zone            = var.vpn_zone
    ipv4_cidr_block = var.vpn_cidr_block
    depends_on = [ibm_is_subnet.subnet]
}

################################################
# Create VPN Gateway
################################################
resource "ibm_is_vpn_gateway" "vpn_gateway" {
  name            = "${var.prefix}-vpn-gateway1"
  resource_group  = var.resource_group_id
  subnet          = ibm_is_subnet.subnet["${var.prefix}-subnet-a"].id
  mode            = "route"
  depends_on = [ibm_is_subnet.subnet]
}