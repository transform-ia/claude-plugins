# Helm Development

## File Extensions

**IMPORTANT: All Helm template files MUST use `.tpl` extension**

Kubernetes manifest templates should be named:
- `deployment.tpl` (NOT deployment.yaml)
- `service.tpl` (NOT service.yaml)
- `configmap.tpl` (NOT configmap.yaml)
- etc.

**Rationale:**
- `.yaml` files get reformatted by prettier, breaking Go template syntax
- yamllint produces false positives on unrendered Go templates
- `.tpl` extension clearly indicates "template file" to all tools

**Exceptions:**
- `Chart.yaml` - Helm chart metadata (plain YAML, not a template)
- `values.yaml` - Default values (plain YAML, not a template)
- `_helpers.tpl` - Template helpers (already uses .tpl by convention)
- `NOTES.txt` - Installation notes (plain text, not YAML)

## Standards

### NEVER

- Use `latest` tag - always pin to specific versions
- Use `pullPolicy: Always` - use `IfNotPresent`
- Put security settings in values.yaml - hardcode in templates

### ALWAYS

- Keep values.yaml minimal - only user-overridable values
- Hardcode security context in templates
- Use `.Chart.AppVersion` as default image tag

## Chart Structure

```text
chart/
├── Chart.yaml
├── values.yaml
├── .helmignore
└── templates/
    ├── _helpers.tpl
    ├── NOTES.txt
    └── *.tpl
```

## Patterns

### values.yaml (MINIMAL)

```yaml
image:
  repository: ghcr.io/org/app
  tag: "" # Defaults to .Chart.AppVersion
  pullPolicy: IfNotPresent

replicas: 1
```

### Image Tag in Template

```yaml
image:
  "{{ .Values.image.repository }}:{{ .Values.image.tag | default
  .Chart.AppVersion }}"
```

### Security Context (HARDCODED in templates)

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: [ALL]
```

### Private Registry Authentication

```yaml
# values.yaml
registry:
  username: ""
  password: ""

# templates/_helpers.tpl
{{- define "myapp.imagePullSecrets" -}}
{{- if and .Values.registry.username .Values.registry.password }}
- name: {{ include "myapp.fullname" . }}-ghcr
{{- end }}
{{- end }}
```

### Checksum Annotations

Trigger pod restarts on config changes:

```yaml
spec:
  template:
    metadata:
      annotations:
        checksum/config:
          {
            {
              include (print $.Template.BasePath "/configmap.tpl") . |
              sha256sum,
            },
          }
        checksum/secret:
          {
            {
              include (print $.Template.BasePath "/secret.tpl") . | sha256sum,
            },
          }
```

### Required Values

```yaml
# values.yaml
config:
  apiUrl: "" # REQUIRED

# template
{{- if not .Values.config.apiUrl }}
{{- fail "config.apiUrl is required" }}
{{- end }}
```

## Version Management

- `version`: Chart version - bump for template changes
- `appVersion`: Application version - default image tag

## Getting Latest Versions

**To find the latest version of a Docker image or Helm chart before updating:**

- **Docker Hub images**: `/docker:cmd-image-tag <image>` (e.g., `/docker:cmd-image-tag nginx`)
- **GHCR images**: `/docker:cmd-image-tag ghcr.io/<org>/<repo>`
- **GHCR from git tags**: `/github:cmd-latest-version <path>` - gets latest semantic version tag from a git repository

**Use cases in Helm charts:**

1. **Update appVersion** - get latest app image tag:
   ```text
   /docker:cmd-image-tag ghcr.io/transform-ia/myapp
   ```

2. **Update dependency chart** - get latest chart version:
   ```text
   /github:cmd-latest-version /path/to/dependency-chart
   ```

3. **Check upstream images** - before updating values.yaml defaults:
   ```text
   /docker:cmd-image-tag redis
   /docker:cmd-image-tag postgres
   ```
