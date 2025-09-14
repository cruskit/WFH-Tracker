import Foundation
import UserNotifications
import OSLog

@MainActor
class SettingsManager: ObservableObject {
    @Published var notificationSettings: NotificationSettings {
        didSet {
            saveSettings()
            scheduleNotificationIfNeeded()
        }
    }

    @Published var lastError: WFHTrackerError?
    @Published var isLoading = false

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
        do {
            if let data = userDefaults.data(forKey: storageKey) {
                let decodedSettings = try JSONDecoder().decode(NotificationSettings.self, from: data)
                notificationSettings = decodedSettings
                Logger.persistence.logInfo("Successfully loaded notification settings", context: "SettingsManager")
            } else {
                notificationSettings = .default
                Logger.persistence.logInfo("No existing settings found, using defaults", context: "SettingsManager")
            }
        } catch {
            let error = WFHTrackerError.persistenceFailure(error.localizedDescription)
            Logger.persistence.logError(error, context: "SettingsManager.loadSettings")
            notificationSettings = .default
            lastError = error
        }
    }

    private func saveSettings() {
        do {
            let encodedData = try JSONEncoder().encode(notificationSettings)
            userDefaults.set(encodedData, forKey: storageKey)
            Logger.persistence.logInfo("Successfully saved notification settings", context: "SettingsManager")
        } catch {
            let error = WFHTrackerError.persistenceFailure(error.localizedDescription)
            Logger.persistence.logError(error, context: "SettingsManager.saveSettings")
            lastError = error
        }
    }

    // MARK: - Notification Management

    nonisolated func requestNotificationPermission() async -> Bool {
        let result = await notificationService.requestPermission()
        await MainActor.run {
            if !result {
                lastError = .notificationPermissionDenied
                Logger.notifications.logWarning("Notification permission denied", context: "SettingsManager")
            } else {
                Logger.notifications.logInfo("Notification permission granted", context: "SettingsManager")
            }
        }
        return result
    }

    nonisolated func checkNotificationPermission() async -> UNAuthorizationStatus {
        return await notificationService.checkPermissionStatus()
    }

    private func scheduleNotificationIfNeeded() {
        Task {
            isLoading = true
            defer {
                Task { @MainActor in
                    isLoading = false
                }
            }

            if notificationSettings.isEnabled {
                await notificationService.scheduleWeeklyReminder(with: notificationSettings)
                Logger.notifications.logInfo("Scheduled weekly reminder", context: "SettingsManager")
            } else {
                await notificationService.cancelAllNotifications()
                Logger.notifications.logInfo("Cancelled all notifications", context: "SettingsManager")
            }
        }
    }

    // MARK: - Settings Updates

    func updateNotificationEnabled(_ enabled: Bool) {
        notificationSettings.isEnabled = enabled
        Logger.stateManagement.logInfo("Notification enabled: \(enabled)", context: "SettingsManager")
    }

    func updateNotificationDay(_ dayOfWeek: Int) {
        notificationSettings.dayOfWeek = dayOfWeek
        Logger.stateManagement.logInfo("Notification day updated to: \(dayOfWeek)", context: "SettingsManager")
    }

    func updateNotificationTime(hour: Int, minute: Int) {
        notificationSettings.hour = hour
        notificationSettings.minute = minute
        Logger.stateManagement.logInfo("Notification time updated to: \(hour):\(minute)", context: "SettingsManager")
    }

    func updateDisplayWeekends(_ displayWeekends: Bool) {
        notificationSettings.displayWeekends = displayWeekends
        Logger.stateManagement.logInfo("Display weekends: \(displayWeekends)", context: "SettingsManager")
    }

    func updateDefaultHours(_ hours: Double) {
        let clampedHours = max(1.0, min(12.0, hours))
        notificationSettings.defaultHoursPerDay = clampedHours
        Logger.stateManagement.logInfo("Default hours updated to: \(clampedHours)", context: "SettingsManager")
    }

    func resetToDefaults() {
        notificationSettings = .default
        Logger.stateManagement.logInfo("Settings reset to defaults", context: "SettingsManager")
    }

    // MARK: - Helper Methods

    nonisolated var isNotificationPermissionGranted: Bool {
        get async {
            let status = await checkNotificationPermission()
            return status == .authorized
        }
    }

    var nextScheduledNotification: Date? {
        notificationSettings.scheduledDate
    }

    func clearError() {
        lastError = nil
    }
}