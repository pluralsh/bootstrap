# This file should not be commited to repository.
# GCP uses the kubernetes.bootstrap provider.

locals {
  console_values = yamldecode(data.local_sensitive_file.console.content)
}

resource "kubernetes_namespace" "infra_gcp" {
  count = "{{ .Provider }}" == "gcp" ? 1 : 0
  provider = kubernetes.bootstrap

  metadata {
    name = "infra"
  }

  depends_on = [module.mgmt.cluster, module.mgmt.ready]
}

resource "kubernetes_namespace" "infra" {
  count = "{{ .Provider }}" == "gcp" ? 0 : 1

  metadata {
    name = "infra"
  }

  depends_on = [module.mgmt.cluster, module.mgmt.ready]
}

resource "kubernetes_secret" "console_config_gcp" {
  count = "{{ .Provider }}" == "gcp" ? 1 : 0
  provider = kubernetes.bootstrap

  metadata {
    name      = "console-config"
    namespace = kubernetes_namespace.infra_gcp[0].metadata[0].name
  }

  type = "Opaque"

  data = {
    consoleDns = tostring(try(local.console_values.ingress.console_dns, ""))
    kasDns     = tostring(try(local.console_values.ingress.kas_dns, ""))

    clusterIssuer = "plural"

    provider = tostring(try(local.console_values.provider, ""))

    jwt                = tostring(try(local.console_values.secrets.jwt, ""))
    erlang             = tostring(try(local.console_values.secrets.erlang, ""))
    aesKey             = tostring(try(local.console_values.secrets.aes_key, ""))
    key                = tostring(try(local.console_values.secrets.key, ""))
    identity           = tostring(try(local.console_values.secrets.identity, ""))
    pluralClientId     = tostring(try(local.console_values.secrets.plural_client_id, ""))
    pluralClientSecret = tostring(try(local.console_values.secrets.plural_client_secret, ""))
    adminName          = tostring(try(local.console_values.secrets.admin_name, ""))
    adminEmail         = tostring(try(local.console_values.secrets.admin_email, ""))
    adminPassword      = tostring(try(local.console_values.secrets.admin_password, ""))
    clusterName        = tostring(try(local.console_values.secrets.cluster_name, ""))

    pluralToken   = tostring(try(local.console_values.extraSecretEnv.PLURAL_TOKEN, ""))
    kasApi        = tostring(try(local.console_values.extraSecretEnv.KAS_API_SECRET, ""))
    kasPrivateApi = tostring(try(local.console_values.extraSecretEnv.KAS_PRIVATE_API_SECRET, ""))
    kasRedis      = tostring(try(local.console_values.extraSecretEnv.KAS_REDIS_SECRET, ""))
    postgresUrl   = tostring(try(local.console_values.extraSecretEnv.POSTGRES_URL, ""))
  }

  depends_on = [kubernetes_namespace.infra_gcp, module.mgmt.cluster, module.mgmt.ready]
}

resource "kubernetes_secret" "console_config" {
  count = "{{ .Provider }}" == "gcp" ? 0 : 1

  metadata {
    name      = "console-config"
    namespace = kubernetes_namespace.infra[0].metadata[0].name
  }

  type = "Opaque"

  data = {
    consoleDns = tostring(try(local.console_values.ingress.console_dns, ""))
    kasDns     = tostring(try(local.console_values.ingress.kas_dns, ""))

    clusterIssuer = "plural"

    provider = tostring(try(local.console_values.provider, ""))

    jwt                = tostring(try(local.console_values.secrets.jwt, ""))
    erlang             = tostring(try(local.console_values.secrets.erlang, ""))
    aesKey             = tostring(try(local.console_values.secrets.aes_key, ""))
    key                = tostring(try(local.console_values.secrets.key, ""))
    identity           = tostring(try(local.console_values.secrets.identity, ""))
    pluralClientId     = tostring(try(local.console_values.secrets.plural_client_id, ""))
    pluralClientSecret = tostring(try(local.console_values.secrets.plural_client_secret, ""))
    adminName          = tostring(try(local.console_values.secrets.admin_name, ""))
    adminEmail         = tostring(try(local.console_values.secrets.admin_email, ""))
    adminPassword      = tostring(try(local.console_values.secrets.admin_password, ""))
    clusterName        = tostring(try(local.console_values.secrets.cluster_name, ""))

    pluralToken   = tostring(try(local.console_values.extraSecretEnv.PLURAL_TOKEN, ""))
    kasApi        = tostring(try(local.console_values.extraSecretEnv.KAS_API_SECRET, ""))
    kasPrivateApi = tostring(try(local.console_values.extraSecretEnv.KAS_PRIVATE_API_SECRET, ""))
    kasRedis      = tostring(try(local.console_values.extraSecretEnv.KAS_REDIS_SECRET, ""))
    postgresUrl   = tostring(try(local.console_values.extraSecretEnv.POSTGRES_URL, ""))
  }

  depends_on = [kubernetes_namespace.infra, module.mgmt.cluster, module.mgmt.ready]
}

resource "kubernetes_secret" "runtime_config_gcp" {
  count = "{{ .Provider }}" == "gcp" ? 1 : 0
  provider = kubernetes.bootstrap

  metadata {
    name      = "runtime-config"
    namespace = kubernetes_namespace.infra_gcp[0].metadata[0].name
  }

  type = "Opaque"

  data = {
    ownerEmail    = "{{ .Config.Email }}"
    pluralToken   = "{{ .Config.Token }}"
    acmeEABKid    = "{{ .Acme.KeyId }}"
    acmeEABSecret = "{{ .Acme.HmacKey }}"
  }

  depends_on = [kubernetes_namespace.infra_gcp, module.mgmt.cluster, module.mgmt.ready]
}

resource "kubernetes_secret" "runtime_config" {
  count = "{{ .Provider }}" == "gcp" ? 0 : 1

  metadata {
    name      = "runtime-config"
    namespace = kubernetes_namespace.infra[0].metadata[0].name
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
