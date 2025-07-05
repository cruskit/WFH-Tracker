import SwiftUI

struct TotalsCard: View {
    let title: String
    let totals: WorkTotals
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Home:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.0fh (%dd)", totals.homeHours, Int(round(totals.homeHours / 8.0))))
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Office:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.0fh (%dd)", totals.officeHours, Int(round(totals.officeHours / 8.0))))
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        TotalsCard(
            title: "Monthly Totals",
            totals: WorkTotals(homeHours: 45.5, officeHours: 32.0)
        )
        
        TotalsCard(
            title: "Yearly Totals",
            totals: WorkTotals(homeHours: 520.0, officeHours: 380.5)
        )
    }
    .padding()
} 
