# Infrastructure Operations

## Ansible Deployments

All infrastructure changes are applied via Ansible playbooks running inside
Docker (`alpine/ansible:2.20.0`). The plugin wraps this in
`/infrastructure:cmd-deploy`.

### Safety Protocol

1. Always dry-run first (no `--apply` flag) and review the diff output
2. Only pass `--apply` after confirming the dry-run looks correct
3. Use `--limit` and `--tags` to scope changes when possible

### Usage

```bash
/infrastructure:cmd-deploy                              # Dry-run all hosts
/infrastructure:cmd-deploy --apply                      # Apply changes
/infrastructure:cmd-deploy --limit command-center       # Dry-run one host
/infrastructure:cmd-deploy --apply --limit command-center  # Apply on one host
/infrastructure:cmd-deploy --tags docker                # Dry-run specific playbook
```

Extra arguments are passed through to `ansible-playbook`.

## Infrastructure Status

Check running containers and services on remote hosts:

```bash
/infrastructure:cmd-status                    # Check all hosts
/infrastructure:cmd-status --host command-center  # Check one host
```

## Container Troubleshooting via SSH

When containers are misbehaving, SSH into the host to investigate:

```bash
# List running containers
ssh -p <port> root@<host> "docker ps"

# Check container logs
ssh -p <port> root@<host> "docker logs <container> --tail 100"

# Follow logs in real-time
ssh -p <port> root@<host> "docker logs <container> -f --tail 50"

# Restart a container
ssh -p <port> root@<host> "docker restart <container>"

# Execute a command inside a container
ssh -p <port> root@<host> "docker exec <container> <command>"

# Check container resource usage
ssh -p <port> root@<host> "docker stats --no-stream"

# Inspect container details
ssh -p <port> root@<host> "docker inspect <container>"
```

Host connection details (IP, port) are in the ansible inventory at
`inventory/host_vars/<hostname>.yaml`. Look for `ansible_host` and
`ansible_port` (defaults to 22 if not set).

## Scope Boundaries

This skill handles operational tasks: deploying, checking status,
troubleshooting.

- For creating or editing Dockerfiles and docker-compose files, defer to
  `/docker:skill-dev`
- For writing or modifying ansible playbooks, roles, or templates, use
  `infrastructure:skill-dev`
