# This file should not be commited to repository.

locals {
  console_values = yamldecode(data.local_sensitive_file.console.content)
}

resource "kubernetes_namespace" "infra" {
  metadata {
    name = "infra"
  }

  depends_on = [module.mgmt.cluster, module.mgmt.ready]
}

resource "kubernetes_secret" "console_config" {
  metadata {
    name      = "console-config"
    namespace = kubernetes_namespace.infra.metadata[0].name
  }

  type = "Opaque"

  data = {
    consoleDns = base64encode(tostring(try(local.console_values.ingress.consoleDns, "")))
    kasDns     = base64encode(tostring(try(local.console_values.ingress.kasDns, "")))

    clusterIssuer = base64encode("plural")

    provider = base64encode(tostring(try(local.console_values.provider, "")))

    jwt                = base64encode(tostring(try(local.console_values.secrets.jwt, "")))
    erlang             = base64encode(tostring(try(local.console_values.secrets.erlang, "")))
    aesKey             = base64encode(tostring(try(local.console_values.secrets.aesKey, "")))
    key                = base64encode(tostring(try(local.console_values.secrets.key, "")))
    identity           = base64encode(tostring(try(local.console_values.secrets.identity, "")))
    pluralClientId     = base64encode(tostring(try(local.console_values.secrets.pluralClientId, "")))
    pluralClientSecret = base64encode(tostring(try(local.console_values.secrets.pluralClientSecret, "")))
    adminName          = base64encode(tostring(try(local.console_values.secrets.adminName, "")))
    adminEmail         = base64encode(tostring(try(local.console_values.secrets.adminEmail, "")))
    adminPassword      = base64encode(tostring(try(local.console_values.secrets.adminPassword, "")))
    clusterName        = base64encode(tostring(try(local.console_values.secrets.clusterName, "")))

    pluralToken   = base64encode(tostring(try(local.console_values.extraSecretEnv.PLURAL_TOKEN, "")))
    kasApi        = base64encode(tostring(try(local.console_values.extraSecretEnv.KAS_API_SECRET, "")))
    kasPrivateApi = base64encode(tostring(try(local.console_values.extraSecretEnv.KAS_PRIVATE_API_SECRET, "")))
    kasRedis      = base64encode(tostring(try(local.console_values.extraSecretEnv.KAS_REDIS_SECRET, "")))
    postgresUrl   = base64encode(tostring(try(local.console_values.extraSecretEnv.POSTGRES_URL, "")))
  }

  depends_on = [kubernetes_namespace.infra, module.mgmt.cluster, module.mgmt.ready]
}

resource "kubernetes_secret" "runtime_config" {
  metadata {
    name      = "runtime-config"
    namespace = kubernetes_namespace.infra.metadata[0].name
  }

  type = "Opaque"

  data = {
    ownerEmail    = base64encode("{{ .Config.Email }}")
    pluralToken   = base64encode("{{ .Config.Token }}")
    acmeEABKid    = base64encode("{{ .Acme.KeyId }}")
    acmeEABSecret = base64encode("{{ .Acme.HmacKey }}")
  }

  depends_on = [kubernetes_namespace.infra, module.mgmt.cluster, module.mgmt.ready]
}
