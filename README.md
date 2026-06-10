# platform-apps

Spoke app-of-apps Helm chart. **Installed by Argo CD automatically** — you do not `helm install` this directly. The `spoke-argocd-bootstrap` chart creates a root `Application` on each spoke that points here.

## What it does

The repo root chart (`Chart.yaml` + `templates/`) renders Argo CD `Application` CRs — one per platform component enabled in `platform-config`. It does **not** contain any workload manifests.

Leaf charts (actual K8s resources) live in the **helm-catalog** repo.

## Template layout

`_helpers.tpl` stays at `templates/` root. Templates are split into three directories by cluster scope:

```
templates/
├── _helpers.tpl          # shared helpers (default.variables, default.valueFiles)
├── hub/                  # rendered only when clusterType=hub
│   └── advanced-cluster-security-app.yaml
├── spoke/                # rendered only when clusterType!=hub
│   ├── capabilities/     # consumer-facing platform services (Reloader, Strimzi, etc.)
│   │   └── stakater-reloader-app.yaml
│   ├── devspaces-app.yaml
│   └── rosa-machine-pool-app.yaml
└── shared/               # rendered for all cluster types
    ├── alertmanager-config-app.yaml
    ├── cluster-banner-app.yaml
    └── operator-installer-app.yaml
```

Hub and spoke templates carry `clusterType` guards at the top. `repoURL`, `path`, and `targetRevision` are baked into each template as defaults — override them from `platform-config` only when needed (e.g. to pin a chart version per cluster).

**Directory intent:**
- `hub/` — management-plane tools (ACS, future ACM integrations)
- `spoke/capabilities/` — consumer-facing platform services offered to development teams
- `spoke/` root — spoke infrastructure (ROSA MachinePools, future node-level tooling)
- `shared/` — cross-cutting concerns that apply to all cluster types

## Local render (dry-run / review)

Values come from `platform-config` via Argo multi-source in production. For local review, supply the config files directly:

```bash
helm template platform . \
  -f ../platform-config/default.yaml \
  -f ../platform-config/clusters/dev/common.yaml
```

## Adding a new platform component

1. Add `platform.argocdApps.<name>` entry (`repoURL`, `path`, `enabled`) to `platform-config/default.yaml`.
2. Add `templates/<domain>/<name>-app.yaml` using helpers from `_helpers.tpl`.
3. Add the Helm chart itself to `helm-catalog/<name>/`.
4. Push all three repos; Argo CD picks up the new app on next sync.
