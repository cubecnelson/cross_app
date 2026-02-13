#!/bin/bash
# daily_task_selector.sh
# Automatically selects and processes one task from the Cross app backlog each day

set -e

BACKLOG_FILE="./BACKLOG.md"
LOG_FILE="./daily_task_log.json"
TODAY=$(date +%Y-%m-%d)
WORKDIR=$(pwd)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Cross App Daily Task Selector ===${NC}"
echo -e "${BLUE}Date: ${TODAY}${NC}"
echo ""

# Check if backlog file exists
if [ ! -f "$BACKLOG_FILE" ]; then
    echo -e "${RED}Error: Backlog file not found at $BACKLOG_FILE${NC}"
    exit 1
fi

# Initialize log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    echo '{"daily_tasks": {}, "statistics": {"total_tasks": 0, "completed": 0, "in_progress": 0}}' > "$LOG_FILE"
fi

# Function to extract tasks from backlog
extract_tasks() {
    local priority=$1
    awk -v priority="$priority" '
    BEGIN { in_section=0; task_id=""; task_title=""; task_status=""; task_effort="" }
    /^### 🟢 P1 Tasks/ && priority == "P1" { in_section=1; next }
    /^### 🟡 P2 Tasks/ && priority == "P2" { in_section=1; next }
    /^### 🔵 P3 Tasks/ && priority == "P3" { in_section=1; next }
    /^### 🟣 P4 Tasks/ && priority == "P4" { in_section=1; next }
    /^### [^P]/ { in_section=0 }  # Next section starts
    
    in_section && /^\*\*P[0-9]-[0-9]+\*\*/ {
        # Extract task info
        line=$0
        if (match(line, /\*\*(P[0-9]-[0-9]+)\*\*: (.+)/)) {
            task_id = substr(line, RSTART+2, RLENGTH-4)
            # Extract just the ID
            split(task_id, parts, /\*\*: /)
            task_id = parts[1]
            task_title = parts[2]
        }
        
        # Look for status in next few lines
        for(i=1; i<=10; i++) {
            getline next_line
            if (next_line ~ /- \*\*Status\*\*: /) {
                if (match(next_line, /- \*\*Status\*\*: ([A-Za-z ]+)/)) {
                    task_status = substr(next_line, RSTART+17, RLENGTH-17)
                }
            }
            if (next_line ~ /- \*\*Effort\*\*: /) {
                if (match(next_line, /- \*\*Effort\*\*: ([0-9]+) hours/)) {
                    task_effort = substr(next_line, RSTART+17, RLENGTH-24)
                    gsub(/ hours/, "", task_effort)
                }
            }
            if (task_status && task_effort) break
        }
        
        if (task_id && task_status == "Not Started") {
            print task_id "|" task_title "|" task_effort
        }
    }
    ' "$BACKLOG_FILE"
}

# Function to select a task
select_task() {
    echo -e "${YELLOW}Selecting task for today...${NC}"
    
    # Get all available tasks by priority
    P1_TASKS=$(extract_tasks "P1")
    P2_TASKS=$(extract_tasks "P2") 
    P3_TASKS=$(extract_tasks "P3")
    P4_TASKS=$(extract_tasks "P4")
    
    # Priority weights (higher = more likely to be selected)
    # 70% chance for P1, 20% for P2, 7% for P3, 3% for P4
    RAND=$((RANDOM % 100))
    
    if [ $RAND -lt 70 ] && [ -n "$P1_TASKS" ]; then
        SELECTED_PRIORITY="P1"
        TASK_POOL="$P1_TASKS"
        echo -e "${GREEN}Selected from P1 (Critical) tasks${NC}"
    elif [ $RAND -lt 90 ] && [ -n "$P2_TASKS" ]; then
        SELECTED_PRIORITY="P2"
        TASK_POOL="$P2_TASKS"
        echo -e "${GREEN}Selected from P2 (Important) tasks${NC}"
    elif [ $RAND -lt 97 ] && [ -n "$P3_TASKS" ]; then
        SELECTED_PRIORITY="P3"
        TASK_POOL="$P3_TASKS"
        echo -e "${GREEN}Selected from P3 (Enhancement) tasks${NC}"
    elif [ -n "$P4_TASKS" ]; then
        SELECTED_PRIORITY="P4"
        TASK_POOL="$P4_TASKS"
        echo -e "${GREEN}Selected from P4 (Technical Debt) tasks${NC}"
    else
        # Fallback to any available task
        if [ -n "$P1_TASKS" ]; then
            SELECTED_PRIORITY="P1"
            TASK_POOL="$P1_TASKS"
        elif [ -n "$P2_TASKS" ]; then
            SELECTED_PRIORITY="P2"
            TASK_POOL="$P2_TASKS"
        elif [ -n "$P3_TASKS" ]; then
            SELECTED_PRIORITY="P3"
            TASK_POOL="$P3_TASKS"
        elif [ -n "$P4_TASKS" ]; then
            SELECTED_PRIORITY="P4"
            TASK_POOL="$P4_TASKS"
        else
            echo -e "${RED}No tasks available! All tasks may be completed or in progress.${NC}"
            exit 0
        fi
    fi
    
    # Count tasks in pool
    TASK_COUNT=$(echo "$TASK_POOL" | wc -l | tr -d ' ')
    
    if [ "$TASK_COUNT" -eq 0 ]; then
        echo -e "${RED}No tasks available in selected priority!${NC}"
        # Try next priority
        if [ "$SELECTED_PRIORITY" = "P1" ] && [ -n "$P2_TASKS" ]; then
            SELECTED_PRIORITY="P2"
            TASK_POOL="$P2_TASKS"
        elif [ "$SELECTED_PRIORITY" = "P2" ] && [ -n "$P3_TASKS" ]; then
            SELECTED_PRIORITY="P3"
            TASK_POOL="$P3_TASKS"
        elif [ "$SELECTED_PRIORITY" = "P3" ] && [ -n "$P4_TASKS" ]; then
            SELECTED_PRIORITY="P4"
            TASK_POOL="$P4_TASKS"
        else
            echo -e "${RED}No tasks available at all!${NC}"
            exit 0
        fi
        TASK_COUNT=$(echo "$TASK_POOL" | wc -l | tr -d ' ')
    fi
    
    # Randomly select a task from the pool
    RANDOM_INDEX=$((RANDOM % TASK_COUNT))
    SELECTED_TASK=$(echo "$TASK_POOL" | sed -n "$((RANDOM_INDEX + 1))p")
    
    # Parse task details
    TASK_ID=$(echo "$SELECTED_TASK" | cut -d'|' -f1)
    TASK_TITLE=$(echo "$SELECTED_TASK" | cut -d'|' -f2)
    TASK_EFFORT=$(echo "$SELECTED_TASK" | cut -d'|' -f3)
    
    echo -e "${GREEN}Selected Task: ${TASK_ID} - ${TASK_TITLE}${NC}"
    echo -e "${GREEN}Estimated Effort: ${TASK_EFFORT} hours${NC}"
    
    # Update backlog with selected task
    update_backlog "$TASK_ID"
    
    # Log the selection
    log_selection "$TASK_ID" "$TASK_TITLE" "$TASK_EFFORT"
    
    # Generate work plan
    generate_work_plan "$TASK_ID" "$TASK_TITLE" "$TASK_EFFORT"
}

# Function to update backlog with selected task
update_backlog() {
    local task_id=$1
    
    echo -e "${YELLOW}Updating backlog status...${NC}"
    
    # Create backup
    cp "$BACKLOG_FILE" "${BACKLOG_FILE}.bak"
    
    # Update status to "In Progress" and add today's date
    awk -v task_id="$task_id" -v today="$TODAY" '
    BEGIN { in_task=0; updated=0 }
    /^\*\*'"${task_id}"'\*\*/ { 
        in_task=1
        print $0
        next
    }
    in_task && /- \*\*Status\*\*: / {
        print "- **Status**: In Progress"
        in_task=0
        updated=1
        next
    }
    /^## Daily Selection Log/ {
        print $0
        print ""
        print "### " today
        print "**Selected Task**: " task_id
        print "**Reason**: Automatically selected by daily task selector"
        print "**Status**: In Progress"
        print "**Start Time**: 9:00 AM"
        print "**Expected Completion**: " strftime("%I:%M %p", systime() + 4*3600)
        print ""
        next
    }
    { print $0 }
    END {
        if (!updated) {
            print "Warning: Task " task_id " not found in backlog" > "/dev/stderr"
        }
    }
    ' "$BACKLOG_FILE" > "${BACKLOG_FILE}.tmp"
    
    mv "${BACKLOG_FILE}.tmp" "$BACKLOG_FILE"
    echo -e "${GREEN}Backlog updated${NC}"
}

# Function to log selection
log_selection() {
    local task_id=$1
    local task_title=$2
    local task_effort=$3
    
    # Read existing log
    LOG_JSON=$(cat "$LOG_FILE")
    
    # Update JSON with new task
    NEW_JSON=$(echo "$LOG_JSON" | jq --arg date "$TODAY" \
        --arg id "$task_id" \
        --arg title "$task_title" \
        --arg effort "$task_effort" \
        '.daily_tasks += {($date): {"task_id": $id, "task_title": $title, "effort_hours": $effort|tonumber, "status": "in_progress", "selected_at": now|todate}} |
        .statistics.in_progress += 1')
    
    echo "$NEW_JSON" > "$LOG_FILE"
    echo -e "${GREEN}Selection logged${NC}"
}

# Function to generate work plan
generate_work_plan() {
    local task_id=$1
    local task_title=$2
    local task_effort=$3
    
    WORK_PLAN_FILE="./daily_work_plan_${TODAY}.md"
    
    cat > "$WORK_PLAN_FILE" << EOF
# Daily Work Plan - $TODAY

## Selected Task
- **ID**: $task_id
- **Title**: $task_title  
- **Estimated Effort**: $task_effort hours
- **Priority**: ${SELECTED_PRIORITY}
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
    
    echo -e "${GREEN}Work plan generated: $WORK_PLAN_FILE${NC}"
}

# Function to complete previous day's task
complete_previous_task() {
    YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)
    
    echo -e "${YELLOW}Checking for yesterday's task to complete...${NC}"
    
    # Check if yesterday's task exists in log
    YESTERDAY_TASK=$(jq -r --arg date "$YESTERDAY" '.daily_tasks[$date] // empty' "$LOG_FILE" 2>/dev/null)
    
    if [ -n "$YESTERDAY_TASK" ]; then
        TASK_ID=$(echo "$YESTERDAY_TASK" | jq -r '.task_id')
        TASK_STATUS=$(echo "$YESTERDAY_TASK" | jq -r '.status')
        
        if [ "$TASK_STATUS" = "in_progress" ]; then
            echo -e "${BLUE}Found yesterday's task: $TASK_ID${NC}"
            read -p "Mark task as completed? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                mark_task_completed "$TASK_ID" "$YESTERDAY"
            else
                echo -e "${YELLOW}Skipping completion for now${NC}"
            fi
        fi
    else
        echo -e "${GREEN}No yesterday's task found or already completed${NC}"
    fi
}

# Function to mark task as completed
mark_task_completed() {
    local task_id=$1
    local task_date=$2
    
    echo -e "${YELLOW}Marking task $task_id as completed...${NC}"
    
    # Update backlog
    cp "$BACKLOG_FILE" "${BACKLOG_FILE}.bak"
    
    awk -v task_id="$task_id" -v today="$TODAY" '
    BEGIN { in_task=0; updated=0 }
    /^\*\*'"${task_id}"'\*\*/ { 
        in_task=1
        print $0
        next
    }
    in_task && /- \*\*Status\*\*: / {
        print "- **Status**: Done"
        print "- **Completed**: " today
        in_task=0
        updated=1
        next
    }
    { print $0 }
    END {
        if (!updated) {
            print "Warning: Task " task_id " not found in backlog" > "/dev/stderr"
        }
    }
    ' "$BACKLOG_FILE" > "${BACKLOG_FILE}.tmp"
    
    mv "${BACKLOG_FILE}.tmp" "$BACKLOG_FILE"
    
    # Update log
    LOG_JSON=$(cat "$LOG_FILE")
    NEW_JSON=$(echo "$LOG_JSON" | jq --arg date "$task_date" \
        '.daily_tasks[$date].status = "completed" |
        .daily_tasks[$date].completed_at = now|todate |
        .statistics.in_progress -= 1 |
        .statistics.completed += 1')
    
    echo "$NEW_JSON" > "$LOG_FILE"
    
    echo -e "${GREEN}Task $task_id marked as completed${NC}"
    
    # Generate completion report
    generate_completion_report "$task_id" "$task_date"
}

# Function to generate completion report
generate_completion_report() {
    local task_id=$1
    local task_date=$2
    
    REPORT_FILE="./completion_report_${task_date}.md"
    
    cat > "$REPORT_FILE" << EOF
# Task Completion Report - $task_date

## Task Details
- **Task ID**: $task_id
- **Completed Date**: $TODAY
- **Original Selection Date**: $task_date

## Summary
Task successfully completed as per requirements.

## What Was Done
1. Implementation completed
2. Testing passed
3. Documentation updated
4. Code reviewed

## Time Spent
- Estimated: [Fill in]
- Actual: [Fill in]
- Variance: [Fill in]

## Challenges
- [List any challenges faced]

## Lessons Learned
- [Key takeaways]

## Next Steps
- [Any follow-up actions]

## Quality Metrics
- [ ] Code coverage maintained
- [ ] No new bugs introduced
- [ ] Performance benchmarks met
- [ ] User experience improved

---
*Generated by Daily Task Selector at $(date)*
EOF
    
    echo -e "${GREEN}Completion report generated: $REPORT_FILE${NC}"
}

# Main execution
main() {
    # Complete previous day's task first
    complete_previous_task
    
    # Select today's task
    select_task
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Today's task has been selected!${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review the work plan: ./cross_app/daily_work_plan_${TODAY}.md"
    echo "2. Start working on the task"
    echo "3. Update progress throughout the day"
    echo "4. Mark as completed when done"
    echo ""
    echo "To manually mark as completed later:"
    echo "  ./daily_task_selector.sh --complete $TASK_ID"
}

# Check for command line arguments
if [ "$1" = "--complete" ] && [ -n "$2" ]; then
    mark_task_completed "$2" "$TODAY"
    exit 0
elif [ "$1" = "--help" ]; then
    echo "Usage: $0 [OPTION]"
    echo "Options:"
    echo "  --complete TASK_ID    Mark a specific task as completed"
    echo "  --help                Show this help message"
    echo ""
    echo "Without options, runs the daily task selection process."
    exit 0
fi

# Run main function
main