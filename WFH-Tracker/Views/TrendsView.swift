//
//  TrendsView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI

struct TrendsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Trends")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Work hours trends and analytics will be displayed here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    TrendsView()
} 