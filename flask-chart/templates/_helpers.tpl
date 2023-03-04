{{/*
Generate common labels
*/}}
{{- define "flask-chart.labels" -}}
date: {{ now | htmlDate }}
chart: {{ .Chart.Name }}
version: {{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Labels for deployment
*/}}
{{- define "flask-chart.appLabels" -}}
app: flask-app
{{- end }} 

{{/*
Labels for stateful set
*/}}
{{- define "flask-chart.dbLabels" -}}
db: mysql-instance
{{- end }} 

{{/*
Tolerations for no scheduling on controller node
*/}}
{{- define "flask-chart.noSchedule" -}}
tolerations:
- key: kubernetes.io/hostname
  operator: Equal
  value: kind-control-plane
  effect: NoSchedule
{{- end }} 
