import SwiftUI

struct CompactDayEntryRow: View {
    let date: Date
    let entry: WorkDayEntry
    let defaultHours: Double
    let onWorkTypeSelected: (WorkType) -> Void
    let onAdvancedTapped: () -> Void

    private let calendar = Calendar.current

    private var isToday: Bool { calendar.isDateInToday(date) }

    var body: some View {
        HStack(spacing: 10) {
            // Date badge
            VStack(spacing: 1) {
                Text(DateFormatters.dayNumber.string(from: date))
                    .font(.breezeDisplay(17))
                    .foregroundStyle(Color.breezeInk)
                    .lineLimit(1)

                Text(DateFormatters.dayName.string(from: date).uppercased())
                    .font(.system(size: 10.5, weight: .heavy))
                    .foregroundStyle(Color.breezeInkFaint)
            }
            .frame(width: 38, alignment: .center)

            // Work-type buttons
            HStack(spacing: 7) {
                ForEach(WorkType.allCases, id: \.self) { workType in
                    CompactWorkTypeButton(
                        workType: workType,
                        isSelected: entry.selectedWorkType == workType,
                        isActive: entry.workEntries[workType] != nil,
                        onTapped: { onWorkTypeSelected(workType) }
                    )
                }
            }

            // Advanced entry button
            Button(action: onAdvancedTapped) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.breezeBrandInk)
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(Color.breezeBrandSoft)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Advanced entry")
            .accessibilityHint("Split hours across types for \(DateFormatters.dayName.string(from: date))")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.breezeSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(isToday ? Color.breezeBrand : Color.breezeLine, lineWidth: isToday ? 2 : 1)
                )
        )
        .breezeShadowSm()
        .animation(.easeInOut(duration: 0.2), value: entry.hasData)
    }
}

#Preview {
    VStack(spacing: 9) {
        CompactDayEntryRow(
            date: Date(),
            entry: WorkDayEntry(selectedWorkType: .home, workEntries: [.home: 8.0]),
            defaultHours: 8.0,
            onWorkTypeSelected: { _ in },
            onAdvancedTapped: {}
        )
        CompactDayEntryRow(
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            entry: WorkDayEntry(),
            defaultHours: 8.0,
            onWorkTypeSelected: { _ in },
            onAdvancedTapped: {}
        )
    }
    .padding()
    .background(Color.breezeBackground)
}
