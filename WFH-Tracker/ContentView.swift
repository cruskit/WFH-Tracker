//
//  ContentView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LogView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Log")
                }
            
            TrendsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Trends")
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
