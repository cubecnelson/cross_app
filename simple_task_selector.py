#!/usr/bin/env python3
"""
Simple task selector for Cross app
Finds available tasks in BACKLOG.md
"""

import re
import random
from datetime import datetime

def parse_backlog(filepath):
    """Parse BACKLOG.md to find available tasks"""
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Find all tasks in the backlog
    tasks = []
    
    # Look for tasks in the format:
    # **P1-001**: Task title
    # - **Status**: Not Started
    # - **Effort**: X hours
    
    # Find the detailed task sections (not the summary at the top)
    # The detailed sections have headers like "### 🟢 P1 Tasks"
    
    # Extract P1 Tasks section
    p1_match = re.search(r'### 🟢 P1 Tasks(.*?)(?:### 🟡 P2 Tasks|$)', content, re.DOTALL)
    p1_section = p1_match.group(1) if p1_match else ""
    
    # Extract P2 Tasks section
    p2_match = re.search(r'### 🟡 P2 Tasks(.*?)(?:### 🔵 P3 Tasks|$)', content, re.DOTALL)
    p2_section = p2_match.group(1) if p2_match else ""
    
    # Extract P3 Tasks section
    p3_match = re.search(r'### 🔵 P3 Tasks(.*?)(?:### 🟣 P4 Tasks|$)', content, re.DOTALL)
    p3_section = p3_match.group(1) if p3_match else ""
    
    # Debug: print section sizes
    print(f"P1 section: {len(p1_section)} chars")
    print(f"P2 section: {len(p2_section)} chars")
    print(f"P3 section: {len(p3_section)} chars")
    
    # Debug: show first 200 chars of each section
    print(f"\nP1 first 200 chars: {p1_section[:200]}")
    print(f"\nP2 first 200 chars: {p2_section[:200]}")
    print(f"\nP3 first 200 chars: {p3_section[:200]}")
    
    # Parse P1 tasks
    for match in re.finditer(r'\*\*(P1-\d+)\*\*: (.+?)\n(?:- .+\n)*?- \*\*Status\*\*: Not Started\n- \*\*Effort\*\*: (\d+) hours', p1_section, re.DOTALL):
        task_id = match.group(1)
        task_title = match.group(2).strip()
        effort = int(match.group(3))
        tasks.append({
            'id': task_id,
            'title': task_title,
            'effort': effort,
            'priority': 'P1'
        })
    
    # Parse P2 tasks  
    for match in re.finditer(r'\*\*(P2-\d+)\*\*: (.+?)\n(?:- .+\n)*?- \*\*Status\*\*: Not Started\n- \*\*Effort\*\*: (\d+) hours', p2_section, re.DOTALL):
        task_id = match.group(1)
        task_title = match.group(2).strip()
        effort = int(match.group(3))
        tasks.append({
            'id': task_id,
            'title': task_title,
            'effort': effort,
            'priority': 'P2'
        })
    
    # Parse P3 tasks
    for match in re.finditer(r'\*\*(P3-\d+)\*\*: (.+?)\n(?:- .+\n)*?- \*\*Status\*\*: Not Started\n- \*\*Effort\*\*: (\d+) hours', p3_section, re.DOTALL):
        task_id = match.group(1)
        task_title = match.group(2).strip()
        effort = int(match.group(3))
        tasks.append({
            'id': task_id,
            'title': task_title,
            'effort': effort,
            'priority': 'P3'
        })
    
    return tasks

def select_task(tasks):
    """Select a task based on priority weighting"""
    if not tasks:
        return None
    
    # Filter by effort (≤ 4 hours for daily task)
    filtered_tasks = [t for t in tasks if t['effort'] <= 4]
    if not filtered_tasks:
        # If no tasks under 4 hours, take the smallest
        filtered_tasks = sorted(tasks, key=lambda x: x['effort'])[:3]
    
    # Weight by priority
    p1_tasks = [t for t in filtered_tasks if t['priority'] == 'P1']
    p2_tasks = [t for t in filtered_tasks if t['priority'] == 'P2']
    p3_tasks = [t for t in filtered_tasks if t['priority'] == 'P3']
    
    # 70% chance for P1, 20% for P2, 10% for P3
    rand = random.random()
    
    if p1_tasks and rand < 0.7:
        return random.choice(p1_tasks)
    elif p2_tasks and rand < 0.9:
        return random.choice(p2_tasks)
    elif p3_tasks:
        return random.choice(p3_tasks)
    elif p2_tasks:
        return random.choice(p2_tasks)
    elif p1_tasks:
        return random.choice(p1_tasks)
    
    return None

def main():
    backlog_file = './BACKLOG.md'
    
    print("=== Cross App Daily Task Selector (Python) ===")
    print(f"Date: {datetime.now().strftime('%Y-%m-%d')}")
    print()
    
    # Parse tasks
    tasks = parse_backlog(backlog_file)
    
    print(f"Found {len(tasks)} available tasks:")
    for task in tasks:
        print(f"  {task['id']}: {task['title']} ({task['effort']} hours, {task['priority']})")
    
    # Select task
    selected = select_task(tasks)
    
    if not selected:
        print("No tasks available for selection.")
        return
    
    print()
    print(f"Selected Task: {selected['id']} - {selected['title']}")
    print(f"Priority: {selected['priority']}")
    print(f"Estimated Effort: {selected['effort']} hours")
    
    # Update backlog status (simplified - in real script we'd update the file)
    print()
    print("To update backlog status, run:")
    print(f"  sed -i '' \"s/- \\*\\*Status\\*\\*: Not Started/- \\*\\*Status\\*\\*: In Progress/g\" BACKLOG.md")
    
    # Generate work plan
    today = datetime.now().strftime('%Y-%m-%d')
    work_plan_file = f"./daily_work_plan_{today}.md"
    
    work_plan = f"""# Daily Work Plan - {today}

## Selected Task
- **ID**: {selected['id']}
- **Title**: {selected['title']}
- **Estimated Effort**: {selected['effort']} hours
- **Priority**: {selected['priority']}
- **Status**: In Progress

## Time Allocation
- **9:00-10:00**: Research and planning
- **10:00-12:00**: Implementation
- **12:00-13:00**: Lunch break
- **13:00-15:00**: Testing and refinement
- **15:00-16:00**: Documentation and cleanup

## Implementation Steps
1. Research requirements and existing code
2. Set up development environment
3. Implement core functionality
4. Test and debug
5. Update documentation

## Success Criteria
- Feature implemented as specified
- Code follows project standards
- Tests pass
- Documentation updated

---
*Generated by Daily Task Selector at {datetime.now().strftime('%H:%M %p')}*
"""
    
    print()
    print(f"Work plan would be saved to: {work_plan_file}")

if __name__ == "__main__":
    main()