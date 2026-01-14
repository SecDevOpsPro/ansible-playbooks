# Contributing to Ansible Playbook Examples

Thank you for considering contributing to this project! We welcome contributions from the community.

## How to Contribute

### Reporting Issues

- Use the GitHub issue tracker to report bugs
- Include detailed information about the issue
- Provide steps to reproduce the problem
- Include Ansible version, OS, and relevant configuration

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Run ansible-lint on your playbooks
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Guidelines

#### Ansible Best Practices

- Follow [Ansible best practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- Use meaningful variable names
- Document all variables in README files
- Use Ansible Vault for sensitive data
- Ensure playbooks are idempotent
- Test on all supported OS versions

#### Code Style

- Use 2 spaces for indentation in YAML files
- Use snake_case for variable names
- Add comments for complex tasks
- Use proper task naming: `Action | Description`
- Keep lines under 120 characters when possible

#### Testing Requirements

- All playbooks must pass `ansible-lint`
- All playbooks must pass syntax check
- Test on Ubuntu 20.04, 22.04, Debian 11 minimum
- Add Molecule tests for new roles when possible

#### Documentation

- Update README.md with new playbooks or features
- Document all role variables in role README
- Add usage examples for new playbooks
- Update CHANGELOG.md

#### Security

- Never commit secrets or credentials
- Use Ansible Vault for sensitive data
- Follow security best practices
- Report security vulnerabilities privately

### Testing Locally

```bash
# Install dependencies
pip install ansible ansible-lint molecule

# Lint playbooks
ansible-lint playbooks/your-playbook.yml

# Syntax check
ansible-playbook --syntax-check playbooks/your-playbook.yml

# Dry run
ansible-playbook -i inventory/hosts.example playbooks/your-playbook.yml --check

# Molecule test (for roles)
cd roles/your-role
molecule test
```

### Commit Message Format

Use clear, descriptive commit messages:

```text
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Example:**

```text
feat(nginx): add HTTP/2 support

- Enable HTTP/2 in NGINX configuration
- Update template with http2 directive
- Test on Ubuntu 22.04

Closes #123
```

### Code Review Process

1. Maintainers will review your PR
2. Address any feedback or requested changes
3. Once approved, your PR will be merged
4. Your contribution will be acknowledged in CHANGELOG.md

### Community

- Be respectful and inclusive
- Help others in discussions
- Share knowledge and best practices

### License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Questions?** Open an issue or contact us at <contact@secdevopspro.com>

**Thank you for contributing!** 🎉
