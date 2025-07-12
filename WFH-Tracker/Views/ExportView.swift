//
//  ExportView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI

struct ExportView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Export")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Export your work hours data to various formats")
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
    ExportView()
} 