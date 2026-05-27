# platform-apps

Spoke app-of-apps Helm chart. **Installed by Argo CD automatically** — you do not `helm install` this directly. The `spoke-argocd-bootstrap` chart creates a root `Application` on each spoke that points here.

## What it does

The repo root chart (`Chart.yaml` + `templates/`) renders Argo CD `Application` CRs — one per platform component enabled in `platform-config`. It does **not** contain any workload manifests.

Leaf charts (actual K8s resources) live in the **helm-catalog** repo.

## Template layout

`_helpers.tpl` stays at `templates/` root. Domain subdirs group application templates by concern:

```
templates/
├── _helpers.tpl                                  # shared helpers (default.variables, default.valueFiles)
├── infra/                                        # cluster node infrastructure
│   └── rosa-machine-pool-app.yaml
├── observability/                                # monitoring, alerting, logging
│   └── alertmanager-config-app.yaml
├── security/                                     # ACS, certs, auth
│   └── advanced-cluster-security-app.yaml
├── capabilities/                                 # developer platform services
│   ├── platform-tools-argocd-app.yaml
│   └── stakater-reloader-app.yaml
└── operators/                                    # OLM operator lifecycle
    └── operator-installer-app.yaml
```

New templates go into the matching domain subdir. `platform-config` keys remain flat (`platform.argocdApps.*`).

## Local render (dry-run / review)

Values come from `platform-config` via Argo multi-source in production. For local review, supply the config files directly:

```bash
helm template platform . \
  -f ../platform-config/default.yaml \
  -f ../platform-config/dev/common.yaml
```

## Adding a new platform component

1. Add `platform.argocdApps.<name>` entry (`repoURL`, `path`, `enabled`) to `platform-config/default.yaml`.
2. Add `templates/<domain>/<name>-app.yaml` using helpers from `_helpers.tpl`.
3. Add the Helm chart itself to `helm-catalog/<name>/`.
4. Push all three repos; Argo CD picks up the new app on next sync.
