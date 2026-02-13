#!/bin/bash
# cross_daily_task.sh
# Wrapper script for Cross app daily task selection

cd /Users/nelson.cheung/clawd/cross_app
./daily_task_simple.sh

# Send notification to Telegram
TODAY=$(date +%Y-%m-%d)
# Extract task details from work plan
TASK_ID=$(grep -m1 "^\*\*ID\*\*:" daily_work_plan_${TODAY}.md | sed 's/.*\*\*ID\*\*: //')
TASK_TITLE=$(grep -m1 "^\*\*Title\*\*:" daily_work_plan_${TODAY}.md | sed 's/.*\*\*Title\*\*: //')
TASK_EFFORT=$(grep -m1 "^\*\*Estimated Effort\*\*:" daily_work_plan_${TODAY}.md | sed 's/.*\*\*Estimated Effort\*\*: //')
TASK_PRIORITY=$(grep -m1 "^\*\*Priority\*\*:" daily_work_plan_${TODAY}.md | sed 's/.*\*\*Priority\*\*: //')

# Create a simple notification message
cat > notification_${TODAY}.txt << EOF
📋 Cross App Daily Task Selected

Task selected for ${TODAY}:
**ID**: ${TASK_ID}
**Title**: ${TASK_TITLE}
**Effort**: ${TASK_EFFORT}
**Priority**: ${TASK_PRIORITY}

Work plan: daily_work_plan_${TODAY}.md
Backlog updated: BACKLOG.md

Start working on it today!
EOF

echo "Task selected for ${TODAY}"
echo "Notification saved to notification_${TODAY}.txt"