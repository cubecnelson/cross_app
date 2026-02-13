#!/bin/bash
# Automated daily task selector for cron job

set -e

cd /Users/nelson.cheung/clawd/cross_app

BACKLOG_FILE="./BACKLOG.md"
LOG_FILE="./daily_task_log.json"
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)

echo "=== Cross App Daily Task Selector (Automated) ==="
echo "Date: $TODAY"
echo "Yesterday: $YESTERDAY"
echo ""

# Check if yesterday's task is still in progress and auto-complete it
if jq -e --arg date "$YESTERDAY" '.daily_tasks[$date].status == "in_progress"' "$LOG_FILE" >/dev/null 2>&1; then
    echo "Auto-completing yesterday's task..."
    TASK_ID=$(jq -r --arg date "$YESTERDAY" '.daily_tasks[$date].task_id' "$LOG_FILE")
    
    # Update backlog - mark yesterday's task as done
    sed -i '' "s/^\*\*$TASK_ID\*\*:.*$/\*\*$TASK_ID\*\*: [Task Title]\\
- **Status**: ✅ Done\\
- **Completed**: $TODAY/g" "$BACKLOG_FILE"
    
    # Update log
    COMPLETED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    jq --arg date "$YESTERDAY" \
       --arg completed_at "$COMPLETED_AT" \
       '.daily_tasks[$date].status = "completed" |
        .daily_tasks[$date].completed_at = $completed_at |
        .statistics.in_progress -= 1 |
        .statistics.completed += 1' "$LOG_FILE" > "${LOG_FILE}.tmp"
    mv "${LOG_FILE}.tmp" "$LOG_FILE"
    
    echo "Task $TASK_ID marked as completed."
fi

# Find available tasks (simplified version)
echo "Selecting today's task..."

# Look for P1 tasks that are not started
P1_TASKS=$(awk '
/^### 🟢 P1 Tasks/ {in_p1=1; next}
/^### 🟡 P2 Tasks/ {in_p1=0; next}
in_p1 && /^\*\*P1-[0-9]+\*\*:/ {
    task_line=$0
    task_id=""
    task_title=""
    
    # Get task ID
    if (match(task_line, /\*\*(P1-[0-9]+)\*\*:/)) {
        task_id = substr(task_line, RSTART+2, RLENGTH-4)
    }
    
    # Check next 3 lines for status
    for(i=1; i<=3; i++) {
        getline next_line
        if (next_line ~ /- \*\*Status\*\*: Not Started/) {
            # Go back to get full title
            split(task_line, parts, /: /)
            if (length(parts) > 1) {
                task_title = parts[2]
            }
            
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
' "$BACKLOG_FILE")

# Look for P2 tasks if no P1 available
if [ -z "$P1_TASKS" ]; then
    P2_TASKS=$(awk '
    /^### 🟡 P2 Tasks/ {in_p2=1; next}
    /^### 🔵 P3 Tasks/ {in_p2=0; next}
    in_p2 && /^\*\*P2-[0-9]+\*\*:/ {
        task_line=$0
        task_id=""
        task_title=""
        
        if (match(task_line, /\*\*(P2-[0-9]+)\*\*:/)) {
            task_id = substr(task_line, RSTART+2, RLENGTH-4)
        }
        
        for(i=1; i<=3; i++) {
            getline next_line
            if (next_line ~ /- \*\*Status\*\*: Not Started/) {
                split(task_line, parts, /: /)
                if (length(parts) > 1) {
                    task_title = parts[2]
                }
                
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
    ' "$BACKLOG_FILE")
    
    TASK_LIST="$P2_TASKS"
    PRIORITY="P2"
else
    TASK_LIST="$P1_TASKS"
    PRIORITY="P1"
fi

if [ -z "$TASK_LIST" ]; then
    echo "No tasks available for selection."
    exit 0
fi

# Select random task
TASK_COUNT=$(echo "$TASK_LIST" | wc -l | tr -d ' ')
RANDOM_INDEX=$((RANDOM % TASK_COUNT))
SELECTED_TASK=$(echo "$TASK_LIST" | sed -n "$((RANDOM_INDEX + 1))p")

# Parse selected task
TASK_ID=$(echo "$SELECTED_TASK" | cut -d'|' -f1)
TASK_TITLE=$(echo "$SELECTED_TASK" | cut -d'|' -f2)
TASK_EFFORT=$(echo "$SELECTED_TASK" | cut -d'|' -f3)

echo "Selected Task: $TASK_ID - $TASK_TITLE"
echo "Estimated Effort: $TASK_EFFORT hours"
echo "Priority: $PRIORITY"

# Update backlog status
sed -i '' "/^\*\*$TASK_ID\*\*:/,/^$/s/- \*\*Status\*\*: Not Started/- **Status**: In Progress/g" "$BACKLOG_FILE"

# Update daily selection log
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
SELECTED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq --arg date "$TODAY" \
   --arg id "$TASK_ID" \
   --arg title "$TASK_TITLE" \
   --arg effort "$TASK_EFFORT" \
   --arg priority "$PRIORITY" \
   --arg selected_at "$SELECTED_AT" \
   '.daily_tasks += {($date): {"task_id": $id, "task_title": $title, "effort_hours": ($effort|tonumber), "priority": $priority, "status": "in_progress", "selected_at": $selected_at}} |
    .statistics.in_progress += 1 |
    .statistics.total_tasks += 1' "$LOG_FILE" > "${LOG_FILE}.tmp"
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
- Expected completion: $(date -v+${TASK_EFFORT}H +%I:%M\ %p)
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
echo "Summary:"
echo "- Task: $TASK_ID - $TASK_TITLE"
echo "- Effort: $TASK_EFFORT hours"
echo "- Priority: $PRIORITY"
echo "- Work Plan: $WORK_PLAN_FILE"
echo "- Backlog Updated: $BACKLOG_FILE"

# Create notification
cat > notification_${TODAY}.txt << EOF
📋 Cross App Daily Task Selected

Task selected for ${TODAY}:
**ID**: ${TASK_ID}
**Title**: ${TASK_TITLE}
**Effort**: ${TASK_EFFORT} hours
**Priority**: ${PRIORITY}

Work plan: daily_work_plan_${TODAY}.md
Backlog updated: BACKLOG.md

Start working on it today!
EOF

echo "Notification saved to notification_${TODAY}.txt"