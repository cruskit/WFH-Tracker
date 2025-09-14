import Foundation

// MARK: - Error Types

enum WFHTrackerError: LocalizedError, Equatable {
    case persistenceFailure(String)
    case notificationPermissionDenied
    case invalidDateRange
    case exportFailure(String)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .persistenceFailure(let message):
            return "Failed to save data: \(message)"
        case .notificationPermissionDenied:
            return "Notification permission is required to receive work hour reminders"
        case .invalidDateRange:
            return "Invalid date range selected"
        case .exportFailure(let message):
            return "Failed to export data: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }

    var failureReason: String? {
        switch self {
        case .persistenceFailure:
            return "The app was unable to save your work data to the device"
        case .notificationPermissionDenied:
            return "Notifications are disabled for this app"
        case .invalidDateRange:
            return "The selected date range is invalid"
        case .exportFailure:
            return "The export operation could not be completed"
        case .networkError:
            return "A network connection is required for this operation"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .persistenceFailure:
            return "Try restarting the app or check available storage space"
        case .notificationPermissionDenied:
            return "Enable notifications in Settings to receive reminders"
        case .invalidDateRange:
            return "Please select a valid date range"
        case .exportFailure:
            return "Ensure you have enough storage space and try again"
        case .networkError:
            return "Check your internet connection and try again"
        }
    }
}