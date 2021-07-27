
{{/*
Common labels
*/}}
{{- define "init.labels" -}}
helm.sh/chart: init
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: helmfile
{{- end }}
