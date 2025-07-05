# WFH-Tracker

A SwiftUI-based iOS application for tracking work-from-home and office hours with a beautiful calendar interface and comprehensive reporting.

## Overview

WFH-Tracker helps you monitor your work hours split between home and office locations. The app provides an intuitive calendar interface where you can log your daily work hours and view monthly and financial year totals at a glance.

## Features

### 📅 Calendar Interface
- **Multi-month calendar view** with smooth navigation
- **Interactive day cells** that show work status at a glance
- **Week-based data entry** for efficient bulk updates
- **Visual indicators** for days with logged hours

### ⏰ Work Hours Tracking
- **Dual location tracking**: Separate fields for home and office hours
- **Flexible data entry**: Log hours for individual days or entire weeks
- **Real-time calculations**: Automatic total hours computation
- **Data persistence**: All data saved locally using UserDefaults

### 📊 Reporting & Analytics
- **Monthly totals**: Current month work hours summary
- **Financial year tracking**: Australian financial year (July-June) totals
- **Breakdown by location**: Separate home and office hour totals
- **Visual cards**: Clean, modern display of statistics

### 🎨 User Experience
- **Native iOS design**: Built with SwiftUI for seamless integration
- **Responsive layout**: Optimized for different screen sizes
- **Intuitive navigation**: Easy month-to-month browsing
- **Clean interface**: Minimalist design focused on functionality

## Architecture

### Models
- **`WorkDay`**: Core data structure for daily work hours
- **`WorkTotals`**: Aggregated statistics for reporting
- **`CalendarMonth`**: Month representation and navigation
- **`CalendarStateManager`**: Main state management and data persistence

### Views
- **`ContentView`**: Main app container and navigation
- **`MultiMonthCalendarView`**: Calendar display component
- **`WorkHoursEntryView`**: Data entry interface
- **`TotalsCard`**: Statistics display component
- **`CalendarNavigationView`**: Month navigation controls

### Key Components

#### CalendarStateManager
The central state manager that handles:
- Calendar navigation and month management
- Work day data persistence (UserDefaults)
- Data loading and saving operations
- Totals calculations for different time periods

#### WorkHoursEntryView
A comprehensive data entry interface that allows:
- Individual day hour entry
- Week-based bulk updates
- Validation and error handling
- Preview of existing data

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- macOS 14.0 or later (for development)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/WFH-Tracker.git
   cd WFH-Tracker
   ```

2. Open the project in Xcode:
   ```bash
   open WFH-Tracker.xcodeproj
   ```

3. Build and run the project on your iOS device or simulator

### Usage

#### Adding Work Hours
1. Tap on any day in the calendar
2. Enter your home and/or office hours for that day
3. Optionally add hours for the entire week
4. Tap "Save" to persist your data

#### Navigating the Calendar
- Use the arrow buttons to navigate between months
- The current month is highlighted in the navigation
- Previous and next months are visible for context

#### Viewing Totals
- Monthly totals are displayed at the bottom of the screen
- Financial year totals are calculated based on Australian financial year (July-June)
- Totals are automatically updated as you add or modify data

## Data Structure

### WorkDay Model
```swift
struct WorkDay {
    let date: Date
    var homeHours: Double?
    var officeHours: Double?
    var totalHours: Double // Computed property
}
```

### WorkTotals Model
```swift
struct WorkTotals {
    let homeHours: Double
    let officeHours: Double
    var totalHours: Double // Computed property
}
```

## Data Persistence

The app uses `UserDefaults` for data persistence:
- Work day data is automatically saved when modified
- Data is loaded on app launch
- No external dependencies or cloud storage required

## Financial Year Calculation

The app uses Australian financial year conventions:
- Financial year runs from July 1 to June 30
- For months July-December: Financial year = Current year + 1
- For months January-June: Financial year = Current year

## Development

### Project Structure
```
WFH-Tracker/
├── Models/
│   ├── CalendarStateManager.swift
│   ├── CalendarMonth.swift
│   ├── WorkDay.swift
│   └── WorkTotals.swift
├── Views/
│   ├── CalendarView.swift
│   ├── CalendarNavigationView.swift
│   ├── DayCell.swift
│   ├── HeaderView.swift
│   ├── MultiMonthCalendarView.swift
│   ├── TotalsCard.swift
│   └── WorkHoursEntryView.swift
├── ContentView.swift
├── WFH_TrackerApp.swift
└── Assets.xcassets/
```

### Key Design Patterns
- **MVVM Architecture**: Clear separation of data and presentation
- **ObservableObject**: Reactive UI updates using @Published properties
- **@MainActor**: UI updates on main thread
- **Codable**: JSON serialization for data persistence

## Testing

The project includes unit tests and UI tests:
- `WFH-TrackerTests/`: Unit tests for models and business logic
- `WFH-TrackerUITests/`: UI automation tests

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Paul Ruskin** - [GitHub Profile](https://github.com/yourusername)

Created on June 29, 2025

## Acknowledgments

- Built with SwiftUI and iOS native frameworks
- Designed for simplicity and ease of use
- Inspired by the need for better work hour tracking in hybrid work environments 