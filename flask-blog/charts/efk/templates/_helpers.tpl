{{/*
Expand the name of the chart.
*/}}
{{- define "efk.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "efk.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "efk.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the chart for elasticsearch resources
*/}}
{{- define "efk.elasticsearchName" -}}
{{- if .Values.elasticsearchNameOverride }}
{{- printf "%s-elasticsearch" .Values.elasticsearchNameOverride | trunc 63 }}
{{- else }}
{{- printf "%s-elasticsearch" (include "efk.name" . ) | trunc 63 }}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart for kibana resources
*/}}
{{- define "efk.kibanaName" -}}
{{- if .Values.kibanaNameOverride }}
{{- printf "%s-kibana" .Values.kibanaNameOverride | trunc 63 }}
{{- else }}
{{- printf "%s-kibana" (include "efk.name" .) | trunc 63 }}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart for fluentd resources
*/}}
{{- define "efk.fluentdName" -}}
{{- if .Values.fluentdNameOverride }}
{{- printf "%s-fluentd" .Values.fluentdNameOverride | trunc 63 }}
{{- else }}
{{- printf "%s-fluentd" (include "efk.name" .) | trunc 63 }}
{{- end }}
{{- end }}


{{/*
Common labels for ElasticSearch
*/}}
{{- define "efk.elasticsearch.labels" -}}
helm.sh/chart: {{ include "efk.chart" . }}
{{ include "efk.elasticsearch.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: blog-app
{{- end }}

{{/*
Common labels for Kibana
*/}}
{{- define "efk.kibana.labels" -}}
helm.sh/chart: {{ include "efk.chart" . }}
{{ include "efk.kibana.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: blog-app
{{- end }}

{{/*
Common labels for Fluentd
*/}}
{{- define "efk.fluentd.labels" -}}
helm.sh/chart: {{ include "efk.chart" . }}
{{ include "efk.fluentd.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: blog-app
{{- end }}

{{/*
Selector labels for ElasticSearch
*/}}
{{- define "efk.elasticsearch.selectorLabels" -}}
app.kubernetes.io/name: {{ include "efk.elasticsearchName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: flask-monitoring-stack
{{- end }}

{{/*
Selector labels for Kibana
*/}}
{{- define "efk.kibana.selectorLabels" -}}
app.kubernetes.io/name: {{ include "efk.kibanaName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: flask-monitoring-stack
{{- end }}

{{/*
Selector labels for Fluentd
*/}}
{{- define "efk.fluentd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "efk.fluentdName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: flask-monitoring-stack
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "efk.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "efk.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Retrieve Elasticsearch image using tag, digest of default AppVersion
*/}}
{{- define "efk.elasticsearch.getImage" -}}
{{- if .Values.elasticsearch.image.digest }}
{{ .Values.elasticsearch.image.repository }}@{{ .Values.elasticsearch.image.digest }}
{{- else }}
{{- .Values.elasticsearch.image.repository }}:{{- .Values.elasticsearch.image.tag }}
{{- end }}
{{- end }}

{{/*
Retrieve Kibana image using tag, digest of default AppVersion
*/}}
{{- define "efk.kibana.getImage" -}}
{{- if .Values.kibana.image.digest }}
{{ .Values.kibana.image.repository }}@{{ .Values.kibana.image.digest }}
{{- else }}
{{- .Values.kibana.image.repository }}:{{- .Values.kibana.image.tag }}
{{- end }}
{{- end }}

{{/*
Retrieve Fluentd image using tag, digest of default AppVersion
*/}}
{{- define "efk.fluentd.getImage" -}}
{{- if .Values.fluentd.image.digest }}
{{ .Values.fluentd.image.repository }}@{{ .Values.fluentd.image.digest }}
{{- else }}
{{- .Values.fluentd.image.repository }}:{{- .Values.fluentd.image.tag }}
{{- end }}
{{- end }}
