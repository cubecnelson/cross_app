#!/usr/bin/env python3
"""
Script to fix common Flutter/Dart analyzer issues
"""

import os
import re
from pathlib import Path

def fix_const_constructors(file_path):
    """Fix prefer_const_constructors warnings"""
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Pattern to find non-const constructors that could be const
    # Match patterns like: Widget(...)
    patterns = [
        (r'(\s+)Widget\(', r'\1const Widget('),
        (r'(\s+)Container\(', r'\1const Container('),
        (r'(\s+)Padding\(', r'\1const Padding('),
        (r'(\s+)SizedBox\(', r'\1const SizedBox('),
        (r'(\s+)Icon\(', r'\1const Icon('),
        (r'(\s+)Text\(', r'\1const Text('),
        (r'(\s+)Divider\(', r'\1const Divider('),
        (r'(\s+)Card\(', r'\1const Card('),
        (r'(\s+)ListTile\(', r'\1const ListTile('),
    ]
    
    original = content
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content)
    
    if original != content:
        with open(file_path, 'w') as f:
            f.write(content)
        return True
    return False

def fix_unused_imports(file_path):
    """Remove unused imports"""
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    # Simple check - if import line has trailing comment about being unused
    # This is a basic check; in real use we'd need Dart analyzer output
    new_lines = []
    for line in lines:
        if '// ignore:' in line or '// coverage:ignore' in line:
            new_lines.append(line)
        elif re.match(r'^\s*import\s+[\'"].*[\'"];', line):
            # Keep import lines for now
            new_lines.append(line)
        else:
            new_lines.append(line)
    
    with open(file_path, 'w') as f:
        f.writelines(new_lines)
    
    return False  # Placeholder

def process_directory(directory):
    """Process all Dart files in directory"""
    dart_files = list(Path(directory).rglob('*.dart'))
    fixed_files = []
    
    for dart_file in dart_files:
        if 'test' in str(dart_file) or '.git' in str(dart_file):
            continue
        
        file_str = str(dart_file)
        if fix_const_constructors(file_str):
            fixed_files.append(file_str)
    
    return fixed_files

if __name__ == '__main__':
    project_dir = os.path.dirname(os.path.abspath(__file__))
    lib_dir = os.path.join(project_dir, 'lib')
    
    print("Fixing const constructor issues...")
    fixed = process_directory(lib_dir)
    
    if fixed:
        print(f"Fixed {len(fixed)} files:")
        for f in fixed:
            print(f"  - {os.path.relpath(f, project_dir)}")
    else:
        print("No files needed fixing.")