{{- define "default.variables" -}}
{{- $_ := set .vars "repoURL" (required "repoURL missing" .appConfig.repoURL) -}}
{{- $_ := set .vars "chart" (default false .appConfig.chart) -}}
{{- $_ := set .vars "path" (default false .appConfig.path) -}}
{{- $_ := set .vars "targetRevision" (required "targetRevision missing" .appConfig.targetRevision) -}}
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
- $platform_values/default.yaml
- $platform_values/regions/{{ .vars.region }}/region.yaml
- $platform_values/clusters/{{ .vars.clusterType }}/common.yaml
- $platform_values/clusters/{{ .vars.clusterType }}/{{ .vars.clusterGroup }}/groupdef.yaml
- $platform_values/clusters/{{ .vars.clusterType }}/{{ .vars.clusterGroup }}/{{ .vars.region }}/clusterdef.yaml
{{- end -}}