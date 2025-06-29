import Foundation

struct WorkTotals: Codable {
    let homeHours: Double
    let officeHours: Double
    
    init(homeHours: Double = 0, officeHours: Double = 0) {
        self.homeHours = homeHours
        self.officeHours = officeHours
    }
    
    var totalHours: Double {
        homeHours + officeHours
    }
    
    static func calculateMonthlyTotals(for workDays: [WorkDay], month: Int, year: Int) -> WorkTotals {
        let filteredDays = workDays.filter { workDay in
            workDay.month == month && workDay.year == year
        }
        
        let homeTotal = filteredDays.compactMap { $0.homeHours }.reduce(0, +)
        let officeTotal = filteredDays.compactMap { $0.officeHours }.reduce(0, +)
        
        return WorkTotals(homeHours: homeTotal, officeHours: officeTotal)
    }
    
    static func calculateYearlyTotals(for workDays: [WorkDay], date: Date) -> WorkTotals {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: date)
        let currentMonth = calendar.component(.month, from: date)
        
        // Financial year runs from July 1 to June 30
        let financialYearStart: Int
        let financialYearEnd: Int
        
        if currentMonth >= 7 {
            // July to December - current year is start of financial year
            financialYearStart = currentYear
            financialYearEnd = currentYear + 1
        } else {
            // January to June - previous year is start of financial year
            financialYearStart = currentYear - 1
            financialYearEnd = currentYear
        }
        
        let filteredDays = workDays.filter { workDay in
            let workDayYear = workDay.year
            let workDayMonth = workDay.month
            
            if workDayYear == financialYearStart {
                return workDayMonth >= 7 // July onwards
            } else if workDayYear == financialYearEnd {
                return workDayMonth <= 6 // January to June
            }
            return false
        }
        
        let homeTotal = filteredDays.compactMap { $0.homeHours }.reduce(0, +)
        let officeTotal = filteredDays.compactMap { $0.officeHours }.reduce(0, +)
        
        return WorkTotals(homeHours: homeTotal, officeHours: officeTotal)
    }
} 