import Foundation
import UserNotifications

@MainActor
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var notificationSettings: NotificationSettings {
        didSet {
            saveSettings()
            scheduleNotificationIfNeeded()
        }
    }

    private let userDefaults: UserDefaults
    private let storageKey: String
    private let notificationService: NotificationServiceProtocol

    init(userDefaults: UserDefaults = UserDefaults.standard,
         storageKey: String = "notificationSettings",
         notificationService: NotificationServiceProtocol = NotificationService.shared) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        self.notificationService = notificationService
        self.notificationSettings = .default
        loadSettings()
    }

    // MARK: - Settings Persistence

    private func loadSettings() {
        if let data = userDefaults.data(forKey: storageKey),
           let decodedSettings = try? JSONDecoder().decode(NotificationSettings.self, from: data) {
            notificationSettings = decodedSettings
        } else {
            notificationSettings = .default
        }
    }

    private func saveSettings() {
        do {
            let encodedData = try JSONEncoder().encode(notificationSettings)
            userDefaults.set(encodedData, forKey: storageKey)
        } catch {
            print("Failed to save notification settings: \(error)")
        }
    }

    // MARK: - Notification Management

    func requestNotificationPermission() async -> Bool {
        return await notificationService.requestPermission()
    }

    func checkNotificationPermission() async -> UNAuthorizationStatus {
        return await notificationService.checkPermissionStatus()
    }

    private func scheduleNotificationIfNeeded() {
        Task {
            if notificationSettings.isEnabled {
                await notificationService.scheduleWeeklyReminder(with: notificationSettings)
            } else {
                await notificationService.cancelAllNotifications()
            }
        }
    }

    // MARK: - Settings Updates

    func updateNotificationEnabled(_ enabled: Bool) {
        notificationSettings.isEnabled = enabled
    }

    func updateNotificationDay(_ dayOfWeek: Int) {
        notificationSettings.dayOfWeek = dayOfWeek
    }

    func updateNotificationTime(hour: Int, minute: Int) {
        notificationSettings.hour = hour
        notificationSettings.minute = minute
    }

    func updateDisplayWeekends(_ displayWeekends: Bool) {
        notificationSettings.displayWeekends = displayWeekends
    }

    func resetToDefaults() {
        notificationSettings = .default
    }

    // MARK: - Helper Methods

    var isNotificationPermissionGranted: Bool {
        get async {
            let status = await checkNotificationPermission()
            return status == .authorized
        }
    }

    var nextScheduledNotification: Date? {
        notificationSettings.scheduledDate
    }
}