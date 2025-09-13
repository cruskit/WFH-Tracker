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
        let totals = WorkTotals(homeHours: 45.5, officeHours: 32.0, holidayHours: 16.0, sickHours: 8.0)

        #expect(totals.homeHours == 45.5)
        #expect(totals.officeHours == 32.0)
        #expect(totals.holidayHours == 16.0)
        #expect(totals.sickHours == 8.0)
        #expect(totals.totalHours == 101.5)
    }
    
    @Test func testWorkTotalsDefaultInitialization() async throws {
        let totals = WorkTotals()

        #expect(totals.homeHours == 0.0)
        #expect(totals.officeHours == 0.0)
        #expect(totals.holidayHours == 0.0)
        #expect(totals.sickHours == 0.0)
        #expect(totals.totalHours == 0.0)
    }
    
    @Test func testMonthlyTotalsCalculation() async throws {
        let calendar = Calendar.current
        
        // Create work days for January 2025
        let januaryWorkDays = [
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!, workEntries: [.home: 4.0, .office: 3.0]),
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 1, day: 2))!, workEntries: [.home: 6.0, .office: 2.0]),
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 1, day: 3))!, workEntries: [.home: 8.0]),
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 1, day: 4))!, workEntries: [.holiday: 8.0]),
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 1, day: 5))!, workEntries: [.sick: 4.0]),
            // February day should not be included
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 2, day: 1))!, workEntries: [.home: 5.0, .office: 5.0])
        ]

        let monthlyTotals = WorkTotals.calculateMonthlyTotals(for: januaryWorkDays, month: 1, year: 2025)

        #expect(monthlyTotals.homeHours == 18.0) // 4 + 6 + 8
        #expect(monthlyTotals.officeHours == 5.0) // 3 + 2 + 0
        #expect(monthlyTotals.holidayHours == 8.0) // 8
        #expect(monthlyTotals.sickHours == 4.0) // 4
        #expect(monthlyTotals.totalHours == 35.0)
    }
    
    @Test func testYearlyTotalsCalculationForJulyToDecember() async throws {
        let calendar = Calendar.current
        
        // Test for a date in December 2025 (financial year 2025-2026)
        let decemberDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 15))!
        
        let workDays = [
            // July 2025 (included in financial year 2025-2026)
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 1))!, workEntries: [.home: 4.0, .office: 3.0]),
            // December 2025 (included in financial year 2025-2026)
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!, workEntries: [.home: 6.0, .office: 2.0]),
            // June 2025 (not included in financial year 2025-2026)
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 1))!, workEntries: [.home: 8.0, .office: 1.0]),
            // January 2026 (included in financial year 2025-2026)
            WorkDay(date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!, workEntries: [.home: 5.0, .office: 4.0, .holiday: 2.0])
        ]

        let yearlyTotals = WorkTotals.calculateYearlyTotals(for: workDays, date: decemberDate)

        #expect(yearlyTotals.homeHours == 15.0) // 4 + 6 + 5 (July, Dec, Jan)
        #expect(yearlyTotals.officeHours == 9.0) // 3 + 2 + 4 (July, Dec, Jan)
        #expect(yearlyTotals.holidayHours == 2.0) // 2 (Jan)
        #expect(yearlyTotals.sickHours == 0.0)
        #expect(yearlyTotals.totalHours == 26.0)
    }
    
    @Test func testYearlyTotalsCalculationForJanuaryToJune() async throws {
        let calendar = Calendar.current
        
        // Test for a date in March 2025 (financial year 2024-2025)
        let marchDate = calendar.date(from: DateComponents(year: 2025, month: 3, day: 15))!
        
        let workDays = [
            // July 2024 (included in financial year 2024-2025)
            WorkDay(date: calendar.date(from: DateComponents(year: 2024, month: 7, day: 1))!, workEntries: [.home: 4.0, .office: 3.0]),
            // December 2024 (included in financial year 2024-2025)
            WorkDay(date: calendar.date(from: DateComponents(year: 2024, month: 12, day: 1))!, workEntries: [.home: 6.0, .office: 2.0, .sick: 1.0]),
            // March 2025 (included in financial year 2024-2025)
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 3, day: 1))!, workEntries: [.home: 8.0, .office: 1.0]),
            // July 2025 (not included in financial year 2024-2025)
            WorkDay(date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 1))!, workEntries: [.home: 5.0, .office: 4.0])
        ]

        let yearlyTotals = WorkTotals.calculateYearlyTotals(for: workDays, date: marchDate)

        #expect(yearlyTotals.homeHours == 18.0) // 4 + 6 + 8 (July 2024, Dec 2024, Mar 2025)
        #expect(yearlyTotals.officeHours == 6.0) // 3 + 2 + 1 (July 2024, Dec 2024, Mar 2025)
        #expect(yearlyTotals.holidayHours == 0.0)
        #expect(yearlyTotals.sickHours == 1.0) // 1 (Dec 2024)
        #expect(yearlyTotals.totalHours == 25.0)
    }
    
    @Test func testEmptyWorkDays() async throws {
        let emptyWorkDays: [WorkDay] = []
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!

        let monthlyTotals = WorkTotals.calculateMonthlyTotals(for: emptyWorkDays, month: 1, year: 2025)
        let yearlyTotals = WorkTotals.calculateYearlyTotals(for: emptyWorkDays, date: testDate)

        #expect(monthlyTotals.homeHours == 0.0)
        #expect(monthlyTotals.officeHours == 0.0)
        #expect(monthlyTotals.holidayHours == 0.0)
        #expect(monthlyTotals.sickHours == 0.0)
        #expect(monthlyTotals.totalHours == 0.0)

        #expect(yearlyTotals.homeHours == 0.0)
        #expect(yearlyTotals.officeHours == 0.0)
        #expect(yearlyTotals.holidayHours == 0.0)
        #expect(yearlyTotals.sickHours == 0.0)
        #expect(yearlyTotals.totalHours == 0.0)
    }

    // MARK: - New WorkTotals Tests

    @Test func testWorkHoursAndLeaveHours() async throws {
        let totals = WorkTotals(homeHours: 40.0, officeHours: 20.0, holidayHours: 16.0, sickHours: 8.0)

        #expect(totals.workHours == 60.0) // home + office
        #expect(totals.leaveHours == 24.0) // holiday + sick
        #expect(totals.totalHours == 84.0) // all
    }

    @Test func testHoursForWorkType() async throws {
        let totals = WorkTotals(homeHours: 40.0, officeHours: 20.0, holidayHours: 16.0, sickHours: 8.0)

        #expect(totals.hours(for: .home) == 40.0)
        #expect(totals.hours(for: .office) == 20.0)
        #expect(totals.hours(for: .holiday) == 16.0)
        #expect(totals.hours(for: .sick) == 8.0)
    }
    

} 