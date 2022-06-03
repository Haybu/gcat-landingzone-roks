##############################################################################
# Access Groups
##############################################################################

/**
output access_groups {
    description = "Access group information"
    value       = module.access_groups.access_groups
}
*/

##############################################################################


##############################################################################
# VPC
##############################################################################

output vpc_id {
  description = "ID of VPC created"
  value       = module.multizone_vpc.vpc_id
}

output acl_id {
  description = "ID of ACL created for subnets"
  value       = module.multizone_vpc.acl_id
}

output public_gateways {
  description = "Public gateways created"
  value       = module.multizone_vpc.public_gateways
}

##############################################################################

##############################################################################
# Subnet Outputs
##############################################################################

output subnet_ids {
  description = "The IDs of the subnets"
  value       = module.multizone_vpc.subnet_ids
}

output subnet_detail_list {
  description = "A list of subnets containing names, CIDR blocks, and zones."
  value       = module.multizone_vpc.subnet_detail_list
}

output subnet_zone_list {
  description = "A list containing subnet IDs and subnet zones"
  value       = module.multizone_vpc.subnet_zone_list
}

##############################################################################

##############################################################################
# Cluster Outputs
##############################################################################

output cluster_id {
  description = "ID of cluster created"
  value       = module.roks_cluster.id
}

output cluster_name {
  description = "Name of cluster created"
  value       = module.roks_cluster.name
}

output cluster_private_service_endpoint_url {
    description = "URL For Cluster Private Service Endpoint"
    value       = module.roks_cluster.private_service_endpoint_url
}

output cluster_private_service_endpoint_port {
    description = "Port for Cluster private service endpoint"
    value       = module.roks_cluster.private_service_endpoint_port
}

##############################################################################
#Haytham: added for ALB

/**
output cluster_alb_id {
    description = "ID of ALB created"
    value       = module.roks_cluster.alb_id
}

output cluster_alb_hostname {
    description = "Hostname of ALB created"
    value       = module.roks_cluster.alb_hostname
}

output cluster_alb_name {
    description = "Name of ALB created"
    value       = module.roks_cluster.alb_name
}


output cluster_alb_state {
    description = "State of ALB created"
    value       = module.roks_cluster.alb_state
}

output cluster_alb_status {
    description = "Status of ALB created"
    value       = module.roks_cluster.alb_status
}

output cluster_alb_resize {
    description = "Is ALB resize required"
    value       = module.roks_cluster.alb_resize
}
*/