import SwiftUI
import UserNotifications
import OSLog

struct SettingsView: View {
    @EnvironmentObject var diContainer: DIContainer
    @State private var showingPermissionAlert = false
    @State private var showingErrorAlert = false
    @State private var permissionStatus: UNAuthorizationStatus = .notDetermined
    @State private var defaultHoursText: String = ""

    private var settings: NotificationSettings { diContainer.settingsManager.notificationSettings }
    private let weekdays = Calendar.current.weekdaySymbols

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // CALENDAR section
                    sectionHeader("Calendar")

                    listCard {
                        // Show weekends
                        settingsRow(
                            icon: "📅", iconBg: Color.breezeOfficeSoft,
                            title: "Show weekends",
                            subtitle: "Turn off for weekdays only (Mon–Fri)"
                        ) {
                            Toggle("", isOn: Binding(
                                get: { settings.displayWeekends },
                                set: { diContainer.settingsManager.updateDisplayWeekends($0) }
                            ))
                            .labelsHidden()
                            .tint(Color.breezeOffice)
                        }

                        rowDivider()

                        // Default hours
                        settingsRow(
                            icon: "⏰", iconBg: Color.breezeHomeSoft,
                            title: "Default hours",
                            subtitle: "Filled in when you tap a work type"
                        ) {
                            TextField("", text: $defaultHoursText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 14.5, weight: .heavy))
                                .foregroundStyle(Color.breezeInkMuted)
                                .frame(width: 60)
                                .onChange(of: defaultHoursText) { _, newValue in
                                    if let parsed = Double(newValue) {
                                        let clamped = min(max(parsed, 0.1), 24.0)
                                        let rounded = (clamped * 10).rounded() / 10
                                        diContainer.settingsManager.updateDefaultHours(rounded)
                                    }
                                }
                        }
                    }

                    // REMINDERS section
                    sectionHeader("Reminders")

                    listCard {
                        // Weekly nudge toggle
                        settingsRow(
                            icon: "🔔", iconBg: Color.breezeHolidaySoft,
                            title: "Weekly nudge",
                            subtitle: "A friendly reminder to log"
                        ) {
                            Toggle("", isOn: Binding(
                                get: { settings.isEnabled },
                                set: { newValue in
                                    if newValue && permissionStatus != .authorized {
                                        requestAndEnable()
                                    } else {
                                        diContainer.settingsManager.updateNotificationEnabled(newValue)
                                    }
                                }
                            ))
                            .labelsHidden()
                            .tint(Color.breezeOffice)
                        }

                        if settings.isEnabled {
                            rowDivider()

                            // Remind me on
                            settingsRow(
                                icon: "📆", iconBg: Color.breezeBrandSoft,
                                title: "Remind me on",
                                subtitle: nil
                            ) {
                                Picker("", selection: Binding(
                                    get: { settings.dayOfWeek },
                                    set: { diContainer.settingsManager.updateNotificationDay($0) }
                                )) {
                                    ForEach(1...7, id: \.self) { Text(weekdays[$0 - 1]).tag($0) }
                                }
                                .pickerStyle(.menu)
                                .tint(Color.breezeInkMuted)
                            }

                            rowDivider()

                            // At (time)
                            settingsRow(
                                icon: "🕓", iconBg: Color.breezeSickSoft,
                                title: "At",
                                subtitle: nil
                            ) {
                                DatePicker("", selection: Binding(
                                    get: {
                                        var comps = DateComponents()
                                        comps.hour = settings.hour
                                        comps.minute = settings.minute
                                        return Calendar.current.date(from: comps) ?? Date()
                                    },
                                    set: { d in
                                        let comps = Calendar.current.dateComponents([.hour, .minute], from: d)
                                        diContainer.settingsManager.updateNotificationTime(
                                            hour: comps.hour ?? 16,
                                            minute: comps.minute ?? 0
                                        )
                                    }
                                ), displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .tint(Color.breezeBrand)
                            }
                        }
                    }

                    if settings.isEnabled {
                        Text("We'll only nudge you if you haven't logged any hours that week.")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.breezeInkFaint)
                            .padding(.horizontal, 24)
                            .padding(.top, 9)
                    }

                    // Reset card
                    listCard {
                        Button {
                            diContainer.settingsManager.resetToDefaults()
                            Logger.ui.logInfo("Settings reset to defaults", context: "SettingsView")
                        } label: {
                            HStack(spacing: 13) {
                                Text("↺")
                                    .font(.system(size: 18, weight: .bold))
                                    .frame(width: 36, height: 36)
                                    .background(
                                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                                            .fill(Color.breezeSurfaceSunken)
                                    )
                                Text("Reset to defaults")
                                    .font(.system(size: 15.5, weight: .heavy))
                                    .foregroundStyle(Color.breezeBrandInk)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 22)

                    // About section
                    sectionHeader("About")

                    listCard {
                        Link(destination: URL(string: "https://thecruskit.com/wfh-tracker/privacy-policy")!) {
                            HStack(spacing: 13) {
                                Text("🔒")
                                    .font(.system(size: 16))
                                    .frame(width: 36, height: 36)
                                    .background(
                                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                                            .fill(Color.breezeSurfaceSunken)
                                    )
                                Text("Privacy Policy")
                                    .font(.system(size: 15.5, weight: .heavy))
                                    .foregroundStyle(Color.breezeInk)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.breezeInkFaint)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                    }

                    Spacer(minLength: 32)
                }
            }
            .background(Color.breezeBackground.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                defaultHoursText = String(format: "%.1f", settings.defaultHoursPerDay)
                checkPermission()
                Logger.ui.logInfo("Settings view appeared", context: "SettingsView")
            }
            .alert("Enable Notifications", isPresented: $showingPermissionAlert) {
                Button("Open Settings") { openAppSettings() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("To receive work hour reminders, please enable notifications in Settings.")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK") { diContainer.settingsManager.clearError() }
            } message: {
                Text(diContainer.settingsManager.lastError?.localizedDescription ?? "An unknown error occurred")
            }
            .onChange(of: diContainer.settingsManager.lastError) { _, error in
                showingErrorAlert = error != nil
            }
        }
    }

    // MARK: - Layout helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .heavy))
            .foregroundStyle(Color.breezeInkFaint)
            .tracking(0.8)
            .padding(.horizontal, 24)
            .padding(.top, 22)
            .padding(.bottom, 9)
    }

    private func listCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.breezeSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.breezeLine, lineWidth: 1)
                    )
            )
            .breezeShadowSm()
            .padding(.horizontal, 18)
    }

    private func settingsRow<Control: View>(
        icon: String,
        iconBg: Color,
        title: String,
        subtitle: String?,
        @ViewBuilder control: () -> Control
    ) -> some View {
        HStack(spacing: 13) {
            Text(icon)
                .font(.system(size: 16))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 11, style: .continuous).fill(iconBg)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15.5, weight: .heavy))
                    .foregroundStyle(Color.breezeInk)
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundStyle(Color.breezeInkFaint)
                }
            }

            Spacer()

            control()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func rowDivider() -> some View {
        Divider().overlay(Color.breezeLine).padding(.leading, 65)
    }

    // MARK: - Permission handling

    private func requestAndEnable() {
        Task {
            let granted = await diContainer.settingsManager.requestNotificationPermission()
            await MainActor.run {
                if granted {
                    diContainer.settingsManager.updateNotificationEnabled(true)
                    permissionStatus = .authorized
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }

    private func checkPermission() {
        Task {
            let status = await diContainer.settingsManager.checkNotificationPermission()
            await MainActor.run { permissionStatus = status }
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView().environmentObject(DIContainer.shared)
}
