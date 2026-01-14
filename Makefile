# Ansible Playbook Examples - Makefile
# Common automation commands for the project

.PHONY: help lint syntax-check test install-deps encrypt-vault decrypt-vault list-playbooks deploy-staging deploy-production clean

# Default target
help:
	@echo "=== Ansible Playbook Examples - Available Commands ==="
	@echo ""
	@echo "Development:"
	@echo "  make install-deps      Install required Python dependencies"
	@echo "  make lint              Run ansible-lint on all playbooks"
	@echo "  make syntax-check      Check syntax of all playbooks"
	@echo "  make test              Run full test suite (lint + syntax)"
	@echo ""
	@echo "Vault Management:"
	@echo "  make encrypt-vault     Encrypt all vault.yml files"
	@echo "  make decrypt-vault     Decrypt all vault.yml files"
	@echo "  make create-vault      Create new encrypted vault file"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy-staging    Deploy to staging environment"
	@echo "  make deploy-production Deploy to production environment"
	@echo "  make list-playbooks    List all available playbooks"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean             Remove temporary files and caches"
	@echo "  make check-inventory   Verify inventory files"
	@echo ""

# Install required dependencies
install-deps:
	@echo "Installing Python dependencies..."
	pip install --upgrade pip
	pip install ansible ansible-lint molecule molecule-docker docker yamllint
	pip install bcrypt jmespath netaddr
	@echo "✅ Dependencies installed successfully"

# Lint all playbooks
lint:
	@echo "Running ansible-lint on all playbooks..."
	@for playbook in playbooks/*.yml; do \
		echo "Linting $$playbook..."; \
		ansible-lint $$playbook || exit 1; \
	done
	@echo "✅ All playbooks passed ansible-lint"

# Syntax check all playbooks
syntax-check:
	@echo "Checking syntax of all playbooks..."
	@for playbook in playbooks/*.yml; do \
		echo "Checking $$playbook..."; \
		ansible-playbook --syntax-check $$playbook || exit 1; \
	done
	@echo "✅ All playbooks passed syntax check"

# Run full test suite
test: lint syntax-check
	@echo "✅ All tests passed!"

# List all playbooks
list-playbooks:
	@echo "=== Available Playbooks ==="
	@for playbook in playbooks/*.yml; do \
		name=$$(basename $$playbook .yml); \
		description=$$(grep -m1 "^# Description:" $$playbook | cut -d: -f2- | xargs); \
		printf "%-30s %s\n" "$$name" "$$description"; \
	done

# Encrypt vault files
encrypt-vault:
	@echo "Encrypting vault files..."
	@find group_vars -name "vault.yml" -type f -exec ansible-vault encrypt {} \;
	@echo "✅ Vault files encrypted"

# Decrypt vault files
decrypt-vault:
	@echo "Decrypting vault files..."
	@find group_vars -name "vault.yml" -type f -exec ansible-vault decrypt {} \;
	@echo "✅ Vault files decrypted"

# Create new vault file
create-vault:
	@read -p "Enter vault file path (e.g., group_vars/production/vault.yml): " vault_path; \
	ansible-vault create $$vault_path

# Deploy to staging
deploy-staging:
	@echo "Deploying to staging environment..."
	@read -p "Enter playbook name (without .yml): " playbook; \
	ansible-playbook -i inventory/staging playbooks/$$playbook.yml --ask-vault-pass

# Deploy to production
deploy-production:
	@echo "⚠️  WARNING: Deploying to PRODUCTION environment"
	@read -p "Are you sure? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		read -p "Enter playbook name (without .yml): " playbook; \
		ansible-playbook -i inventory/production playbooks/$$playbook.yml --ask-vault-pass; \
	else \
		echo "❌ Deployment cancelled"; \
	fi

# Check inventory files
check-inventory:
	@echo "Checking inventory files..."
	@ansible-inventory -i inventory/staging --list > /dev/null && echo "✅ Staging inventory OK" || echo "❌ Staging inventory has errors"
	@ansible-inventory -i inventory/production --list > /dev/null && echo "✅ Production inventory OK" || echo "❌ Production inventory has errors"

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	rm -rf /tmp/ansible_facts
	rm -f *.retry
	rm -f ansible.log
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name ".pytest_cache" -delete
	@echo "✅ Cleanup complete"

# Dry run (check mode)
dry-run:
	@read -p "Enter inventory (staging/production): " env; \
	read -p "Enter playbook name (without .yml): " playbook; \
	ansible-playbook -i inventory/$$env playbooks/$$playbook.yml --check --diff --ask-vault-pass

# Quick ping test
ping:
	@read -p "Enter inventory (staging/production): " env; \
	ansible all -i inventory/$$env -m ping

# Display Ansible version
version:
	@echo "Ansible version:"
	@ansible --version
	@echo ""
	@echo "ansible-lint version:"
	@ansible-lint --version

# Generate documentation
docs:
	@echo "Generating playbook documentation..."
	@echo "# Ansible Playbook Examples - Quick Reference" > PLAYBOOKS.md
	@echo "" >> PLAYBOOKS.md
	@for playbook in playbooks/*.yml; do \
		name=$$(basename $$playbook); \
		echo "## $$name" >> PLAYBOOKS.md; \
		grep "^# Description:" $$playbook | cut -d: -f2- >> PLAYBOOKS.md; \
		grep "^# Tested on:" $$playbook | cut -d: -f2- >> PLAYBOOKS.md; \
		echo "" >> PLAYBOOKS.md; \
	done
	@echo "✅ Documentation generated: PLAYBOOKS.md"
