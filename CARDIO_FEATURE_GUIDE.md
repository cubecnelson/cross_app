# 🏋️ Complete Exercise Type Guide

## Overview

Cross now supports **three types of exercises**: strength training, cardio activities, and isometric holds! This guide explains all exercise types and how to use them.

---

## 🎯 Exercise Types

### **Strength Exercises** 💪
Track traditional weightlifting with:
- ✅ Weight (kg/lbs)
- ✅ Reps
- ✅ Sets
- ✅ Rest time
- ✅ RPE (Rate of Perceived Exertion)

### **Cardio Exercises** 🏃
Track running, cycling, swimming, and more with:
- ✅ **Distance** (km/miles)
- ✅ **Duration** (time)
- ✅ **Pace** (min/km or min/mile)
- ✅ **Heart Rate** (avg BPM)
- ✅ **Calories** burned
- ✅ **Elevation Gain** (meters/feet)
- ✅ **RPE** (Rate of Perceived Exertion)

### **Isometric Exercises** 🧘 (NEW!)
Track static holds and isometric contractions with:
- ✅ **Hold Time/Duration** (seconds)
- ✅ **Sets** (multiple holds)
- ✅ **Rest time** between holds
- ✅ **RPE** (Rate of Perceived Exertion)
- ✅ **Notes** (form cues, difficulty)

---

## 📊 Cardio Attributes (Inspired by Strava)

### **Distance** 🛣️
- Measured in kilometers or miles
- Tracks how far you've traveled
- **Example:** "5.2 km" or "3.1 miles"

### **Duration** ⏱️
- Time spent exercising
- Measured in seconds (displayed as HH:MM:SS)
- **Example:** "25:30" (25 minutes 30 seconds)

### **Pace** 🏃‍♂️
- Average time per distance unit
- **Example:** "5:30 min/km" or "8:52 min/mile"
- Automatically calculated from distance/duration

### **Heart Rate** ❤️
- Average heart rate during activity
- Measured in beats per minute (BPM)
- **Example:** "145 BPM"

### **Calories** 🔥
- Estimated calories burned
- **Example:** "320 cal"

### **Elevation Gain** ⛰️
- Total elevation climbed
- Measured in meters or feet
- **Example:** "120 m" or "394 ft"
- Great for trail running, hiking, cycling

---

## 🏋️ Model Changes

### **Exercise Model**

```dart
enum ExerciseType {
  strength,   // Traditional weightlifting
  cardio,     // Running, cycling, swimming, etc.
  isometric   // Planks, wall sits, holds, etc.
}

class Exercise {
  final ExerciseType exerciseType;
  // ... other fields
  
  bool get isStrength => exerciseType == ExerciseType.strength;
  bool get isCardio => exerciseType == ExerciseType.cardio;
  bool get isIsometric => exerciseType == ExerciseType.isometric;
}
```

### **WorkoutSet Model**

```dart
class WorkoutSet {
  // Strength attributes (now optional)
  final int? reps;
  final double? weight;
  final int? restTime;
  
  // Cardio attributes (NEW!)
  final double? distance;
  final int? duration;
  final double? pace;
  final int? heartRate;
  final int? calories;
  final double? elevationGain;
  
  // Common attributes
  final int? rpe;  // Works for both types
  final String? notes;
  
  // Computed properties
  double? get averagePace { ... }
  double? get speed { ... }
  bool get isStrength { ... }
  bool get isCardio { ... }
}
```

---

## 📱 Usage Examples

### **Strength Workout Set**
```dart
WorkoutSet(
  exerciseName: 'Bench Press',
  setNumber: 1,
  weight: 80.0,      // 80 kg
  reps: 10,
  restTime: 120,     // 2 minutes
  rpe: 7,
  isCompleted: true,
)
```

### **Cardio Workout Set**
```dart
WorkoutSet(
  exerciseName: 'Running',
  setNumber: 1,
  distance: 5.2,           // 5.2 km
  duration: 1530,          // 25 min 30 sec
  pace: 4.9,               // 4:54 min/km
  heartRate: 145,          // 145 BPM
  calories: 320,
  elevationGain: 45.0,     // 45 meters
  rpe: 8,
  isCompleted: true,
)
```

---

## 🗄️ Database Migration

### Run This SQL Script:

Open **Supabase SQL Editor** and run: `scripts/add_cardio_support.sql`

This will:
1. ✅ Add `exercise_type` column to `exercises` table
2. ✅ Make `reps` and `weight` nullable in `sets` table
3. ✅ Add cardio columns to `sets` table:
   - `distance` (DOUBLE PRECISION)
   - `duration` (INTEGER)
   - `pace` (DOUBLE PRECISION)
   - `heart_rate` (INTEGER)
   - `calories` (INTEGER)
   - `elevation_gain` (DOUBLE PRECISION)
4. ✅ Add 12 predefined cardio exercises
5. ✅ Create indexes for performance
6. ✅ Add documentation comments

---

## 🏃 Predefined Cardio Exercises

After running the migration, you'll have these cardio exercises:

| Exercise | Description | Typical Metrics |
|----------|-------------|-----------------|
| **Running** 🏃 | Outdoor/treadmill | Distance, Duration, Pace, HR |
| **Cycling** 🚴 | Road/stationary | Distance, Duration, Pace, HR |
| **Swimming** 🏊 | Lap swimming | Distance, Duration, Calories |
| **Rowing** 🚣 | Machine/water | Distance, Duration, HR, Calories |
| **Walking** 🚶 | Outdoor/treadmill | Distance, Duration, Pace |
| **Elliptical** | Trainer | Duration, Calories, HR |
| **Stair Climbing** | Machine/actual stairs | Duration, Elevation, HR |
| **Jump Rope** | Skipping | Duration, Calories, HR |
| **HIIT** | High-intensity intervals | Duration, Calories, HR |
| **Trail Running** ⛰️ | Off-road with elevation | Distance, Duration, Elevation |
| **Mountain Biking** | Off-road cycling | Distance, Duration, Elevation |
| **Hiking** | Outdoor with elevation | Distance, Duration, Elevation |

---

## 🎨 UI Considerations

### **Input Fields by Exercise Type**

**Strength Exercise Screen:**
```
┌─────────────────────────┐
│ Weight:  [80    ] kg    │
│ Reps:    [10    ]       │
│ Rest:    [120   ] sec   │
│ RPE:     [7     ]       │
└─────────────────────────┘
```

**Cardio Exercise Screen:**
```
┌─────────────────────────┐
│ Distance: [5.2  ] km    │
│ Duration: [25:30]       │
│ Pace:     [4:54 ] /km   │
│ HR:       [145  ] BPM   │
│ Calories: [320  ]       │
│ Elevation:[45   ] m     │
│ RPE:      [8    ]       │
└─────────────────────────┘
```

### **Display Formats**

**Distance:**
- Metric: "5.2 km"
- Imperial: "3.2 mi"

**Duration:**
- Short: "25:30" (MM:SS)
- Long: "1:25:30" (HH:MM:SS)

**Pace:**
- Metric: "4:54 /km"
- Imperial: "7:52 /mi"

**Heart Rate:**
- "145 BPM"
- Color zones: 🟢 Easy | 🟡 Moderate | 🟠 Hard | 🔴 Max

**Elevation:**
- Metric: "120 m"
- Imperial: "394 ft"

---

## 📈 Calculated Metrics

### **For Cardio:**

```dart
// Average Pace (if not provided)
double? get averagePace {
  if (distance != null && duration != null && distance! > 0) {
    return (duration! / 60) / distance!;  // min/km
  }
  return pace;
}

// Speed
double? get speed {
  if (distance != null && duration != null && duration! > 0) {
    return (distance! / duration!) * 3600;  // km/h
  }
  return null;
}
```

### **For Strength (existing):**

```dart
// Volume
double? get volume => (weight != null && reps != null) 
    ? weight! * reps! 
    : null;

// One-Rep Max (Epley formula)
double? get estimatedOneRepMax {
  if (weight == null || reps == null) return null;
  if (reps == 1) return weight;
  return weight! * (1 + reps! / 30);
}
```

---

## 🔄 Backward Compatibility

✅ **All existing data remains intact!**

- Existing strength exercises: Still work perfectly
- Existing workout sets: `reps` and `weight` preserved
- Migration: Only **adds** new fields, doesn't remove anything

---

## 🧪 Testing Checklist

### After Migration:

- [ ] Run `add_cardio_support.sql` in Supabase
- [ ] Verify 12 cardio exercises added
- [ ] Check `sets` table has new columns
- [ ] Test creating a cardio workout
- [ ] Test creating a strength workout (still works)
- [ ] Verify existing workouts display correctly

### Example Test Queries:

```sql
-- Check cardio exercises
SELECT name, exercise_type 
FROM exercises 
WHERE exercise_type = 'cardio';

-- Check sets table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'sets';

-- Create test cardio set
INSERT INTO sets (
  id, workout_id, exercise_id, exercise_name,
  set_number, distance, duration, heart_rate,
  is_completed, created_at
) VALUES (
  uuid_generate_v4(),
  '<your_workout_id>',
  '<cardio_exercise_id>',
  'Running',
  1,
  5.2,    -- 5.2 km
  1530,   -- 25:30 minutes
  145,    -- 145 BPM
  true,
  NOW()
);
```

---

## 🚀 Next Steps

### 1. **Update UI Screens**
- [ ] Add exercise type selector in create exercise screen
- [ ] Create cardio-specific input form
- [ ] Update workout display to show cardio metrics
- [ ] Add exercise type filter in exercise picker

### 2. **Enhanced Features**
- [ ] GPS route tracking (future)
- [ ] Heart rate zones visualization
- [ ] Pace charts and trends
- [ ] Strava integration (future)
- [ ] Split times for intervals

### 3. **Progress Tracking**
- [ ] Distance over time charts
- [ ] Pace improvements
- [ ] Calories burned tracking
- [ ] Personal records (PRs) for distance/time

---

## 📊 Example Workout Data

### **Cardio Workout:**
```json
{
  "workout": {
    "date": "2026-01-21",
    "routine_name": "Morning Run",
    "duration": 1530
  },
  "sets": [
    {
      "exercise_name": "Running",
      "distance": 5.2,
      "duration": 1530,
      "pace": 4.9,
      "heart_rate": 145,
      "calories": 320,
      "elevation_gain": 45,
      "rpe": 8
    }
  ]
}
```

### **Mixed Workout (Strength + Cardio):**
```json
{
  "workout": {
    "date": "2026-01-21",
    "routine_name": "CrossFit WOD"
  },
  "sets": [
    {
      "exercise_name": "Squats",
      "weight": 100,
      "reps": 10,
      "rpe": 8
    },
    {
      "exercise_name": "Rowing",
      "distance": 0.5,
      "duration": 120,
      "heart_rate": 160,
      "calories": 80
    }
  ]
}
```

---

## 💡 Benefits

### **For Users:**
- ✅ **One App for Everything** - Track both strength and cardio
- ✅ **Strava-like Metrics** - Familiar interface for runners/cyclists
- ✅ **Comprehensive Tracking** - All fitness data in one place
- ✅ **Better Insights** - Understand your complete fitness journey

### **For Developers:**
- ✅ **Flexible Model** - Supports any exercise type
- ✅ **Type-Safe** - Enum-based exercise types
- ✅ **Extensible** - Easy to add more metrics later
- ✅ **Backward Compatible** - Existing data unaffected

---

## 🆘 Support

### Common Questions:

**Q: Can I mix strength and cardio in one workout?**
A: Yes! Add both types of exercises to the same workout.

**Q: What if I don't have all the cardio metrics?**
A: All cardio fields are optional. Just fill in what you have!

**Q: Will my existing workouts still work?**
A: Absolutely! All existing strength workouts are unaffected.

**Q: Can I create custom cardio exercises?**
A: Yes! Just set `exercise_type = cardio` when creating.

---

## ✅ Summary

🎉 **Cross now supports comprehensive cardio tracking!**

- 💪 Strength training: Weight, reps, sets
- 🏃 Cardio activities: Distance, pace, heart rate, elevation
- 📱 Flexible UI: Different inputs for different exercise types
- 📊 Rich metrics: Speed, pace, calories, and more
- 🔄 Fully compatible: Existing data works perfectly

**Next:** Run the migration script and start tracking your cardio! 🚀

