# Edit Routine Feature - User Flow Documentation

## User Interface Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Routines List Screen                      │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Routine 1                              [3 exercises]│    │
│  │  Description of routine                               │    │
│  │                                [▶] [✏] [🗑]          │    │
│  └────────────────────────────────────────────────────┘    │
│                         ⬇ (User clicks edit button)         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Edit Routine Screen                       │
│                                                              │
│  Routine Name: [____Leg Day____] ← Pre-filled               │
│                                                              │
│  Description:  [Lower body workout] ← Pre-filled            │
│                                                              │
│  Exercises                                    [+ Add]        │
│  ┌────────────────────────────────────────────────────┐    │
│  │ ≡ Squats                            [✏] [🗑]       │    │
│  │   3 sets × 10 reps @ 100kg                         │    │
│  └────────────────────────────────────────────────────┘    │
│  ┌────────────────────────────────────────────────────┐    │
│  │ ≡ Leg Press                         [✏] [🗑]       │    │
│  │   4 sets × 12 reps                                 │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│                    [Update Routine]                          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Interaction Details

### 1. Accessing Edit Screen
**From**: Routines List Screen  
**Action**: Tap edit (pencil) icon on any routine card  
**Result**: Navigate to Edit Routine Screen with pre-populated data

### 2. Editing Routine Name
**Field**: Routine Name (Required)  
**Validation**: 
- Cannot be empty
- Cannot be only whitespace
**Error Message**: "Routine name cannot be empty"

### 3. Editing Description
**Field**: Description (Optional)  
**Validation**: None required  
**Behavior**: Saves as null if empty

### 4. Managing Exercises

#### Adding Exercise
```
Tap [+ Add] → Exercise Picker → Configure Dialog → Exercise Added
```

**Configure Dialog Fields**:
- Sets (Required, positive integer)
- Reps (Required, positive integer)
- Weight (Optional, positive decimal)
- Rest Time (Optional, integer seconds)

#### Editing Exercise
```
Tap [✏] on exercise → Configure Dialog (pre-filled) → Save changes
```

#### Removing Exercise
```
Tap [🗑] on exercise → Exercise removed → Orders updated
```

#### Reordering Exercises
```
Drag ≡ handle → Move to new position → Release → Orders updated
```

### 5. Validation States

#### Valid State
- Name is not empty
- At least one exercise exists
- All exercise fields are valid
- → "Update Routine" button enabled

#### Invalid States

**Empty Name**:
```
⚠️ "Routine name cannot be empty"
```

**No Exercises**:
```
⚠️ "Please add at least one exercise"
```

**Invalid Sets**:
```
⚠️ "Please enter a valid number of sets"
```

**Invalid Reps**:
```
⚠️ "Please enter a valid number of reps"
```

**Invalid Weight**:
```
⚠️ "Weight must be a positive number"
```

### 6. Saving Changes

#### Success Flow
```
Tap [Update Routine] → Loading state → Database update → 
Success message → Navigate back to list
```

**Success Message**:
```
✅ "Routine updated successfully!"
```

#### Error Flow
```
Tap [Update Routine] → Loading state → Database error → 
Error message → Stay on edit screen
```

**Error Message**:
```
❌ "Failed to update routine: [error details]"
```

### 7. Loading States

During save operation:
- "Update Routine" button shows loading indicator
- Button is disabled
- Form inputs remain enabled (can cancel)

## Visual States

### Before Edit
```
┌────────────────────────────────┐
│ Morning Workout    [5 exercises]│
│ Quick morning routine           │
│                  [▶] [✏] [🗑]  │
└────────────────────────────────┘
```

### During Edit
```
┌──────────────────────────────────────────┐
│ Edit Routine                              │
├──────────────────────────────────────────┤
│ Routine Name: [Morning Workout]          │
│ Description:  [Quick morning routine]    │
│                                           │
│ Exercises:                    [+ Add]     │
│ ≡ Push-ups      3×15         [✏] [🗑]   │
│ ≡ Pull-ups      3×10         [✏] [🗑]   │
│ ...                                       │
│                                           │
│          [Update Routine]                 │
└──────────────────────────────────────────┘
```

### After Edit Success
```
┌────────────────────────────────┐
│ Morning Workout    [6 exercises]│  ← Updated count
│ Enhanced morning routine        │  ← Updated description
│                  [▶] [✏] [🗑]  │
└────────────────────────────────┘

✅ Routine updated successfully!
```

## Keyboard Navigation

1. **Tab Order**:
   - Routine Name → Description → Add Exercise → Exercise 1 Edit → Exercise 1 Delete → ...

2. **Enter Key**:
   - In text fields: Move to next field
   - On "Update Routine": Submit form

3. **Escape Key**:
   - Close dialogs
   - Return to previous screen (with confirmation if changes made)

## Accessibility Features

- **Screen Reader Support**: All buttons and fields have semantic labels
- **Color Indicators**: 
  - Green for success (✅)
  - Red for errors (❌)
  - Blue for actions (✏, +)
- **Icon + Text**: Icons paired with text for clarity
- **Touch Targets**: Minimum 48x48 dp for all interactive elements

## Error Prevention

1. **Validation on Input**: Real-time feedback as user types
2. **Clear Requirements**: Labels indicate required fields
3. **Confirmation Dialogs**: For destructive actions (removing exercises)
4. **Undo Support**: Can navigate back without saving
5. **Auto-save Draft**: (Future enhancement)

## Performance Considerations

1. **Lazy Loading**: Only load exercise picker when needed
2. **Debounced Validation**: Validate after user stops typing
3. **Optimistic Updates**: UI updates before database confirmation
4. **Caching**: Exercise data cached for picker
5. **Minimal Rebuilds**: Only affected widgets rebuild

## Mobile-Specific Behaviors

### iOS
- Pull-to-refresh on lists
- Swipe-back gesture
- Native keyboard handling
- Haptic feedback on actions

### Android
- Material Design ripple effects
- Back button handling
- Floating action button styling
- Snackbar notifications

## Edge Cases Handled

1. **Empty Exercises List**: Show placeholder with "Add Exercise" prompt
2. **Long Names**: Ellipsis truncation with full text on tap
3. **Many Exercises**: Scrollable list with proper keyboard handling
4. **Offline Mode**: Queue updates for when online
5. **Concurrent Edits**: Last-write-wins with timestamp check
6. **Network Errors**: Retry option with clear messaging

## Future Enhancements

These are NOT implemented but documented for future reference:

1. **Undo/Redo**: History stack for changes
2. **Auto-save**: Periodic saves as user types
3. **Change Tracking**: Visual indicators for modified fields
4. **Duplicate Routine**: Quick copy with edit
5. **Templates**: Save as template for reuse
6. **Sharing**: Share routine with other users
7. **Import/Export**: Backup and restore routines
8. **Voice Input**: Dictation for descriptions
9. **Rich Text**: Formatting in descriptions
10. **Exercise Notes**: Per-exercise instructions
