import Foundation

struct FinancialYear: Hashable, Comparable, Identifiable {
    let startYear: Int
    
    var id: Int { startYear }
    
    var displayString: String {
        "\(startYear)/\(startYear + 1)"
    }
    
    var startDate: Date {
        var components = DateComponents()
        components.year = startYear
        components.month = 7
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var endDate: Date {
        var components = DateComponents()
        components.year = startYear + 1
        components.month = 6
        components.day = 30
        return Calendar.current.date(from: components) ?? Date()
    }
    
    init(startYear: Int) {
        self.startYear = startYear
    }
    
    init(for date: Date) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        if month >= 7 {
            self.startYear = year
        } else {
            self.startYear = year - 1
        }
    }
    
    static func < (lhs: FinancialYear, rhs: FinancialYear) -> Bool {
        lhs.startYear < rhs.startYear
    }
}
