import SwiftUI
import UserNotifications
import OSLog

struct SettingsView: View {
    @EnvironmentObject var diContainer: DIContainer
    @State private var showingPermissionAlert = false
    @State private var showingErrorAlert = false
    @State private var permissionStatus: UNAuthorizationStatus = .notDetermined

    private let weekdays = Calendar.current.weekdaySymbols

    var body: some View {
        NavigationView {
            Form {
                // Notifications Section
                notificationSection

                // Schedule Section (only visible when notifications are enabled)
                if diContainer.settingsManager.notificationSettings.isEnabled {
                    scheduleSection
                }

                // Work Hours Section
                workHoursSection

                // Calendar Display Section
                calendarSection

                // Actions Section
                actionsSection

                // Debug Section (for development)
                #if DEBUG
                debugSection
                #endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                checkPermissionStatus()
                Logger.ui.logInfo("Settings view appeared", context: "SettingsView")
            }
            .alert("Enable Notifications", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    openAppSettings()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("To receive work hour reminders, please enable notifications in Settings.")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK") {
                    diContainer.settingsManager.clearError()
                }
            } message: {
                Text(diContainer.settingsManager.lastError?.localizedDescription ?? "An unknown error occurred")
            }
            .onChange(of: diContainer.settingsManager.lastError) { _, error in
                showingErrorAlert = error != nil
            }
        }
    }

    // MARK: - View Sections

    private var notificationSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.blue)
                        .frame(width: 24)

                    Text("Entry Reminders")

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { diContainer.settingsManager.notificationSettings.isEnabled },
                        set: { newValue in
                            if newValue && permissionStatus != .authorized {
                                requestPermissionAndEnable()
                            } else {
                                diContainer.settingsManager.updateNotificationEnabled(newValue)
                            }
                        }
                    ))
                    .accessibilityLabel("Enable entry reminders")
                    .accessibilityHint("Toggles weekly work hour entry reminders")
                }

                if diContainer.settingsManager.notificationSettings.isEnabled {
                    Text("Get reminded to log your work hours")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Enable to receive weekly reminders")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Notifications")
        } footer: {
            if diContainer.settingsManager.notificationSettings.isEnabled {
                Text("You'll receive a reminder on \(diContainer.settingsManager.notificationSettings.dayName) at \(diContainer.settingsManager.notificationSettings.timeString) if you haven't logged any hours for the week.")
            }
        }
    }

    private var scheduleSection: some View {
        Section {
            // Day of Week Picker
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.green)
                    .frame(width: 24)

                Text("Day of Week")
                    .font(.body)

                Spacer()

                Picker("", selection: Binding(
                    get: { diContainer.settingsManager.notificationSettings.dayOfWeek },
                    set: { diContainer.settingsManager.updateNotificationDay($0) }
                )) {
                    ForEach(1...7, id: \.self) { dayIndex in
                        Text(weekdays[dayIndex - 1])
                            .tag(dayIndex)
                    }
                }
                .pickerStyle(.menu)
                .tint(.blue)
                .accessibilityLabel("Reminder day of week")
            }
            .padding(.vertical, 4)

            // Time Picker
            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(.orange)
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
                            components.hour = diContainer.settingsManager.notificationSettings.hour
                            components.minute = diContainer.settingsManager.notificationSettings.minute
                            return calendar.date(from: components) ?? Date()
                        },
                        set: { newDate in
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.hour, .minute], from: newDate)
                            diContainer.settingsManager.updateNotificationTime(
                                hour: components.hour ?? 16,
                                minute: components.minute ?? 0
                            )
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .accessibilityLabel("Reminder time")
            }
            .padding(.vertical, 4)

        } header: {
            Text("Reminder Schedule")
        } footer: {
            if let nextDate = diContainer.settingsManager.nextScheduledNotification {
                Text("Next reminder: \(nextDate, formatter: DateFormatters.nextReminder)")
            }
        }
    }

    private var workHoursSection: some View {
        Section {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.green)
                    .frame(width: 24)

                Text("Default Hours: ")
                    .font(.body)

                Spacer()

                Stepper(value: Binding(
                    get: { diContainer.settingsManager.notificationSettings.defaultHoursPerDay },
                    set: { diContainer.settingsManager.updateDefaultHours($0) }
                ), in: 1.0...12.0, step: 0.1) {
                    Text(String(format: "%.1f", diContainer.settingsManager.notificationSettings.defaultHoursPerDay))
                        .foregroundStyle(.primary)
                        .fontWeight(.medium)
                }
                .accessibilityLabel("Default hours per day")
                .accessibilityValue("\(diContainer.settingsManager.notificationSettings.defaultHoursPerDay, specifier: "%.1f") hours")
            }
            .padding(.vertical, 4)
        } header: {
            Text("Work Hours")
        } footer: {
            Text("Default number of hours used when selecting a work type for a day. You can still use advanced entry for custom hours.")
        }
    }

    private var calendarSection: some View {
        Section {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                    .frame(width: 24)

                Text("Show weekends")
                    .font(.body)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { diContainer.settingsManager.notificationSettings.displayWeekends },
                    set: { diContainer.settingsManager.updateDisplayWeekends($0) }
                ))
                .accessibilityLabel("Show weekends in calendar")
                .accessibilityHint("Toggles weekend display in calendar view")
            }
            .padding(.vertical, 4)
        } header: {
            Text("Calendar")
        } footer: {
            Text("Show Saturday and Sunday in the calendar view. When disabled, only Monday through Friday are displayed.")
        }
    }

    private var actionsSection: some View {
        Section {
            Button(action: {
                diContainer.settingsManager.resetToDefaults()
                Logger.ui.logInfo("Settings reset to defaults", context: "SettingsView")
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(.blue)
                        .frame(width: 24)
                    Text("Reset to Defaults")
                        .foregroundStyle(.blue)
                }
                .accessibilityLabel("Reset all settings to default values")
            }
            .padding(.vertical, 4)
        } footer: {
            Text("Reset notification settings to default values (Friday at 4:00 PM, disabled).")
        }
    }

    #if DEBUG
    private var debugSection: some View {
        Section {
            Button(action: {
                Task {
                    await NotificationService.shared.scheduleTestNotification()
                }
            }) {
                HStack {
                    Image(systemName: "testtube.2")
                        .foregroundStyle(.purple)
                        .frame(width: 24)
                    Text("Send Test Notification")
                        .foregroundStyle(.purple)
                }
            }
            .padding(.vertical, 4)
            .accessibilityLabel("Send test notification")
            .accessibilityHint("Sends a test notification in 5 seconds")
        } header: {
            Text("Debug")
        } footer: {
            Text("Development only: Send a test notification in 5 seconds.")
        }
    }
    #endif

    // MARK: - Helper Methods

    private func requestPermissionAndEnable() {
        Task {
            let granted = await diContainer.settingsManager.requestNotificationPermission()
            await MainActor.run {
                if granted {
                    diContainer.settingsManager.updateNotificationEnabled(true)
                    permissionStatus = .authorized
                    Logger.notifications.logInfo("Notification permission granted and enabled", context: "SettingsView")
                } else {
                    showingPermissionAlert = true
                    Logger.notifications.logWarning("Notification permission denied", context: "SettingsView")
                }
            }
        }
    }

    private func checkPermissionStatus() {
        Task {
            let status = await diContainer.settingsManager.checkNotificationPermission()
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
}

#Preview {
    SettingsView()
        .environmentObject(DIContainer.shared)
}