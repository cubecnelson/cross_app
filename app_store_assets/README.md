# App Store Assets for Cross Workout App

## Overview
This directory contains SVG mockups of key app screens for app store submission (iOS App Store and Google Play Store).

## Created Mockups

### SVG Files (270×585 pixels - Phone mockup size)
1. **dashboard.svg** - Main dashboard with stats and quick actions
2. **active_workout.svg** - Active workout screen with timer and exercise cards  
3. **progress.svg** - Progress analytics with charts and training load
4. **routines.svg** - Routines list with play/edit/delete buttons
5. **achievements.svg** - Achievements screen with badges and streaks
6. **workout.svg** - Existing workout screen mockup (from docs)

## App Store Requirements

### iOS App Store
- **iPhone 6.5-inch**: 1242×2688 pixels (portrait)
- **iPhone 5.5-inch**: 1242×2208 pixels (portrait)
- **iPad 12.9-inch**: 2048×2732 pixels (portrait)
- **App Preview Video**: 15-30 seconds, vertical

### Google Play Store  
- **Phone**: 1080×1920 pixels (portrait)
- **7-inch Tablet**: 1200×1920 pixels (portrait)
- **10-inch Tablet**: 1600×2560 pixels (portrait)
- **Feature Graphic**: 1024×500 pixels (landscape)
- **Promo Video**: Up to 120 seconds

## Conversion Steps

### Step 1: Convert SVGs to PNGs
You have several options:

#### Option A: Online Converters (Easiest)
1. Go to https://svgtopng.com/ or similar
2. Upload each SVG file
3. Set output size (see sizes above)
4. Download PNGs

#### Option B: Command Line (if tools available)
```bash
# Using Inkscape (install via Homebrew: brew install inkscape)
inkscape -w 1242 -h 2688 dashboard.svg -o dashboard_iphone_6.5.png

# Using ImageMagick (install via Homebrew: brew install imagemagick)
convert -resize 1242x2688 dashboard.svg dashboard_iphone_6.5.png
```

#### Option C: Python Script (requires cairosvg)
```bash
pip install cairosvg
python3 convert_svgs.py
```

### Step 2: Add Device Frames
Use free online tools or design software:

1. **App Store Screenshot Maker** (https://appstorescreenshot.com/)
2. **Mockuphone** (https://mockuphone.com/)
3. **Figma Device Mockups** (templates available)
4. **Photoshop/Illustrator** with device frame templates

### Step 3: Create Feature Graphic
Combine key screens into a 1024×500 banner:
- App icon
- Tagline: "Track. Analyze. Improve. Your AI-powered workout companion."
- 3-4 key feature highlights

### Step 4: App Preview Video (Optional but Recommended)
1. **Script**: 30-second video showing app flow
2. **Recording**: Use iOS Simulator/Android Emulator screen recording
3. **Editing**: Add voiceover, text overlays, music
4. **Export**: MP4, H.264, 30fps, 1080×1920

## Screenshot Organization

### For iOS App Store
```
ios/
├── iphone_6.5/
│   ├── 01_dashboard.png
│   ├── 02_active_workout.png
│   ├── 03_progress.png
│   ├── 04_routines.png
│   ├── 05_achievements.png
│   └── 06_settings.png
├── iphone_5.5/ (same screens)
├── ipad_12.9/ (same screens)
└── app_preview.mp4
```

### For Google Play Store
```
android/
├── phone_1080x1920/
├── tablet_7inch/
├── tablet_10inch/
├── feature_graphic.png
└── promo_video.mp4
```

## Recommended Screenshot Order

### iOS/Android (8 screens recommended):
1. **Dashboard** - App overview and quick stats
2. **Active Workout** - Tracking workout with timer
3. **Progress Analytics** - Charts and training load
4. **Routines List** - Browse and manage workouts
5. **Create Routine** - Building custom workout
6. **Achievements** - Badges and gamification
7. **Training Alerts** - Injury prevention notifications
8. **Settings** - App customization

## Metadata (App Store Text)

### App Name
Cross: AI Workout Tracker

### Subtitle (iOS)
Track. Analyze. Improve.

### Description
Transform your workouts with data-driven insights. Cross combines workout tracking with AI-powered analytics to help you train smarter, avoid injury, and stay motivated.

### Key Features
- 📊 **Smart Tracking**: Log workouts with sets, reps, RPE, and rest times
- 📈 **Training Analytics**: Monitor ACWR, acute/chronic load, injury risk
- 🏆 **Gamification**: Earn badges for consistency, PRs, and streaks
- 🔄 **Custom Routines**: Create and edit workout routines
- ⚡ **Real-time Updates**: Over-the-air updates with Shorebird
- 🔔 **Smart Alerts**: Get notified about training load and achievements

### Keywords
workout, fitness, tracking, analytics, gym, training, exercise, health, crossfit, strength, cardio

## Next Actions

1. ✅ **Mockups created** (SVG files in this directory)
2. 🔄 **Convert to PNG** at required sizes
3. 🔄 **Add device frames** using online tools
4. 🔄 **Create feature graphic** (1024×500)
5. 🔄 **Write app store descriptions** (see above)
6. 🔄 **Optional**: Create app preview video

## Tools & Resources

- **SVG to PNG**: https://svgtopng.com/
- **Device Frames**: https://deviceframes.com/
- **App Store Screenshots**: https://appstorescreenshot.com/
- **Video Editing**: DaVinci Resolve (free), iMovie
- **Design**: Figma (free for personal use)

## Notes
- All mockups created based on actual app screens
- Colors and layout match app's design system
- Update mockups if major UI changes occur
- Test screenshots on different device backgrounds