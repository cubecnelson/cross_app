#!/usr/bin/env python3
import os
import re

# Find all ConsumerStatefulWidget classes
consumer_stateful = set()
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                content = f.read()
                matches = re.findall(r'class\s+(\w+)\s+extends\s+ConsumerStatefulWidget', content)
                consumer_stateful.update(matches)

print('ConsumerStatefulWidget classes:', consumer_stateful)

# Find all const WidgetName( patterns
issues = []
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                lines = f.readlines()
                for i, line in enumerate(lines):
                    for widget in consumer_stateful:
                        # Look for const WidgetName( but not const WidgetName({
                        if f'const {widget}(' in line and f'const {widget}({{' not in line:
                            # Check if it's a constructor definition (has { after)
                            # Simple heuristic: if line contains { after const WidgetName(
                            if '{' in line.split(f'const {widget}(')[1]:
                                continue  # constructor definition, okay
                            issues.append((path, i+1, line.strip()))

print(f'\nFound {len(issues)} potential issues:')
for path, line_num, line in issues:
    print(f'{path}:{line_num}: {line}')
