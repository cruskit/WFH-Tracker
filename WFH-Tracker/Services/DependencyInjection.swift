import Foundation
import SwiftUI
import Combine

// MARK: - Observable Dependency Container

@MainActor
class DIContainer: ObservableObject {
    static let shared = DIContainer()

    // MARK: - Services
    let notificationService: NotificationServiceProtocol
    let calendarStateManager: CalendarStateManager
    let settingsManager: SettingsManager

    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Initialize core services
        self.notificationService = NotificationService.shared
        self.calendarStateManager = CalendarStateManager()
        self.settingsManager = SettingsManager(
            notificationService: NotificationService.shared
        )

        // Forward changes from child ObservableObjects
        setupObservation()
    }

    // MARK: - Test Initializer
    init(notificationService: NotificationServiceProtocol? = nil) {
        self.notificationService = notificationService ?? NotificationService.shared
        self.calendarStateManager = CalendarStateManager()
        self.settingsManager = SettingsManager(
            notificationService: self.notificationService
        )

        setupObservation()
    }

    private func setupObservation() {
        // Forward settings manager changes
        settingsManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Forward calendar state manager changes
        calendarStateManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Environment Key

private struct DIContainerKey: EnvironmentKey {
    static let defaultValue = DIContainer.shared
}

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}