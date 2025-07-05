//
//  WorkHoursEntryViewTests.swift
//  WFH-TrackerTests
//
//  Created by Paul Ruskin on 29/6/2025.
//

import Testing
import SwiftUI
@testable import WFH_Tracker

struct WorkHoursEntryViewTests {
    
    @Test func testWorkHoursEntryViewInitialization() async throws {
        let testDate = Date()
        let testWorkDay = WorkDay(date: testDate, homeHours: 6.5, officeHours: 2.0)
        
        // Test that the view can be created with existing data
        let view = WorkHoursEntryView(
            date: testDate,
            existingWorkDay: testWorkDay,
            onSave: { _ in },
            onCancel: { }
        )
        
        #expect(view != nil)
    }
    
    @Test func testWorkHoursEntryViewWithNoExistingData() async throws {
        let testDate = Date()
        
        // Test that the view can be created without existing data
        let view = WorkHoursEntryView(
            date: testDate,
            existingWorkDay: nil,
            onSave: { _ in },
            onCancel: { }
        )
        
        #expect(view != nil)
    }
    
    @Test func testWorkDayCreationWithValidHours() async throws {
        let testDate = Date()
        let homeHours = 6.5
        let officeHours = 2.0
        
        let workDay = WorkDay(
            date: testDate,
            homeHours: homeHours,
            officeHours: officeHours
        )
        
        #expect(workDay.homeHours == homeHours)
        #expect(workDay.officeHours == officeHours)
        #expect(workDay.totalHours == 8.5)
        #expect(workDay.hasData == true)
    }
    
    @Test func testWorkDayCreationWithNilHours() async throws {
        let testDate = Date()
        
        let workDay = WorkDay(
            date: testDate,
            homeHours: nil,
            officeHours: nil
        )
        
        #expect(workDay.homeHours == nil)
        #expect(workDay.officeHours == nil)
        #expect(workDay.totalHours == 0.0)
        #expect(workDay.hasData == false)
    }
    
    @Test func testWorkDayCreationWithPartialHours() async throws {
        let testDate = Date()
        
        // Only home hours
        let homeOnlyWorkDay = WorkDay(
            date: testDate,
            homeHours: 8.0,
            officeHours: nil
        )
        
        #expect(homeOnlyWorkDay.homeHours == 8.0)
        #expect(homeOnlyWorkDay.officeHours == nil)
        #expect(homeOnlyWorkDay.totalHours == 8.0)
        #expect(homeOnlyWorkDay.hasData == true)
        
        // Only office hours
        let officeOnlyWorkDay = WorkDay(
            date: testDate,
            homeHours: nil,
            officeHours: 6.5
        )
        
        #expect(officeOnlyWorkDay.homeHours == nil)
        #expect(officeOnlyWorkDay.officeHours == 6.5)
        #expect(officeOnlyWorkDay.totalHours == 6.5)
        #expect(officeOnlyWorkDay.hasData == true)
    }
}

// Note: For more comprehensive UI testing, we would use SwiftUI's ViewInspector
// or create UI tests using XCUITest framework to test the actual user interactions 