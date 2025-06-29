//
//  CalendarMonthTests.swift
//  WFH-TrackerTests
//
//  Created by Paul Ruskin on 29/6/2025.
//

import Testing
import Foundation
@testable import WFH_Tracker

struct CalendarMonthTests {
    
    @Test func testCalendarMonthInitialization() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let calendarMonth = CalendarMonth(date: testDate)
        
        #expect(calendarMonth.month == 1)
        #expect(calendarMonth.year == 2025)
    }
    
    @Test func testMonthNameFormatting() async throws {
        let calendar = Calendar.current
        let januaryDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let januaryMonth = CalendarMonth(date: januaryDate)
        
        #expect(januaryMonth.monthName == "January 2025")
        
        let decemberDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 15))!
        let decemberMonth = CalendarMonth(date: decemberDate)
        
        #expect(decemberMonth.monthName == "December 2024")
    }
    
    @Test func testWeeksGeneration() async throws {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let calendarMonth = CalendarMonth(date: testDate)
        
        let weeks = calendarMonth.weeks
        
        // Should generate 6 weeks (42 days) to ensure full month coverage
        #expect(weeks.count == 6)
        
        // Each week should have 7 days
        for week in weeks {
            #expect(week.count == 7)
        }
        
        // First week should start with the calendar's first day of the week
        let firstWeek = weeks[0]
        let firstDayOfWeek = calendar.component(.weekday, from: firstWeek[0])
        let expectedFirstDay = calendar.firstWeekday
        #expect(firstDayOfWeek == expectedFirstDay)
    }
    
    @Test func testNextMonthNavigation() async throws {
        let calendar = Calendar.current
        let januaryDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let januaryMonth = CalendarMonth(date: januaryDate)
        
        let februaryMonth = januaryMonth.nextMonth()
        
        #expect(februaryMonth.month == 2)
        #expect(februaryMonth.year == 2025)
        #expect(februaryMonth.monthName == "February 2025")
    }
    
    @Test func testPreviousMonthNavigation() async throws {
        let calendar = Calendar.current
        let januaryDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let januaryMonth = CalendarMonth(date: januaryDate)
        
        let decemberMonth = januaryMonth.previousMonth()
        
        #expect(decemberMonth.month == 12)
        #expect(decemberMonth.year == 2024)
        #expect(decemberMonth.monthName == "December 2024")
    }
    
    @Test func testYearBoundaryNavigation() async throws {
        let calendar = Calendar.current
        let decemberDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 15))!
        let decemberMonth = CalendarMonth(date: decemberDate)
        
        let nextMonth = decemberMonth.nextMonth()
        #expect(nextMonth.month == 1)
        #expect(nextMonth.year == 2025)
        
        let januaryDate2 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let januaryMonth2 = CalendarMonth(date: januaryDate2)
        
        let previousMonth = januaryMonth2.previousMonth()
        #expect(previousMonth.month == 12)
        #expect(previousMonth.year == 2024)
    }
    
    @Test func testIsDateInCurrentMonth() async throws {
        let calendar = Calendar.current
        let januaryDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let calendarMonth = CalendarMonth(date: januaryDate)
        
        // Date in same month
        let sameMonthDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 20))!
        #expect(calendarMonth.isDateInCurrentMonth(sameMonthDate) == true)
        
        // Date in different month
        let differentMonthDate = calendar.date(from: DateComponents(year: 2025, month: 2, day: 15))!
        #expect(calendarMonth.isDateInCurrentMonth(differentMonthDate) == false)
        
        // Date in different year
        let differentYearDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 15))!
        #expect(calendarMonth.isDateInCurrentMonth(differentYearDate) == false)
    }
    
    @Test func testDefaultInitialization() async throws {
        let calendarMonth = CalendarMonth()
        let currentDate = Date()
        let calendar = Calendar.current
        
        #expect(calendarMonth.month == calendar.component(.month, from: currentDate))
        #expect(calendarMonth.year == calendar.component(.year, from: currentDate))
    }
} 