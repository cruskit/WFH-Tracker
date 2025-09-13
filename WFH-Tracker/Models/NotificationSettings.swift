import Foundation

struct NotificationSettings: Codable, Equatable {
    var isEnabled: Bool
    var dayOfWeek: Int // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
    var hour: Int // 0-23
    var minute: Int // 0-59
    var displayWeekends: Bool // Whether to show weekends in calendar

    init(isEnabled: Bool = false, dayOfWeek: Int = 6, hour: Int = 16, minute: Int = 0, displayWeekends: Bool = false) {
        self.isEnabled = isEnabled
        self.dayOfWeek = max(1, min(7, dayOfWeek)) // Ensure valid day range
        self.hour = max(0, min(23, hour)) // Ensure valid hour range
        self.minute = max(0, min(59, minute)) // Ensure valid minute range
        self.displayWeekends = displayWeekends
    }

    var dayName: String {
        let calendar = Calendar.current
        let weekdays = calendar.weekdaySymbols
        let adjustedIndex = (dayOfWeek - 1) % 7 // Convert to 0-based index
        return weekdays[adjustedIndex]
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        if let date = calendar.date(from: components) {
            return formatter.string(from: date)
        }

        return String(format: "%02d:%02d", hour, minute)
    }

    var scheduledDate: Date? {
        guard isEnabled else { return nil }

        let calendar = Calendar.current
        let now = Date()

        // Get the current week's target day
        var dateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: now)
        let currentWeekday = dateComponents.weekday ?? 1

        // Calculate days to add/subtract to get to target day
        let targetWeekday = dayOfWeek
        var daysToAdd = targetWeekday - currentWeekday

        // If target day has passed this week, schedule for next week
        if daysToAdd < 0 || (daysToAdd == 0 && calendar.component(.hour, from: now) >= hour) {
            daysToAdd += 7
        }

        // Create target date with specified time
        if let targetDate = calendar.date(byAdding: .day, value: daysToAdd, to: now) {
            var targetComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
            targetComponents.hour = hour
            targetComponents.minute = minute
            targetComponents.second = 0

            return calendar.date(from: targetComponents)
        }

        return nil
    }

    static let `default` = NotificationSettings()
}