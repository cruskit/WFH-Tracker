import Foundation
import SwiftUI

enum WorkType: String, CaseIterable, Codable {
    case home = "home"
    case office = "office"
    case holiday = "holiday"
    case sick = "sick"

    var icon: String {
        switch self {
        case .home: return "🏠"
        case .office: return "🏢"
        case .holiday: return "🏖️"
        case .sick: return "🤒"
        }
    }

    var displayName: String {
        switch self {
        case .home: return "Home"
        case .office: return "Office"
        case .holiday: return "Holiday"
        case .sick: return "Sick"
        }
    }

    // Primary work-type colour
    var color: Color {
        switch self {
        case .home: return .breezeHome
        case .office: return .breezeOffice
        case .holiday: return .breezeHoliday
        case .sick: return .breezeSick
        }
    }

    // Soft tinted background
    var softColor: Color {
        switch self {
        case .home: return .breezeHomeSoft
        case .office: return .breezeOfficeSoft
        case .holiday: return .breezeHolidaySoft
        case .sick: return .breezeSickSoft
        }
    }

    // Darker tinted foreground for text on soft background
    var inkColor: Color {
        switch self {
        case .home: return .breezeHomeInk
        case .office: return .breezeOfficeInk
        case .holiday: return .breezeHolidayInk
        case .sick: return .breezeSickInk
        }
    }

    var backgroundColor: Color { softColor }
}
