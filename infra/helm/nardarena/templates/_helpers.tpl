{{- define "nardarena.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nardarena.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "nardarena.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "nardarena.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* Selector labels for one component: include "nardarena.selector" (list . "api") */}}
{{- define "nardarena.selector" -}}
{{- $root := index . 0 -}}
app.kubernetes.io/name: {{ include "nardarena.name" $root }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
app.kubernetes.io/component: {{ index . 1 }}
{{- end -}}

{{- define "nardarena.apiImage" -}}
{{ .Values.images.api.repository }}:{{ .Values.images.api.tag }}
{{- end -}}

{{/* Non-secret API settings as key: value lines (ConfigMap data). */}}
{{- define "nardarena.apiConfig" -}}
APP_URL: {{ .Values.api.url | quote }}
DB_CONNECTION: "mysql"
DB_HOST: {{ .Values.mysql.host | quote }}
DB_PORT: {{ .Values.mysql.port | quote }}
DB_DATABASE: {{ .Values.mysql.database | quote }}
DB_USERNAME: {{ .Values.mysql.username | quote }}
REDIS_HOST: {{ .Values.redis.host | quote }}
REDIS_PORT: {{ .Values.redis.port | quote }}
GAME_SERVER_URL: {{ printf "http://%s-game-server:8080" (include "nardarena.fullname" .) | quote }}
{{- range $k, $v := .Values.api.env }}
{{ $k }}: {{ $v | quote }}
{{- end }}
{{- end -}}

{{/* Secret env shared by API pods (all keys of the existing Secret). */}}
{{- define "nardarena.apiEnvFrom" -}}
- configMapRef:
    name: {{ include "nardarena.fullname" . }}-api
- secretRef:
    name: {{ .Values.secrets.name }}
{{- end -}}

{{- define "nardarena.podCommon" -}}
{{- with .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.podSecurityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Writable paths of the API image on a read-only root (ADR-047). Every pod
that runs the API image (api, scheduler, queue, migrate) mounts both; the
image's entrypoint recreates storage/'s layout in the empty volume.
*/}}
{{- define "nardarena.apiVolumes" -}}
- name: storage
  emptyDir:
    sizeLimit: {{ .Values.api.storageSizeLimit }}
- name: tmp
  emptyDir:
    sizeLimit: {{ .Values.api.tmpSizeLimit }}
{{- end -}}

{{- define "nardarena.apiVolumeMounts" -}}
- name: storage
  mountPath: /app/storage
- name: tmp
  mountPath: /tmp
{{- end -}}
