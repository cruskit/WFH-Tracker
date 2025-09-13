//
//  WorkTypeTests.swift
//  WFH-TrackerTests
//
//  Created by Paul Ruskin on 29/6/2025.
//

import Testing
import Foundation
import SwiftUI
@testable import WFH_Tracker

struct WorkTypeTests {

    @Test func testWorkTypeAllCases() async throws {
        let allTypes = WorkType.allCases

        #expect(allTypes.count == 4)
        #expect(allTypes.contains(.home))
        #expect(allTypes.contains(.office))
        #expect(allTypes.contains(.holiday))
        #expect(allTypes.contains(.sick))
    }

    @Test func testWorkTypeIcons() async throws {
        #expect(WorkType.home.icon == "🏠")
        #expect(WorkType.office.icon == "🏢")
        #expect(WorkType.holiday.icon == "🏖️")
        #expect(WorkType.sick.icon == "🤒")
    }

    @Test func testWorkTypeDisplayNames() async throws {
        #expect(WorkType.home.displayName == "Home")
        #expect(WorkType.office.displayName == "Office")
        #expect(WorkType.holiday.displayName == "Holiday")
        #expect(WorkType.sick.displayName == "Sick")
    }

    @Test func testWorkTypeColors() async throws {
        #expect(WorkType.home.color == .blue)
        #expect(WorkType.office.color == .green)
        #expect(WorkType.holiday.color == .orange)
        #expect(WorkType.sick.color == .red)
    }

    @Test func testWorkTypeBackgroundColors() async throws {
        #expect(WorkType.home.backgroundColor == .blue.opacity(0.1))
        #expect(WorkType.office.backgroundColor == .green.opacity(0.1))
        #expect(WorkType.holiday.backgroundColor == .orange.opacity(0.1))
        #expect(WorkType.sick.backgroundColor == .red.opacity(0.1))
    }

    @Test func testWorkTypeCodable() async throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // Test encoding and decoding each work type
        for workType in WorkType.allCases {
            let encodedData = try encoder.encode(workType)
            let decodedWorkType = try decoder.decode(WorkType.self, from: encodedData)

            #expect(decodedWorkType == workType)
        }
    }

    @Test func testWorkTypeRawValues() async throws {
        #expect(WorkType.home.rawValue == "home")
        #expect(WorkType.office.rawValue == "office")
        #expect(WorkType.holiday.rawValue == "holiday")
        #expect(WorkType.sick.rawValue == "sick")
    }
}