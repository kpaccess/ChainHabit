# Habit Tracker App

A modern SwiftUI habit tracking application using SwiftData for persistence.

## Features

### Core Functionality
- ✅ Create and manage daily/weekly habits
- ✅ Mark habits as complete/incomplete for today
- ✅ Track completion streaks
- ✅ Color-coded habits with 10 preset colors
- ✅ Calendar-style completion history (last 14 days)
- ✅ Total completion statistics
- ✅ Edit and delete habits

### Architecture

#### Models (`Models/`)
- **Habit.swift**: Main habit model with:
  - Properties: name, color, creation date, frequency
  - Relationship to HabitLog (cascade delete)
  - Computed properties for streaks and completion status
  - Sample data for testing
  
- **HabitLog.swift**: Tracks individual completions
  - Records completion date
  - Links back to parent Habit

#### Views (`Views/`)
- **HabitListView.swift**: Main screen showing all habits
  - List of habits with completion status
  - Empty state view
  - Add new habit button
  
- **HabitRowView.swift**: Individual habit row
  - Checkable completion button
  - Shows current streak
  - Frequency indicator
  - Tap to see details
  
- **AddEditHabitView.swift**: Form for creating/editing habits
  - Text field for habit name
  - Segmented picker for frequency (daily/weekly)
  - Color picker grid with 10 colors
  - Handles both new habits and editing
  
- **HabitDetailView.swift**: Detailed habit information
  - Header with habit color and completion status
  - Statistics cards (streak, total completions)
  - 14-day calendar grid showing completion pattern
  - Edit and delete options

#### Utilities (`Utilities/`)
- **Color+Extensions.swift**: 
  - Hex color conversion
  - 10 predefined habit colors
  
- **Date+Extensions.swift**:
  - Date formatting helpers
  - Day calculations

#### App Configuration
- **HabitTrackerApp.swift**: 
  - SwiftData ModelContainer setup
  - Schema definition
  - Sample data insertion in DEBUG mode

## SwiftData Best Practices Used

1. **Proper Relationships**: One-to-many relationship between Habit and HabitLog with cascade delete
2. **@Query Attribute**: Used for automatic data fetching and updates
3. **@Environment(\.modelContext)**: Injected for data operations
4. **Type-safe Schema**: Explicit schema definition in ModelContainer
5. **In-Memory Testing**: Preview helpers use in-memory containers
6. **Separation of Concerns**: Models separate from views

## Key Implementation Details

### Streak Calculation
The streak algorithm:
1. Sorts logs by date (most recent first)
2. Checks if most recent is today or yesterday (otherwise streak is 0)
3. Counts consecutive days backwards from today
4. Breaks on any gap in dates

### Completion Toggle
When toggling completion:
1. Checks if a log exists for today
2. If yes: deletes the log (mark incomplete)
3. If no: creates new log (mark complete)
4. Uses calendar to ensure date accuracy

### Sample Data
In DEBUG mode, the app:
- Checks if habits already exist
- If empty, adds 5 sample habits
- Creates 3-7 random completion logs for each habit
- Helps with testing and screenshots

## Usage

### Running the App
1. Build and run in Xcode
2. Sample data loads automatically in DEBUG mode
3. Tap (+) to add new habits
4. Tap the circle to toggle completion
5. Tap the row to see details

### Data Persistence
- Data is stored persistently using SwiftData
- Survives app restarts
- Stored in app's documents directory

## Customization Ideas

### Easy Additions:
- Add habit icons/emojis
- Custom date range for history
- Weekly goal tracking
- Notifications/reminders
- Export data to CSV
- Charts showing progress over time
- Best streak vs current streak
- Habit categories/tags

### Advanced Features:
- iCloud sync between devices
- Widgets for home screen
- Apple Watch companion app
- Siri shortcuts integration
- Habit templates
- Social sharing of achievements

## Testing

Each view includes a `#Preview` with sample data:
- Uses in-memory ModelContainer
- Creates realistic test data
- Enables live preview in Xcode Canvas

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- SwiftUI and SwiftData

## File Structure

```
HabitTracker/
├── HabitTrackerApp.swift          # App entry point & SwiftData setup
├── ContentView.swift               # Root view
├── Models/
│   ├── Habit.swift                # Main habit model
│   └── HabitLog.swift             # Completion log model
├── Views/
│   ├── HabitListView.swift        # Main list screen
│   ├── HabitRowView.swift         # Individual habit row
│   ├── AddEditHabitView.swift     # Add/edit form
│   └── HabitDetailView.swift      # Detail & history screen
└── Utilities/
    ├── Color+Extensions.swift      # Color helpers
    └── Date+Extensions.swift       # Date helpers
```

## License

Free to use and modify for personal and commercial projects.
