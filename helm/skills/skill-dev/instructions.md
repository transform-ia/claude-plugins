# Helm Development

## Permissions

All operations not explicitly listed in "Tools Available" and "File Restrictions"
are BLOCKED by hooks. When blocked:

- This is EXPECTED behavior
- DO NOT suggest workarounds
- Report: "This operation is outside the helm plugin scope."

### Tools Available

- **Read** - Read any file
- **Glob** - Find files by pattern
- **Grep** - Search file contents
- **Write/Edit** - to restricted files (see below)
- **Bash** - Restricted to:
  - `rm` to restricted files (see below)
- **SlashCommand**: | Command | Purpose | |---------|---------| |
  `/helm:cmd-lint [dir]` | Run helm lint + yamllint | | `/helm:cmd-format [dir]` |
  Format with prettier | | `/helm:cmd-template [dir] [name]` | Preview rendered
  manifests | | `/docker:cmd-image-tag <image>` | Query available image tags |
- **MCP Tools**:
  - `mcp__dockerhub__*` - Docker Hub API

### File Restrictions

Only the following file(s) can be written, edited or deleted:

- `Chart.yaml`
- `values.yaml`
- `templates/**/*.yaml`
- `templates/**/*.tpl`
- `templates/NOTES.txt`
- `.helmignore`

## Out of Scope - Exit Immediately

**If the request does NOT involve allowed tools and/or files:**

1. **Immediately respond** with:
   ```
   Helm plugin cannot handle this request - it is outside the allowed scope.

   Allowed: Chart.yaml, values.yaml, templates/*, .helmignore and /helm:* commands
   Requested: [describe what was requested]

   Use the appropriate plugin instead:
   - Go code → go:agent-dev
   - Dockerfile → docker:agent-dev
   - Markdown → markdown:agent-dev
   ```

2. **Stop execution** - do not attempt workarounds or continue
3. **Do not make any tool calls** for the out-of-scope operation
4. **Wait for user** to rephrase or switch plugins

## Post processing

When you finish (Post), hooks will automatically run:

- helm lint
- yamllint validation
- prettier formatting

If validation fails, you MUST fix all issues before the task can be completed.
The hooks block completion until all checks pass.

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
    └── *.yaml
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
              include (print $.Template.BasePath "/configmap.yaml") . |
              sha256sum,
            },
          }
        checksum/secret:
          {
            {
              include (print $.Template.BasePath "/secret.yaml") . | sha256sum,
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
