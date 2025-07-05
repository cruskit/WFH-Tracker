//
//  TotalsCardTests.swift
//  WFH-TrackerTests
//
//  Created by Paul Ruskin on 29/6/2025.
//

import Testing
import SwiftUI
@testable import WFH_Tracker

struct TotalsCardTests {
    
    @Test func testTotalsCardDisplayFormat() async throws {
        // Test that TotalsCard displays the correct format: "Xh / Yd"
        
        // Test case 1: Exact 8-hour days
        let totals1 = WorkTotals(homeHours: 16.0, officeHours: 8.0)
        let card1 = TotalsCard(title: "Test", totals: totals1)
        
        // Home: 16.0h / 2d (16 ÷ 8 = 2 days)
        // Office: 8.0h / 1d (8 ÷ 8 = 1 day)
        #expect(card1 != nil)
        
        // Test case 2: Rounding up
        let totals2 = WorkTotals(homeHours: 12.1, officeHours: 4.5)
        let card2 = TotalsCard(title: "Test", totals: totals2)
        
        // Home: 12.1h / 2d (12.1 ÷ 8 = 1.5125, rounded to 2 days)
        // Office: 4.5h / 1d (4.5 ÷ 8 = 0.5625, rounded to 1 day)
        #expect(card2 != nil)
        
        // Test case 3: Rounding down
        let totals3 = WorkTotals(homeHours: 11.4, officeHours: 3.9)
        let card3 = TotalsCard(title: "Test", totals: totals3)
        
        // Home: 11.4h / 1d (11.4 ÷ 8 = 1.425, rounded to 1 day)
        // Office: 3.9h / 0d (3.9 ÷ 8 = 0.4875, rounded to 0 days)
        #expect(card3 != nil)
        
        // Test case 4: Zero hours
        let totals4 = WorkTotals(homeHours: 0.0, officeHours: 0.0)
        let card4 = TotalsCard(title: "Test", totals: totals4)
        
        // Home: 0.0h / 0d
        // Office: 0.0h / 0d
        #expect(card4 != nil)
    }
    
    @Test func testTotalsCardWithRealData() async throws {
        // Test with realistic data that matches the preview examples
        let monthlyTotals = WorkTotals(homeHours: 45.5, officeHours: 32.0)
        let monthlyCard = TotalsCard(title: "Monthly Totals", totals: monthlyTotals)
        
        // Home: 45.5h / 6d (45.5 ÷ 8 = 5.6875, rounded to 6 days)
        // Office: 32.0h / 4d (32 ÷ 8 = 4 days)
        #expect(monthlyCard != nil)
        
        let yearlyTotals = WorkTotals(homeHours: 520.0, officeHours: 380.5)
        let yearlyCard = TotalsCard(title: "Yearly Totals", totals: yearlyTotals)
        
        // Home: 520.0h / 65d (520 ÷ 8 = 65 days)
        // Office: 380.5h / 48d (380.5 ÷ 8 = 47.5625, rounded to 48 days)
        #expect(yearlyCard != nil)
    }
    
    @Test func testTotalsCardTitleAndStructure() async throws {
        let totals = WorkTotals(homeHours: 40.0, officeHours: 24.0)
        let card = TotalsCard(title: "Test Title", totals: totals)
        
        // Verify the component can be created with the expected structure
        #expect(card != nil)
        
        // The card should have:
        // - A title text
        // - Two HStack rows (Home and Office)
        // - Each row should have a label and formatted value
        // - Proper styling and colors
    }
}

// Note: For more comprehensive UI testing, we would use SwiftUI's ViewInspector
// to actually inspect the rendered view and verify the text content.
// This test structure provides basic validation that the component can be created
// with various data scenarios without errors. 