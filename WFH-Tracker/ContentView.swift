//
//  ContentView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var calendarManager = CalendarStateManager()
    
    var body: some View {
        TabView {
            LogView(calendarManager: calendarManager)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Log")
                }
            
            ExportView()
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                }
        }
    }
}

#Preview {
    ContentView()
}
