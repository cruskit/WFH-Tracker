import Foundation

struct WorkDay: Identifiable, Codable {
    let id = UUID()
    let date: Date
    var workEntries: [WorkType: Double]

    // Legacy properties for backwards compatibility
    var homeHours: Double? {
        get { workEntries[.home] }
        set {
            if let value = newValue, value > 0 {
                workEntries[.home] = value
            } else {
                workEntries.removeValue(forKey: .home)
            }
        }
    }

    var officeHours: Double? {
        get { workEntries[.office] }
        set {
            if let value = newValue, value > 0 {
                workEntries[.office] = value
            } else {
                workEntries.removeValue(forKey: .office)
            }
        }
    }

    var holidayHours: Double? {
        get { workEntries[.holiday] }
        set {
            if let value = newValue, value > 0 {
                workEntries[.holiday] = value
            } else {
                workEntries.removeValue(forKey: .holiday)
            }
        }
    }

    var sickHours: Double? {
        get { workEntries[.sick] }
        set {
            if let value = newValue, value > 0 {
                workEntries[.sick] = value
            } else {
                workEntries.removeValue(forKey: .sick)
            }
        }
    }

    init(date: Date, workEntries: [WorkType: Double] = [:]) {
        self.date = date
        self.workEntries = workEntries.filter { $0.value > 0 }
    }

    // Legacy initializer for backwards compatibility
    init(date: Date, homeHours: Double? = nil, officeHours: Double? = nil) {
        self.date = date
        self.workEntries = [:]

        if let homeHours = homeHours, homeHours > 0 {
            self.workEntries[.home] = homeHours
        }
        if let officeHours = officeHours, officeHours > 0 {
            self.workEntries[.office] = officeHours
        }
    }

    var totalHours: Double {
        workEntries.values.reduce(0, +)
    }

    var hasData: Bool {
        !workEntries.isEmpty
    }

    var isAdvancedEntry: Bool {
        workEntries.count > 1
    }

    var activeWorkTypes: [WorkType] {
        Array(workEntries.keys).sorted { $0.rawValue < $1.rawValue }
    }

    func hours(for workType: WorkType) -> Double {
        workEntries[workType] ?? 0
    }
    
    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: date)
    }
    
    var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }

    var month: Int {
        Calendar.current.component(.month, from: date)
    }

    var year: Int {
        Calendar.current.component(.year, from: date)
    }
}

// MARK: - Custom Codable Implementation for Migration Support

extension WorkDay {
    enum CodingKeys: String, CodingKey {
        case id, date, homeHours, officeHours, workEntries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Always present properties
        date = try container.decode(Date.self, forKey: .date)

        // Try to decode new format first
        if let entries = try? container.decode([WorkType: Double].self, forKey: .workEntries) {
            workEntries = entries.filter { $0.value > 0 }
        } else {
            // Fall back to legacy format
            workEntries = [:]

            if let homeHours = try container.decodeIfPresent(Double.self, forKey: .homeHours), homeHours > 0 {
                workEntries[.home] = homeHours
            }
            if let officeHours = try container.decodeIfPresent(Double.self, forKey: .officeHours), officeHours > 0 {
                workEntries[.office] = officeHours
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(date, forKey: .date)
        try container.encode(workEntries, forKey: .workEntries)

        // Also encode legacy properties for compatibility
        try container.encodeIfPresent(homeHours, forKey: .homeHours)
        try container.encodeIfPresent(officeHours, forKey: .officeHours)
    }
} 