apiVersion: v1
kind: Secret
metadata:
  name: runtime-secret
type: Opaque
stringData:
  pluralToken: {{ .Values.pluralToken | quote }}
  acmeEABKid: {{ .Values.acmeEAB.kid | quote }}
  acmeEABSecret: {{ .Values.acmeEAB.secret | quote }}
