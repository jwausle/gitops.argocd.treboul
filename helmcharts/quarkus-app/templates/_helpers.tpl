{{/*
Expand the name of the chart.
*/}}
{{- define "quarkus-app.name" -}}
{{- $parts := regexSplit "/" .Values.image.repository -1 }}
{{- default (last $parts) .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "quarkus-app.fullname" -}}
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
{{- define "quarkus-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "quarkus-app.labels" -}}
helm.sh/chart: {{ include "quarkus-app.chart" . }}
{{ include "quarkus-app.selectorLabels" . }}
{{- if .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "quarkus-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "quarkus-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "quarkus-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "quarkus-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Extract the configured spring boot application port from either application properties
or from a specified environment variable
*/}}
{{- define "quarkus-app.userApplicationPort" -}}
{{- $extraEnv := fromYaml (printf "env: \n%s" (tpl .Values.extraEnv .)) -}}
{{- $appConfig := include "quarkus-app.mergedConfig" . | fromYaml -}}
{{- $serverPort := ($appConfig.server).port -}}
{{- range $extraEnv.env }}
{{- if eq .name "SERVER_PORT" }}
{{- $serverPort = .value }}
{{- end }}
{{- end }}
{{- if $serverPort }}
{{- $serverPort }}
{{- end }}
{{- end }}

{{/*
Provides the environment configuration for the server port of the spring boot application.
Might not output anything, if a port has been defined by the user of the chart
*/}}
{{- define "quarkus-app.applicationPortEnvironment" -}}
{{- $serverPort := include "quarkus-app.userApplicationPort" . -}}
{{- if not $serverPort }}
- name: SERVER_PORT
  value: {{ .Values.app.port | quote }}
{{- end }}
{{- end }}

{{/*
Extract the configured spring boot application port from either application properties
or from a specified environment variable or from the specified default value
*/}}
{{- define "quarkus-app.applicationPort" -}}
{{- $serverPort := include "quarkus-app.userApplicationPort" . -}}
{{- default .Values.app.port $serverPort }}
{{- end }}

{{/*
Merges the configurations specified in app.config and app.rawConfig
*/}}
{{- define "quarkus-app.mergedConfig" -}}
{{- $mergedConfig := mustMerge (default dict .Values.app.config) (tpl .Values.app.rawConfig . | fromYaml) }}
{{- if eq 0 (len $mergedConfig) }}
{{- "# No configuration specified" }}
{{- else }}
{{- $mergedConfig | toYaml | trim }}
{{- end }}
{{- end }}

{{/*
Extracts the configured context path from the spring boot application properties
*/}}
{{- define "quarkus-app.contextPath" -}}
{{- $mergedConfig := mustMerge (default dict .Values.app.config) (tpl .Values.app.rawConfig . | fromYaml) }}
{{- $servletConfig := ($mergedConfig.server).servlet }}
{{- if $servletConfig }}
{{- trimSuffix "/" (index (($mergedConfig.server).servlet) "context-path") }}
{{- end }}
{{- end }}

{{/*
Merge user defined secrets with default secrets
*/}}
{{- define "quarkus-app.secrets" -}}
{{- $secrets := .Values.app.secrets }}
secrets:
{{- $secrets | toYaml | nindent 2 }}
{{- end }}