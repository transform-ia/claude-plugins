# Infrastructure Development

## Ansible Repo Design Principles

- **Flat inventory**: `inventory/hosts.yaml` contains only host names. All
  configuration lives in `inventory/host_vars/<hostname>.yaml`.
- **Skip pattern**: Playbooks target `hosts: all` and skip hosts that lack the
  relevant vars (e.g., `when: wg is not defined` then `meta: end_host`). No
  host groups needed.
- **Single entrypoint**: `site.yaml` imports all playbooks in order. The plugin
  command `/infrastructure:deploy` wraps it in Docker.
- **No code duplication**: One playbook per concern, templated by role (e.g.,
  `wg.role: server|client`).

## Adding a New Host

1. Add hostname to `inventory/hosts.yaml`
2. Create `inventory/host_vars/<hostname>.yaml` with `ansible_host` and any
   playbook-specific vars (e.g., `wg`, `docker`, `postgresql`)
3. Run `/infrastructure:deploy --limit <hostname>` to verify (dry-run)

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
  (`/docker:container`)

## Cloudflare DNS Zone Management

DNS zones are managed as YAML data files in `playbooks/cloudflare/zones/`.
The playbook applies declared records then **purges** any Cloudflare records
not present in the file (except NS, SOA, and `_acme-challenge` TXT records).

### Zone file location

One file per domain: `playbooks/cloudflare/zones/<domain>.yaml`

Existing zones: `robotinfra.com`, `transformia.ca`, `tournevent.ca`,
`bit-flippers.com`, `agpad.app`, `afkcollection.com`, `crawford-alexander.com`

### Zone file format

```yaml
---
dns_records:
  - type: A
    name: td              # subdomain, or "@" for apex
    content: "1.2.3.4"
    ttl: 300              # optional, default 1 (auto)
  - type: CNAME
    name: www
    content: td.example.com
  - type: MX
    name: "@"
    content: aspmx.l.google.com
    priority: 1           # required for MX
    ttl: 3600
  - type: TXT
    name: "@"
    content: "v=spf1 mx ~all"
    ttl: 3600
```

Supported optional fields: `ttl` (default auto), `proxied` (default false),
`priority`, `weight`, `port`, `service`, `proto` (for SRV records).

### Adding a new DNS record

1. Edit `playbooks/cloudflare/zones/<domain>.yaml`
2. Add the record entry under `dns_records`
3. Dry-run: `/infrastructure:deploy --tags cloudflare`
4. Review the diff, then apply: `/infrastructure:deploy --tags cloudflare --apply`

### Removing a DNS record

Delete the entry from the zone file. The purge step will remove it from
Cloudflare on the next apply run.

### Adding a new zone

1. Create `playbooks/cloudflare/zones/<new-domain>.yaml` with a `dns_records`
   list
2. Add `<new-domain>` (without `.yaml`) to the `cloudflare.zones` list in
   the host vars of the host that manages Cloudflare
3. Dry-run and apply as above

### Important behavior

- **Purge is destructive**: any record in Cloudflare not declared in the YAML
  file will be deleted on apply (except NS, SOA, `_acme-challenge`)
- Always dry-run first to review which records would be purged
- The `community.general.cloudflare_dns` module silently succeeds if an
  identical record already exists

## Validation

Always validate changes with a dry-run before applying:

```bash
/infrastructure:deploy --limit <host>          # Dry-run specific host
/infrastructure:deploy --tags <playbook>       # Dry-run specific playbook
```

Review the diff output carefully before running with `--apply`.
