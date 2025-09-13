//
//  WFH_TrackerApp.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI
import UserNotifications

@main
struct WFH_TrackerApp: App {
    @StateObject private var appState = AppState()

    init() {
        // Setup notification categories on app launch
        NotificationService.shared.setupNotificationCategories()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
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
