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
        let manager = await CalendarStateManager(initialDate: testDate)
        
        // Wait for isLoading to become false
        while await manager.isLoading {
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms
        }
        
        #expect(await manager.currentMonth.month == 1)
        #expect(await manager.currentMonth.year == 2025)
        #expect(await manager.visibleMonths.count == 3)
        #expect(await manager.workDays.isEmpty == false) // sample data is generated
        #expect(await manager.isLoading == false)
    }
    
    @Test func testVisibleMonthsStructure() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let manager = await CalendarStateManager(initialDate: testDate)
        
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
    }
    
    @Test func testNextMonthNavigation() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let manager = await CalendarStateManager(initialDate: testDate)
        
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
    }
    
    @Test func testPreviousMonthNavigation() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let manager = await CalendarStateManager(initialDate: testDate)
        
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
    }
    
    @Test func testScrollToMonth() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let manager = await CalendarStateManager(initialDate: testDate)
        
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
    }
    
    @Test func testGetWorkDay() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let manager = await CalendarStateManager(initialDate: testDate)
        
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
    }
    
    @Test func testUpdateWorkDay() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let manager = await CalendarStateManager(initialDate: testDate)
        
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
    }
    
    @Test func testGetMonthlyTotals() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let manager = await CalendarStateManager(initialDate: testDate)
        
        // Add work days for January 2025
        let workDay1 = WorkDay(date: testDate, homeHours: 8.0, officeHours: 2.0)
        let workDay2 = WorkDay(date: calendar.date(byAdding: .day, value: 1, to: testDate) ?? testDate, homeHours: 6.0, officeHours: 4.0)
        await manager.updateWorkDay(workDay1)
        await manager.updateWorkDay(workDay2)
        
        let totals = await manager.getMonthlyTotals(for: await manager.currentMonth)
        
        #expect(totals.homeHours == 14.0)
        #expect(totals.officeHours == 6.0)
        #expect(totals.totalHours == 20.0)
    }
    
    @Test func testGetYearlyTotals() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let manager = await CalendarStateManager(initialDate: testDate)
        
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
    }
    
    @Test func testYearBoundaryNavigation() async throws {
        let calendar = Calendar.current
        let decemberDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 15))!
        let manager = await CalendarStateManager(initialDate: decemberDate)
        
        await manager.nextMonth()
        
        #expect(await manager.currentMonth.month == 1)
        #expect(await manager.currentMonth.year == 2025)
        
        await manager.previousMonth()
        
        #expect(await manager.currentMonth.month == 12)
        #expect(await manager.currentMonth.year == 2024)
    }
} 