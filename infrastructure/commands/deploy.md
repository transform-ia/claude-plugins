---
description: "Run ansible playbook: /infrastructure:deploy [--apply] [--limit host] [--tags tag] [host]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/deploy.sh *)]
---

# Ansible Playbook Run

## Permissions

This command runs ansible playbooks via Docker. Default is dry-run (`--check --diff`).

---

## Safety Rules

1. ALWAYS dry-run first (no `--apply` flag)
2. Review the diff output before applying
3. Use `--limit` and `--tags` to scope changes
4. Only pass `--apply` after confirming the dry-run looks correct

---

Run the ansible playbook using the plugin script.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/deploy.sh $ARGUMENTS")
```
