ownerEmail: {{ "{{ configuration.ownerEmail }}" }}

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

pluralToken: {{ "{{ configuration.pluralToken }}" }}

acmeEAB:
  kid: {{ "{{ configuration.acmeEABKid }}" }}
  secret: {{ "{{ configuration.acmeEABSecret }}" }}
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

ingress-nginx:
  enabled: false
ingress-nginx-private:
  enabled: false
{{ end }}

{{ if and (eq .Provider "aws") (not .Cloud) }}
ingress-nginx:
  controller:
    service:
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
        service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
        service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: 'true'
        service.beta.kubernetes.io/aws-load-balancer-type: external
        service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
        service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
        service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: '3600'
    config:
      compute-full-forwarded-for: 'true'
      use-forwarded-headers: 'true'
      use-proxy-protocol: 'true'
ingress-nginx-private:
  controller:
    service:
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
        service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: 'true'
        service.beta.kubernetes.io/aws-load-balancer-type: external
        service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
        service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
        service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: '3600'
    config:
      compute-full-forwarded-for: 'true'
      use-forwarded-headers: 'true'
      use-proxy-protocol: 'true'
{{ end }}