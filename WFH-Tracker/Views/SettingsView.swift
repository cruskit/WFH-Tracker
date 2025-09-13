import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager()
    @State private var showingPermissionAlert = false
    @State private var permissionStatus: UNAuthorizationStatus = .notDetermined

    private let weekdays = Calendar.current.weekdaySymbols

    var body: some View {
        NavigationView {
            Form {
                // Notifications Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)

                            Text("Entry Reminders")
                                .font(.headline)

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { settingsManager.notificationSettings.isEnabled },
                                set: { newValue in
                                    if newValue && permissionStatus != .authorized {
                                        requestPermissionAndEnable()
                                    } else {
                                        settingsManager.updateNotificationEnabled(newValue)
                                    }
                                }
                            ))
                        }

                        if settingsManager.notificationSettings.isEnabled {
                            Text("Get reminded to log your work hours")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Enable to receive weekly reminders")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Notifications")
                } footer: {
                    if settingsManager.notificationSettings.isEnabled {
                        Text("You'll receive a reminder on \(settingsManager.notificationSettings.dayName) at \(settingsManager.notificationSettings.timeString) if you haven't logged any hours for the week.")
                    }
                }

                // Schedule Section (only visible when notifications are enabled)
                if settingsManager.notificationSettings.isEnabled {
                    Section {
                        // Day of Week Picker
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.green)
                                .frame(width: 24)

                            Text("Day of Week")
                                .font(.body)

                            Spacer()

                            Picker("", selection: Binding(
                                get: { settingsManager.notificationSettings.dayOfWeek },
                                set: { settingsManager.updateNotificationDay($0) }
                            )) {
                                ForEach(1...7, id: \.self) { dayIndex in
                                    Text(weekdays[dayIndex - 1])
                                        .tag(dayIndex)
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(.blue)
                        }
                        .padding(.vertical, 4)

                        // Time Picker
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                                .frame(width: 24)

                            Text("Time")
                                .font(.body)

                            Spacer()

                            DatePicker(
                                "",
                                selection: Binding(
                                    get: {
                                        let calendar = Calendar.current
                                        var components = DateComponents()
                                        components.hour = settingsManager.notificationSettings.hour
                                        components.minute = settingsManager.notificationSettings.minute
                                        return calendar.date(from: components) ?? Date()
                                    },
                                    set: { newDate in
                                        let calendar = Calendar.current
                                        let components = calendar.dateComponents([.hour, .minute], from: newDate)
                                        settingsManager.updateNotificationTime(
                                            hour: components.hour ?? 16,
                                            minute: components.minute ?? 0
                                        )
                                    }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                        }
                        .padding(.vertical, 4)

                    } header: {
                        Text("Reminder Schedule")
                    } footer: {
                        if let nextDate = settingsManager.nextScheduledNotification {
                            Text("Next reminder: \(nextDate, formatter: nextReminderFormatter)")
                        }
                    }
                }

                // Actions Section
                Section {
                    Button(action: {
                        settingsManager.resetToDefaults()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Reset to Defaults")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                } footer: {
                    Text("Reset notification settings to default values (Friday at 4:00 PM, disabled).")
                }

                // Debug Section (for development)
                #if DEBUG
                Section {
                    Button(action: {
                        Task {
                            await NotificationService.shared.scheduleTestNotification()
                        }
                    }) {
                        HStack {
                            Image(systemName: "testtube.2")
                                .foregroundColor(.purple)
                                .frame(width: 24)
                            Text("Send Test Notification")
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Debug")
                } footer: {
                    Text("Development only: Send a test notification in 5 seconds.")
                }
                #endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                checkPermissionStatus()
            }
            .alert("Enable Notifications", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    openAppSettings()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("To receive work hour reminders, please enable notifications in Settings.")
            }
        }
    }

    // MARK: - Helper Methods

    private func requestPermissionAndEnable() {
        Task {
            let granted = await settingsManager.requestNotificationPermission()
            await MainActor.run {
                if granted {
                    settingsManager.updateNotificationEnabled(true)
                    permissionStatus = .authorized
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }

    private func checkPermissionStatus() {
        Task {
            let status = await settingsManager.checkNotificationPermission()
            await MainActor.run {
                permissionStatus = status
            }
        }
    }

    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    private var nextReminderFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    SettingsView()
}
