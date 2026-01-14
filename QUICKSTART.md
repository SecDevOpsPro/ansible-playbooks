# Quick Start Guide - Ansible Playbook Examples

## Prerequisites

- Ubuntu 20.04/22.04, Debian 11, CentOS 8, or RHEL 9
- Python 3.8+ installed
- SSH access to target servers
- Sudo privileges

## Installation

### Step 1: Clone Repository

```bash
git clone https://github.com/SecDevOpsPro/ansible-playbooks.git
cd ansible-playbooks
```

### Step 2: Install Dependencies

```bash
# Using Makefile
make install-deps

# Or manually
pip install ansible ansible-lint molecule
pip install bcrypt jmespath netaddr PyMySQL
```

### Step 3: Configure Ansible

The `ansible.cfg` is already configured with optimal settings:

- Fact caching enabled (24 hours)
- Pipelining for performance
- YAML output format
- 10 parallel forks

## Basic Usage

### Configure Inventory

```bash
# Copy example inventory
cp inventory/hosts.example inventory/my-servers

# Edit inventory
nano inventory/my-servers
```

Add your servers:

```ini
[web_servers]
web01 ansible_host=192.168.1.10 ansible_python_interpreter=/usr/bin/python3

[db_servers]
db01 ansible_host=192.168.1.20 ansible_python_interpreter=/usr/bin/python3
```

### Test Connectivity

```bash
# Ping all hosts
ansible all -i inventory/my-servers -m ping

# Check Python version
ansible all -i inventory/my-servers -a "python3 --version"
```

### Run Your First Playbook

```bash
# Install NGINX on web servers
ansible-playbook -i inventory/my-servers playbooks/nginx-setup.yml
```

## Common Playbook Scenarios

### Scenario 1: Setup Web Server

```bash
# 1. Edit variables
nano group_vars/web.yml
# Set: domain_name, ssl_email, nginx_worker_processes

# 2. Dry run first
ansible-playbook -i inventory/my-servers playbooks/nginx-setup.yml --check --diff

# 3. Run playbook
ansible-playbook -i inventory/my-servers playbooks/nginx-setup.yml

# 4. Verify
curl http://your-domain.com
```

### Scenario 2: Setup MySQL Database

```bash
# 1. Create vault for passwords
ansible-vault create group_vars/db/vault.yml

# Add to vault:
# vault_mysql_root_password: "YourSecurePassword123!"

# 2. Run playbook
ansible-playbook -i inventory/my-servers playbooks/mysql-setup.yml --ask-vault-pass

# 3. Test connection
ansible db_servers -i inventory/my-servers -a "mysql -e 'SELECT VERSION();'"
```

### Scenario 3: Security Hardening

```bash
# Harden Ubuntu servers
ansible-playbook -i inventory/my-servers playbooks/ubuntu-hardening.yml

# Verify firewall
ansible all -i inventory/my-servers -a "ufw status"

# Check fail2ban
ansible all -i inventory/my-servers -a "fail2ban-client status"
```

### Scenario 4: Deploy Node.js Application

```bash
# 1. Configure application variables
nano group_vars/app.yml
# Set: app_name, app_port, git_repo

# 2. Deploy application
ansible-playbook -i inventory/my-servers playbooks/nodejs-app.yml --ask-vault-pass

# 3. Check PM2 status
ansible app_servers -i inventory/my-servers -a "pm2 status"
```

## Working with Ansible Vault

### Create Encrypted File

```bash
# Create new vault file
ansible-vault create group_vars/production/vault.yml
```

Add secrets:

```yaml
---
vault_mysql_root_password: "SuperSecretPassword123!"
vault_db_password: "AppDbPassword456!"
vault_app_secret_key: "YourSecretKey789!"
```

### Edit Encrypted File

```bash
ansible-vault edit group_vars/production/vault.yml
```

### Use Vault in Variables

```yaml
# group_vars/db.yml (unencrypted)
mysql_root_password: "{{ vault_mysql_root_password }}"
```

### Run Playbook with Vault

```bash
# Prompt for password
ansible-playbook -i inventory/hosts playbooks/mysql-setup.yml --ask-vault-pass

# Use password file
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass
ansible-playbook -i inventory/hosts playbooks/mysql-setup.yml --vault-password-file .vault_pass
```

## Testing Playbooks

### Syntax Check

```bash
# Single playbook
ansible-playbook --syntax-check playbooks/nginx-setup.yml

# All playbooks (using Makefile)
make syntax-check
```

### Lint Playbooks

```bash
# Single playbook
ansible-lint playbooks/nginx-setup.yml

# All playbooks
make lint
```

### Dry Run (Check Mode)

```bash
# See what would change without actually changing anything
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml --check --diff
```

### Full Test Suite

```bash
make test
```

## Multi-Environment Setup

### Create Environments

```bash
# Staging inventory
nano inventory/staging

# Production inventory
nano inventory/production
```

### Environment-Specific Variables

```bash
# Staging variables
mkdir -p group_vars/staging
nano group_vars/staging/vars.yml

# Production variables
mkdir -p group_vars/production
nano group_vars/production/vars.yml
nano group_vars/production/vault.yml
ansible-vault encrypt group_vars/production/vault.yml
```

### Deploy to Specific Environment

```bash
# Deploy to staging
ansible-playbook -i inventory/staging playbooks/nginx-setup.yml

# Deploy to production
ansible-playbook -i inventory/production playbooks/nginx-setup.yml --ask-vault-pass
```

## Using Tags

### Run Specific Tasks

```bash
# Only run tasks tagged with "packages"
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml --tags "packages"

# Skip specific tags
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml --skip-tags "ssl"
```

### List Available Tags

```bash
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml --list-tags
```

## Limiting Execution

### Limit to Specific Hosts

```bash
# Run on single host
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml --limit web01

# Run on group
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml --limit web_servers

# Run on multiple hosts
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml --limit "web01,web02"
```

## Ad-Hoc Commands

### Common Operations

```bash
# Check uptime
ansible all -i inventory/hosts -a "uptime"

# Check disk space
ansible all -i inventory/hosts -a "df -h"

# Restart service
ansible web_servers -i inventory/hosts -m service -a "name=nginx state=restarted" --become

# Copy file
ansible all -i inventory/hosts -m copy -a "src=file.txt dest=/tmp/file.txt"

# Install package
ansible all -i inventory/hosts -m apt -a "name=htop state=present" --become
```

## Troubleshooting

### SSH Connection Issues

```bash
# Test SSH manually
ssh ansible@your-server

# Use verbose mode
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml -vvv

# Check SSH configuration
ansible all -i inventory/hosts -m setup -a "filter=ansible_ssh*"
```

### Permission Denied

```bash
# Ensure user has sudo without password
# On target server:
sudo visudo
# Add: ansible ALL=(ALL) NOPASSWD:ALL

# Or use --ask-become-pass
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml --ask-become-pass
```

### Module Not Found

```bash
# Install collections
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix
```

### Idempotency Issues

```bash
# Run twice to check idempotency
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml
# Second run should show: changed=0
```

## Best Practices

1. **Always test in staging first**
2. **Use dry-run (`--check`) before production deployment**
3. **Keep secrets in Ansible Vault**
4. **Use version control for all playbooks**
5. **Document playbook purpose and usage**
6. **Tag tasks for selective execution**
7. **Test idempotency (run twice)**
8. **Use roles for reusable components**
9. **Follow naming conventions** (snake_case for variables)
10. **Validate configurations before applying**

## Next Steps

1. **Explore Available Playbooks**: Run `make list-playbooks` to see all available playbooks
2. **Read Documentation**: Check `PROJECT_SUMMARY.md` for comprehensive documentation
3. **Setup CI/CD**: Configure GitLab CI or GitHub Actions for automated testing
4. **Create Custom Playbooks**: Use existing playbooks as templates
5. **Learn Ansible Vault**: Master secrets management for production use

## Getting Help

- **Documentation**: `PROJECT_SUMMARY.md`
- **List Playbooks**: `make list-playbooks`
- **Ansible Docs**: <https://docs.ansible.com>
- **Project Repository**: <https://github.com/SecDevOpsPro/ansible-playbooks>

## Support

Need help? Contact **SecDevOpsPro**:

- 📧 Email: <contact@secdevopspro.com>
- 🌐 Website: <https://secdevopspro.com>
- 💬 Support: Professional Ansible automation services available

---

### **Happy Automating! 🚀**
