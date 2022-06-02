##############################################################################
# Cluster Outputs
##############################################################################

output id {
    description = "ID of cluster created"
    value       = ibm_container_vpc_cluster.cluster.id
    # Ensure cluster is finished before outputting variable from module
    depends_on  = [ ibm_container_vpc_cluster.cluster ]
}

output name {
    description = "Name of cluster created"
    value       = ibm_container_vpc_cluster.cluster.name
    # Ensure cluster is finished before outputting variable from module
    depends_on  = [ ibm_container_vpc_cluster.cluster ]
}

output private_service_endpoint_url {
    description = "URL For Cluster Private Service Endpoint"
    value       = ibm_container_vpc_cluster.cluster.private_service_endpoint_url
}

output private_service_endpoint_port {
    description = "Port for Cluster private service endpoint"
    value       = split(":", ibm_container_vpc_cluster.cluster.private_service_endpoint_url)[2]
}

##############################################################################

# Haytham: app load balancer
output alb_id {
    description = "ID of ALB created"
    value       = ibm_container_vpc_alb_create.alb.alb_id
}

output alb_hostname {
    description = "Hostname of ALB created"
    value       = ibm_container_vpc_alb_create.alb.load_balancer_hostname
}

output alb_name {
    description = "Name of ALB created"
    value       = ibm_container_vpc_alb_create.alb.name
}


output alb_state {
    description = "State of ALB created"
    value       = ibm_container_vpc_alb_create.alb.state
}

output alb_status {
    description = "status of ALB created"
    value       = ibm_container_vpc_alb_create.alb.status
}

output alb_resize {
    description = "Is ALB resize required"
    value       = ibm_container_vpc_alb_create.alb.resize
}
