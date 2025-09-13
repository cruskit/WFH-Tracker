import Testing
import Foundation
@testable import WFH_Tracker

struct NotificationSettingsTests {

    @Test func testNotificationSettingsInitialization() async throws {
        let settings = NotificationSettings()

        #expect(settings.isEnabled == false)
        #expect(settings.dayOfWeek == 6) // Friday
        #expect(settings.hour == 16) // 4 PM
        #expect(settings.minute == 0)
        #expect(settings.displayWeekends == false) // Weekends disabled by default
    }

    @Test func testNotificationSettingsCustomInitialization() async throws {
        let settings = NotificationSettings(
            isEnabled: true,
            dayOfWeek: 2, // Monday
            hour: 9,
            minute: 30,
            displayWeekends: true
        )

        #expect(settings.isEnabled == true)
        #expect(settings.dayOfWeek == 2)
        #expect(settings.hour == 9)
        #expect(settings.minute == 30)
        #expect(settings.displayWeekends == true)
    }

    @Test func testNotificationSettingsValidation() async throws {
        // Test day validation
        let invalidDay = NotificationSettings(dayOfWeek: 8) // Invalid
        #expect(invalidDay.dayOfWeek == 7) // Should be clamped to valid range

        let negativeDay = NotificationSettings(dayOfWeek: 0) // Invalid
        #expect(negativeDay.dayOfWeek == 1) // Should be clamped to valid range

        // Test hour validation
        let invalidHour = NotificationSettings(hour: 25) // Invalid
        #expect(invalidHour.hour == 23) // Should be clamped to valid range

        let negativeHour = NotificationSettings(hour: -1) // Invalid
        #expect(negativeHour.hour == 0) // Should be clamped to valid range

        // Test minute validation
        let invalidMinute = NotificationSettings(minute: 60) // Invalid
        #expect(invalidMinute.minute == 59) // Should be clamped to valid range

        let negativeMinute = NotificationSettings(minute: -1) // Invalid
        #expect(negativeMinute.minute == 0) // Should be clamped to valid range
    }

    @Test func testDayNameProperty() async throws {
        let sundaySettings = NotificationSettings(dayOfWeek: 1)
        #expect(sundaySettings.dayName == "Sunday")

        let mondaySettings = NotificationSettings(dayOfWeek: 2)
        #expect(mondaySettings.dayName == "Monday")

        let fridaySettings = NotificationSettings(dayOfWeek: 6)
        #expect(fridaySettings.dayName == "Friday")

        let saturdaySettings = NotificationSettings(dayOfWeek: 7)
        #expect(sundaySettings.dayName == "Sunday")
    }

    @Test func testTimeStringProperty() async throws {
        let morningSettings = NotificationSettings(hour: 9, minute: 30)
        let timeString = morningSettings.timeString
        #expect(timeString.contains("9") || timeString.contains("09"))
        #expect(timeString.contains("30"))

        let afternoonSettings = NotificationSettings(hour: 16, minute: 0)
        let afternoonTimeString = afternoonSettings.timeString
        #expect(afternoonTimeString.contains("4") || afternoonTimeString.contains("16"))
    }

    @Test func testScheduledDateWhenDisabled() async throws {
        let disabledSettings = NotificationSettings(isEnabled: false)
        #expect(disabledSettings.scheduledDate == nil)
    }

    @Test func testScheduledDateWhenEnabled() async throws {
        let enabledSettings = NotificationSettings(
            isEnabled: true,
            dayOfWeek: 6, // Friday
            hour: 16,
            minute: 0
        )

        let scheduledDate = enabledSettings.scheduledDate
        #expect(scheduledDate != nil)

        if let date = scheduledDate {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.weekday, .hour, .minute], from: date)

            #expect(components.weekday == 6) // Friday
            #expect(components.hour == 16)
            #expect(components.minute == 0)
        }
    }

    @Test func testCodableConformance() async throws {
        let originalSettings = NotificationSettings(
            isEnabled: true,
            dayOfWeek: 3,
            hour: 14,
            minute: 45,
            displayWeekends: true
        )

        // Encode
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(originalSettings)

        // Decode
        let decoder = JSONDecoder()
        let decodedSettings = try decoder.decode(NotificationSettings.self, from: encodedData)

        // Verify equality
        #expect(decodedSettings.isEnabled == originalSettings.isEnabled)
        #expect(decodedSettings.dayOfWeek == originalSettings.dayOfWeek)
        #expect(decodedSettings.hour == originalSettings.hour)
        #expect(decodedSettings.minute == originalSettings.minute)
        #expect(decodedSettings.displayWeekends == originalSettings.displayWeekends)
    }

    @Test func testEquatableConformance() async throws {
        let settings1 = NotificationSettings(isEnabled: true, dayOfWeek: 6, hour: 16, minute: 0)
        let settings2 = NotificationSettings(isEnabled: true, dayOfWeek: 6, hour: 16, minute: 0)
        let settings3 = NotificationSettings(isEnabled: false, dayOfWeek: 6, hour: 16, minute: 0)

        #expect(settings1 == settings2)
        #expect(settings1 != settings3)
    }

    @Test func testDefaultStaticProperty() async throws {
        let defaultSettings = NotificationSettings.default

        #expect(defaultSettings.isEnabled == false)
        #expect(defaultSettings.dayOfWeek == 6)
        #expect(defaultSettings.hour == 16)
        #expect(defaultSettings.minute == 0)
        #expect(defaultSettings.displayWeekends == false)
    }

    @Test func testDisplayWeekendsProperty() async throws {
        let weekendsEnabled = NotificationSettings(displayWeekends: true)
        #expect(weekendsEnabled.displayWeekends == true)

        let weekendsDisabled = NotificationSettings(displayWeekends: false)
        #expect(weekendsDisabled.displayWeekends == false)
    }
}