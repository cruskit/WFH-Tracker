//
//  ExportView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI

struct ExportView: View {
    @EnvironmentObject var calendarManager: CalendarStateManager
    
    @Binding var selectedYear: FinancialYear?
    @State private var shareItem: ShareItem?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Financial Year")) {
                    if calendarManager.financialYears.isEmpty {
                        Text("No data available to export.")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Financial Year", selection: $selectedYear) {
                            ForEach(calendarManager.financialYears) { year in
                                Text(year.displayString).tag(year as FinancialYear?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section {
                    Button(action: { generateAndExportCSV() }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.fill")
                            Text("Export to CSV")
                        }
                    }
                    .disabled(selectedYear == nil)
                }
            }
            .navigationTitle("Export Data")
            .sheet(item: $shareItem) { item in
                ShareSheet(url: item.url)
            }
        }
    }
    
    private func generateAndExportCSV() {
        guard let year = selectedYear else { return }
        
        let csvString = generateCSVString(for: year)
        
        let fileName = "WFH-Export-\(year.displayString.replacingOccurrences(of: "/", with: "-")).csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            self.shareItem = ShareItem(url: path)
        } catch {
            print("Failed to generate CSV file: \(error.localizedDescription)")
        }
    }
    
    private func generateCSVString(for year: FinancialYear) -> String {
        var csvText = "date,home days,office days,home hours,office hours\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        var currentDate = year.startDate
        let calendar = Calendar.current
        
        while currentDate <= year.endDate {
            let workDay = calendarManager.getWorkDay(for: currentDate)
            
            let homeHours = workDay?.homeHours ?? 0
            let officeHours = workDay?.officeHours ?? 0
            
            let homeDays = round((homeHours / 8.0) * 10) / 10.0
            let officeDays = round((officeHours / 8.0) * 10) / 10.0
            
            let dateString = dateFormatter.string(from: currentDate)
            
            let row = "\(dateString),\(homeDays),\(officeDays),\(homeHours),\(officeHours)\n"
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
                .environmentObject(calendarManager)
                .onAppear {
                    // You can add dummy data to the manager for previewing
                    // calendarManager.workDays = [WorkDay(date: Date())]
                    selectedYear = calendarManager.financialYears.first
                }
        }
    }
    
    return PreviewWrapper()
} 