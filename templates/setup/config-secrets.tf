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
    consoleDns = tostring(try(local.console_values.ingress.consoleDns, ""))
    kasDns     = tostring(try(local.console_values.ingress.kasDns, ""))

    clusterIssuer = "plural"

    provider = tostring(try(local.console_values.provider, ""))

    jwt                = tostring(try(local.console_values.secrets.jwt, ""))
    erlang             = tostring(try(local.console_values.secrets.erlang, ""))
    aesKey             = tostring(try(local.console_values.secrets.aesKey, ""))
    key                = tostring(try(local.console_values.secrets.key, ""))
    identity           = tostring(try(local.console_values.secrets.identity, ""))
    pluralClientId     = tostring(try(local.console_values.secrets.pluralClientId, ""))
    pluralClientSecret = tostring(try(local.console_values.secrets.pluralClientSecret, ""))
    adminName          = tostring(try(local.console_values.secrets.adminName, ""))
    adminEmail         = tostring(try(local.console_values.secrets.adminEmail, ""))
    adminPassword      = tostring(try(local.console_values.secrets.adminPassword, ""))
    clusterName        = tostring(try(local.console_values.secrets.clusterName, ""))

    pluralToken   = tostring(try(local.console_values.extraSecretEnv.PLURAL_TOKEN, ""))
    kasApi        = tostring(try(local.console_values.extraSecretEnv.KAS_API_SECRET, ""))
    kasPrivateApi = tostring(try(local.console_values.extraSecretEnv.KAS_PRIVATE_API_SECRET, ""))
    kasRedis      = tostring(try(local.console_values.extraSecretEnv.KAS_REDIS_SECRET, ""))
    postgresUrl   = tostring(try(local.console_values.extraSecretEnv.POSTGRES_URL, ""))
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
    ownerEmail    = "{{ .Config.Email }}"
    pluralToken   = "{{ .Config.Token }}"
    acmeEABKid    = "{{ .Acme.KeyId }}"
    acmeEABSecret = "{{ .Acme.HmacKey }}"
  }

  depends_on = [kubernetes_namespace.infra, module.mgmt.cluster, module.mgmt.ready]
}
