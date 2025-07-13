//
//  ContentView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var calendarManager = CalendarStateManager()
    @State private var selectedFinancialYear: FinancialYear?

    var body: some View {
        TabView {
            LogView(calendarManager: calendarManager)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Log")
                }

            ExportView(selectedYear: $selectedFinancialYear)
                .environmentObject(calendarManager)
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                }
        }
        .onAppear(perform: setupInitialFinancialYear)
        .onChange(of: calendarManager.financialYears) { _ in
            setupInitialFinancialYear()
        }
    }

    private func setupInitialFinancialYear() {
        if selectedFinancialYear == nil {
            selectedFinancialYear = calendarManager.financialYears.first
        }
    }
}

#Preview {
    ContentView()
}
