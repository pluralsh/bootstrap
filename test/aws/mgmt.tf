module "mgmt" {
    source              = "../../terraform/clouds/aws"
    cluster_name        = "boot-test"
    vpc_name            = "boot-test"
    deletion_protection = false
}
