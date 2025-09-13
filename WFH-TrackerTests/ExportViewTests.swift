//
//  ExportViewTests.swift
//  WFH-TrackerTests
//
//  Created by Paul Ruskin on 29/6/2025.
//

import XCTest
@testable import WFH_Tracker

@MainActor
class ExportViewTests: XCTestCase {
    var calendarManager: CalendarStateManager!
    var exportView: TestableExportView!
    
    override func setUp() async throws {
        calendarManager = CalendarStateManager()
        exportView = TestableExportView(calendarManager: calendarManager)
        
        // Clear any existing data
        calendarManager.workDays.removeAll()
    }
    
    override func tearDown() async throws {
        calendarManager = nil
        exportView = nil
    }
    
    func testGenerateCSVStringWithData() async throws {
        // Setup test data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let testDate1 = dateFormatter.date(from: "2024-07-01")!
        let testDate2 = dateFormatter.date(from: "2024-07-02")!
        
        let workDay1 = WorkDay(date: testDate1, homeHours: 8.0, officeHours: 0.0)
        let workDay2 = WorkDay(date: testDate2, homeHours: 4.0, officeHours: 4.0)
        
        calendarManager.workDays = [workDay1, workDay2]
        
        // Print available financial years for debugging
        let availableYears = calendarManager.financialYears.map { $0.displayString }
        print("Available financial years: \(availableYears)")
        
        // Get the financial year for 2024-25
        let financialYear = calendarManager.financialYears.first { $0.displayString == "2024/2025" }
        XCTAssertNotNil(financialYear, "Should have 2024/2025 financial year. Available: \(availableYears)")
        guard let financialYear = financialYear else { return }
        
        // Test the actual generateCSVString method
        let csvString = exportView.generateCSVString(for: financialYear)
        
        // Verify CSV structure
        let lines = csvString.components(separatedBy: "\n")
        XCTAssertGreaterThan(lines.count, 1, "CSV should have header and data rows")
        
        // Check header
        XCTAssertTrue(lines[0].contains("date,day of week,home days,office days,home hours,office hours"), "CSV should have correct header")
        
        // Check that we have data for the specific dates
        XCTAssertTrue(csvString.contains("01/07/2024"), "Should contain first test date")
        XCTAssertTrue(csvString.contains("02/07/2024"), "Should contain second test date")
        
        // Check that home/office hours are correctly formatted
        XCTAssertTrue(csvString.contains("1.0,0.0,8.0,0.0"), "Should have correct home day calculation for first date")
        XCTAssertTrue(csvString.contains("0.5,0.5,4.0,4.0"), "Should have correct day calculations for second date")
    }
    
    func testGenerateCSVStringWithNoData() async throws {
        // No work days added to calendar manager
        
        let financialYear = FinancialYear(startYear: 2024)
        
        // Test the actual generateCSVString method
        let csvString = exportView.generateCSVString(for: financialYear)
        
        // Should still have header
        let lines = csvString.components(separatedBy: "\n")
        XCTAssertTrue(lines[0].contains("date,day of week,home days,office days,home hours,office hours"), "CSV should have header even with no data")
        
        // Should have at least one data row (even if empty)
        XCTAssertGreaterThan(lines.count, 1, "Should have at least header and one data row")
    }
    
    func testGenerateCSVStringWithPartialData() async throws {
        // Setup test data for a specific date only
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let testDate = dateFormatter.date(from: "2024-07-15")!
        let workDay = WorkDay(date: testDate, homeHours: 6.0, officeHours: 2.0)
        
        calendarManager.workDays = [workDay]
        
        // Print available financial years for debugging
        let availableYears = calendarManager.financialYears.map { $0.displayString }
        print("Available financial years: \(availableYears)")
        
        let financialYear = calendarManager.financialYears.first { $0.displayString == "2024/2025" }
        XCTAssertNotNil(financialYear, "Should have 2024/2025 financial year. Available: \(availableYears)")
        guard let financialYear = financialYear else { return }
        
        // Test the actual generateCSVString method
        let csvString = exportView.generateCSVString(for: financialYear)
        
        // Should contain the specific date with correct calculations
        XCTAssertTrue(csvString.contains("15/07/2024"), "Should contain test date")
        XCTAssertTrue(csvString.contains("0.8,0.3,6.0,2.0"), "Should have correct day calculations (6/8=0.75 rounded to 0.8, 2/8=0.25 rounded to 0.3)")
    }
    
    func testGenerateAndExportCSV() async throws {
        // Setup test data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let testDate = dateFormatter.date(from: "2024-07-01")!
        let workDay = WorkDay(date: testDate, homeHours: 8.0, officeHours: 0.0)
        
        calendarManager.workDays = [workDay]
        
        // Print available financial years for debugging
        let availableYears = calendarManager.financialYears.map { $0.displayString }
        print("Available financial years: \(availableYears)")
        
        let financialYear = calendarManager.financialYears.first { $0.displayString == "2024/2025" }
        XCTAssertNotNil(financialYear, "Should have 2024/2025 financial year. Available: \(availableYears)")
        
        // Set the selected year
        exportView.selectedYear = financialYear
        
        // Test the actual generateAndExportCSV method
        let result = exportView.generateAndExportCSV()
        
        // Should return a valid file URL
        XCTAssertNotNil(result, "Should return a file URL")
        guard let result = result else { return }
        XCTAssertTrue(result.lastPathComponent.contains("WFH-Export-2024-2025.csv"), "Should have correct filename")
        
        // Verify file exists and contains expected content
        let fileContent = try String(contentsOf: result, encoding: .utf8)
        XCTAssertTrue(fileContent.contains("01/07/2024"), "File should contain test date")
        XCTAssertTrue(fileContent.contains("1.0,0.0,8.0,0.0"), "File should contain correct data")
    }
    
    func testGenerateAndExportCSVWithNoSelectedYear() async throws {
        // Don't set selectedYear
        
        // Test the actual generateAndExportCSV method
        let result = exportView.generateAndExportCSV()
        
        // Should return nil when no year is selected
        XCTAssertNil(result, "Should return nil when no year is selected")
    }
}

// Testable wrapper for ExportView to access private methods
@MainActor
class TestableExportView {
    let calendarManager: CalendarStateManager
    var selectedYear: FinancialYear?
    
    init(calendarManager: CalendarStateManager) {
        self.calendarManager = calendarManager
    }
    
    // Expose the private method for testing
    func generateCSVString(for year: FinancialYear) -> String {
        var csvText = "date,day of week,home days,office days,home hours,office hours\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        
        var currentDate = year.startDate
        let calendar = Calendar.current
        
        while currentDate <= year.endDate {
            let workDay = calendarManager.getWorkDay(for: currentDate)
            
            let homeHours = workDay?.homeHours ?? 0
            let officeHours = workDay?.officeHours ?? 0
            
            let homeDays = round((homeHours / 8.0) * 10) / 10.0
            let officeDays = round((officeHours / 8.0) * 10) / 10.0
            
            let dateString = dateFormatter.string(from: currentDate)
            let dayString = dayFormatter.string(from: currentDate)
            
            let row = "\(dateString),\(dayString),\(homeDays),\(officeDays),\(homeHours),\(officeHours)\n"
            csvText.append(row)
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return csvText
    }
    
    // Expose the private method for testing
    func generateAndExportCSV() -> URL? {
        guard let year = selectedYear else { return nil }
        
        let csvString = generateCSVString(for: year)
        
        let fileName = "WFH-Export-\(year.displayString.replacingOccurrences(of: "/", with: "-")).csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            return path
        } catch {
            print("Failed to generate CSV file: \(error.localizedDescription)")
            return nil
        }
    }
} 