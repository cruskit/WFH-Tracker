import SwiftUI

struct CompactDayEntryRow: View {
    let date: Date
    let entry: WorkDayEntry
    let defaultHours: Double
    let onWorkTypeSelected: (WorkType) -> Void
    let onAdvancedTapped: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // Day Info - Fixed width
            VStack(spacing: 1) {
                Text(DateFormatters.dayName.string(from: date))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Text(DateFormatters.dayNumber.string(from: date))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .frame(width: 40, alignment: .center)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(DateFormatters.dayName.string(from: date)) \(DateFormatters.dayNumber.string(from: date))")

            // Work Type Buttons
            HStack(spacing: 6) {
                ForEach(WorkType.allCases, id: \.self) { workType in
                    CompactWorkTypeButton(
                        workType: workType,
                        isSelected: entry.selectedWorkType == workType,
                        isActive: entry.workEntries[workType] != nil,
                        onTapped: {
                            onWorkTypeSelected(workType)
                        }
                    )
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Work type selection for \(DateFormatters.dayName.string(from: date))")

            Spacer()

            // Advanced Entry Button - Icon only
            Button(action: onAdvancedTapped) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(.blue.opacity(0.1))
                    )
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.15), value: entry.isAdvanced)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Advanced entry")
            .accessibilityHint("Opens detailed time entry for \(DateFormatters.dayName.string(from: date))")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .opacity(entry.hasData ? 0.6 : 0.2)
        )
        .animation(.easeInOut(duration: 0.2), value: entry.hasData)
    }
}

#Preview {
    VStack(spacing: 8) {
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
}