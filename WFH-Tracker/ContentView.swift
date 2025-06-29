//
//  ContentView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var calendarManager = CalendarStateManager()
    @State private var selectedDate: Date?
    
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
                                selectedDate = date
                                // TODO: Show entry screen for selected date
                            }
                        )
                    }
                }
                .padding(.top, 16)
            }
            
            // Totals Section
            VStack(spacing: 16) {
                TotalsCard(
                    title: "Monthly Totals",
                    totals: calendarManager.getMonthlyTotals(for: calendarManager.currentMonth)
                )
                
                TotalsCard(
                    title: "Yearly Totals",
                    totals: calendarManager.getYearlyTotals(for: calendarManager.currentMonth)
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
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
