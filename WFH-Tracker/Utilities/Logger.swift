import Foundation
import OSLog

// MARK: - Logging Utilities

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let persistence = Logger(subsystem: subsystem, category: "Persistence")
    static let notifications = Logger(subsystem: subsystem, category: "Notifications")
    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let export = Logger(subsystem: subsystem, category: "Export")
    static let stateManagement = Logger(subsystem: subsystem, category: "StateManagement")
}

// MARK: - Logging Extensions

extension Logger {
    func logError(_ error: Error, context: String = "") {
        self.error("❌ Error in \(context): \(error.localizedDescription)")
    }

    func logInfo(_ message: String, context: String = "") {
        self.info("ℹ️ \(context): \(message)")
    }

    func logDebug(_ message: String, context: String = "") {
        self.debug("🔍 \(context): \(message)")
    }

    func logWarning(_ message: String, context: String = "") {
        self.warning("⚠️ \(context): \(message)")
    }
}