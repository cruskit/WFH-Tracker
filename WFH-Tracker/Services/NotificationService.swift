import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestPermission() async -> Bool
    func checkPermissionStatus() async -> UNAuthorizationStatus
    func scheduleWeeklyReminder(with settings: NotificationSettings) async
    func cancelAllNotifications() async
}

class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let notificationIdentifier = "weekly-hours-reminder"

    private init() {}

    // MARK: - Permission Management

    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Notification Scheduling

    func scheduleWeeklyReminder(with settings: NotificationSettings) async {
        guard settings.isEnabled,
              let scheduledDate = settings.scheduledDate else {
            await cancelAllNotifications()
            return
        }

        // Cancel existing notifications
        await cancelAllNotifications()

        // Check permission before scheduling
        let status = await checkPermissionStatus()
        guard status == .authorized else {
            print("Notification permission not granted")
            return
        }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Log Your Work Hours"
        content.body = "Don't forget to record where you worked this week!"
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_REMINDER"

        // Add custom data for deep linking
        content.userInfo = [
            "action": "open_current_week_entry",
            "timestamp": Date().timeIntervalSince1970
        ]

        // Create date components for weekly recurring notification
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.weekday, .hour, .minute], from: scheduledDate)
        dateComponents.weekday = settings.dayOfWeek

        // Create trigger for weekly recurrence
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        // Create request
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
            print("Weekly reminder scheduled for \(settings.dayName) at \(settings.timeString)")
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }

    func cancelAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        print("All notifications cancelled")
    }

    // MARK: - Notification Content Logic

    func shouldSendNotification(calendarManager: CalendarStateManager) async -> Bool {
        let calendar = Calendar.current
        let now = Date()

        // Get the current week's date range
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return false
        }

        // Check if any work days exist for the current week
        let weekDays = await calendarManager.workDays.filter { workDay in
            weekInterval.contains(workDay.date)
        }

        // Only send notification if no hours have been logged for the current week
        return weekDays.isEmpty || weekDays.allSatisfy { workDay in
            (workDay.homeHours ?? 0) == 0 && (workDay.officeHours ?? 0) == 0
        }
    }

    // MARK: - Notification Actions

    func setupNotificationCategories() {
        let openAction = UNNotificationAction(
            identifier: "OPEN_APP",
            title: "Log Hours",
            options: [.foreground]
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Remind Later",
            options: []
        )

        let category = UNNotificationCategory(
            identifier: "WEEKLY_REMINDER",
            actions: [openAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        notificationCenter.setNotificationCategories([category])
    }

    // MARK: - Debug Helpers

    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }

    func scheduleTestNotification(in seconds: TimeInterval = 5) async {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification for WFH Tracker"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
            print("Test notification scheduled for \(seconds) seconds")
        } catch {
            print("Failed to schedule test notification: \(error)")
        }
    }
}