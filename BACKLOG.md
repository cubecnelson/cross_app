# Cross App - Improvement Backlog

This is a prioritized backlog of improvements and features for the Cross workout tracking app. The system will automatically select and complete one task per day.

## Backlog Categories

### 🟢 P1 - Critical (High Impact, Low Effort)
- **P1-001**: Fix any crash bugs or stability issues
- **P1-002**: Improve startup performance
- **P1-003**: Fix authentication edge cases
- **P1-004**: Add error handling for network failures
- **P1-005**: Add achievement system (gamification) - NEW
- **P1-006**: Implement workout streaks - NEW

### 🟡 P2 - Important (Medium Impact, Medium Effort)
- **P2-001**: Implement Google OAuth authentication
- **P2-002**: Implement Apple Sign-In
- **P2-003**: Add workout rest timer with notifications
- **P2-004**: Add exercise videos and tutorials
- **P2-005**: Implement data export (CSV/PDF)
- **P2-006**: Add Apple Health/Google Fit integration
- **P2-007**: Add basic social sharing - MOVED FROM P3-001
- **P2-008**: Implement advanced analytics (1RM tracking, PRs) - MOVED FROM P3-005
- **P2-009**: Add monthly challenges - NEW

### 🔵 P3 - Enhancement (Low Impact, High Effort)
- **P3-001**: Create workout templates marketplace
- **P3-002**: Enhance ML recommendations
- **P3-003**: Implement periodization planning
- **P3-004**: Add smart watch integration - NEW
- **P3-005**: Add nutrition tracking integration - NEW
- **P3-006**: Expand video workout library - NEW
- **P3-007**: Create web/desktop version

### 🟣 P4 - Technical Debt
- **P4-001**: Add comprehensive unit tests
- **P4-002**: Add widget/integration tests
- **P4-003**: Refactor large components
- **P4-004**: Update dependencies
- **P4-005**: Improve documentation
- **P4-006**: Add performance monitoring

## Daily Task Selection System

### Selection Criteria
1. **Priority** (P1 > P2 > P3 > P4)
2. **Estimated Effort** (≤ 4 hours for daily task)
3. **Dependencies** (blocked tasks postponed)
4. **Random Weighting** (avoid always choosing same category)

### Daily Workflow
1. **Morning (9:00 AM)**: System selects task for the day
2. **Daytime**: Work on selected task
3. **Evening (6:00 PM)**: Report progress/complete task
4. **Next Morning**: Select new task

### Automation Rules
- Each task must be completable in ≤ 4 hours
- If blocked, mark as "blocked" and select alternative
- Completed tasks moved to "Done" section
- Partially complete tasks can be split

## Task Templates

### Feature Implementation Template
```
## [Task ID] - [Task Title]

**Priority**: P1/P2/P3/P4
**Estimated Effort**: X hours
**Dependencies**: None/[List dependencies]
**Status**: Not Started/In Progress/Done/Blocked

### Description
[Detailed description of what needs to be done]

### Acceptance Criteria
- [ ] [Specific requirement 1]
- [ ] [Specific requirement 2]
- [ ] [Specific requirement 3]

### Implementation Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Files to Modify
- `path/to/file1.dart`
- `path/to/file2.dart`
- `path/to/file3.dart`

### Testing Requirements
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing

### Notes
[Any additional notes]
```

### Bug Fix Template
```
## [Task ID] - [Bug Description]

**Priority**: P1/P2/P3/P4
**Estimated Effort**: X hours
**Dependencies**: None/[List dependencies]
**Status**: Not Started/In Progress/Done/Blocked

### Bug Description
[What's broken]

### Reproduction Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]

### Root Cause
[Suspected cause]

### Fix Plan
1. [Fix step 1]
2. [Fix step 2]
3. [Fix step 3]

### Testing
- [ ] Test fix
- [ ] Regression test
- [ ] Edge cases
```

## Current Backlog

### 🟢 P1 Tasks
**P1-001**: [Task Title]
- **Status**: ✅ Done
- **Completed**: 2026-02-10
- **Status**: ✅ Done
- **Completed**: 2026-02-10
- **Status**: ✅ Done (blocked, moved to backlog)
- **Effort**: 2 hours
- **Notes**: No crash logs found, moved to backlog for future investigation

**P1-002**: Improve startup performance  
- **Status**: ✅ Done (partially completed with workflow cleanup)
- **Effort**: 3 hours
- **Notes**: Profiled and optimized workflow startup, removed complex fallback logic, simplified CI/CD pipeline

**P1-003**: Fix authentication edge cases
- **Status**: Not Started
- **Effort**: 2 hours
- **Notes**: Test offline auth, token refresh issues

**P1-004**: Add error handling for network failures
- **Status**: Done
- **Completed**: 2026-02-03
- **Effort**: 2 hours
- **Notes**: Add retry logic, better error messages

**P1-005**: Add achievement system (gamification)
- **Status**: ✅ Partially Complete
- **Completed**: 2026-02-19
- **Effort**: 3 hours
- **Notes**: Implemented achievement notifications for milestones (50/100 workouts, 10k/50k AU, 7/30 day streaks) via TrainingAlertService. Still needs UI components (badges, achievement screen, points system).

**P1-006**: Implement workout streaks
- **Status**: ✅ Partially Complete
- **Completed**: 2026-02-19
- **Effort**: 2 hours
- **Notes**: Implemented streak calculation logic in TrainingAlertService with notifications for 7-day and 30-day streaks. Still needs UI display (current streak on dashboard, streak calendar).

### 🟡 P2 Tasks
**P2-001**: Implement Google OAuth authentication
- **Status**: In Progress
- **Effort**: 4 hours
- **Notes**: Follow Google Auth setup guide in docs

**P2-002**: Implement Apple Sign-In
- **Status**: Not Started
- **Effort**: 4 hours
- **Notes**: Required for iOS App Store

**P2-003**: Add workout rest timer with notifications
- **Status**: ✅ Done
- **Effort**: 3 hours
- **Notes**: Background timer, local notifications
- **Completed Features**:
  - Full rest timer service with notifications
  - Timer widget with pause/resume/skip/reset controls
  - Integration into active workout screen
  - Quick duration presets (30s, 1m, 1m30s, 2m, 3m)
  - Progress visualization with circular and linear indicators
  - Local notifications for timer completion
  - Floating action button for quick access during workouts

**P2-004**: Add exercise videos and tutorials
- **Status**: ✅ Done (2026-02-03)
- **Effort**: 4 hours
- **Notes**: Curate or create exercise videos
- **Completed Features**:
  - Added video_url and tutorial_url fields to exercises table
  - Created ExerciseDetailScreen with video/tutorial viewing
  - Seeded 10+ popular exercises with YouTube tutorial URLs
  - Updated ExercisePickerScreen to show video icons and details

**P2-005**: Implement data export (CSV/PDF)
- **Status**: ✅ Done
- **Effort**: 3 hours
- **Completed**: 2026-02-12 16:00 GMT+8
- **Notes**: Export workout history
- **Completed Features**:
  - Full CSV export with detailed workout data (sets, reps, weights, cardio metrics)
  - PDF export with workout summaries and statistics (text-based placeholder)
  - DataExportScreen with statistics display and format selection
  - Integration with device sharing system (share_plus)
  - Support for both CSV and PDF formats
  - Statistics display showing total workouts, sets, volume, and date range

**P2-006**: Add Apple Health/Google Fit integration
- **Status**: ✅ Done (2026-02-03)
- **Effort**: 4 hours
- **Notes**: Sync workout data with health apps
- **Completed Features**:
  - Added health, healthkit, and google_fit dependencies
  - Created HealthService with platform detection
  - Added HealthSettingsScreen for connection management
  - Support sync of workouts to Apple Health/Google Fit
  - Display daily health metrics in app

**P2-007**: Add basic social sharing
- **Status**: Not Started
- **Effort**: 4 hours
- **Notes**: Share workouts to social media, friends

**P2-008**: Implement advanced analytics (1RM tracking, PRs)
- **Status**: Not Started
- **Effort**: 6 hours
- **Notes**: One-rep max calculations, personal records

**P2-009**: Add monthly challenges
- **Status**: In Progress
- **Effort**: 3 hours
- **Notes**: Community challenges, leaderboards

### 🔵 P3 Tasks
**P3-001**: Create workout templates marketplace
- **Status**: Not Started
- **Effort**: 12 hours
- **Notes**: User-generated content system

**P3-002**: Enhance ML recommendations
- **Status**: Not Started
- **Effort**: 16 hours
- **Notes**: Advanced personalization, AI-generated workouts

**P3-003**: Implement periodization planning
- **Status**: Not Started
- **Effort**: 8 hours
- **Notes**: Advanced training planning

**P3-004**: Add smart watch integration
- **Status**: Not Started
- **Effort**: 6 hours
- **Notes**: Apple Watch, Garmin, Fitbit integration

**P3-005**: Add nutrition tracking integration
- **Status**: Not Started
- **Effort**: 8 hours
- **Notes**: Meal logging, calorie tracking

**P3-006**: Expand video workout library
- **Status**: Not Started
- **Effort**: 4 hours
- **Notes**: Premium workout videos, form tutorials

**P3-007**: Create web/desktop version
- **Status**: Not Started
- **Effort**: 20 hours
- **Notes**: Flutter web/desktop support

### 🟣 P4 Tasks
**P4-001**: Add comprehensive unit tests
- **Status**: Not Started
- **Effort**: 10 hours
- **Notes**: Test coverage for all models/services

**P4-002**: Add widget/integration tests
- **Status**: Not Started
- **Effort**: 12 hours
- **Notes**: UI testing

**P4-003**: Refactor large components
- **Status**: Not Started
- **Effort**: 8 hours
- **Notes**: Break down complex widgets

**P4-004**: Update dependencies
- **Status**: Not Started
- **Effort**: 2 hours
- **Notes**: Keep packages up to date

**P4-005**: Improve documentation
- **Status**: Not Started
- **Effort**: 4 hours
- **Notes**: API docs, user guides

**P4-006**: Add performance monitoring
- **Status**: Not Started
- **Effort**: 3 hours
- **Notes**: Add analytics for performance metrics

## Daily Selection Log

### 2026-02-20
**Selected Task**: P2-009
**Reason**: Automatically selected by daily task selector
**Status**: In Progress
**Start Time**: 9:00 AM
**Expected Completion**: 12:01 PM

### 2026-02-19
**Selected Task**: P1-005
**Reason**: Automatically selected by daily task selector
**Status**: In Progress
**Start Time**: 9:00 AM
**Expected Completion**: 1:00 PM


### 2026-02-12
**Selected Task**: P2-005
**Reason**: User requested implementation of data export feature
**Status**: ✅ Completed
**Start Time**: 10:21 AM GMT+8
**Completion Time**: 16:00 PM GMT+8
**Work Completed**:
- Created ExportService with CSV and PDF export functionality
- Built DataExportScreen with statistics display and format selection
- Added provider for state management
- Integrated with Settings screen
- Added share_plus and path_provider dependencies

### 2026-02-11
**Selected Task**: P2-001
**Reason**: Automatically selected by daily task selector
**Status**: In Progress
**Start Time**: 9:00 AM
**Expected Completion**: 01:02 PM

### 2026-02-10
**Selected Task**: P2-003
**Reason**: User requested to switch to P2-003 (rest timer notifications)
**Status**: In Progress
**Start Time**: 17:29 GMT+8
**Expected Completion**: 20:29 GMT+8

### 2026-02-09
**Selected Task**: P1-001
**Reason**: Automatically selected by daily task selector
**Status**: In Progress
**Start Time**: 9:00 AM
**Expected Completion**: 11:01 AM

### 2026-02-05
**Selected Task**: P1-002
**Reason**: Automatically selected by daily task selector
**Status**: Completed
**Start Time**: 9:00 AM
**Completion Time**: 11:44 PM
**Work Completed**:
- Simplified GitHub Actions workflows for faster build startup
- Removed complex fallback logic from `build-ios.yml`
- Standardized API key variable names for reliability
- Cleaned up backup files to reduce analysis time
- Installed Flutter 3.38.7 for consistent local/CI development

### 2026-02-03
**Selected Task**: P1-004
**Reason**: Automatically selected by daily task selector
**Status**: Completed
**Start Time**: 9:00 AM
**Expected Completion**: 06:29 PM
**Completion Time**: 8:02 PM

### 2026-02-04
**Selected Task**: P1-001 - Fix any crash bugs or stability issues
**Reason**: Highest priority, foundation for all other work
**Status**: In Progress (P2-005 completed 2026-02-12)
**Start Time**: 9:00 AM 2026-02-04
**Expected Completion**: 11:00 AM 2026-02-04

## Completed Tasks

### ✅ 2026-02-03
**P2-004**: Add exercise videos and tutorials
- **Video URLs**: 10+ popular exercises seeded with YouTube tutorials
- **Detail Screen**: ExerciseDetailScreen with video/tutorial viewing
- **Integration**: ExercisePickerScreen shows video icons and long-press for details

**P2-006**: Add Apple Health/Google Fit integration  
- **Platform Support**: Automatic detection of Apple Health or Google Fit
- **Data Sync**: Workouts automatically synced to health platforms
- **Health Metrics**: Display steps, calories, heart rate, distance in app
- **Settings**: HealthSettingsScreen for connection management

## Statistics
- **Total Tasks**: 22
- **P1 (Critical)**: 4 tasks
- **P2 (Important)**: 6 tasks  
- **P3 (Enhancement)**: 6 tasks
- **P4 (Technical Debt)**: 6 tasks
- **Completed**: 4 tasks (P1‑002, P1‑004, P2‑004, P2‑006)
- **In Progress**: 1 task (P1‑001)
- **Blocked**: 0 tasks

## Automation Script

A script will run daily to:
1. Select next task based on priority and effort
2. Create daily work plan
3. Track progress
4. Move completed tasks to done

To implement the automation:
- Create cron job for daily task selection
- Build task selection algorithm
- Add progress tracking
- Generate daily reports
