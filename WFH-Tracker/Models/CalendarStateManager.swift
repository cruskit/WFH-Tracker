import Foundation
import SwiftUI

@MainActor
class CalendarStateManager: ObservableObject {
    @Published var currentMonth: CalendarMonth
    @Published var visibleMonths: [CalendarMonth]
    @Published var workDays: [WorkDay]
    
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
        // Initialize with empty data - no dummy data generation
        if hasInitializedData {
            return
        }
        
        hasInitializedData = true
        loadPersistedData()
    }
    
    // MARK: - Data Persistence
    
    private func loadPersistedData() {
        if let data = UserDefaults.standard.data(forKey: "workDays"),
           let decodedWorkDays = try? JSONDecoder().decode([WorkDay].self, from: data) {
            workDays = decodedWorkDays
        } else {
            // If loading fails, start with empty array
            workDays = []
        }
    }
    
    private func savePersistedData() {
        do {
            let encodedData = try JSONEncoder().encode(workDays)
            UserDefaults.standard.set(encodedData, forKey: "workDays")
        } catch {
            print("Failed to save work days data: \(error)")
        }
    }
    
    // MARK: - Work Day Management
    
    func getWorkDay(for date: Date) -> WorkDay? {
        return workDays.first { workDay in
            calendar.isDate(workDay.date, inSameDayAs: date)
        }
    }
    
    func getWorkDays(for dates: [Date]) -> [WorkDay] {
        return workDays.filter { workDay in
            dates.contains { date in
                calendar.isDate(workDay.date, inSameDayAs: date)
            }
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
        savePersistedData()
    }
    
    func deleteWorkDay(for date: Date) {
        workDays.removeAll { workDay in
            calendar.isDate(workDay.date, inSameDayAs: date)
        }
        savePersistedData()
    }
    
    func clearAllData() {
        workDays.removeAll()
        savePersistedData()
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