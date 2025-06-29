import Foundation

struct WorkDay: Identifiable, Codable {
    let id = UUID()
    let date: Date
    var homeHours: Double?
    var officeHours: Double?
    
    init(date: Date, homeHours: Double? = nil, officeHours: Double? = nil) {
        self.date = date
        self.homeHours = homeHours
        self.officeHours = officeHours
    }
    
    var totalHours: Double {
        (homeHours ?? 0) + (officeHours ?? 0)
    }
    
    var hasData: Bool {
        homeHours != nil || officeHours != nil
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