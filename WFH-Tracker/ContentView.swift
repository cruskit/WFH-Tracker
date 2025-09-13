//
//  ContentView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var calendarManager = CalendarStateManager()
    @EnvironmentObject var appState: AppState
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

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .onAppear(perform: setupInitialFinancialYear)
        .onChange(of: calendarManager.financialYears) { _ in
            setupInitialFinancialYear()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenCurrentWeekEntry"))) { _ in
            // Trigger app state to open current week entry
            appState.openCurrentWeekEntry()
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
