//
//  ContentView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI

struct IdentifiableDate: Identifiable, Equatable {
    let id: Date
    var date: Date { id }
    init(_ date: Date) { self.id = date }
}

struct ContentView: View {
    @StateObject private var calendarManager = CalendarStateManager()
    @State private var selectedDate: IdentifiableDate?
    @State private var showingWorkHoursEntry = false
    
    private func getFinancialYear(for month: CalendarMonth) -> Int {
        // Financial year runs from July 1 to June 30
        // If month is July or later, financial year is current year + 1
        // If month is January to June, financial year is current year
        if month.month >= 7 {
            return month.year + 1
        } else {
            return month.year
        }
    }
    
    private func getFinancialYearDate(for month: CalendarMonth) -> CalendarMonth {
        let financialYear = getFinancialYear(for: month)
        // Create a date in July of the financial year start
        let calendar = Calendar.current
        let components = DateComponents(year: financialYear - 1, month: 7, day: 1)
        let date = calendar.date(from: components) ?? Date()
        return CalendarMonth(date: date)
    }
    
    private func getWeekDates(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        var dates: [Date] = []
        
        for i in 0..<7 {
            if let weekDate = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                dates.append(weekDate)
            }
        }
        
        return dates
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Header
            CalendarNavigationView(calendarManager: calendarManager)
            
            Divider()
            
            // Calendar View
            ScrollView {
                VStack(spacing: 16) {
                    if calendarManager.isLoading {
                        LoadingView()
                    } else {
                        MultiMonthCalendarView(
                            calendarManager: calendarManager,
                            onDayTap: { date in
                                selectedDate = IdentifiableDate(date)
                            }
                        )
                    }
                }
                .padding(.top, 16)
            }
            
            // Totals Section
            HStack(spacing: 16) {
                TotalsCard(
                    title: calendarManager.currentMonth.monthName,
                    totals: calendarManager.getMonthlyTotals(for: calendarManager.currentMonth)
                )
                
                TotalsCard(
                    title: "FY \(getFinancialYear(for: calendarManager.currentMonth))",
                    totals: calendarManager.getYearlyTotals(for: getFinancialYearDate(for: calendarManager.currentMonth))
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .sheet(item: $selectedDate) { identifiableDate in
            let weekDates = getWeekDates(for: identifiableDate.date)
            let existingWorkDays = calendarManager.getWorkDays(for: weekDates)
            
            WorkHoursEntryView(
                date: identifiableDate.date,
                existingWorkDay: calendarManager.getWorkDay(for: identifiableDate.date),
                existingWorkDays: existingWorkDays,
                onSave: { workDays in
                    for workDay in workDays {
                        calendarManager.updateWorkDay(workDay)
                    }
                    selectedDate = nil
                },
                onCancel: {
                    selectedDate = nil
                }
            )
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading calendar data...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
    }
}

#Preview {
    ContentView()
}
