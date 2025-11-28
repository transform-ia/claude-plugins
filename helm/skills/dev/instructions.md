# Helm Chart Development Guidelines

## Critical: Hook Restrictions

**This context restricts operations to Helm chart files only.**

Allowed files:
- `Chart.yaml`, `values.yaml`
- `templates/*.yaml`, `templates/*.yml`, `templates/*.tpl`, `templates/NOTES.txt`
- `.helmignore`, `.yamllint.yaml`

When an operation is BLOCKED by hooks:
- This is EXPECTED behavior
- For README.md, use `/markdown:lint`
- For other files, exit the plugin context

## Available Commands

| Command | Purpose |
|---------|---------|
| `/helm:lint [dir]` | Run helm lint + yamllint |
| `/helm:format [dir]` | Format with prettier |
| `/helm:template [dir] [name]` | Preview rendered manifests |

For image tag discovery, use `/docker:image-tag`.

## Rules

1. **Linter runs automatically** when you finish. Fix all issues before completing.
2. **File restrictions:** Only helm chart files can be modified.
3. **templates/ directory:** MUST be ignored in .yamllint.yaml (Go templates, not valid YAML).
4. **NEVER use `latest` tag** - always pin to specific versions.
5. **NEVER use `pullPolicy: Always`** - use `IfNotPresent`.

## Chart Structure

```
chart/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── .yamllint.yaml      # YAML lint config (MUST ignore templates/)
├── .helmignore         # Files to exclude from package
└── templates/
    ├── _helpers.tpl    # Template helpers
    ├── NOTES.txt       # Post-install notes
    └── *.yaml          # Resource templates
```

## values.yaml Best Practices

**Keep values.yaml MINIMAL** - only include values users will override:

```yaml
# GOOD: Minimal values
image:
  repository: ghcr.io/org/app
  tag: ""  # Defaults to .Chart.AppVersion
  pullPolicy: IfNotPresent

replicas: 1

# BAD: Security settings in values.yaml (hardcode in templates instead)
# securityContext:
#   runAsNonRoot: true
```

## Required Values (No Defaults)

Environment-specific and security-critical values MUST require explicit input:

```yaml
# values.yaml
config:
  apiUrl: ""  # REQUIRED: API endpoint URL

# templates/deployment.yaml
{{- if not .Values.config.apiUrl }}
{{- fail "config.apiUrl is required" }}
{{- end }}
```

## yamllint Configuration

Every chart MUST have `.yamllint.yaml`:

```yaml
extends: default
ignore: |
  templates/    # REQUIRED: Go templates are not valid YAML
  charts/

rules:
  line-length:
    max: 120
    level: warning
  document-start: disable
```

## Image Tag Pattern

```yaml
# values.yaml
image:
  repository: ghcr.io/org/app
  tag: ""  # Defaults to .Chart.AppVersion
  pullPolicy: IfNotPresent

# template
image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
```

## Private Registry Authentication

For private GHCR images, use release-specific secret names:

```yaml
# values.yaml
registry:
  existingSecret: ""  # Use existing secret (recommended)
  username: ""        # Or create from credentials
  password: ""

# templates/_helpers.tpl
{{- define "myapp.imagePullSecrets" -}}
{{- if .Values.registry.existingSecret }}
- name: {{ .Values.registry.existingSecret }}
{{- else if and .Values.registry.username .Values.registry.password }}
- name: {{ include "myapp.fullname" . }}-ghcr
{{- end }}
{{- end }}
```

## Checksum Annotations

Add checksums for ConfigMaps/Secrets to trigger pod restarts on config changes:

```yaml
spec:
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
        checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
```

## Version Management

- `version`: Chart version - bump for template/structure changes
- `appVersion`: Application version - used as default image tag

**Bump versions instead of using `pullPolicy: Always`:**
- ✅ Bump `appVersion` when application image changes
- ✅ Bump `version` when templates change
- ❌ Never use `pullPolicy: Always` as a workaround

## Chart Naming (OCI Registries)

GHCR doesn't distinguish Docker images from Helm charts. Use suffixes:

```
Docker image: ghcr.io/org/myapp-image
Helm chart:   ghcr.io/org/myapp-chart
```

## Security Hardening

Hardcode security settings in templates (not values.yaml):

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: [ALL]
```

## Testing

```bash
# Render templates
helm template test . --debug

# Validate structure
helm lint .

# Dry-run against cluster
helm template test . | kubectl apply --dry-run=client -f -
```

## Out of Scope - Bail Out Immediately

**If the request does NOT involve Helm chart files, STOP and report:**

"This request is outside my scope. I handle Helm chart development only:
- Chart.yaml, values.yaml
- templates/*.yaml, templates/*.tpl
- .helmignore

For other file types, use the appropriate agent."
