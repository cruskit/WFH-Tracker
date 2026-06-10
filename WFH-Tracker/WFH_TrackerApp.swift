//
//  WFH_TrackerApp.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI
import UserNotifications
import OSLog

@main
struct WFH_TrackerApp: App {
    @StateObject private var diContainer = DIContainer.shared
    @StateObject private var appState = AppState()

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["WFH_SCREENSHOT_MODE"] == "1" {
            Self.seedScreenshotData()
        }
        #endif
        // Setup notification categories on app launch
        NotificationService.shared.setupNotificationCategories()
        Logger.ui.logInfo("WFH Tracker app initialized", context: "WFH_TrackerApp")
    }

    #if DEBUG
    // Populates UserDefaults with a full FY2026 dataset so screenshots show rich data.
    // Called before DIContainer.shared is first accessed (StateObject is lazy).
    private static func seedScreenshotData() {
        let cal = Calendar.current

        func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
            cal.date(from: DateComponents(year: year, month: month, day: day))!
        }

        // Single-type overrides (year-month-day → WorkType)
        let overrides: [String: WorkType] = [
            "2025-11-4":  .holiday, // Melbourne Cup
            "2025-12-25": .holiday, // Christmas
            "2025-12-26": .holiday, // Boxing Day
            "2026-1-1":   .holiday, // New Year's Day
            "2026-1-26":  .holiday, // Australia Day
            "2026-4-3":   .holiday, // Good Friday
            "2026-4-6":   .holiday, // Easter Monday
            "2026-4-25":  .holiday, // ANZAC Day
            "2026-2-17":  .sick,    // Sick day
            "2026-6-1":   .home,
            "2026-6-2":   .office,
            "2026-6-3":   .home,
            "2026-6-4":   .home,
            "2026-6-5":   .office,
            "2026-6-8":   .office,
            "2026-6-9":   .home,
            "2026-6-10":  .office,
        ]

        // Split-day overrides (year-month-day → multiple WorkTypes with hours)
        let splitOverrides: [String: [WorkType: Double]] = [
            "2026-6-11": [.home: 4.0, .office: 4.0], // Thu Jun 11 – split day screenshot
        ]

        let cycle: [WorkType] = [.home, .office, .home, .home, .office]
        var cycleIdx = 0
        var workDays: [WorkDay] = []

        let startDate = makeDate(2025, 7, 1)
        let endDate   = makeDate(2026, 6, 11) // extend to include split day
        var current   = startDate

        while current <= endDate {
            let weekday = cal.component(.weekday, from: current)
            if weekday >= 2 && weekday <= 6 {
                let y = cal.component(.year, from: current)
                let m = cal.component(.month, from: current)
                let d = cal.component(.day, from: current)
                let key = "\(y)-\(m)-\(d)"

                let entries: [WorkType: Double]
                if let split = splitOverrides[key] {
                    entries = split
                } else if let ov = overrides[key] {
                    entries = [ov: 8.0]
                } else {
                    let workType = cycle[cycleIdx % cycle.count]
                    cycleIdx += 1
                    entries = [workType: 8.0]
                }

                workDays.append(WorkDay(date: current, workEntries: entries))
            }
            current = cal.date(byAdding: .day, value: 1, to: current) ?? endDate
        }

        if let data = try? JSONEncoder().encode(workDays) {
            UserDefaults.standard.set(data, forKey: "workDays")
        }
    }
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(diContainer)
                .environmentObject(appState)
                .onAppear {
                    // Handle any pending notification actions
                    handleAppLaunch()
                }
        }
    }

    private func handleAppLaunch() {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        Logger.ui.logInfo("App launch handling completed", context: "WFH_TrackerApp")
    }
}

// MARK: - App State Management

@MainActor
class AppState: ObservableObject {
    @Published var shouldShowCurrentWeekEntry = false
    @Published var notificationTapDate: Date?

    func openCurrentWeekEntry() {
        shouldShowCurrentWeekEntry = true
        notificationTapDate = Date()
    }

    func resetNotificationState() {
        shouldShowCurrentWeekEntry = false
        notificationTapDate = nil
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    private override init() {
        super.init()
    }

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if let action = userInfo["action"] as? String,
           action == "open_current_week_entry" {

            // Post notification to trigger app state change
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenCurrentWeekEntry"),
                object: nil
            )
        }

        completionHandler()
    }
}
