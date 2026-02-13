#!/bin/bash
# complete_task.sh
# Mark a task as completed

if [ -z "$1" ]; then
    echo "Usage: $0 <task-id>"
    echo "Example: $0 P1-001"
    exit 1
fi

TASK_ID=$1
TODAY=$(date +%Y-%m-%d)
BACKLOG_FILE="./BACKLOG.md"
LOG_FILE="./daily_task_log.json"

echo "Completing task: $TASK_ID"

# Update backlog
if grep -q "**$TASK_ID**:" "$BACKLOG_FILE"; then
    # Update status to Done
    sed -i '' "/^\*\*$TASK_ID\*\*:/,/^$/s/- \*\*Status\*\*: [A-Za-z ]+/- **Status**: Done\\
- **Completed**: $TODAY/g" "$BACKLOG_FILE"
    
    # Update in progress status if exists
    sed -i '' "/^\*\*$TASK_ID\*\*:/,/^$/s/- \*\*Status\*\*: In Progress/- **Status**: Done\\
- **Completed**: $TODAY/g" "$BACKLOG_FILE"
    
    echo "Backlog updated: $TASK_ID marked as Done"
else
    echo "Error: Task $TASK_ID not found in backlog"
    exit 1
fi

# Update log if exists
if [ -f "$LOG_FILE" ]; then
    # Find the date this task was selected
    TASK_DATE=$(jq -r '.daily_tasks | to_entries[] | select(.value.task_id == "'"$TASK_ID"'") | .key' "$LOG_FILE" 2>/dev/null)
    
    if [ -n "$TASK_DATE" ]; then
        jq --arg date "$TASK_DATE" \
           '.daily_tasks[$date].status = "completed" |
            .daily_tasks[$date].completed_at = now|todate |
            .statistics.in_progress -= 1 |
            .statistics.completed += 1' "$LOG_FILE" > "${LOG_FILE}.tmp"
        mv "${LOG_FILE}.tmp" "$LOG_FILE"
        echo "Log updated for task selected on $TASK_DATE"
    fi
fi

# Generate completion report
REPORT_FILE="./completion_report_${TODAY}_${TASK_ID}.md"
cat > "$REPORT_FILE" << EOF
# Task Completion Report

## Task Details
- **Task ID**: $TASK_ID
- **Completed Date**: $TODAY

## Summary
Task marked as completed.

## Notes
Add completion details here:
- What was implemented
- Testing results
- Any issues resolved
- Time spent

## Next Actions
- [ ] Update documentation
- [ ] Commit changes to git
- [ ] Push to repository
- [ ] Notify team (if applicable)

---
*Marked as completed at $(date)*
EOF

echo "Completion report generated: $REPORT_FILE"
echo ""
echo "Next:"
echo "1. Fill in completion details in $REPORT_FILE"
echo "2. Commit changes: git add . && git commit -m 'Completed $TASK_ID'"
echo "3. Continue with next task tomorrow"