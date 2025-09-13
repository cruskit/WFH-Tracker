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
- **CalendarStateManager**: Central state manager handling calendar navigation, data persistence via UserDefaults, and totals calculations. Uses @MainActor for thread safety and @Published properties for reactive UI updates. Includes week hours checking for notification logic.
- **SettingsManager**: Manages notification settings with UserDefaults persistence and notification scheduling coordination
- **AppState**: Global app state for handling notification-triggered navigation
- **Data Flow**: UserDefaults → CalendarStateManager/SettingsManager → SwiftUI Views with automatic updates via @ObservableObject/@StateObject pattern

### Key Models
- **WorkDay**: Core data structure for daily work hours (date, homeHours, officeHours, computed totalHours)
- **WorkTotals**: Aggregated statistics for reporting periods
- **CalendarMonth**: Month representation and navigation
- **FinancialYear**: Australian financial year calculation (July-June cycle)
- **NotificationSettings**: Configurable notification preferences (enabled, day, time) with Codable persistence

### View Architecture
- **ContentView**: Main TabView container with LogView, ExportView, and SettingsView tabs
- **LogView**: Main calendar interface combining MultiMonthCalendarView, WorkHoursEntryView, and TotalsCard. Handles notification-triggered entry display
- **MultiMonthCalendarView**: Three-month scrollable calendar display
- **WorkHoursEntryView**: Modal data entry for individual days or entire weeks
- **ExportView**: CSV export functionality for financial year data
- **SettingsView**: Apple HIG-compliant settings interface for notification configuration with Form, Section, Toggle, Picker, and DatePicker controls

### Notification System
- **NotificationService**: Handles permission requests, weekly reminder scheduling, and notification content generation
- **NotificationServiceProtocol**: Protocol for testability and dependency injection
- **Weekly Reminders**: Configurable day/time notifications that check if current week has logged hours
- **Deep Linking**: Notification taps open WorkHoursEntryView for current week
- **Permission Handling**: Proper iOS notification permission flow with fallback to Settings app

### Data Persistence
- Uses UserDefaults for local storage (keys: "workDays", "notificationSettings")
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
  - **CalendarStateManagerTests**: Calendar navigation, data persistence, week checking
  - **NotificationSettingsTests**: Settings model validation, Codable conformance, scheduled date calculation
  - **SettingsManagerTests**: Settings persistence, notification service integration with mock
  - **NotificationServiceTests**: Permission handling, notification scheduling logic
  - **SettingsViewTests**: UI logic validation and data flow testing
- **WFH-TrackerUITests/**: UI automation tests
- **Mock Services**: MockNotificationService for isolated testing with dependency injection

## Development Notes
- Minimum deployment: iOS 17.0+
- Built with Xcode 15.0+
- Pure SwiftUI implementation (no UIKit dependencies)
- Uses UserNotifications framework for local notifications
- No external package dependencies
- Uses native iOS frameworks only (UserNotifications, Foundation, SwiftUI)
- Apple HIG-compliant UI design patterns throughout