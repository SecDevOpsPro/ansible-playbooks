#!/usr/bin/env python3
"""
Fix ansible-lint violations in playbooks and roles
"""

import re
import glob
from pathlib import Path

# FQCN mapping for builtin modules
FQCN_MAP = {
    'apt': 'ansible.builtin.apt',
    'yum': 'ansible.builtin.yum',
    'package': 'ansible.builtin.package',
    'service': 'ansible.builtin.service',
    'systemd': 'ansible.builtin.systemd',
    'copy': 'ansible.builtin.copy',
    'template': 'ansible.builtin.template',
    'file': 'ansible.builtin.file',
    'lineinfile': 'ansible.builtin.lineinfile',
    'user': 'ansible.builtin.user',
    'group': 'ansible.builtin.group',
    'command': 'ansible.builtin.command',
    'shell': 'ansible.builtin.shell',
    'debug': 'ansible.builtin.debug',
    'set_fact': 'ansible.builtin.set_fact',
    'include_tasks': 'ansible.builtin.include_tasks',
    'import_tasks': 'ansible.builtin.import_tasks',
    'fail': 'ansible.builtin.fail',
    'assert': 'ansible.builtin.assert',
    'wait_for': 'ansible.builtin.wait_for',
    'get_url': 'ansible.builtin.get_url',
    'uri': 'ansible.builtin.uri',
    'pip': 'ansible.builtin.pip',
    'npm': 'community.general.npm',
    'git': 'ansible.builtin.git',
    'cron': 'ansible.builtin.cron',
    'sysctl': 'ansible.posix.sysctl',
    'synchronize': 'ansible.posix.synchronize',
    'mysql_db': 'community.mysql.mysql_db',
    'mysql_user': 'community.mysql.mysql_user',
    'postgresql_db': 'community.postgresql.postgresql_db',
    'postgresql_user': 'community.postgresql.postgresql_user',
}

def fix_fqcn(content):
    """Fix FQCN for builtin modules"""
    for short_name, fqcn in FQCN_MAP.items():
        # Match module calls with proper indentation
        pattern = rf'^(\s+){short_name}:$'
        replacement = rf'\1{fqcn}:'
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    return content

def fix_truthy(content):
    """Fix truthy values - yes/no to true/false"""
    # Fix yes/no in YAML
    content = re.sub(r'^(\s+\w+):\s+yes\s*$', r'\1: true', content, flags=re.MULTILINE)
    content = re.sub(r'^(\s+\w+):\s+no\s*$', r'\1: false', content, flags=re.MULTILINE)
    return content

def fix_handler_names(content):
    """Fix handler names to start with uppercase"""
    # Fix handler names in handlers section
    content = re.sub(r'^(\s+- name: )([a-z])', lambda m: m.group(1) + m.group(2).upper(), content, flags=re.MULTILINE)
    # Fix notify references
    content = re.sub(r'^(\s+notify: )([a-z])', lambda m: m.group(1) + m.group(2).upper(), content, flags=re.MULTILINE)
    return content

def process_file(filepath):
    """Process a single file"""
    print(f"Processing: {filepath}")

    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    # Apply fixes
    content = fix_fqcn(content)
    content = fix_truthy(content)
    content = fix_handler_names(content)

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"  ✓ Fixed {filepath}")
        return True
    else:
        print(f"  - No changes needed for {filepath}")
        return False

def main():
    """Main function"""
    print("Fixing ansible-lint violations...\n")

    # Find all playbooks and role files
    files = []
    files.extend(glob.glob('playbooks/*.yml'))
    files.extend(glob.glob('roles/*/tasks/*.yml'))
    files.extend(glob.glob('roles/*/handlers/*.yml'))
    files.extend(glob.glob('roles/*/defaults/*.yml'))

    fixed_count = 0
    for filepath in files:
        if process_file(filepath):
            fixed_count += 1

    print(f"\n✓ Fixed {fixed_count} files")

if __name__ == '__main__':
    main()
