#!/bin/bash
# daily_task_simple.sh
# Simple version of daily task selector for Cross app

set -e

BACKLOG_FILE="./BACKLOG.md"
LOG_FILE="./daily_task_log.json"
TODAY=$(date +%Y-%m-%d)

echo "=== Cross App Daily Task Selector ==="
echo "Date: $TODAY"
echo ""

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    echo '{"daily_tasks": {}, "statistics": {"total_tasks": 0, "completed": 0, "in_progress": 0}}' > "$LOG_FILE"
fi

# Complete previous day's task if exists
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)
if jq -e --arg date "$YESTERDAY" '.daily_tasks[$date].status == "in_progress"' "$LOG_FILE" >/dev/null 2>&1; then
    echo "Found yesterday's task in progress."
    read -p "Mark as completed? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        TASK_ID=$(jq -r --arg date "$YESTERDAY" '.daily_tasks[$date].task_id' "$LOG_FILE")
        
        # Update backlog
        sed -i '' "s/- \*\*Status\*\*: In Progress/- **Status**: Done\\
- **Completed**: $TODAY/g" "$BACKLOG_FILE"
        
        # Update log
        jq --arg date "$YESTERDAY" \
           '.daily_tasks[$date].status = "completed" |
            .daily_tasks[$date].completed_at = now|todate |
            .statistics.in_progress -= 1 |
            .statistics.completed += 1' "$LOG_FILE" > "${LOG_FILE}.tmp"
        mv "${LOG_FILE}.tmp" "$LOG_FILE"
        
        echo "Task $TASK_ID marked as completed."
    fi
fi

# Find available tasks
echo "Looking for available tasks..."

# Extract P1 tasks
P1_TASKS=$(awk '
/^### 🟢 P1 Tasks/ {in_p1=1; next}
/^### 🟡 P2 Tasks/ {in_p1=0; next}
in_p1 && /^\*\*P1-[0-9]+\*\*:/ {
    task_line=$0
    # Get task ID and title
    if (match(task_line, /\*\*(P1-[0-9]+)\*\*: (.+)/)) {
        task_id = substr(task_line, RSTART+2, RLENGTH-4)
        split(task_id, parts, /\*\*: /)
        task_id = parts[1]
        task_title = parts[2]
        
        # Check next few lines for status
        for(i=1; i<=5; i++) {
            getline next_line
            if (next_line ~ /- \*\*Status\*\*: Not Started/) {
                # Get effort
                getline effort_line
                if (effort_line ~ /- \*\*Effort\*\*: ([0-9]+) hours/) {
                    match(effort_line, /([0-9]+)/)
                    effort = substr(effort_line, RSTART, RLENGTH)
                    print task_id "|" task_title "|" effort
                }
                break
            }
        }
    }
}
' "$BACKLOG_FILE")

# Extract P2 tasks
P2_TASKS=$(awk '
/^### 🟡 P2 Tasks/ {in_p2=1; next}
/^### 🔵 P3 Tasks/ {in_p2=0; next}
in_p2 && /^\*\*P2-[0-9]+\*\*:/ {
    task_line=$0
    if (match(task_line, /\*\*(P2-[0-9]+)\*\*: (.+)/)) {
        task_id = substr(task_line, RSTART+2, RLENGTH-4)
        split(task_id, parts, /\*\*: /)
        task_id = parts[1]
        task_title = parts[2]
        
        for(i=1; i<=5; i++) {
            getline next_line
            if (next_line ~ /- \*\*Status\*\*: Not Started/) {
                getline effort_line
                if (effort_line ~ /- \*\*Effort\*\*: ([0-9]+) hours/) {
                    match(effort_line, /([0-9]+)/)
                    effort = substr(effort_line, RSTART, RLENGTH)
                    print task_id "|" task_title "|" effort
                }
                break
            }
        }
    }
}
' "$BACKLOG_FILE")

# Select task based on priority
SELECTED_TASK=""
PRIORITY=""

if [ -n "$P1_TASKS" ]; then
    # 70% chance for P1
    if [ $((RANDOM % 100)) -lt 70 ]; then
        TASK_COUNT=$(echo "$P1_TASKS" | wc -l | tr -d ' ')
        RANDOM_INDEX=$((RANDOM % TASK_COUNT))
        SELECTED_TASK=$(echo "$P1_TASKS" | sed -n "$((RANDOM_INDEX + 1))p")
        PRIORITY="P1"
        echo "Selected from P1 (Critical) tasks"
    fi
fi

if [ -z "$SELECTED_TASK" ] && [ -n "$P2_TASKS" ]; then
    # 20% chance for P2 (or fallback)
    if [ $((RANDOM % 100)) -lt 20 ] || [ -z "$P1_TASKS" ]; then
        TASK_COUNT=$(echo "$P2_TASKS" | wc -l | tr -d ' ')
        RANDOM_INDEX=$((RANDOM % TASK_COUNT))
        SELECTED_TASK=$(echo "$P2_TASKS" | sed -n "$((RANDOM_INDEX + 1))p")
        PRIORITY="P2"
        echo "Selected from P2 (Important) tasks"
    fi
fi

if [ -z "$SELECTED_TASK" ]; then
    echo "No tasks available for selection."
    exit 0
fi

# Parse selected task
TASK_ID=$(echo "$SELECTED_TASK" | cut -d'|' -f1)
TASK_TITLE=$(echo "$SELECTED_TASK" | cut -d'|' -f2)
TASK_EFFORT=$(echo "$SELECTED_TASK" | cut -d'|' -f3)

echo "Selected Task: $TASK_ID - $TASK_TITLE"
echo "Estimated Effort: $TASK_EFFORT hours"

# Update backlog status
sed -i '' "/^\*\*$TASK_ID\*\*:/,/^$/s/- \*\*Status\*\*: Not Started/- **Status**: In Progress/g" "$BACKLOG_FILE"

# Update daily selection log in backlog
if ! grep -q "### $TODAY" "$BACKLOG_FILE"; then
    sed -i '' "/^## Daily Selection Log/a\\
\\
### $TODAY\\
**Selected Task**: $TASK_ID\\
**Reason**: Automatically selected by daily task selector\\
**Status**: In Progress\\
**Start Time**: 9:00 AM\\
**Expected Completion**: $(date -v+${TASK_EFFORT}H +%I:%M\ %p)\\
" "$BACKLOG_FILE"
fi

# Log selection
jq --arg date "$TODAY" \
   --arg id "$TASK_ID" \
   --arg title "$TASK_TITLE" \
   --arg effort "$TASK_EFFORT" \
   '.daily_tasks += {($date): {"task_id": $id, "task_title": $title, "effort_hours": ($effort|tonumber), "status": "in_progress", "selected_at": now|todate}} |
    .statistics.in_progress += 1' "$LOG_FILE" > "${LOG_FILE}.tmp"
mv "${LOG_FILE}.tmp" "$LOG_FILE"

# Generate work plan
WORK_PLAN_FILE="./daily_work_plan_${TODAY}.md"
cat > "$WORK_PLAN_FILE" << EOF
# Daily Work Plan - $TODAY

## Selected Task
- **ID**: $TASK_ID
- **Title**: $TASK_TITLE  
- **Estimated Effort**: $TASK_EFFORT hours
- **Priority**: $PRIORITY
- **Status**: In Progress

## Time Allocation
- **9:00-10:00**: Research and planning
- **10:00-12:00**: Implementation
- **12:00-13:00**: Lunch break
- **13:00-15:00**: Testing and refinement
- **15:00-16:00**: Documentation and cleanup

## Implementation Steps

### 1. Research & Setup (30 minutes)
- Review task requirements
- Check existing codebase
- Set up development environment
- Create test cases

### 2. Core Implementation (2 hours)
- Write main functionality
- Follow coding standards
- Add error handling
- Implement logging

### 3. Testing & Debugging (1 hour)
- Run unit tests
- Manual testing
- Fix bugs
- Edge case testing

### 4. Documentation & Cleanup (30 minutes)
- Update documentation
- Add code comments
- Commit changes
- Update backlog status

## Success Criteria
- [ ] Feature implemented as specified
- [ ] No regressions in existing functionality
- [ ] Code follows project standards
- [ ] Tests pass
- [ ] Documentation updated

## Notes
- Start time: 9:00 AM
- Expected completion: 1:00 PM (4 hours total)
- Take breaks every 50 minutes
- Ask for help if stuck for more than 30 minutes

## Files to Work On
\`\`\`
# Will be populated during implementation
\`\`\`

## Progress Tracking
- [ ] 9:00 AM - Started
- [ ] 10:00 AM - Research complete
- [ ] 11:00 AM - Core implementation
- [ ] 12:00 PM - Testing phase
- [ ] 1:00 PM - Documentation
- [ ] 2:00 PM - Completed

---
*Generated by Daily Task Selector at $(date)*
EOF

echo "Work plan generated: $WORK_PLAN_FILE"
echo ""
echo "========================================"
echo "Today's task has been selected!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Review the work plan: $WORK_PLAN_FILE"
echo "2. Start working on the task"
echo "3. Update progress throughout the day"
echo "4. Run this script tomorrow to complete"
echo ""
echo "To manually mark as completed:"
echo "  sed -i '' \"s/- \\*\\*Status\\*\\*: In Progress/- \\*\\*Status\\*\\*: Done/g\" $BACKLOG_FILE"