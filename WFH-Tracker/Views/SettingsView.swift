//
//  SettingsView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("App settings and preferences will be displayed here")
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
    SettingsView()
} 