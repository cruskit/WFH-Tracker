//
//  WorkTotalsTests.swift
//  WFH-TrackerTests
//
//  Created by Paul Ruskin on 29/6/2025.
//

import Testing
import Foundation
@testable import WFH_Tracker

struct WorkTotalsTests {
    
    @Test func testWorkTotalsInitialization() async throws {
        let totals = WorkTotals(homeHours: 45.5, officeHours: 32.0)
        
        #expect(totals.homeHours == 45.5)
        #expect(totals.officeHours == 32.0)
        #expect(totals.totalHours == 77.5)
    }
    
    @Test func testWorkTotalsDefaultInitialization() async throws {
        let totals = WorkTotals()
        
        #expect(totals.homeHours == 0.0)
        #expect(totals.officeHours == 0.0)
        #expect(totals.totalHours == 0.0)
    }
    
    @Test func testMonthlyTotalsCalculation() async throws {
        let calendar = Calendar.current
        
        // Create work days for January 2025
        let januaryWorkDays = [
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!, homeHours: 4.0, officeHours: 3.0),
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 1, day: 2))!, homeHours: 6.0, officeHours: 2.0),
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 1, day: 3))!, homeHours: 8.0, officeHours: nil),
            // February day should not be included
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 2, day: 1))!, homeHours: 5.0, officeHours: 5.0)
        ]
        
        let monthlyTotals = WorkTotals.calculateMonthlyTotals(for: januaryWorkDays, month: 1, year: 2025)
        
        #expect(monthlyTotals.homeHours == 18.0) // 4 + 6 + 8
        #expect(monthlyTotals.officeHours == 5.0) // 3 + 2 + 0
        #expect(monthlyTotals.totalHours == 23.0)
    }
    
    @Test func testYearlyTotalsCalculationForJulyToDecember() async throws {
        let calendar = Calendar.current
        
        // Test for a date in December 2025 (financial year 2025-2026)
        let decemberDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 15))!
        
        let workDays = [
            // July 2025 (included in financial year 2025-2026)
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 1))!, homeHours: 4.0, officeHours: 3.0),
            // December 2025 (included in financial year 2025-2026)
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!, homeHours: 6.0, officeHours: 2.0),
            // June 2025 (not included in financial year 2025-2026)
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 1))!, homeHours: 8.0, officeHours: 1.0),
            // January 2026 (included in financial year 2025-2026)
            WorkDay(date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!, homeHours: 5.0, officeHours: 4.0)
        ]
        
        let yearlyTotals = WorkTotals.calculateYearlyTotals(for: workDays, date: decemberDate)
        
        #expect(yearlyTotals.homeHours == 15.0) // 4 + 6 + 5 (July, Dec, Jan)
        #expect(yearlyTotals.officeHours == 9.0) // 3 + 2 + 4 (July, Dec, Jan)
        #expect(yearlyTotals.totalHours == 24.0)
    }
    
    @Test func testYearlyTotalsCalculationForJanuaryToJune() async throws {
        let calendar = Calendar.current
        
        // Test for a date in March 2025 (financial year 2024-2025)
        let marchDate = calendar.date(from: DateComponents(year: 2025, month: 3, day: 15))!
        
        let workDays = [
            // July 2024 (included in financial year 2024-2025)
            WorkDay(date: calendar.date(from: DateComponents(year: 2024, month: 7, day: 1))!, homeHours: 4.0, officeHours: 3.0),
            // December 2024 (included in financial year 2024-2025)
            WorkDay(date: calendar.date(from: DateComponents(year: 2024, month: 12, day: 1))!, homeHours: 6.0, officeHours: 2.0),
            // March 2025 (included in financial year 2024-2025)
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 3, day: 1))!, homeHours: 8.0, officeHours: 1.0),
            // July 2025 (not included in financial year 2024-2025)
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 1))!, homeHours: 5.0, officeHours: 4.0)
        ]
        
        let yearlyTotals = WorkTotals.calculateYearlyTotals(for: workDays, date: marchDate)
        
        #expect(yearlyTotals.homeHours == 18.0) // 4 + 6 + 8 (July 2024, Dec 2024, Mar 2025)
        #expect(yearlyTotals.officeHours == 6.0) // 3 + 2 + 1 (July 2024, Dec 2024, Mar 2025)
        #expect(yearlyTotals.totalHours == 24.0)
    }
    
    @Test func testEmptyWorkDays() async throws {
        let emptyWorkDays: [WorkDay] = []
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        
        let monthlyTotals = WorkTotals.calculateMonthlyTotals(for: emptyWorkDays, month: 1, year: 2025)
        let yearlyTotals = WorkTotals.calculateYearlyTotals(for: emptyWorkDays, date: testDate)
        
        #expect(monthlyTotals.homeHours == 0.0)
        #expect(monthlyTotals.officeHours == 0.0)
        #expect(monthlyTotals.totalHours == 0.0)
        
        #expect(yearlyTotals.homeHours == 0.0)
        #expect(yearlyTotals.officeHours == 0.0)
        #expect(yearlyTotals.totalHours == 0.0)
    }
} 