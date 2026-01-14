# Ansible Playbook Examples

## **Production-ready Ansible playbooks for infrastructure automation**

A collection of Ansible playbooks for common DevOps tasks: server provisioning, application deployment, security hardening, and configuration management. Tested on Ubuntu 20.04/22.04, Debian 11, CentOS 8, and RHEL 9.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/SecDevOpsPro/ansible-playbooks.git
cd ansible-playbooks

# Install dependencies
pip install ansible>=2.15

# Configure inventory
cp inventory/hosts.example inventory/hosts
nano inventory/hosts

# Run a playbook
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml
```

## 📦 Available Playbooks

### Web Servers

- **`nginx-setup.yml`** - Install and configure NGINX with TLS
- **`apache-setup.yml`** - Apache2 with mod_security
- **`nginx-php-fpm.yml`** - NGINX + PHP-FPM stack

### Databases

- **`mysql-setup.yml`** - MySQL 8.0 with secure defaults
- **`postgresql-setup.yml`** - PostgreSQL 15 with replication
- **`redis-cluster.yml`** - Redis cluster setup (3 masters, 3 replicas)

### Container Orchestration

- **`docker-install.yml`** - Docker + Docker Compose installation
- **`kubernetes-node.yml`** - Kubernetes node preparation
- **`containerd-setup.yml`** - containerd runtime configuration

### Security Hardening

- **`ubuntu-hardening.yml`** - CIS Ubuntu Benchmark compliance
- **`fail2ban-setup.yml`** - Intrusion prevention
- **`firewall-setup.yml`** - UFW/iptables configuration
- **`ssh-hardening.yml`** - Secure SSH configuration

### Monitoring & Logging

- **`prometheus-node-exporter.yml`** - Prometheus metrics collection
- **`grafana-setup.yml`** - Grafana dashboard server
- **`elk-stack.yml`** - Elasticsearch, Logstash, Kibana
- **`fluentd-setup.yml`** - Log aggregation

### Application Deployment

- **`nodejs-app.yml`** - Node.js application with PM2
- **`python-app.yml`** - Python app with Gunicorn + systemd
- **`docker-compose-app.yml`** - Deploy via Docker Compose

## 🏗️ Playbook Structure

```text
ansible-playbooks/
├── playbooks/
│   ├── nginx-setup.yml
│   ├── mysql-setup.yml
│   └── ...
├── roles/
│   ├── common/
│   ├── nginx/
│   ├── security/
│   └── monitoring/
├── inventory/
│   ├── hosts.example
│   ├── production/
│   └── staging/
├── group_vars/
│   ├── all.yml
│   ├── web.yml
│   └── db.yml
└── templates/
    ├── nginx.conf.j2
    ├── my.cnf.j2
    └── ...
```

## 📝 Usage Example: NGINX + TLS

```yaml
# playbooks/nginx-setup.yml
---
- name: Setup NGINX with TLS
  hosts: web_servers
  become: yes

  vars:
    nginx_version: "1.24"
    domain_name: "example.com"
    enable_ssl: true
    ssl_provider: "letsencrypt"

  roles:
    - common
    - nginx
    - security

  tasks:
    - name: Deploy application
      copy:
        src: "{{ playbook_dir }}/../app/"
        dest: "/var/www/{{ domain_name }}"
        owner: www-data
        mode: '0755'

    - name: Configure SSL certificate
      include_role:
        name: certbot
      when: ssl_provider == "letsencrypt"

    - name: Restart NGINX
      service:
        name: nginx
        state: restarted
```

**Run with:**

```bash
ansible-playbook -i inventory/production playbooks/nginx-setup.yml --ask-become-pass
```

## 🔒 Security Best Practices

All playbooks implement:

✅ **Idempotency** - Safe to run multiple times
✅ **Non-Root User** - Dedicated service accounts
✅ **Firewall Rules** - Only necessary ports exposed
✅ **TLS/SSL** - Encrypted communications
✅ **Secrets Management** - Ansible Vault for sensitive data
✅ **Audit Logging** - Track configuration changes
✅ **Principle of Least Privilege** - Minimal permissions

## 🎯 Real-World Examples

### 1. Multi-Tier App Deployment

```yaml
# Deploy full stack: Load Balancer + App Servers + Database
ansible-playbook -i inventory/production playbooks/multi-tier-app.yml \
  --extra-vars "app_version=v2.1.0"
```

### 2. Rolling Update (Zero Downtime)

```yaml
# Update app servers one at a time
ansible-playbook -i inventory/production playbooks/rolling-update.yml \
  --extra-vars "serial=1" \
  --extra-vars "max_fail_percentage=0"
```

### 3. Disaster Recovery

```yaml
# Restore database from backup
ansible-playbook -i inventory/production playbooks/db-restore.yml \
  --extra-vars "backup_file=/backups/mysql-2025-01-14.sql.gz" \
  --extra-vars "target_db=production_db"
```

## 🚦 CI/CD Integration

### GitLab CI Example

```yaml
# .gitlab-ci.yml
stages:
  - lint
  - test
  - deploy

ansible:lint:
  stage: lint
  script:
    - ansible-lint playbooks/*.yml

ansible:test:
  stage: test
  script:
    - molecule test

deploy:staging:
  stage: deploy
  script:
    - ansible-playbook -i inventory/staging playbooks/deploy-app.yml
  only:
    - develop

deploy:production:
  stage: deploy
  script:
    - ansible-playbook -i inventory/production playbooks/deploy-app.yml
  only:
    - main
  when: manual
```

## 📊 Performance Optimization

### Parallel Execution

```yaml
# Run on 10 hosts simultaneously
ansible-playbook -i inventory/hosts playbooks/update-servers.yml --forks=10
```

### Fact Caching (Redis)

```ini
# ansible.cfg
[defaults]
gathering = smart
fact_caching = redis
fact_caching_timeout = 86400
fact_caching_connection = localhost:6379:0
```

### Pipelining

```ini
# ansible.cfg
[ssh_connection]
pipelining = True
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
```

## 🛠️ Prerequisites

- Ansible 2.15+
- Python 3.8+
- SSH access to target hosts
- Sudo privileges on target hosts

**Install Ansible:**

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install ansible

# macOS
brew install ansible

# Python pip
pip install ansible

# Verify installation
ansible --version
```

## 📚 Role Documentation

| Role | Purpose | Variables | Dependencies |
| ---- | ------- | --------- | ------------ |
| `common` | Base system setup | `timezone`, `ntp_servers` | None |
| `nginx` | Web server | `nginx_worker_processes`, `ssl_cert_path` | `common` |
| `mysql` | Database | `mysql_root_password`, `mysql_databases` | `common` |
| `docker` | Container runtime | `docker_compose_version` | `common` |
| `security` | System hardening | `fail2ban_enabled`, `ssh_port` | `common` |
| `monitoring` | Prometheus + Grafana | `grafana_admin_password` | `docker` |

## 🤝 Professional Ansible Services

Need help automating your infrastructure?

**SecDevOpsPro** offers expert Ansible consulting:

- Custom playbook development for your stack
- Ansible Tower/AWX setup and configuration
- Infrastructure as Code migration (manual → automated)
- CI/CD pipeline integration
- Team training and best practices workshops
- 24/7 support for production automation

👉 **[Get expert Ansible automation support](https://secdevopspro.com/service-conf/?utm_source=github&utm_medium=ansible-examples&utm_campaign=repo-link)**

📧 [contact@secdevopspro.com](mailto:contact@secdevopspro.com) | 🌐 [secdevopspro.com](https://secdevopspro.com)

## **100+ servers automated | 90% faster provisioning | Zero configuration drift**

## 🧪 Testing

### Syntax Check

```bash
ansible-playbook --syntax-check playbooks/nginx-setup.yml
```

### Dry Run

```bash
ansible-playbook -i inventory/hosts playbooks/nginx-setup.yml --check
```

### Molecule Testing

```bash
cd roles/nginx
molecule test
```

## 📄 License

MIT License - Free for commercial use.

## 🤝 Contributing

Pull requests welcome! Please:

1. Test playbooks on all supported OSes
2. Follow Ansible best practices
3. Document variables in README
4. Add molecule tests for new roles

## 📝 Changelog

- **v1.0.0** - Initial release with 20+ playbooks
- See [CHANGELOG.md](CHANGELOG.md) for details

---

**Maintained by [SecDevOpsPro](https://github.com/SecDevOpsPro)** | Automation Experts | ⚙️ Zero Configuration Drift
