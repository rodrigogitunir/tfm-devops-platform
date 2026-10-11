{{- define "tfm-devops-app.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "tfm-devops-app.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "tfm-devops-app.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "tfm-devops-app.labels" -}}
app.kubernetes.io/name: {{ include "tfm-devops-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.application.version | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
{{- end }}

{{- define "tfm-devops-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfm-devops-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
