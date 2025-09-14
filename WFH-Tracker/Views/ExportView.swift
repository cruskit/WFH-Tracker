//
//  ExportView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI
import OSLog

struct ExportView: View {
    @EnvironmentObject var diContainer: DIContainer

    @Binding var selectedYear: FinancialYear?
    @State private var shareItem: ShareItem?
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Financial Year")) {
                    if diContainer.calendarStateManager.financialYears.isEmpty {
                        Text("No data available to export.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Financial Year", selection: $selectedYear) {
                            ForEach(diContainer.calendarStateManager.financialYears) { year in
                                Text(year.displayString).tag(year as FinancialYear?)
                            }
                        }
                        .pickerStyle(.menu)
                        .accessibilityLabel("Select financial year to export")
                    }
                }
                
                Section {
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Generating export...")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Button(action: { generateAndExportCSV() }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up.fill")
                                Text("Export to CSV")
                            }
                        }
                        .disabled(selectedYear == nil)
                        .accessibilityLabel("Export work data to CSV file")
                        .accessibilityHint(selectedYear == nil ? "Select a financial year first" : "Creates a CSV file with your work data")
                    }
                }
            }
            .navigationTitle("Export Data")
            .sheet(item: $shareItem) { item in
                ShareSheet(url: item.url)
            }
            .alert("Export Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                Logger.ui.logInfo("ExportView appeared", context: "ExportView")
            }
        }
    }
    
    private func generateAndExportCSV() {
        guard let year = selectedYear else {
            errorMessage = "Please select a financial year to export"
            showingError = true
            return
        }

        isLoading = true

        Task {
            do {
                let csvString = await generateCSVString(for: year)
                let fileName = "WFH-Export-\(year.displayString.replacingOccurrences(of: "/", with: "-")).csv"
                let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

                try csvString.write(to: path, atomically: true, encoding: .utf8)

                await MainActor.run {
                    self.shareItem = ShareItem(url: path)
                    self.isLoading = false
                    Logger.export.logInfo("CSV export generated for \(year.displayString)", context: "ExportView")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to generate CSV file: \(error.localizedDescription)"
                    self.showingError = true
                    self.isLoading = false
                    Logger.export.logError(WFHTrackerError.exportFailure(error.localizedDescription), context: "ExportView.generateAndExportCSV")
                }
            }
        }
    }
    
    private func generateCSVString(for year: FinancialYear) async -> String {
        var csvText = "date,day of week,home days,office days,holiday days,sick days,home hours,office hours,holiday hours,sick hours\n"

        var currentDate = year.startDate
        let calendar = Calendar.current

        while currentDate <= year.endDate {
            let workDay = diContainer.calendarStateManager.getWorkDay(for: currentDate)

            let homeHours = workDay?.homeHours ?? 0
            let officeHours = workDay?.officeHours ?? 0
            let holidayHours = workDay?.holidayHours ?? 0
            let sickHours = workDay?.sickHours ?? 0

            let homeDays = round((homeHours / 8.0) * 10) / 10.0
            let officeDays = round((officeHours / 8.0) * 10) / 10.0
            let holidayDays = round((holidayHours / 8.0) * 10) / 10.0
            let sickDays = round((sickHours / 8.0) * 10) / 10.0

            let dateString = DateFormatters.csvDate.string(from: currentDate)
            let dayString = DateFormatters.fullDay.string(from: currentDate)

            let row = "\(dateString),\(dayString),\(homeDays),\(officeDays),\(holidayDays),\(sickDays),\(homeHours),\(officeHours),\(holidayHours),\(sickHours)\n"
            csvText.append(row)

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return csvText
    }
}

private struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedYear: FinancialYear? = nil
        private let calendarManager = CalendarStateManager()
        
        var body: some View {
            ExportView(selectedYear: $selectedYear)
                .environmentObject(DIContainer.shared)
                .onAppear {
                    selectedYear = DIContainer.shared.calendarStateManager.financialYears.first
                }
        }
    }
    
    return PreviewWrapper()
} 