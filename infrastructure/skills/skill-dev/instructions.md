# Infrastructure Development

## Ansible Repo Design Principles

- **Flat inventory**: `inventory/hosts.yaml` contains only host names. All
  configuration lives in `inventory/host_vars/<hostname>.yaml`.
- **Skip pattern**: Playbooks target `hosts: all` and skip hosts that lack the
  relevant vars (e.g., `when: wg is not defined` then `meta: end_host`). No
  host groups needed.
- **Single entrypoint**: `site.yaml` imports all playbooks in order. The plugin
  command `/infrastructure:cmd-run` wraps it in Docker.
- **No code duplication**: One playbook per concern, templated by role (e.g.,
  `wg.role: server|client`).

## Adding a New Host

1. Add hostname to `inventory/hosts.yaml`
2. Create `inventory/host_vars/<hostname>.yaml` with `ansible_host` and any
   playbook-specific vars (e.g., `wg`, `docker`, `postgresql`)
3. Run `/infrastructure:cmd-run --limit <hostname>` to verify (dry-run)

## Adding a New Playbook

1. Create playbook under `playbooks/` with `hosts: all`
2. Add skip condition at the start:
   ```yaml
   - hosts: all
     tasks:
       - meta: end_host
         when: my_var is not defined
       # ... actual tasks
   ```
3. Add `import_playbook` line to `site.yaml` in the correct order

## Template Conventions

- Use Jinja2 `.j2` extension for all templates
- Per-host docker-compose templates go in
  `playbooks/docker/templates/<hostname>.j2`
- Templates are rendered by ansible and deployed to target hosts
- For Dockerfile best practices inside templates, defer to the docker plugin
  (`/docker:skill-dev`)

## Cloudflare DNS Zone Management

DNS zones are managed as YAML data files in `playbooks/cloudflare/zones/`.

- One file per domain: `zones/<domain>.yaml`
- Contains all DNS records (A, CNAME, MX, TXT)
- **GitOps pattern**: Records in Cloudflare that are not declared in the YAML
  file get purged (except NS, SOA, and ACME-challenge records)
- To update DNS: edit the zone file, then run
  `/infrastructure:cmd-run --tags cloudflare`

## Validation

Always validate changes with a dry-run before applying:

```bash
/infrastructure:cmd-run --limit <host>          # Dry-run specific host
/infrastructure:cmd-run --tags <playbook>       # Dry-run specific playbook
```

Review the diff output carefully before running with `--apply`.
