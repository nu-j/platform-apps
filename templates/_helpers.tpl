{{- define "default.variables" -}}
{{- $_ := set .vars "repoURL" (default "" .appConfig.repoURL) -}}
{{- $_ := set .vars "chart" (default false .appConfig.chart) -}}
{{- $_ := set .vars "path" (default false .appConfig.path) -}}
{{- $_ := set .vars "targetRevision" (default "main" .appConfig.targetRevision) -}}
{{- $_ := set .vars "platformSyncPolicy" (default false ((.Values.platform).argocd).syncPolicy) -}}
{{- $_ := set .vars "customSyncPolicy" (default false ((.appConfig).syncPolicy)) -}}
{{- $_ := set .vars "platformVersion" (required "platform.version is required" (.Values.platform).version) -}}
{{- $_ := set .vars "clusterType" .Values.clusterType -}}
{{- $_ := set .vars "clusterGroup" .Values.clusterGroup -}}
{{- $_ := set .vars "clusterName" .Values.clusterName -}}
{{- $_ := set .vars "region" .Values.region -}}
{{- $_ := set .vars "baseDomain" .Values.platform.baseDomain -}}
{{- $_ := set .vars "destinationNamespace" (default "platform-tools" (.appConfig.destination).namespace) -}}
{{- end -}}

{{- define "default.valueFiles" -}}
{{- /*
  Four-layer merge (each later file overrides earlier keys):
    1. default.yaml          — global defaults for every cluster
    2. regions/<r>/region.yaml — region-level overrides (DNS, cloud config, etc.)
    3. clusters/<type>/common.yaml — per-environment defaults (dev / preprod / prod / hub)
    4. clusters/<type>/<group>/clusterdef.yaml — single cluster definition (one folder = one cluster)

  ignoreMissingValueFiles is set on callers, so absent files are silently skipped.
*/ -}}
- $platform_values/default.yaml
- $platform_values/regions/{{ .vars.region }}/region.yaml
- $platform_values/clusters/{{ .vars.clusterType }}/common.yaml
- $platform_values/clusters/{{ .vars.clusterType }}/{{ .vars.clusterGroup }}/clusterdef.yaml
{{- end -}}