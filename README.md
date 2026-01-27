# Cross - Workout Tracking App

A robust mobile application for tracking strength training workouts, managing routines, and monitoring progress.

## Features

- 🔐 Secure authentication (Email/Password, Google, Apple)
- 💪 Comprehensive exercise library
- 📊 Workout logging with sets, reps, and weights
- 📅 Customizable workout routines and programs
- 📈 Progress tracking with charts and analytics
- 🌙 Dark mode support
- 📱 Cross-platform (iOS & Android)
- 🔄 Real-time sync with offline support

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL, Auth, Realtime)
- **State Management**: Riverpod
- **Local Storage**: Hive
- **Charts**: FL Chart

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK
- iOS Simulator or Android Emulator
- Supabase account

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd cross_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Supabase
   - Create a new project at https://supabase.com
   - Copy your project URL and anon key
   - Create a `.env` file in the root directory:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Root app widget
├── core/                     # Core utilities and constants
│   ├── config/              # Configuration files
│   ├── constants/           # App constants
│   ├── theme/               # Theme configurations
│   └── utils/               # Utility functions
├── features/                # Feature modules
│   ├── auth/               # Authentication
│   ├── profile/            # User profile
│   ├── exercises/          # Exercise library
│   ├── workouts/           # Workout logging
│   ├── routines/           # Routines management
│   ├── progress/           # Progress tracking
│   └── settings/           # App settings
├── models/                  # Data models
├── providers/              # Riverpod providers
├── repositories/           # Data repositories
├── services/               # External services
└── widgets/                # Reusable widgets
```

## License

Proprietary - All rights reserved

