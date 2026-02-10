# This file should not be commited to repository.

resource "kubernetes_secret" "runtime_config" {
  metadata {
    name      = "runtime-config"
    namespace = "infra"
  }

  type = "Opaque"

  data = {
    ownerEmail    = base64encode("{{ .Config.Email }}")
    pluralToken   = base64encode("{{ .Config.Token }}")
    acmeEABKid    = base64encode("{{ .Acme.KeyId }}")
    acmeEABSecret = base64encode("{{ .Acme.HmacKey }}")
  }

  depends_on = [module.mgmt.cluster, module.mgmt.ready]
}

resource "kubernetes_secret" "console_config" {
  metadata {
    name      = "console-config"
    namespace = "infra"
  }

  type = "Opaque"

  data = {
    clusterName = base64encode("{{ .Config.ClusterName }}")
    provider    = base64encode("{{ .Config.Provider }}")
    consoleDns  = base64encode("console.{{ .Subdomain }}")
    kasDns      = base64encode("kas.{{ .Subdomain }}")
    postgresUrl = base64encode(module.mgmt.db_url)
  }

  depends_on = [module.mgmt.cluster, module.mgmt.ready]
}

