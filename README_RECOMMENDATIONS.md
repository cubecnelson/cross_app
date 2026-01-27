# 🎯 AI-Powered Workout Recommendations - Quick Start

> **Intelligent workout suggestions based on your training history and sport-specific goals**

## 🚀 What's New

Your app now includes a complete AI recommendation system that:
- 📈 **Detects when to progress** (increase weight/reps)
- 🎯 **Breaks plateaus** with alternative exercises
- ⚽ **Sport-specific conditioning** (basketball, soccer, tennis, etc.)
- 🔄 **Prevents overtraining** with deload suggestions
- 💪 **Adds variety** to your training

## ⚡ Quick Setup (5 Minutes)

### Step 1: Apply Database Changes
```bash
cd supabase
supabase db push

# Or manually:
psql -h your-supabase-url -U postgres -d postgres -f migrations/003_add_recommendation_fields.sql
```

### Step 2: Load Conditioning Exercises
```bash
psql -h your-supabase-url -U postgres -d postgres -f seed/seed_conditioning_exercises.sql
```

### Step 3: Run Your App
```bash
flutter run
```

That's it! Open the app and navigate to **New Workout** to see AI recommendations.

## 📱 Where to Find Recommendations

### Active Workout Screen
When you start a new workout, you'll see:
- **"AI Recommendations"** section with personalized suggestions
- Tap any recommendation to auto-add the exercise with suggested weight/reps
- Dismiss recommendations you don't want

### Workouts List Screen
At the top of your workout history:
- **"Workout Tips"** card with top 3 priority suggestions
- Quick glance at what to focus on next

## 🎨 Example Recommendations

### Progression
```
💪 Increase weight for Bench Press
You've been consistently hitting 12 reps. Try increasing the weight.
→ 52.5kg × 8 reps
Reasoning: Averaging 12.3 reps over last 3 workouts
```

### Plateau Breaking
```
⚠️  Break plateau: Try Dumbbell Bench Press
Your Barbell Bench Press progress has plateaued. Try this alternative.
→ 42.5kg × 10 reps
Reasoning: No weight increase in last 5 workouts
```

### Sport Conditioning (Basketball)
```
🏀 Sport conditioning: Box Jumps
Explosive power for vertical leap. Jump onto a 20-24" box.
→ 3 sets × 8 reps, 120s rest
Reasoning: Recommended for basketball athletes
```

### Deload
```
📉 Deload week: Reduce Squat intensity
You've trained hard recently. Consider reducing weight by 20% to recover.
→ 80kg × 8 reps
Reasoning: 6 workouts in the past week
```

## 🔧 Customization

### Set Your Sport & Goals
To get sport-specific recommendations, update your profile:

```dart
// TODO: Add UI for this in profile settings
UserProfile(
  primaryGoal: 'sports_conditioning',  // or 'hypertrophy', 'strength', 'powerlifting'
  primarySport: 'basketball',          // or 'soccer', 'tennis', 'running', etc.
  experienceLevel: 3,                  // 1-5 scale
)
```

### Adjust Recommendation Thresholds
Edit `lib/services/recommendation_service.dart`:

```dart
// Make progressions more/less aggressive
if (avgRecentReps >= 10) { // Change to 8 or 12
  // Suggest weight increase
}

// Change plateau detection sensitivity
if (recentWeights.length >= 5) { // Change to 3 or 7 workouts
  // Check for plateau
}
```

## 📊 How It Works

### The Recommendation Engine

1. **Analyzes Your History**
   - Last 50 workouts
   - Exercise performance trends
   - Volume, intensity, frequency

2. **Applies Smart Rules**
   - Progression: Reps consistently high → increase weight
   - Plateau: Weight stuck → try alternative exercise
   - Variety: Haven't done exercise in 14+ days
   - Deload: High frequency → reduce intensity
   - Sport: Match sport to conditioning exercises

3. **Prioritizes Suggestions**
   - 🔴 High: Plateaus, deloads (injury prevention)
   - 🟠 Medium: Progressions, sport conditioning
   - ⚪ Low: Variety suggestions

4. **Updates in Real-Time**
   - New workout logged → recommendations refresh
   - Based on your latest performance

## 🎓 Understanding the Types

| Type | Icon | What It Means |
|------|------|---------------|
| **Progression** | 📈 | Time to increase weight or reps |
| **Plateau** | ⚠️ | Progress stalled, try alternatives |
| **Sport Conditioning** | ⚽ | Sport-specific exercises |
| **Variety** | 🔀 | Exercise you haven't done lately |
| **Deload** | 📉 | Reduce intensity to recover |

## 💡 Tips for Best Results

1. **Log Consistently**
   - Need 3+ workouts for recommendations
   - More data = better suggestions

2. **Be Accurate**
   - Enter correct weights and reps
   - Mark sets as completed

3. **Act on Plateaus**
   - Red badges = high priority
   - Don't ignore deload suggestions

4. **Try Sport Conditioning**
   - Adds athleticism to strength training
   - Prevents injuries

5. **Dismiss Wisely**
   - Not interested? Dismiss it
   - Recommendations will adapt

## 🔍 Troubleshooting

### No Recommendations Showing?

**Check:**
1. Do you have 3+ completed workouts?
2. Are workouts logged with weight/reps?
3. Is the app connected to Supabase?

**Debug:**
```dart
// Add to active_workout_screen.dart
final recs = ref.watch(workoutRecommendationsProvider);
recs.when(
  data: (r) => print('${r.length} recommendations'),
  loading: () => print('Loading...'),
  error: (e, _) => print('Error: $e'),
);
```

### Wrong Recommendations?

**Adjust thresholds in `recommendation_service.dart`:**
- Progression trigger: Line 167
- Plateau detection: Line 109
- Deload frequency: Line 346

### Performance Issues?

**Optimize:**
```dart
// Limit history (recommendation_service.dart)
final recentWorkouts = workoutHistory.take(50).toList();
```

## 📈 Future Enhancements

Coming soon:
- 🤖 **Machine Learning**: Personalized progression rates
- 📅 **Periodization**: Auto-plan training cycles
- 📊 **Advanced Analytics**: Volume trends, recovery metrics
- 👥 **Social Recommendations**: What similar users are doing
- 🏆 **Achievement Tracking**: Recommendation acceptance rate

## 📚 Documentation

- **Full System Docs**: `docs/RECOMMENDATIONS_SYSTEM.md`
- **Implementation Guide**: `docs/IMPLEMENTATION_GUIDE.md`
- **Summary**: `docs/IMPLEMENTATION_SUMMARY.md`
- **Seed Data**: `docs/CONDITIONING_EXERCISES_SEED.json`

## 🤝 Contributing

Want to add more sports or customize recommendations?

1. **Add Sport Exercises**: Edit `_getConditioningExercisesForSport()` in `recommendation_service.dart`
2. **New Recommendation Types**: Add to `RecommendationType` enum
3. **Custom Rules**: Add logic to `recommendation_service.dart`
4. **Update UI**: Modify `recommendation_card.dart` for new types

## 📞 Need Help?

1. Check documentation in `docs/` folder
2. Review inline code comments
3. Check Supabase logs for database issues
4. See `IMPLEMENTATION_GUIDE.md` for troubleshooting

## 🎉 Enjoy Your Smarter Workouts!

The recommendation system learns from your training and helps you:
- ✅ Progress faster
- ✅ Avoid injuries
- ✅ Break plateaus
- ✅ Train like an athlete
- ✅ Stay motivated

**Start your next workout and tap on a recommendation to try it out!** 💪
