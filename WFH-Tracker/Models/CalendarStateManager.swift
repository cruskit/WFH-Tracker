import Foundation
import SwiftUI

@MainActor
class CalendarStateManager: ObservableObject {
    @Published var currentMonth: CalendarMonth
    @Published var visibleMonths: [CalendarMonth]
    @Published var workDays: [WorkDay]
    @Published var isLoading: Bool = false
    
    private let calendar = Calendar.current
    private var hasInitializedData = false
    
    init(initialDate: Date = Date()) {
        let currentMonth = CalendarMonth(date: initialDate)
        self.currentMonth = currentMonth
        self.workDays = []
        let previousMonth = currentMonth.previousMonth()
        let nextMonth = currentMonth.nextMonth()
        self.visibleMonths = [previousMonth, currentMonth, nextMonth]
        loadWorkData()
    }
    
    // MARK: - Month Navigation
    
    func scrollToMonth(_ month: CalendarMonth) {
        currentMonth = month
        updateVisibleMonths()
        // Don't reload data when just navigating between months
    }
    
    func nextMonth() {
        currentMonth = currentMonth.nextMonth()
        updateVisibleMonths()
        // Don't reload data when just navigating between months
    }
    
    func previousMonth() {
        currentMonth = currentMonth.previousMonth()
        updateVisibleMonths()
        // Don't reload data when just navigating between months
    }
    
    private func updateVisibleMonths() {
        let previousMonth = currentMonth.previousMonth()
        let nextMonth = currentMonth.nextMonth()
        visibleMonths = [previousMonth, currentMonth, nextMonth]
    }
    
    // MARK: - Data Loading
    
    private func loadWorkData() {
        // Only generate sample data once during initialization
        if hasInitializedData {
            return
        }
        
        isLoading = true
        
        // Load data for visible months
        let startDate = visibleMonths.first?.date ?? currentMonth.date
        let endDate = visibleMonths.last?.date ?? currentMonth.date
        
        // For now, generate sample data
        // In a real app, this would fetch from a data source
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.generateSampleData(for: startDate, to: endDate)
            self.isLoading = false
            self.hasInitializedData = true
        }
    }
    
    private func generateSampleData(for startDate: Date, to endDate: Date) {
        var newWorkDays: [WorkDay] = []
        let calendar = Calendar.current
        
        var currentDate = startDate
        while currentDate <= endDate {
            let isWeekend = calendar.component(.weekday, from: currentDate) == 1 || 
                           calendar.component(.weekday, from: currentDate) == 7
            
            if !isWeekend && Bool.random() {
                let homeHours = Double.random(in: 4...8)
                let officeHours = Double.random(in: 0...4)
                
                newWorkDays.append(WorkDay(
                    date: currentDate,
                    homeHours: homeHours,
                    officeHours: officeHours > 0 ? officeHours : nil
                ))
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Merge with existing data, avoiding duplicates
        let existingDates = Set(workDays.map { calendar.startOfDay(for: $0.date) })
        let newUniqueWorkDays = newWorkDays.filter { workDay in
            !existingDates.contains(calendar.startOfDay(for: workDay.date))
        }
        
        workDays.append(contentsOf: newUniqueWorkDays)
    }
    
    // MARK: - Work Day Management
    
    func getWorkDay(for date: Date) -> WorkDay? {
        return workDays.first { workDay in
            calendar.isDate(workDay.date, inSameDayAs: date)
        }
    }
    
    func updateWorkDay(_ workDay: WorkDay) {
        if let index = workDays.firstIndex(where: { day in
            calendar.isDate(day.date, inSameDayAs: workDay.date)
        }) {
            workDays[index] = workDay
        } else {
            workDays.append(workDay)
        }
    }
    
    // MARK: - Totals Calculation
    
    func getMonthlyTotals(for month: CalendarMonth) -> WorkTotals {
        return WorkTotals.calculateMonthlyTotals(
            for: workDays,
            month: month.month,
            year: month.year
        )
    }
    
    func getYearlyTotals(for month: CalendarMonth) -> WorkTotals {
        return WorkTotals.calculateYearlyTotals(
            for: workDays,
            date: month.date
        )
    }
} 