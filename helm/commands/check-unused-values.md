---
description: "Find unused values: /helm:check-unused-values [directory]"
allowed-tools: [Read, Bash, Grep, Glob]
---
Check for values in values*.yaml that are not referenced in templates.

## Task

1. **Read values files**: Find all `values*.yaml` files in the chart directory
2. **Extract value paths**: Parse YAML to get all dotted paths (e.g., `image.repository`, `config.apiUrl`)
3. **Search templates**: For each value path, search `templates/` for `.Values.<path>` references
4. **Report unused**: List any values that exist in values.yaml but have no template references

## Analysis Method

```bash
# Get all value references from templates
grep -rho '\.Values\.[a-zA-Z0-9_.]*' templates/ | sort -u
```

Compare against keys in values.yaml. Report any keys not found in template references.

## Output

For each unused value found:
- Show the full path (e.g., `config.oldSetting`)
- Recommend removal if truly unused
- Note if it might be used via `index` or dynamic access

If cleanup is needed, offer to remove the unused values.
