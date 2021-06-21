{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "standard-labels" -}}
app: {{ template "fullname" . }}
{{ include "standard-labels-no-app" .}}
{{- end -}}

{{- define "standard-labels-no-app" -}}
chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Database engine
*/}}
{{- define "dbEngineName" -}}
{{- if .Values.mariadb.enabled -}}
{{- printf "mariadb" -}}
{{- else if .Values.mysql.enabled -}}
{{- printf "mysql" -}}
{{- else if .Values.postgresql.enabled -}}
{{- printf "postgresql" -}}
{{- else -}}
{{- printf "ext" -}}
{{- end -}}
{{- end -}}

{{/*
Expand the database user
*/}}
{{- define "databaseUser" -}}
{{- $engine := include "dbEngineName" . }}
{{- $dbKey := dict "mysql" .Values.mysql.mysqlUser "mariadb" .Values.mariadb.auth.username "postgresql" .Values.postgresql.postgresqlUsername "ext" .Values.externalDB.user -}}
{{- printf "%s" (get $dbKey $engine) | quote }}
{{- end -}}

{{/*
Expand the database password
*/}}
{{- define "databasePassword" -}}
{{- $engine := include "dbEngineName" . -}}
{{- $dbKey := dict "mysql" .Values.mysql.mysqlPassword "mariadb" .Values.mariadb.auth.password "postgresql" .Values.postgresql.postgresqlPassword "ext" .Values.externalDB.password -}}
{{- printf "%s" (get $dbKey $engine) | quote -}}
{{- end -}}

{{/*
Expand the database host
*/}}
{{- define "databaseHost" -}}
{{- $engine := include "dbEngineName" . -}}
{{ if eq $engine "ext" -}}
{{- printf "%s" .Values.externalDB.host | quote -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $engine | quote -}}
{{- end -}}
{{- end -}}

{{/*
Expand the database "database"
*/}}
{{- define "databaseDatabase" -}}
{{- $engine := include "dbEngineName" . -}}
{{- $dbKey := dict "mysql" .Values.mysql.mysqlDatabase "mariadb" .Values.mariadb.auth.database "postgresql" .Values.postgresql.postgresqlDatabase "ext" .Values.externalDB.database -}}
{{- printf "%s" (get $dbKey $engine) | quote -}}
{{- end -}}

{{/*
Expand the deployment app name
*/}}
{{- define "fullAppName" -}}
{{- $engine := include "dbEngineName" . -}}
{{ if eq $engine "ext" -}}
{{- printf "%s-%s-%s-%s" .Values.image.name .Chart.AppVersion .Values.image.wikiversion .Values.image.tag | quote -}}
{{- else -}}
{{- printf "%s-%s-%s-%s-tomcat XXXXX" .Values.image.name .Chart.AppVersion .Values.image.wikiversion $engine | quote -}}
{{- end -}}
{{- end -}}

{{/*
XWiki image name db
*/}}
{{- define "xwikiImageName" -}}
{{- $engine := include "dbEngineName" . -}}
{{- $imageInfix := dict "mysql" "mysql"  "mariadb" "mysql"  "postgresql" "postgres" -}}
{{- if eq $engine "ext" -}}
{{- printf "%s:%s" .Values.image.name .Values.image.tag -}}
{{- else -}}
{{- printf "%s:%s-%s-tomcat" .Values.image.name .Values.image.wikiversion (get $imageInfix $engine) -}}
{{- end -}}
{{- end -}}

{{/*
Database secret name holding the password
*/}}
{{- define "dbSecretRefName" -}}
{{- $engine := include "dbEngineName" . -}}
{{ if eq $engine "ext" -}}
{{- printf "%s" .Release.Name | quote -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $engine | quote -}}
{{- end -}}
{{- end -}}


{{/*
Database secret key holding the password
*/}}
{{- define "dbSecretRefKey" -}}
{{- $engine := include "dbEngineName" . -}}
{{ if eq $engine "ext" -}}
{{- printf "DB_PASSWORD" -}}
{{- else -}}
{{- printf "%s-password" $engine | quote -}}
{{- end -}}
{{- end -}}