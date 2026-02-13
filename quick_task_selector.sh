#!/bin/bash
# quick_task_selector.sh
# Simple task selector for Cross app - Updated for new backlog structure

set -e

BACKLOG_FILE="./BACKLOG.md"
TODAY=$(date +%Y-%m-%d)

echo "=== Quick Task Selector ==="
echo "Date: $TODAY"
echo ""

# Clear any previous task selection
TASK_ID=""
TASK_TITLE=""
TASK_EFFORT=""
PRIORITY=""

# Function to extract task details
extract_task_details() {
    local task_id="$1"
    local task_section=""
    local in_section=0
    
    # Extract the section for this task
    while IFS= read -r line; do
        if [[ "$line" =~ ^\*\*$task_id\*\*: ]]; then
            in_section=1
            task_section+="$line"$'\n'
        elif [[ $in_section -eq 1 ]]; then
            if [[ "$line" =~ ^\*\*[A-Z][0-9]-[0-9]+\*\*: ]] || [[ -z "$line" ]]; then
                break
            fi
            task_section+="$line"$'\n'
        fi
    done < "$BACKLOG_FILE"
    
    echo "$task_section"
}

# Check tasks in priority order
TASKS_TO_CHECK=("P1-003" "P1-005" "P1-006" "P2-001" "P2-002" "P2-007" "P2-008" "P2-009")

for task in "${TASKS_TO_CHECK[@]}"; do
    task_section=$(extract_task_details "$task")
    
    if [[ -n "$task_section" ]]; then
        # Check if task is Not Started
        if echo "$task_section" | grep -q "- \*\*Status\*\*: Not Started"; then
            # Extract task title
            TASK_TITLE=$(echo "$task_section" | grep "^\*\*$task\*\*:" | sed -E "s/^\*\*$task\*\*: //")
            
            # Extract effort
            TASK_EFFORT=$(echo "$task_section" | grep "- \*\*Effort\*\*:" | sed -E 's/.*- \*\*Effort\*\*: ([0-9]+) hours.*/\1/')
            
            # Extract priority
            if [[ "$task" == P1-* ]]; then
                PRIORITY="P1"
            elif [[ "$task" == P2-* ]]; then
                PRIORITY="P2"
            fi
            
            TASK_ID="$task"
            echo "Found $task: $TASK_TITLE (Not Started)"
            break
        fi
    fi
done

if [ -z "$TASK_ID" ]; then
    echo "No suitable tasks found (all P1/P2 tasks in progress or completed)."
    echo "Checking P3 tasks..."
    
    # Check P3 tasks
    TASKS_TO_CHECK=("P3-001" "P3-002" "P3-003" "P3-004" "P3-005" "P3-006" "P3-007")
    
    for task in "${TASKS_TO_CHECK[@]}"; do
        task_section=$(extract_task_details "$task")
        
        if [[ -n "$task_section" ]]; then
            if echo "$task_section" | grep -q "- \*\*Status\*\*: Not Started"; then
                TASK_TITLE=$(echo "$task_section" | grep "^\*\*$task\*\*:" | sed -E "s/^\*\*$task\*\*: //")
                TASK_EFFORT=$(echo "$task_section" | grep "- \*\*Effort\*\*:" | sed -E 's/.*- \*\*Effort\*\*: ([0-9]+) hours.*/\1/')
                PRIORITY="P3"
                TASK_ID="$task"
                echo "Found $task: $TASK_TITLE (Not Started)"
                break
            fi
        fi
    done
fi

if [ -z "$TASK_ID" ]; then
    echo "No tasks found with 'Not Started' status."
    exit 1
fi

echo ""
echo "Selected Task: $TASK_ID - $TASK_TITLE"
echo "Estimated Effort: $TASK_EFFORT hours"
echo "Priority: $PRIORITY"

# Update backlog status to In Progress
# Use different sed command for macOS vs Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "/^\*\*$TASK_ID\*\*:/,/^\*\*[A-Z][0-9]-[0-9]+\*\*:/s/- \*\*Status\*\*: Not Started/- **Status**: In Progress/" "$BACKLOG_FILE"
    # Also handle case where it's the last task
    sed -i '' "/^\*\*$TASK_ID\*\*:/,/^$/s/- \*\*Status\*\*: Not Started/- **Status**: In Progress/" "$BACKLOG_FILE"
else
    # Linux
    sed -i "/^\*\*$TASK_ID\*\*:/,/^\*\*[A-Z][0-9]-[0-9]+\*\*:/s/- \*\*Status\*\*: Not Started/- **Status**: In Progress/" "$BACKLOG_FILE"
    sed -i "/^\*\*$TASK_ID\*\*:/,/^$/s/- \*\*Status\*\*: Not Started/- **Status**: In Progress/" "$BACKLOG_FILE"
fi

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

### 2. Core Implementation ($((TASK_EFFORT/2)) hours)
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
- Expected completion: $((9 + TASK_EFFORT)):00 AM
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
*Generated by Quick Task Selector at $(date)*
EOF

echo ""
echo "Work plan generated: $WORK_PLAN_FILE"
echo "Backlog updated: $BACKLOG_FILE"

# Generate notification
cat > "notification_${TODAY}.txt" << EOF
📋 Cross App Daily Task Selected

Task selected for ${TODAY}:
**ID**: ${TASK_ID}
**Title**: ${TASK_TITLE}
**Effort**: ${TASK_EFFORT} hours
**Priority**: ${PRIORITY}

Work plan: ${WORK_PLAN_FILE}
Backlog updated: ${BACKLOG_FILE}

Start working on it today!
EOF

echo "Notification saved to notification_${TODAY}.txt"

# Add to daily selection log
if grep -q "## Daily Selection Log" "$BACKLOG_FILE"; then
    SELECTION_ENTRY="\n### $TODAY\n**Selected Task**: $TASK_ID\n**Reason**: Automatically selected by daily task selector\n**Status**: In Progress\n**Start Time**: 9:00 AM\n**Expected Completion**: $((9 + TASK_EFFORT)):00 AM"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/## Daily Selection Log/a\\
$SELECTION_ENTRY" "$BACKLOG_FILE"
    else
        sed -i "/## Daily Selection Log/a\\$SELECTION_ENTRY" "$BACKLOG_FILE"
    fi
fi