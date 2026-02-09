apiVersion: v1
kind: Secret
metadata:
  name: runtime-config
  namespace: infra
type: Opaque
stringData:
  ownerEmail: {{ .Config.Email | quote }}
  pluralToken: {{ .Config.Token | quote }}
  acmeEABKid: {{ .Acme.KeyId | quote }}
  acmeEABSecret: {{ .Acme.HmacKey | quote }}
