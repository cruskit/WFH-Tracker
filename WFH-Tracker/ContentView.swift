import SwiftUI
import OSLog

struct ContentView: View {
    @EnvironmentObject var diContainer: DIContainer
    @EnvironmentObject var appState: AppState
    @State private var selectedFinancialYear: FinancialYear?

    init() {
        // Style the tab bar to match Breeze
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.breezeSurface)
        appearance.shadowColor = UIColor(Color.breezeLine)

        let normal = UITabBarItemAppearance()
        normal.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.breezeInkFaint)]
        normal.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.breezeBrand)]
        normal.normal.iconColor = UIColor(Color.breezeInkFaint)
        normal.selected.iconColor = UIColor(Color.breezeBrand)
        appearance.stackedLayoutAppearance = normal
        appearance.inlineLayoutAppearance = normal
        appearance.compactInlineLayoutAppearance = normal

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            LogView()
                .tabItem {
                    Label("Log", systemImage: "calendar")
                }
                .accessibilityLabel("Work hours log tab")

            ExportView(selectedYear: $selectedFinancialYear)
                .tabItem {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .accessibilityLabel("Export data tab")

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .accessibilityLabel("Settings tab")
        }
        .tint(Color.breezeBrand)
        .onAppear(perform: setupInitialFinancialYear)
        .onChange(of: diContainer.calendarStateManager.financialYears) { _ in
            setupInitialFinancialYear()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenCurrentWeekEntry"))) { _ in
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
        .environmentObject(DIContainer.shared)
        .environmentObject(AppState())
}
