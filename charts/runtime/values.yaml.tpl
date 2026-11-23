ownerEmail: {{ .Config.Email }}

{{ if not .Cloud }}
external-dns:
  extraArgs:
    plural-cluster: {{ .Cluster }}
    plural-provider: {{ .Provider }}
  domainFilters:
  - {{ .Subdomain }}

dnsSolver: 
  webhook:
    groupName: acme.plural.sh
    solverName: plural-solver
    config:
      cluster: {{ .Cluster }}
      provider: {{ .Provider }}

pluralToken: {{ .Config.Token }}

acmeEAB:
  kid: {{ .Acme.KeyId }}
  secret: {{ .Acme.HmacKey }}
{{ end }}

{{ if .Cloud }}
external-dns:
  enabled: false

plural-certmanager-webhook:
  enabled: false

operator:
  enabled: false

application:
  enabled: false

plural:
  enabled: false

traefik:
  enabled: false
traefik-private:
  enabled: false
{{ end }}

{{ if eq .Provider "byok" }}
external-dns:
  enabled: false

plural-certmanager-webhook:
  enabled: true

operator:
  enabled: true

application:
  enabled: false

plural:
  enabled: false

traefik:
  enabled: false
traefik-private:
  enabled: false
{{ end }}

{{ if and (eq .Provider "aws") (not .Cloud) }}
# NLBs send PROXY protocol v2 headers, only trusted from inside the VPC
traefik:
  ports:
    web:
      proxyProtocol:
        trustedIPs:
        - 10.0.0.0/16
    websecure:
      proxyProtocol:
        trustedIPs:
        - 10.0.0.0/16
traefik-private:
  ports:
    web:
      proxyProtocol:
        trustedIPs:
        - 10.0.0.0/16
    websecure:
      proxyProtocol:
        trustedIPs:
        - 10.0.0.0/16
{{ end }}