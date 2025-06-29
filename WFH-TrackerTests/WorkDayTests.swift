//
//  WorkDayTests.swift
//  WFH-TrackerTests
//
//  Created by Paul Ruskin on 29/6/2025.
//

import Testing
import Foundation
@testable import WFH_Tracker

struct WorkDayTests {
    
    @Test func testWorkDayInitialization() async throws {
        let date = Date()
        let workDay = WorkDay(date: date, homeHours: 4.5, officeHours: 3.0)
        
        #expect(workDay.date == date)
        #expect(workDay.homeHours == 4.5)
        #expect(workDay.officeHours == 3.0)
    }
    
    @Test func testWorkDayWithNilHours() async throws {
        let date = Date()
        let workDay = WorkDay(date: date)
        
        #expect(workDay.homeHours == nil)
        #expect(workDay.officeHours == nil)
        #expect(workDay.hasData == false)
    }
    
    @Test func testTotalHoursCalculation() async throws {
        let workDay1 = WorkDay(date: Date(), homeHours: 4.5, officeHours: 3.0)
        #expect(workDay1.totalHours == 7.5)
        
        let workDay2 = WorkDay(date: Date(), homeHours: 8.0, officeHours: nil)
        #expect(workDay2.totalHours == 8.0)
        
        let workDay3 = WorkDay(date: Date(), homeHours: nil, officeHours: 6.5)
        #expect(workDay3.totalHours == 6.5)
        
        let workDay4 = WorkDay(date: Date())
        #expect(workDay4.totalHours == 0.0)
    }
    
    @Test func testHasDataProperty() async throws {
        let workDay1 = WorkDay(date: Date(), homeHours: 4.5, officeHours: 3.0)
        #expect(workDay1.hasData == true)
        
        let workDay2 = WorkDay(date: Date(), homeHours: 8.0, officeHours: nil)
        #expect(workDay2.hasData == true)
        
        let workDay3 = WorkDay(date: Date(), homeHours: nil, officeHours: 6.5)
        #expect(workDay3.hasData == true)
        
        let workDay4 = WorkDay(date: Date())
        #expect(workDay4.hasData == false)
    }
    
    @Test func testDateComponents() async throws {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let workDay = WorkDay(date: date)
        
        #expect(workDay.dayNumber == 15)
        #expect(workDay.month == 1)
        #expect(workDay.year == 2025)
    }
    
    @Test func testDayOfWeek() async throws {
        let calendar = Calendar.current
        // January 15, 2025 is a Wednesday (weekday 4)
        let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let workDay = WorkDay(date: date)
        
        #expect(workDay.dayOfWeek == 4)
    }
} 