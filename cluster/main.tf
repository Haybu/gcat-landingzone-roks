##############################################################################
# Create IKS on VPC Cluster
##############################################################################

resource ibm_container_vpc_cluster cluster {

  name              = "${var.prefix}-roks-cluster"
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
  flavor            = var.machine_type
  worker_count      = var.workers_per_zone
  kube_version      = var.kube_version != "" ? var.kube_version : null
  tags              = var.tags
  wait_till         = var.wait_till
  entitlement       = var.entitlement == "null" ? null : var.entitlement
  cos_instance_crn  = var.cos_id

  dynamic zones {
    for_each = var.subnets
    content {
      subnet_id = zones.value.id
      name      = zones.value.zone
    }
  }

  disable_public_service_endpoint = true

  # kms_config {
  #   instance_id      = var.key_id
  #   crk_id           = var.ibm_managed_key_id
  #   private_endpoint = true
  # }

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }

}

##############################################################################
# Haytham: Enable Private ALBs, disable public
##############################################################################

# create VPC application load balancer 
resource ibm_container_vpc_alb_create alb {
  cluster = ibm_container_vpc_cluster.cluster.id
  type = "public"
  zone = "us-south-1"
  resource_group_id = var.resource_group_id
  enable = "true"
  depends_on = [ibm_container_vpc_cluster.cluster]
}

/**
resource ibm_container_vpc_alb alb {
  count  = "6" 
  
  alb_id = "${element(ibm_container_vpc_cluster.cluster.albs.*.id, count.index)}"
  enable = "${
    var.enable_albs && !var.only_private_albs 
    ? true
    : var.only_private_albs && "${element(ibm_container_vpc_cluster.cluster.albs.*.alb_type, count.index)}" != "public" 
      ? true
      : false
  }"
}
**/

##############################################################################


##############################################################################
# Worker Pools
##############################################################################

module worker_pools {
  source            = "./worker_pools"
  region            = var.region
  worker_pools      = var.worker_pools
  entitlement       = var.entitlement
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
  cluster_name_id   = ibm_container_vpc_cluster.cluster.id
  subnets           = var.subnets
}

##############################################################################
