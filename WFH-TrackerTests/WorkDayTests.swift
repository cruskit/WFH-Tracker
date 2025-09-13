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

        // Test with new work types
        let workDay5 = WorkDay(date: Date(), workEntries: [.holiday: 8.0])
        #expect(workDay5.hasData == true)

        let workDay6 = WorkDay(date: Date(), workEntries: [:])
        #expect(workDay6.hasData == false)
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

    // MARK: - New WorkEntry Tests

    @Test func testWorkEntriesInitialization() async throws {
        let date = Date()
        let workEntries: [WorkType: Double] = [.home: 6.0, .holiday: 2.0]
        let workDay = WorkDay(date: date, workEntries: workEntries)

        #expect(workDay.workEntries[.home] == 6.0)
        #expect(workDay.workEntries[.holiday] == 2.0)
        #expect(workDay.workEntries[.office] == nil)
        #expect(workDay.workEntries[.sick] == nil)
    }

    @Test func testLegacyCompatibility() async throws {
        let date = Date()
        let workDay = WorkDay(date: date, homeHours: 4.0, officeHours: 4.0)

        // Test legacy properties work
        #expect(workDay.homeHours == 4.0)
        #expect(workDay.officeHours == 4.0)
        #expect(workDay.holidayHours == nil)
        #expect(workDay.sickHours == nil)

        // Test new properties work
        #expect(workDay.workEntries[.home] == 4.0)
        #expect(workDay.workEntries[.office] == 4.0)
        #expect(workDay.workEntries[.holiday] == nil)
        #expect(workDay.workEntries[.sick] == nil)
    }

    @Test func testAdvancedEntryDetection() async throws {
        let date = Date()

        // Single work type - not advanced
        let singleType = WorkDay(date: date, workEntries: [.home: 8.0])
        #expect(singleType.isAdvancedEntry == false)

        // Multiple work types - is advanced
        let multipleTypes = WorkDay(date: date, workEntries: [.home: 4.0, .office: 4.0])
        #expect(multipleTypes.isAdvancedEntry == true)

        // No work types - not advanced
        let noTypes = WorkDay(date: date, workEntries: [:])
        #expect(noTypes.isAdvancedEntry == false)
    }

    @Test func testActiveWorkTypes() async throws {
        let date = Date()
        let workDay = WorkDay(date: date, workEntries: [.home: 4.0, .sick: 2.0, .office: 2.0])

        let activeTypes = workDay.activeWorkTypes
        #expect(activeTypes.count == 3)
        #expect(activeTypes.contains(.home))
        #expect(activeTypes.contains(.office))
        #expect(activeTypes.contains(.sick))
        #expect(!activeTypes.contains(.holiday))
    }

    @Test func testHoursForWorkType() async throws {
        let date = Date()
        let workDay = WorkDay(date: date, workEntries: [.home: 6.0, .holiday: 2.0])

        #expect(workDay.hours(for: .home) == 6.0)
        #expect(workDay.hours(for: .holiday) == 2.0)
        #expect(workDay.hours(for: .office) == 0.0)
        #expect(workDay.hours(for: .sick) == 0.0)
    }

    @Test func testTotalHoursWithAllWorkTypes() async throws {
        let date = Date()
        let workDay = WorkDay(date: date, workEntries: [
            .home: 2.0,
            .office: 3.0,
            .holiday: 1.5,
            .sick: 1.5
        ])

        #expect(workDay.totalHours == 8.0)
    }

    @Test func testLegacyPropertySetters() async throws {
        let date = Date()
        var workDay = WorkDay(date: date)

        // Test setting legacy properties updates workEntries
        workDay.homeHours = 4.0
        workDay.officeHours = 3.0
        workDay.holidayHours = 1.0

        #expect(workDay.workEntries[.home] == 4.0)
        #expect(workDay.workEntries[.office] == 3.0)
        #expect(workDay.workEntries[.holiday] == 1.0)

        // Test setting to nil removes entry
        workDay.homeHours = nil
        #expect(workDay.workEntries[.home] == nil)
        #expect(workDay.homeHours == nil)
    }
} 