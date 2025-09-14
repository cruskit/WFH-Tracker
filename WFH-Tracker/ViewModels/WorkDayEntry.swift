import Foundation

// MARK: - View Models

struct WorkDayEntry {
    var selectedWorkType: WorkType?
    var workEntries: [WorkType: Double] = [:]
    var isAdvanced: Bool = false

    init() {}

    init(selectedWorkType: WorkType? = nil, workEntries: [WorkType: Double] = [:], isAdvanced: Bool = false) {
        self.selectedWorkType = selectedWorkType
        self.workEntries = workEntries
        self.isAdvanced = isAdvanced
    }

    init(from workDay: WorkDay) {
        self.workEntries = workDay.workEntries
        self.isAdvanced = workDay.isAdvancedEntry

        if !isAdvanced && workDay.activeWorkTypes.count == 1 {
            self.selectedWorkType = workDay.activeWorkTypes.first
        }
    }

    var hasData: Bool {
        !workEntries.isEmpty
    }

    var totalHours: Double {
        workEntries.values.reduce(0, +)
    }

    mutating func clear() {
        selectedWorkType = nil
        workEntries.removeAll()
        isAdvanced = false
    }

    mutating func setWorkType(_ workType: WorkType, hours: Double) {
        if hours > 0 {
            workEntries[workType] = hours
            if !isAdvanced {
                selectedWorkType = workType
            }
        } else {
            workEntries.removeValue(forKey: workType)
            if selectedWorkType == workType && !isAdvanced {
                selectedWorkType = nil
            }
        }
    }

    func toWorkDay(for date: Date) -> WorkDay {
        return WorkDay(date: date, workEntries: workEntries)
    }
}

struct DateWrapper: Identifiable {
    let id = UUID()
    let date: Date
}