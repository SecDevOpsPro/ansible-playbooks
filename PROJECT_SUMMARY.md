# Ansible Playbook Examples - Project Summary

## Overview

This project provides **production-ready Ansible playbooks** for automating infrastructure deployment, configuration management, and security hardening. All playbooks follow best practices with idempotency, security-first design, and comprehensive testing.

## Quick Start

```bash
# 1. Install dependencies
make install-deps

# 2. Configure inventory
cp inventory/hosts.example inventory/hosts
nano inventory/hosts  # Add your servers

# 3. Set up vault for secrets
cp group_vars/production/vault.yml.example group_vars/production/vault.yml
ansible-vault encrypt group_vars/production/vault.yml

# 4. Test connectivity
make ping

# 5. Run playbook
ansible-playbook -i inventory/production playbooks/nginx-setup.yml --ask-vault-pass
```

## Available Playbooks (12 Total)

### Infrastructure Setup

1. **nginx-setup.yml** - NGINX web server with TLS/SSL support
2. **mysql-setup.yml** - MySQL 8.0 with replication configuration
3. **postgresql-setup.yml** - PostgreSQL 15 with streaming replication
4. **docker-install.yml** - Docker Engine + Docker Compose installation
5. **redis-cluster.yml** - Redis cluster (3 masters + 3 replicas)

### Kubernetes

1. **kubernetes-node.yml** - Prepare nodes for Kubernetes cluster

### Security

1. **ubuntu-hardening.yml** - CIS Ubuntu Benchmark compliance
2. **fail2ban-setup.yml** - Intrusion prevention system

### Monitoring

1. **prometheus-node-exporter.yml** - Metrics collection agent
2. **grafana-setup.yml** - Grafana dashboard server

### Application Deployment

1. **nodejs-app.yml** - Node.js application with PM2 process manager
2. **multi-tier-app.yml** - Complete multi-tier application deployment (LB + App + DB)

## Project Structure

```text
ansible-playbooks/
├── playbooks/              # Main playbooks (12 files)
├── roles/                  # Reusable roles
│   ├── common/            # Base system configuration
│   ├── nginx/             # NGINX web server role
│   ├── mysql/             # MySQL database role
│   ├── docker/            # Docker runtime role
│   ├── security/          # Security hardening role
│   └── firewall/          # UFW firewall configuration
├── inventory/
│   ├── hosts.example      # Example inventory
│   ├── production         # Production inventory
│   └── staging            # Staging inventory
├── group_vars/            # Variables by group
│   ├── all.yml           # Global variables
│   ├── web.yml           # Web server variables
│   ├── db.yml            # Database variables
│   ├── app.yml           # Application server variables
│   ├── cache.yml         # Redis cache variables
│   ├── monitoring.yml    # Monitoring variables
│   └── production/
│       └── vault.yml     # Encrypted secrets
├── templates/             # Jinja2 configuration templates
│   ├── nginx.conf.j2
│   ├── nginx-vhost.conf.j2
│   ├── nginx-loadbalancer.conf.j2
│   ├── my.cnf.j2
│   ├── fail2ban-jail.local.j2
│   ├── ecosystem.config.js.j2
│   ├── mysql-backup.sh.j2
│   └── 50unattended-upgrades.j2
├── ansible.cfg            # Ansible configuration
└── Makefile              # Common commands
```

## Key Features

### ✅ Production-Ready

- Idempotent playbooks (safe to run multiple times)
- Comprehensive error handling
- Service health checks
- Post-deployment verification

### ✅ Security-First

- Ansible Vault for secrets management
- SSH hardening (disable root, password auth)
- UFW firewall rules
- Fail2ban intrusion prevention
- Unattended security updates
- Non-root service accounts

### ✅ Multi-Environment Support

- Separate inventories for staging/production
- Environment-specific variables
- Group-based configuration
- Role-based access control

### ✅ CI/CD Integration

- GitLab CI pipeline (`.gitlab-ci.yml`)
- GitHub Actions workflow (`.github/workflows/ansible-ci.yml`)
- Automated linting and testing
- Manual production deployment approval

## Common Tasks

### Run a Playbook

```bash
# Staging
ansible-playbook -i inventory/staging playbooks/nginx-setup.yml --ask-vault-pass

# Production (dry-run first)
ansible-playbook -i inventory/production playbooks/nginx-setup.yml --check --diff --ask-vault-pass

# Production (actual deployment)
ansible-playbook -i inventory/production playbooks/nginx-setup.yml --ask-vault-pass
```

### Vault Management

```bash
# Create encrypted vault
ansible-vault create group_vars/production/vault.yml

# Edit encrypted vault
ansible-vault edit group_vars/production/vault.yml

# Encrypt existing file
ansible-vault encrypt group_vars/production/secrets.yml

# Encrypt string
ansible-vault encrypt_string 'MySecretPassword' --name 'vault_mysql_root_password'
```

### Testing

```bash
# Syntax check
make syntax-check

# Lint all playbooks
make lint

# Full test suite
make test

# Check specific playbook
ansible-playbook --syntax-check playbooks/nginx-setup.yml
ansible-lint playbooks/nginx-setup.yml
```

### Inventory Management

```bash
# List all hosts
ansible-inventory -i inventory/production --list

# List specific group
ansible-inventory -i inventory/production --graph web_servers

# Ping all hosts
ansible all -i inventory/production -m ping

# Run ad-hoc command
ansible web_servers -i inventory/production -a "uptime"
```

## Variable Precedence

Variables can be defined at multiple levels (highest to lowest precedence):

1. **Extra vars**: `-e "variable=value"`
2. **Playbook vars**: `vars:` section in playbook
3. **Role vars**: `roles/*/vars/main.yml`
4. **Inventory vars**: `inventory/*/host_vars/` or `group_vars/`
5. **Role defaults**: `roles/*/defaults/main.yml`

## Ansible Vault Pattern

```yaml
# group_vars/production/vars.yml (unencrypted)
mysql_root_password: "{{ vault_mysql_root_password }}"
api_key: "{{ vault_api_key }}"

# group_vars/production/vault.yml (encrypted)
vault_mysql_root_password: "SuperSecretPassword123!"
vault_api_key: "abc123xyz789"
```

## Role Dependencies

Common roles should be applied first, then specific roles:

```yaml
roles:
  - common           # Base system setup
  - firewall         # UFW firewall
  - security         # Security hardening
  - nginx            # NGINX web server
```

## Playbook Execution Order

Multi-tier deployments follow this order:

1. **Base setup** (all hosts): common, firewall, security
2. **Database servers**: MySQL, PostgreSQL, Redis
3. **Application servers**: Node.js, Python, etc.
4. **Load balancers**: NGINX reverse proxy
5. **Monitoring**: Prometheus, Grafana

## Performance Tuning

### ansible.cfg Settings

- `forks = 10` - Parallel execution on 10 hosts
- `pipelining = True` - Reduce SSH round trips
- `gathering = smart` - Cache facts for 24 hours

### Playbook Optimization

- Use `serial:` for rolling updates
- Use `async:` for long-running tasks
- Use `delegate_to:` to run tasks on specific hosts

## Troubleshooting

### SSH Connection Issues

```bash
# Test SSH connection
ssh ansible@your-server

# Use verbose mode
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml -vvv

# Check SSH configuration
ansible all -i inventory/hosts -m setup | grep ansible_ssh
```

### Vault Issues

```bash
# Wrong vault password
ansible-playbook ... --ask-vault-pass

# Multiple vault passwords
ansible-playbook ... --vault-id prod@prompt

# Reset vault password
ansible-vault rekey group_vars/production/vault.yml
```

### Idempotency Failures

```bash
# Run twice to check idempotency
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml
# Second run should show "changed=0"
```

## Dependencies

### System Requirements

- Python 3.8+
- Ansible 2.15+
- SSH access to target hosts
- Sudo privileges on target hosts

### Python Packages

```bash
pip install ansible ansible-lint molecule molecule-docker
pip install bcrypt jmespath netaddr PyMySQL psycopg2-binary
```

### Ansible Collections

```bash
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix
```

## Testing Strategy

### 1. Syntax Check

```bash
ansible-playbook --syntax-check playbooks/*.yml
```

### 2. Linting

```bash
ansible-lint playbooks/*.yml
```

### 3. Dry Run

```bash
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml --check --diff
```

### 4. Molecule Tests (for roles)

```bash
cd roles/nginx
molecule test
```

## CI/CD Pipeline

### GitLab CI Stages

1. **Lint**: ansible-lint on all playbooks
2. **Test**: Molecule tests for roles
3. **Deploy Staging**: Auto-deploy to staging on `develop` branch
4. **Deploy Production**: Manual approval required on `main` branch

### GitHub Actions

- Parallel linting and syntax checking
- Automated testing on pull requests
- Manual production deployment with approval

## Security Checklist

- [ ] Ansible Vault enabled for all secrets
- [ ] SSH key-based authentication configured
- [ ] Root login disabled
- [ ] UFW firewall enabled with default deny
- [ ] Fail2ban installed and configured
- [ ] Unattended security updates enabled
- [ ] Services run as non-root users
- [ ] TLS/SSL enabled for web services
- [ ] Database passwords randomized and vaulted
- [ ] Audit logs enabled

## Best Practices

1. **Always use Ansible Vault** for sensitive data
2. **Test in staging first** before production
3. **Run dry-run** (`--check`) before actual deployment
4. **Use tags** for selective task execution
5. **Document playbooks** with comments and README
6. **Version control** all playbooks and roles
7. **Use roles** for reusable components
8. **Follow naming conventions**: snake_case for variables
9. **Validate configs** before applying (e.g., `nginx -t`)
10. **Use handlers** for service restarts

## Example Deployment Scenarios

### Scenario 1: Deploy NGINX Web Server

```bash
# 1. Configure inventory
nano inventory/production
# Add web servers to [web_servers] group

# 2. Set variables
nano group_vars/web.yml
# Configure domain, SSL settings

# 3. Run playbook
ansible-playbook -i inventory/production playbooks/nginx-setup.yml --ask-vault-pass
```

### Scenario 2: Multi-Tier Application

```bash
# Deploy complete stack (LB + App + DB)
ansible-playbook -i inventory/production playbooks/multi-tier-app.yml --ask-vault-pass
```

### Scenario 3: Security Hardening

```bash
# Harden all Ubuntu servers
ansible-playbook -i inventory/production playbooks/ubuntu-hardening.yml --ask-vault-pass

# Verify
ansible all -i inventory/production -a "ufw status"
ansible all -i inventory/production -a "fail2ban-client status"
```

## Support

Need expert Ansible automation support?

**SecDevOpsPro** offers:

- Custom playbook development
- Ansible Tower/AWX setup
- Infrastructure as Code migration
- CI/CD pipeline integration
- Team training and workshops

📧 <contact@secdevopspro.com>
🌐 <https://secdevopspro.com>

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

**Last Updated**: January 2026
**Maintained by**: SecDevOpsPro
**Repository**: <https://github.com/SecDevOpsPro/ansible-playbooks>
