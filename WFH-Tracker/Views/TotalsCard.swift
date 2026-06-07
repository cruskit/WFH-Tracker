import SwiftUI

struct TotalsCard: View {
    let title: String
    let totals: WorkTotals
    var isWarm: Bool = false

    private let types: [WorkType] = WorkType.allCases

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 12.5, weight: .heavy))
                .foregroundStyle(.white.opacity(0.92))

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(types, id: \.self) { type in
                    let hrs = totals.hours(for: type)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(type.icon)
                            .font(.system(size: 14))
                        Text(formatHours(hrs))
                            .font(.breezeDisplay(19))
                            .foregroundStyle(.white)
                        Text("h")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(hrs > 0 ? 1.0 : 0.42)
                }
            }
            .padding(.top, 13)
        }
        .padding(16)
        .background(
            Group {
                if isWarm { LinearGradient.breezeWarmGrad }
                else { LinearGradient.breezeBrandGrad }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .if(isWarm) { $0.breezeShadowWarm() }
        .if(!isWarm) { $0.breezeShadowBrand() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(Int(totals.totalHours)) total hours")
    }

    private func formatHours(_ h: Double) -> String {
        h.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(h))" : String(format: "%.1f", h)
    }
}

// MARK: - Conditional modifier helper

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition { transform(self) } else { self }
    }
}

#Preview {
    HStack(spacing: 11) {
        TotalsCard(
            title: "January hours",
            totals: WorkTotals(homeHours: 74, officeHours: 54, holidayHours: 16, sickHours: 8)
        )
        TotalsCard(
            title: "FY 2024–25 hours",
            totals: WorkTotals(homeHours: 74, officeHours: 54, holidayHours: 16, sickHours: 8),
            isWarm: true
        )
    }
    .padding(16)
    .background(Color.breezeBackground)
}
