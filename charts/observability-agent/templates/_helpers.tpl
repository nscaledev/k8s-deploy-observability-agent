{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "observability-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "observability-agent.labels" -}}
helm.sh/chart: {{ include "observability-agent.chart" . }}
{{ include "observability-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "observability-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Service account name for cleanup job */}}
{{- define "observability-agent.cleanupServiceAccount" -}}
{{ printf "%s-cleanup" .Release.Name }}
{{- end }}
