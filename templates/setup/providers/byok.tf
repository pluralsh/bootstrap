// BYOK – the cluster already exists externally, so the mgmt module is just a
// stub that provides the outputs expected by console.tf without provisioning anything.
module "mgmt" {
  source = "./cluster"
  db_url = "{{ .Context.DbUrl }}"
}

{{ if .Context.TrustManager }}
// trust-manager distributes CA bundles across namespaces automatically.
// Requires cert-manager to be installed first (handled by console.tf).
resource "helm_release" "trust_manager" {
  name             = "trust-manager"
  namespace        = "cert-manager"
  chart            = "trust-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v0.12.0"
  create_namespace = false
  timeout          = 300
  wait             = true

  set {
    name  = "app.trust.namespace"
    value = "cert-manager"
  }

  depends_on = [helm_release.certmanager]
}

// Create a self-signed CA via cert-manager so local-ca-secret exists
// before trust-manager's Bundle tries to read it.
resource "null_resource" "local_ca" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f - <<EOF
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: selfsigned-issuer
      spec:
        selfSigned: {}
      ---
      apiVersion: cert-manager.io/v1
      kind: Certificate
      metadata:
        name: local-ca
        namespace: cert-manager
      spec:
        isCA: true
        commonName: local-ca
        secretName: local-ca-secret
        privateKey:
          algorithm: RSA
          size: 2048
        issuerRef:
          name: selfsigned-issuer
          kind: ClusterIssuer
          group: cert-manager.io
      ---
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: local-ca-issuer
      spec:
        ca:
          secretName: local-ca-secret
      EOF
      kubectl wait --for=condition=Ready certificate/local-ca -n cert-manager --timeout=60s
    EOT
  }

  depends_on = [helm_release.certmanager]
}

// Bundle distributes the local CA cert into plrl-deploy-operator so the
// deployment-operator pod trusts the console TLS certificate.
// Named "deployment-operator-local-ca" so the ConfigMap name matches the
// chart's certs[] convention: deployment-operator-<cert.name>.
// Uses local-exec because the Bundle CRD is created by trust-manager above
// and kubernetes_manifest would fail at plan time before the CRD exists.
resource "null_resource" "trust_bundle" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f - <<EOF
      apiVersion: trust.cert-manager.io/v1alpha1
      kind: Bundle
      metadata:
        name: deployment-operator-local-ca
      spec:
        sources:
        - secret:
            name: local-ca-secret
            namespace: cert-manager
            key: tls.crt
        target:
          configMap:
            key: local-ca.crt
          namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: plrl-deploy-operator
      EOF
    EOT
  }

  depends_on = [helm_release.trust_manager, null_resource.local_ca]
}
{{ end }}
