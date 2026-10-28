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
        - {{ "{{ configuration.vpcCidr | default: '10.0.0.0/16' }}" }}
    websecure:
      proxyProtocol:
        trustedIPs:
        - {{ "{{ configuration.vpcCidr | default: '10.0.0.0/16' }}" }}
traefik-private:
  ports:
    web:
      proxyProtocol:
        trustedIPs:
        - {{ "{{ configuration.vpcCidr | default: '10.0.0.0/16' }}" }}
    websecure:
      proxyProtocol:
        trustedIPs:
        - {{ "{{ configuration.vpcCidr | default: '10.0.0.0/16' }}" }}
{{ end }}