# App Store Assets Plan - Cross Workout Tracking App

## Overview
This document outlines the screenshots, previews, and marketing assets needed for app store submission (iOS App Store and Google Play Store).

## App Store Requirements

### iOS App Store
- **iPhone Screenshots**: 6.5-inch (iPhone 14 Pro Max) and 5.5-inch (iPhone 8 Plus) displays
- **iPad Screenshots**: 12.9-inch (iPad Pro) and 11-inch (iPad Air) displays  
- **Apple Watch Screenshots** (if applicable)
- **App Preview Video**: 30-second vertical video (optional but recommended)
- **Required Sizes**:
  - iPhone: 1290×2796 pixels (6.7-inch) or 1242×2688 pixels (6.5-inch)
  - iPad: 2048×2732 pixels (12.9-inch) or 1668×2388 pixels (11-inch)

### Google Play Store
- **Phone Screenshots**: 1080×1920 pixels (Full HD)
- **7-inch Tablet Screenshots**: 1200×1920 pixels
- **10-inch Tablet Screenshots**: 1600×2560 pixels
- **Feature Graphic**: 1024×500 pixels
- **Promo Video**: 30-120 seconds (optional)
- **Required**: At least 2 screenshots, recommended 7-8

## Key Features to Showcase

### Primary Screens (Must Have)
1. **Dashboard/Home Screen** - Overview of workouts, progress, quick actions
2. **Active Workout Screen** - Tracking workout with timer, exercises, sets
3. **Workout History/Progress** - Charts, graphs showing training progress
4. **Routines List** - Browse and manage workout routines
5. **Create/Edit Routine** - Building custom workout routines
6. **Training Load/Analytics** - ACWR, injury prevention alerts
7. **Achievements/Gamification** - Badges, streaks, challenges
8. **Settings** - App customization options

### Secondary Screens (Nice to Have)
9. **Exercise Library** - Browse exercises with videos
10. **Social/Sharing** - Share workout achievements
11. **Notifications/Alerts** - Training reminders, achievement unlocks
12. **Data Export** - Export workout data to CSV/PDF

## Screenshot Plan

### iPhone Set (6.5-inch: 1242×2688 pixels)
1. **Dashboard** - Welcome screen with workout stats
2. **Active Workout** - Timer running with exercise details  
3. **Progress Charts** - Training load and workout history
4. **Routines List** - Browse routines with play/edit buttons
5. **Create Routine** - Adding exercises to custom routine
6. **Achievements** - Badges and streaks unlocked
7. **Training Alerts** - ACWR-based injury prevention notification
8. **Settings** - App customization options

### iPad Set (12.9-inch: 2048×2732 pixels)
1. **Dashboard** - Optimized for larger screen
2. **Active Workout** - Multi-pane workout interface
3. **Progress Analytics** - Detailed charts and statistics
4. **Routine Editor** - Drag-and-drop exercise management

### Android Phone Set (1080×1920 pixels)
Same as iPhone set but with Android device frames

### Feature Graphic (1024×500 pixels)
Combination of app icon, tagline, and key features:
"Track. Analyze. Improve. Your AI-powered workout companion."

## App Preview Video Script (30 seconds)

### Scene 1: Opening (0-5s)
- App icon animation
- Tagline: "Transform your workouts with data-driven insights"

### Scene 2: Dashboard (5-10s)  
- Quick overview: "See your training load, streak, and upcoming workouts"

### Scene 3: Start Workout (10-15s)
- Tap routine → Begin workout with timer
- "Track sets, reps, and weights in real-time"

### Scene 4: Progress Analytics (15-20s)
- Swipe to charts: "Monitor your training load and avoid injury"

### Scene 5: Achievements (20-25s)
- Badge unlock animation: "Stay motivated with gamification"

### Scene 6: Closing (25-30s)
- App store badges: "Download on App Store and Google Play"

## Implementation Options

### Option 1: Real Screenshots (Recommended)
- Run app on simulators/emulators
- Capture screenshots using automation
- Most authentic but requires setup

### Option 2: Mockups
- Create using Figma/Sketch/Photoshop
- Use device mockup templates
- More control over appearance

### Option 3: Hybrid Approach
- Base screens from app
- Enhance with overlays/annotations
- Add device frames and backgrounds

## Tools & Resources

### For Screenshot Generation
- **Flutter Screenshot Package**: `screenshots` or `fastlane`
- **Device Frames**: https://deviceframes.com
- **Mockup Tools**: Figma, Sketch, Adobe XD
- **Automation**: Appium, Flutter Driver

### For Video Creation
- **Screen Recording**: iOS Simulator, Android Emulator
- **Video Editing**: Final Cut Pro, Premiere Pro, DaVinci Resolve
- **Animation**: After Effects, Lottie

## Timeline & Tasks

### Phase 1: Planning & Setup (Day 1)
- [ ] Finalize screenshot list
- [ ] Set up screenshot automation
- [ ] Prepare test data for screens

### Phase 2: Screenshot Capture (Day 2)
- [ ] Capture iPhone screenshots
- [ ] Capture iPad screenshots  
- [ ] Capture Android screenshots
- [ ] Create feature graphic

### Phase 3: App Preview Video (Day 3)
- [ ] Write detailed script
- [ ] Record screen footage
- [ ] Edit and add voiceover/music
- [ ] Export in required formats

### Phase 4: Review & Optimization (Day 4)
- [ ] Review all assets
- [ ] Optimize file sizes
- [ ] Create metadata (descriptions, keywords)
- [ ] Prepare for submission

## File Structure
```
app_store_assets/
├── ios/
│   ├── iphone/
│   │   ├── 6.5-inch/
│   │   │   ├── 01_dashboard.png
│   │   │   ├── 02_active_workout.png
│   │   │   └── ...
│   │   └── 5.5-inch/
│   ├── ipad/
│   │   ├── 12.9-inch/
│   │   └── 11-inch/
│   └── app_preview.mp4
├── android/
│   ├── phone/
│   │   └── 1080x1920/
│   ├── tablet/
│   │   ├── 7-inch/
│   │   └── 10-inch/
│   └── feature_graphic.png
├── marketing/
│   ├── app_icon_variants/
│   ├── social_media/
│   └── press_kit/
└── metadata/
    ├── app_store_description.txt
    ├── play_store_description.txt
    └── keywords.txt
```

## Next Steps
1. **Approve this plan** - Confirm screenshots and approach
2. **Set up development environment** for screenshot capture
3. **Prepare test data** to populate screens with realistic content
4. **Begin screenshot capture** using chosen method

Let me know which approach you prefer and I'll start implementation!