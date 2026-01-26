{{/*
Common labels
*/}}
{{- define "democrm.labels" -}}
app: {{ .Values.app.name }}
app.kubernetes.io/name: {{ .Values.global.appName }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "democrm.selectorLabels" -}}
app: {{ .Values.app.name }}
{{- end }}

{{/*
Image reference
*/}}
{{- define "democrm.image" -}}
{{- printf "%s:%s" .Values.app.image.repository .Values.app.image.tag }}
{{- end }}

{{/*
Release name prefix
*/}}
{{- define "democrm.name" -}}
{{- printf "%s-%s" .Release.Name .Values.app.name }}
{{- end }}

{{/*
Full name
*/}}
{{- define "democrm.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.global.appName }}
{{- end }}
