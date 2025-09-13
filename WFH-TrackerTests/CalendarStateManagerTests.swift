//
//  CalendarStateManagerTests.swift
//  WFH-TrackerTests
//
//  Created by Paul Ruskin on 29/6/2025.
//

import Testing
import Foundation
@testable import WFH_Tracker

struct CalendarStateManagerTests {
    
    @Test func testCalendarStateManagerInitialization() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let testStorageKey = "testInit_\(UUID().uuidString)"
        let manager = await CalendarStateManager(initialDate: testDate, storageKey: testStorageKey)

        #expect(await manager.currentMonth.month == 1)
        #expect(await manager.currentMonth.year == 2025)
        #expect(await manager.visibleMonths.count == 3)
        #expect(await manager.workDays.isEmpty == true) // no sample data generated

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }
    
    @Test func testVisibleMonthsStructure() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let testStorageKey = "testVisibleMonths_\(UUID().uuidString)"
        let manager = await CalendarStateManager(initialDate: testDate, storageKey: testStorageKey)
        
        // Should have previous, current, and next month
        let previousMonth = await manager.visibleMonths[0]
        let currentMonth = await manager.visibleMonths[1]
        let nextMonth = await manager.visibleMonths[2]
        
        #expect(previousMonth.month == 12)
        #expect(previousMonth.year == 2024)
        #expect(currentMonth.month == 1)
        #expect(currentMonth.year == 2025)
        #expect(nextMonth.month == 2)
        #expect(nextMonth.year == 2025)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }
    
    @Test func testNextMonthNavigation() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let testStorageKey = "testNextMonth_\(UUID().uuidString)"
        let manager = await CalendarStateManager(initialDate: testDate, storageKey: testStorageKey)
        
        await manager.nextMonth()
        
        #expect(await manager.currentMonth.month == 2)
        #expect(await manager.currentMonth.year == 2025)
        
        // Visible months should be updated
        let previousMonth = await manager.visibleMonths[0]
        let currentMonth = await manager.visibleMonths[1]
        let nextMonth = await manager.visibleMonths[2]
        
        #expect(previousMonth.month == 1)
        #expect(previousMonth.year == 2025)
        #expect(currentMonth.month == 2)
        #expect(currentMonth.year == 2025)
        #expect(nextMonth.month == 3)
        #expect(nextMonth.year == 2025)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }
    
    @Test func testPreviousMonthNavigation() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let testStorageKey = "testPreviousMonth_\(UUID().uuidString)"
        let manager = await CalendarStateManager(initialDate: testDate, storageKey: testStorageKey)
        
        await manager.previousMonth()
        
        #expect(await manager.currentMonth.month == 12)
        #expect(await manager.currentMonth.year == 2024)
        
        // Visible months should be updated
        let previousMonth = await manager.visibleMonths[0]
        let currentMonth = await manager.visibleMonths[1]
        let nextMonth = await manager.visibleMonths[2]
        
        #expect(previousMonth.month == 11)
        #expect(previousMonth.year == 2024)
        #expect(currentMonth.month == 12)
        #expect(currentMonth.year == 2024)
        #expect(nextMonth.month == 1)
        #expect(nextMonth.year == 2025)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }
    
    @Test func testScrollToMonth() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let testStorageKey = "testScrollToMonth_\(UUID().uuidString)"
        let manager = await CalendarStateManager(initialDate: testDate, storageKey: testStorageKey)
        
        let targetDate = calendar.date(from: DateComponents(year: 2025, month: 6, day: 1))!
        let targetMonth = CalendarMonth(date: targetDate)
        
        await manager.scrollToMonth(targetMonth)
        
        #expect(await manager.currentMonth.month == 6)
        #expect(await manager.currentMonth.year == 2025)
        
        // Visible months should be updated
        let previousMonth = await manager.visibleMonths[0]
        let currentMonth = await manager.visibleMonths[1]
        let nextMonth = await manager.visibleMonths[2]
        
        #expect(previousMonth.month == 5)
        #expect(previousMonth.year == 2025)
        #expect(currentMonth.month == 6)
        #expect(currentMonth.year == 2025)
        #expect(nextMonth.month == 7)
        #expect(nextMonth.year == 2025)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }
    
    @Test func testGetWorkDay() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let testStorageKey = "testGetWorkDay_\(UUID().uuidString)"
        let manager = await CalendarStateManager(initialDate: testDate, storageKey: testStorageKey)
        
        // Add a work day
        let workDay = WorkDay(date: testDate, homeHours: 8.0, officeHours: 2.0)
        await manager.updateWorkDay(workDay)
        
        // Test getting the work day
        let retrievedWorkDay = await manager.getWorkDay(for: testDate)
        #expect(retrievedWorkDay != nil)
        #expect(retrievedWorkDay?.homeHours == 8.0)
        #expect(retrievedWorkDay?.officeHours == 2.0)
        
        // Test getting non-existent work day
        let otherDate = calendar.date(byAdding: .day, value: 1, to: testDate) ?? testDate
        let nonExistentWorkDay = await manager.getWorkDay(for: otherDate)
        #expect(nonExistentWorkDay == nil)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }
    
    @Test func testUpdateWorkDay() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let testStorageKey = "testUpdateWorkDay_\(UUID().uuidString)"
        let manager = await CalendarStateManager(initialDate: testDate, storageKey: testStorageKey)
        
        // Add initial work day
        let initialWorkDay = WorkDay(date: testDate, homeHours: 8.0, officeHours: 2.0)
        await manager.updateWorkDay(initialWorkDay)
        
        #expect(await manager.workDays.count == 1)
        #expect(await manager.workDays.first?.homeHours == 8.0)
        
        // Update the same work day
        let updatedWorkDay = WorkDay(date: testDate, homeHours: 6.0, officeHours: 4.0)
        await manager.updateWorkDay(updatedWorkDay)
        
        #expect(await manager.workDays.count == 1) // Should not add duplicate
        #expect(await manager.workDays.first?.homeHours == 6.0)
        #expect(await manager.workDays.first?.officeHours == 4.0)
        
        // Add new work day
        let newDate = calendar.date(byAdding: .day, value: 1, to: testDate) ?? testDate
        let newWorkDay = WorkDay(date: newDate, homeHours: 7.0, officeHours: 1.0)
        await manager.updateWorkDay(newWorkDay)

        #expect(await manager.workDays.count == 2)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }
    
    @Test func testGetMonthlyTotals() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let testStorageKey = "testGetMonthlyTotals_\(UUID().uuidString)"
        let manager = await CalendarStateManager(initialDate: testDate, storageKey: testStorageKey)
        
        // Add work days for January 2025
        let workDay1 = WorkDay(date: testDate, homeHours: 8.0, officeHours: 2.0)
        let workDay2 = WorkDay(date: calendar.date(byAdding: .day, value: 1, to: testDate) ?? testDate, homeHours: 6.0, officeHours: 4.0)
        await manager.updateWorkDay(workDay1)
        await manager.updateWorkDay(workDay2)
        
        let totals = await manager.getMonthlyTotals(for: await manager.currentMonth)

        #expect(totals.homeHours == 14.0)
        #expect(totals.officeHours == 6.0)
        #expect(totals.totalHours == 20.0)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }
    
    @Test func testGetYearlyTotals() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let testStorageKey = "testGetYearlyTotals_\(UUID().uuidString)"
        let manager = await CalendarStateManager(initialDate: testDate, storageKey: testStorageKey)
        
        // Add work days for different months in 2025
        let januaryWorkDay = WorkDay(date: testDate, homeHours: 8.0, officeHours: 2.0)
        let februaryDate = calendar.date(from: DateComponents(year: 2025, month: 2, day: 15))!
        let februaryWorkDay = WorkDay(date: februaryDate, homeHours: 6.0, officeHours: 4.0)
        await manager.updateWorkDay(januaryWorkDay)
        await manager.updateWorkDay(februaryWorkDay)
        
        let totals = await manager.getYearlyTotals(for: await manager.currentMonth)

        #expect(totals.homeHours == 14.0)
        #expect(totals.officeHours == 6.0)
        #expect(totals.totalHours == 20.0)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }
    
    @Test func testYearBoundaryNavigation() async throws {
        let calendar = Calendar.current
        let decemberDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 15))!
        let testStorageKey = "testYearBoundary_\(UUID().uuidString)"
        let manager = await CalendarStateManager(initialDate: decemberDate, storageKey: testStorageKey)
        
        await manager.nextMonth()
        
        #expect(await manager.currentMonth.month == 1)
        #expect(await manager.currentMonth.year == 2025)
        
        await manager.previousMonth()

        #expect(await manager.currentMonth.month == 12)
        #expect(await manager.currentMonth.year == 2024)

        // Clean up
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }
    
    @Test func testDataPersistence() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!

        // Use a unique storage key for this test to avoid conflicts with other tests
        let testStorageKey = "testDataPersistence_\(UUID().uuidString)"

        // Create first manager and add data
        let manager1 = await CalendarStateManager(initialDate: testDate, storageKey: testStorageKey)
        let workDay = WorkDay(date: testDate, homeHours: 8.0, officeHours: 2.0)
        await manager1.updateWorkDay(workDay)

        #expect(await manager1.workDays.count == 1)
        #expect(await manager1.workDays.first?.homeHours == 8.0)

        // Add a small delay to ensure data is saved
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Create second manager (simulating app restart) and verify data is loaded
        let manager2 = await CalendarStateManager(initialDate: testDate, storageKey: testStorageKey)

        #expect(await manager2.workDays.count == 1)
        #expect(await manager2.workDays.first?.homeHours == 8.0)
        #expect(await manager2.workDays.first?.officeHours == 2.0)

        // Test clearing data
        await manager2.clearAllData()
        #expect(await manager2.workDays.isEmpty == true)

        // Add a small delay to ensure data is cleared
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify data is cleared in a new manager instance
        let manager3 = await CalendarStateManager(initialDate: testDate, storageKey: testStorageKey)
        #expect(await manager3.workDays.isEmpty == true)

        // Clean up the test data
        UserDefaults.standard.removeObject(forKey: testStorageKey)
    }
} 