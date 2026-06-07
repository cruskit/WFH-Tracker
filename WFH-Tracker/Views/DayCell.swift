import SwiftUI

struct DayCell: View {
    let date: Date
    let workDay: WorkDay?
    let isCurrentMonth: Bool
    let displayWeekends: Bool
    let onTap: () -> Void

    private let calendar = Calendar.current

    private var dayNumber: Int {
        calendar.component(.day, from: date)
    }

    private var isToday: Bool {
        calendar.isDateInToday(date)
    }

    private var activeTypes: [WorkType] {
        workDay?.activeWorkTypes ?? []
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topLeading) {
                cellBackground

                // Day number
                Text("\(dayNumber)")
                    .font(.breezeDisplay(11))
                    .foregroundStyle(numberColor)
                    .padding(.horizontal, 6)
                    .padding(.top, 5)

                // Centred emoji content
                emojiContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 8)
            }
            .aspectRatio(CGSize(width: 1, height: 1.04), contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: isToday ? 2.5 : 1.5)
            )
            .opacity(isCurrentMonth ? 1.0 : 0.32)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var cellBackground: some View {
        switch activeTypes.count {
        case 0:
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.breezeSurfaceSoft)
        case 1:
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(activeTypes[0].softColor)
        default:
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.breezeSurface)
        }
    }

    @ViewBuilder
    private var emojiContent: some View {
        if activeTypes.count == 1 {
            Text(activeTypes[0].icon)
                .font(.system(size: 26))
        } else if activeTypes.count > 1 {
            HStack(spacing: 1) {
                ForEach(activeTypes, id: \.self) { type in
                    Text(type.icon)
                        .font(.system(size: 17))
                }
            }
        }
    }

    // MARK: - Computed colours

    private var borderColor: Color {
        if isToday { return .breezeBrand }
        if activeTypes.count == 1 { return activeTypes[0].color }
        return .breezeLine
    }

    private var numberColor: Color {
        if activeTypes.count == 1 { return activeTypes[0].inkColor }
        return .breezeInkFaint
    }

    private var accessibilityLabel: String {
        guard !activeTypes.isEmpty else { return "\(dayNumber)" }
        return "\(dayNumber): \(activeTypes.map(\.displayName).joined(separator: " and "))"
    }
}

#Preview {
    HStack(spacing: 7) {
        DayCell(date: Date(), workDay: nil, isCurrentMonth: true, displayWeekends: true, onTap: {})
        DayCell(date: Date(), workDay: WorkDay(date: Date(), workEntries: [.home: 8]), isCurrentMonth: true, displayWeekends: true, onTap: {})
        DayCell(date: Date(), workDay: WorkDay(date: Date(), workEntries: [.office: 8]), isCurrentMonth: true, displayWeekends: true, onTap: {})
        DayCell(date: Date(), workDay: WorkDay(date: Date(), workEntries: [.home: 4, .office: 4]), isCurrentMonth: true, displayWeekends: true, onTap: {})
        DayCell(date: Date(), workDay: nil, isCurrentMonth: false, displayWeekends: true, onTap: {})
    }
    .padding()
    .background(Color.breezeBackground)
}
