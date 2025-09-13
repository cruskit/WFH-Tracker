import Foundation
import SwiftUI

enum WorkType: String, CaseIterable, Codable {
    case home = "home"
    case office = "office"
    case holiday = "holiday"
    case sick = "sick"

    var icon: String {
        switch self {
        case .home:
            return "🏠"
        case .office:
            return "🏢"
        case .holiday:
            return "🏖️"
        case .sick:
            return "🤒"
        }
    }

    var displayName: String {
        switch self {
        case .home:
            return "Home"
        case .office:
            return "Office"
        case .holiday:
            return "Holiday"
        case .sick:
            return "Sick"
        }
    }

    var color: Color {
        switch self {
        case .home:
            return .blue
        case .office:
            return .green
        case .holiday:
            return .orange
        case .sick:
            return .red
        }
    }

    var backgroundColor: Color {
        switch self {
        case .home:
            return .blue.opacity(0.1)
        case .office:
            return .green.opacity(0.1)
        case .holiday:
            return .orange.opacity(0.1)
        case .sick:
            return .red.opacity(0.1)
        }
    }
}