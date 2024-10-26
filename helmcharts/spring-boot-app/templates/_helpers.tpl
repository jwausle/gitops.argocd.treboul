{{/*
Expand the name of the chart.
*/}}
{{- define "spring-boot-app.name" -}}
{{- $parts := regexSplit "/" .Values.image.repository -1 }}
{{- default (last $parts) .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spring-boot-app.fullname" -}}
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
{{- define "spring-boot-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spring-boot-app.labels" -}}
helm.sh/chart: {{ include "spring-boot-app.chart" . }}
{{ include "spring-boot-app.selectorLabels" . }}
{{- if .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "spring-boot-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spring-boot-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "spring-boot-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "spring-boot-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Extract the configured spring boot application port from either application properties
or from a specified environment variable
*/}}
{{- define "spring-boot-app.userApplicationPort" -}}
{{- $extraEnv := fromYaml (printf "env: \n%s" (tpl .Values.extraEnv .)) -}}
{{- $appConfig := include "spring-boot-app.mergedConfig" . | fromYaml -}}
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
{{- define "spring-boot-app.applicationPortEnvironment" -}}
{{- $serverPort := include "spring-boot-app.userApplicationPort" . -}}
{{- if not $serverPort }}
- name: SERVER_PORT
  value: {{ .Values.app.port | quote }}
{{- end }}
{{- end }}

{{/*
Extract the configured spring boot application port from either application properties
or from a specified environment variable or from the specified default value
*/}}
{{- define "spring-boot-app.applicationPort" -}}
{{- $serverPort := include "spring-boot-app.userApplicationPort" . -}}
{{- default .Values.app.port $serverPort }}
{{- end }}

{{/*
Merges the configurations specified in app.config and app.rawConfig
*/}}
{{- define "spring-boot-app.mergedConfig" -}}
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
{{- define "spring-boot-app.contextPath" -}}
{{- $mergedConfig := mustMerge (default dict .Values.app.config) (tpl .Values.app.rawConfig . | fromYaml) }}
{{- $servletConfig := ($mergedConfig.server).servlet }}
{{- if $servletConfig }}
{{- trimSuffix "/" (index (($mergedConfig.server).servlet) "context-path") }}
{{- end }}
{{- end }}

{{/*
Merge user defined secrets with default secrets
*/}}
{{- define "spring-boot-app.secrets" -}}
{{- $secrets := .Values.app.secrets }}
{{- if .Values.app.defaultSecrets }}
{{- range $key, $secretDetails := .Values.app.defaultSecrets }}
{{- if $secretDetails.enabled }}
{{- $secrets = append $secrets $secretDetails.spec }}
{{- end }}
{{- end }}
{{- end }}
secrets:
{{- $secrets | toYaml | nindent 2 }}
{{- end }}