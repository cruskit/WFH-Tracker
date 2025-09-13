# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WFH-Tracker is a SwiftUI-based iOS application for tracking work-from-home and office hours with a calendar interface and comprehensive reporting. The app follows MVVM architecture with SwiftUI and uses UserDefaults for local data persistence.

## Development Commands

### Building and Running
```bash
# Open project in Xcode
open WFH-Tracker.xcodeproj

# Build and run the project
# Use Xcode's build (⌘+B) and run (⌘+R) commands
# Or Product > Build / Product > Run from Xcode menu
```

### Testing
```bash
# Run tests in Xcode
# Use Product > Test (⌘+U) or Test Navigator
# Test targets: WFH-TrackerTests (unit tests), WFH-TrackerUITests (UI tests)
```

## Architecture

### Core State Management
- **CalendarStateManager**: Central state manager handling calendar navigation, data persistence via UserDefaults, and totals calculations. Uses @MainActor for thread safety and @Published properties for reactive UI updates.
- **Data Flow**: UserDefaults → CalendarStateManager → SwiftUI Views with automatic updates via @ObservableObject/@StateObject pattern.

### Key Models
- **WorkDay**: Core data structure for daily work hours (date, homeHours, officeHours, computed totalHours)
- **WorkTotals**: Aggregated statistics for reporting periods
- **CalendarMonth**: Month representation and navigation
- **FinancialYear**: Australian financial year calculation (July-June cycle)

### View Architecture
- **ContentView**: Main TabView container with LogView and ExportView tabs
- **LogView**: Main calendar interface combining MultiMonthCalendarView, WorkHoursEntryView, and TotalsCard
- **MultiMonthCalendarView**: Three-month scrollable calendar display
- **WorkHoursEntryView**: Modal data entry for individual days or entire weeks
- **ExportView**: CSV export functionality for financial year data

### Data Persistence
- Uses UserDefaults for local storage (key: "workDays")
- JSON encoding/decoding via Codable protocol
- Automatic save on data modification
- No external dependencies or cloud storage

### Financial Year Logic
Australian financial year conventions:
- July-December: FY = current year + 1
- January-June: FY = current year
- Example: July 2024 = FY2025, January 2025 = FY2025

## Key Design Patterns
- **MVVM**: Clear separation with ObservableObject state management
- **@MainActor**: UI operations on main thread
- **Reactive UI**: @Published properties drive automatic view updates
- **Codable**: JSON serialization for data persistence
- **TabView**: Main navigation structure

## Testing Structure
- **WFH-TrackerTests/**: Unit tests for models and business logic
- **WFH-TrackerUITests/**: UI automation tests
- Test key components: WorkDay, CalendarStateManager, ContentView, etc.

## Development Notes
- Minimum deployment: iOS 17.0+
- Built with Xcode 15.0+
- Pure SwiftUI implementation (no UIKit dependencies)
- No external package dependencies
- Uses native iOS frameworks only