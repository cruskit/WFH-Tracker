import Testing
import Foundation
import UserNotifications
@testable import WFH_Tracker

// Mock NotificationService for testing
class MockNotificationService: NotificationServiceProtocol {
    var permissionRequested = false
    var permissionGranted = false
    var notificationsScheduled = false
    var notificationsCancelled = false
    var scheduledSettings: NotificationSettings?

    func requestPermission() async -> Bool {
        permissionRequested = true
        return permissionGranted
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        return permissionGranted ? .authorized : .denied
    }

    func scheduleWeeklyReminder(with settings: NotificationSettings) async {
        notificationsScheduled = true
        scheduledSettings = settings
    }

    func cancelAllNotifications() async {
        notificationsCancelled = true
    }

    func reset() {
        permissionRequested = false
        permissionGranted = false
        notificationsScheduled = false
        notificationsCancelled = false
        scheduledSettings = nil
    }
}

@MainActor
struct SettingsManagerTests {

    @Test func testSettingsManagerInitialization() async throws {
        let testStorageKey = "testSettingsManager_\(UUID().uuidString)"
        let mockService = MockNotificationService()
        let manager = SettingsManager(
            userDefaults: UserDefaults.standard,
            storageKey: testStorageKey,
            notificationService: mockService
        )

        #expect(manager.notificationSettings.isEnabled == false)
        #expect(manager.notificationSettings.dayOfWeek == 6)
        #expect(manager.notificationSettings.hour == 16)
        #expect(manager.notificationSettings.minute == 0)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }

    @Test func testSettingsPersistence() async throws {
        let testStorageKey = "testPersistence_\(UUID().uuidString)"
        let mockService = MockNotificationService()

        // Create first manager and save settings
        let manager1 = SettingsManager(
            userDefaults: UserDefaults.standard,
            storageKey: testStorageKey,
            notificationService: mockService
        )

        manager1.updateNotificationEnabled(true)
        manager1.updateNotificationDay(3)
        manager1.updateNotificationTime(hour: 10, minute: 30)

        // Wait for persistence
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Create second manager and verify data loaded
        let manager2 = SettingsManager(
            userDefaults: UserDefaults.standard,
            storageKey: testStorageKey,
            notificationService: mockService
        )

        #expect(manager2.notificationSettings.isEnabled == true)
        #expect(manager2.notificationSettings.dayOfWeek == 3)
        #expect(manager2.notificationSettings.hour == 10)
        #expect(manager2.notificationSettings.minute == 30)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }

    @Test func testUpdateNotificationEnabled() async throws {
        let testStorageKey = "testEnabled_\(UUID().uuidString)"
        let mockService = MockNotificationService()
        let manager = SettingsManager(
            userDefaults: UserDefaults.standard,
            storageKey: testStorageKey,
            notificationService: mockService
        )

        // Test enabling notifications
        mockService.reset()
        manager.updateNotificationEnabled(true)

        #expect(manager.notificationSettings.isEnabled == true)
        // Note: In a real app test, we'd check if notification was scheduled
        // but our mock doesn't automatically trigger scheduling

        // Test disabling notifications
        mockService.reset()
        manager.updateNotificationEnabled(false)

        #expect(manager.notificationSettings.isEnabled == false)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }

    @Test func testUpdateNotificationDay() async throws {
        let testStorageKey = "testDay_\(UUID().uuidString)"
        let mockService = MockNotificationService()
        let manager = SettingsManager(
            userDefaults: UserDefaults.standard,
            storageKey: testStorageKey,
            notificationService: mockService
        )

        manager.updateNotificationDay(2) // Monday

        #expect(manager.notificationSettings.dayOfWeek == 2)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }

    @Test func testUpdateNotificationTime() async throws {
        let testStorageKey = "testTime_\(UUID().uuidString)"
        let mockService = MockNotificationService()
        let manager = SettingsManager(
            userDefaults: UserDefaults.standard,
            storageKey: testStorageKey,
            notificationService: mockService
        )

        manager.updateNotificationTime(hour: 14, minute: 45)

        #expect(manager.notificationSettings.hour == 14)
        #expect(manager.notificationSettings.minute == 45)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }

    @Test func testResetToDefaults() async throws {
        let testStorageKey = "testReset_\(UUID().uuidString)"
        let mockService = MockNotificationService()
        let manager = SettingsManager(
            userDefaults: UserDefaults.standard,
            storageKey: testStorageKey,
            notificationService: mockService
        )

        // Modify settings
        manager.updateNotificationEnabled(true)
        manager.updateNotificationDay(2)
        manager.updateNotificationTime(hour: 10, minute: 30)

        // Reset to defaults
        manager.resetToDefaults()

        #expect(manager.notificationSettings.isEnabled == false)
        #expect(manager.notificationSettings.dayOfWeek == 6)
        #expect(manager.notificationSettings.hour == 16)
        #expect(manager.notificationSettings.minute == 0)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }

    @Test func testRequestNotificationPermission() async throws {
        let testStorageKey = "testPermission_\(UUID().uuidString)"
        let mockService = MockNotificationService()
        let manager = SettingsManager(
            userDefaults: UserDefaults.standard,
            storageKey: testStorageKey,
            notificationService: mockService
        )

        // Test granted permission
        mockService.permissionGranted = true
        let granted = await manager.requestNotificationPermission()

        #expect(granted == true)
        #expect(mockService.permissionRequested == true)

        // Test denied permission
        mockService.reset()
        mockService.permissionGranted = false
        let denied = await manager.requestNotificationPermission()

        #expect(denied == false)
        #expect(mockService.permissionRequested == true)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }

    @Test func testCheckNotificationPermission() async throws {
        let testStorageKey = "testCheckPermission_\(UUID().uuidString)"
        let mockService = MockNotificationService()
        let manager = SettingsManager(
            userDefaults: UserDefaults.standard,
            storageKey: testStorageKey,
            notificationService: mockService
        )

        // Test authorized status
        mockService.permissionGranted = true
        let authorizedStatus = await manager.checkNotificationPermission()
        #expect(authorizedStatus == .authorized)

        // Test denied status
        mockService.permissionGranted = false
        let deniedStatus = await manager.checkNotificationPermission()
        #expect(deniedStatus == .denied)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }

    @Test func testNextScheduledNotification() async throws {
        let testStorageKey = "testScheduled_\(UUID().uuidString)"
        let mockService = MockNotificationService()
        let manager = SettingsManager(
            userDefaults: UserDefaults.standard,
            storageKey: testStorageKey,
            notificationService: mockService
        )

        // When disabled, should return nil
        #expect(manager.nextScheduledNotification == nil)

        // When enabled, should return a date
        manager.updateNotificationEnabled(true)
        let scheduledDate = manager.nextScheduledNotification
        #expect(scheduledDate != nil)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }

    @Test func testInvalidSettingsLoad() async throws {
        let testStorageKey = "testInvalidLoad_\(UUID().uuidString)"
        let mockService = MockNotificationService()

        // Store invalid JSON data
        let invalidData = "invalid json".data(using: .utf8)!
        UserDefaults.standard.set(invalidData, forKey: testStorageKey)

        // Manager should handle invalid data gracefully
        let manager = SettingsManager(
            userDefaults: UserDefaults.standard,
            storageKey: testStorageKey,
            notificationService: mockService
        )

        // Should fall back to defaults
        #expect(manager.notificationSettings.isEnabled == false)
        #expect(manager.notificationSettings.dayOfWeek == 6)
        #expect(manager.notificationSettings.hour == 16)
        #expect(manager.notificationSettings.minute == 0)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }
}