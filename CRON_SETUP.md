# Cross App Daily Task Automation - Cron Setup

This document describes how to set up automatic daily task selection and completion for the Cross app backlog.

## Overview

The system consists of:
1. **Backlog file** (`BACKLOG.md`) - Contains all tasks with priorities
2. **Daily selector script** (`daily_task_selector.sh`) - Selects and manages tasks
3. **Cron job** - Runs the script automatically every weekday
4. **Log file** (`daily_task_log.json`) - Tracks progress and statistics

## Setup Instructions

### 1. Test the Script
```bash
cd /Users/nelson.cheung/clawd/cross_app
./daily_task_selector.sh
```

### 2. Set Up Cron Job
Add this to your crontab to run at 9:00 AM every weekday:

```bash
# Edit crontab
crontab -e

# Add this line (adjust path as needed)
0 9 * * 1-5 cd /Users/nelson.cheung/clawd && ./cross_app/daily_task_selector.sh >> /Users/nelson.cheung/clawd/cross_app/cron.log 2>&1
```

### Alternative: Use Clawdbot's Cron System
```bash
# Create a cron job via Clawdbot
clawdbot cron add --schedule "0 9 * * 1-5" --command "cd /Users/nelson.cheung/clawd && ./cross_app/daily_task_selector.sh"
```

### 3. Manual Commands

#### Select today's task:
```bash
./cross_app/daily_task_selector.sh
```

#### Mark a task as completed:
```bash
./cross_app/daily_task_selector.sh --complete P1-001
```

#### Check status:
```bash
# View backlog
cat ./cross_app/BACKLOG.md | grep -A5 "Status:"

# View log
cat ./cross_app/daily_task_log.json | jq .
```

## Daily Workflow

### Morning (9:00 AM)
1. Cron runs `daily_task_selector.sh`
2. Script completes yesterday's task (if any)
3. Script selects today's task based on priority and effort
4. Updates backlog status to "In Progress"
5. Generates daily work plan
6. Logs selection

### During the Day
1. Developer works on selected task
2. Updates progress in work plan file
3. Tests implementation

### Evening (Optional - 6:00 PM)
1. Script can be run manually to mark task as completed
2. Generates completion report
3. Updates statistics

## Task Selection Algorithm

### Priority Weights
- **P1 (Critical)**: 70% chance
- **P2 (Important)**: 20% chance  
- **P3 (Enhancement)**: 7% chance
- **P4 (Technical Debt)**: 3% chance

### Selection Criteria
1. Only tasks with "Not Started" status are considered
2. Tasks must have estimated effort ≤ 4 hours
3. Random selection within priority pool
4. Falls back to next priority if pool is empty

## File Structure

```
cross_app/
├── BACKLOG.md                    # Main backlog with all tasks
├── daily_task_selector.sh        # Automation script
├── daily_task_log.json           # Progress tracking log
├── daily_work_plan_YYYY-MM-DD.md # Today's work plan
├── completion_report_YYYY-MM-DD.md # Completion reports
└── cron.log                      # Cron job output
```

## Customization

### Adjust Priority Weights
Edit `daily_task_selector.sh` around line 100:
```bash
# Priority weights (higher = more likely to be selected)
# 70% chance for P1, 20% for P2, 7% for P3, 3% for P4
RAND=$((RANDOM % 100))
```

### Change Daily Schedule
Edit crontab:
```bash
# Run at 8:30 AM instead of 9:00 AM
30 8 * * 1-5 cd /Users/nelson.cheung/clawd && ./cross_app/daily_task_selector.sh
```

### Add More Tasks
Edit `BACKLOG.md` and add tasks in the appropriate priority sections.

## Monitoring

### Check Daily Status
```bash
# View today's work plan
cat ./cross_app/daily_work_plan_$(date +%Y-%m-%d).md

# View progress statistics
cat ./cross_app/daily_task_log.json | jq '.statistics'

# View all completed tasks
cat ./cross_app/BACKLOG.md | grep -B2 "Status: Done"
```

### View Logs
```bash
# Cron job logs
tail -f ./cross_app/cron.log

# Script output
./cross_app/daily_task_selector.sh --help
```

## Troubleshooting

### Script Fails to Run
1. Check permissions: `chmod +x ./cross_app/daily_task_selector.sh`
2. Check dependencies: `jq` command must be installed
3. Check paths: Update paths in script if needed

### No Tasks Selected
1. Check if all tasks are marked as "Done" or "In Progress"
2. Add more tasks to backlog
3. Check task parsing in script

### Cron Job Not Running
1. Check crontab: `crontab -l`
2. Check cron service: `sudo service cron status`
3. Check logs: `grep CRON /var/log/syslog`

## Integration with Development Workflow

### With Git
```bash
# After completing a task
git add ./cross_app/BACKLOG.md ./cross_app/daily_task_log.json
git commit -m "Completed P1-001: Fix crash bugs"
git push
```

### With IDE
- Open daily work plan file at start of day
- Update progress throughout day
- Commit changes when task completed

### With Team Collaboration
- Share backlog with team
- Review completed tasks weekly
- Adjust priorities based on feedback

## Statistics Tracking

The system tracks:
- Total tasks completed
- Tasks in progress
- Time spent per task
- Priority distribution
- Completion rate

View statistics:
```bash
cat ./cross_app/daily_task_log.json | jq '.statistics'
```

## Advanced Features (Future)

### 1. Slack/Telegram Notifications
- Send daily task selection to chat
- Send completion notifications

### 2. Time Tracking Integration
- Track actual vs estimated time
- Generate time reports

### 3. AI-Powered Task Selection
- Learn from completion patterns
- Adjust weights based on success rate

### 4. Dependency Tracking
- Automatically handle task dependencies
- Reschedule blocked tasks

## Support

For issues:
1. Check script logs: `./cross_app/cron.log`
2. Verify backlog format matches expected pattern
3. Ensure `jq` is installed: `brew install jq`
4. Check file permissions

## Example Daily Output

```
=== Cross App Daily Task Selector ===
Date: 2026-02-04

Checking for yesterday's task to complete...
No yesterday's task found or already completed

Selecting task for today...
Selected from P1 (Critical) tasks
Selected Task: P1-001 - Fix any crash bugs or stability issues
Estimated Effort: 2 hours
Updating backlog status...
Backlog updated
Selection logged
Work plan generated: ./cross_app/daily_work_plan_2026-02-04.md

========================================
Today's task has been selected!
========================================

Next steps:
1. Review the work plan: ./cross_app/daily_work_plan_2026-02-04.md
2. Start working on the task
3. Update progress throughout the day
4. Mark as completed when done
```