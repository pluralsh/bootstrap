resource "linode_lke_cluster" "cluster" {
  label       = var.cluster
  k8s_version = var.kubernetes_vsn
  region      = var.region

  control_plane {
    high_availability = false
    # acl {
    #     enabled = true
    #     addresses {
    #         ipv4 = ["0.0.0.0/0"]
    #         ipv6 = ["2001:db8::/32"]
    #     }
    # }
  }

  dynamic "pool" {
    for_each = var.node_pools
    content {
      type  = pool.value.type
      count = pool.value.count
      autoscaler {
        min = pool.value.autoscaler.min
        max = pool.value.autoscaler.max
      }
    }
  }
}