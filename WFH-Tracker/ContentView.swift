//
//  ContentView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI
import OSLog

struct ContentView: View {
    @EnvironmentObject var diContainer: DIContainer
    @EnvironmentObject var appState: AppState
    @State private var selectedFinancialYear: FinancialYear?

    var body: some View {
        TabView {
            LogView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Log")
                }
                .accessibilityLabel("Work hours log tab")

            ExportView(selectedYear: $selectedFinancialYear)
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                }
                .accessibilityLabel("Export data tab")

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .accessibilityLabel("Settings tab")
        }
        .onAppear(perform: setupInitialFinancialYear)
        .onChange(of: diContainer.calendarStateManager.financialYears) { _ in
            setupInitialFinancialYear()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenCurrentWeekEntry"))) { _ in
            // Trigger app state to open current week entry
            appState.openCurrentWeekEntry()
        }
    }

    private func setupInitialFinancialYear() {
        if selectedFinancialYear == nil {
            selectedFinancialYear = diContainer.calendarStateManager.financialYears.first
            Logger.ui.logInfo("Initial financial year set", context: "ContentView")
        }
    }

}

#Preview {
    ContentView()
}
