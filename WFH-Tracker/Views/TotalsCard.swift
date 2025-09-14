import SwiftUI
import OSLog

struct TotalsCard: View {
    let title: String
    let totals: WorkTotals
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
            
            VStack(spacing: 8) {
                totalsRow("Home", hours: totals.homeHours, color: .blue)

                totalsRow("Office", hours: totals.officeHours, color: .green)

                totalsRow("Holiday", hours: totals.holidayHours, color: .orange)

                totalsRow("Sick", hours: totals.sickHours, color: .red)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title) work summary")
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func totalsRow(_ label: String, hours: Double, color: Color) -> some View {
        HStack {
            Text("\(label):")
                .foregroundStyle(.secondary)

            Spacer()

            if hours > 0 {
                Text("\(Int(round(hours / 8.0)))d")
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                + Text(" (\(String(format: "%.0fh", hours)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("0d (0h)")
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(Int(round(hours / 8.0))) days, \(Int(hours)) hours")
    }
}

#Preview {
    VStack(spacing: 16) {
        TotalsCard(
            title: "Monthly Totals",
            totals: WorkTotals(homeHours: 45.5, officeHours: 32.0, holidayHours: 16.0, sickHours: 8.0)
        )

        TotalsCard(
            title: "Yearly Totals",
            totals: WorkTotals(homeHours: 520.0, officeHours: 380.5, holidayHours: 120.0, sickHours: 40.0)
        )
    }
    .padding()
} 
