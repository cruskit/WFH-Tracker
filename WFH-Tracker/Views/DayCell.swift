import SwiftUI

struct DayCell: View {
    let date: Date
    let workDay: WorkDay?
    let isCurrentMonth: Bool
    let displayWeekends: Bool
    let onTap: () -> Void

    private let calendar = Calendar.current

    private var cellWidth: CGFloat {
        displayWeekends ? 50 : 70
    }

    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                // Date header (always at the top)
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isToday ? .bold : .medium))
                    .foregroundColor(isToday ? .white : (isCurrentMonth ? .primary : .secondary))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isToday ? Color.blue : Color.clear)
                    )
                
                // Work type icons (if any)
                if let workDay = workDay, workDay.hasData {
                    WorkTypeIconsView(
                        workTypes: workDay.activeWorkTypes,
                        cellWidth: cellWidth
                    )
                }
                Spacer() // Always push content to the top
            }
            .frame(width: cellWidth, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .opacity(workDay?.hasData == true ? 0.3 : 0.1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}

#Preview {
    HStack {
        DayCell(
            date: Date(),
            workDay: WorkDay(date: Date(), homeHours: 4.5, officeHours: 3.0),
            isCurrentMonth: true,
            displayWeekends: true,
            onTap: {}
        )

        DayCell(
            date: Date(),
            workDay: WorkDay(date: Date(), homeHours: 8.0, officeHours: 0.0),
            isCurrentMonth: true,
            displayWeekends: true,
            onTap: {}
        )

        DayCell(
            date: Date(),
            workDay: WorkDay(date: Date(), homeHours: 0.0, officeHours: 8.0),
            isCurrentMonth: true,
            displayWeekends: true,
            onTap: {}
        )

        DayCell(
            date: Date(),
            workDay: nil,
            isCurrentMonth: true,
            displayWeekends: false,
            onTap: {}
        )

        DayCell(
            date: Date(),
            workDay: nil,
            isCurrentMonth: false,
            displayWeekends: false,
            onTap: {}
        )
    }
    .padding()
}

// MARK: - Work Type Icons Component

struct WorkTypeIconsView: View {
    let workTypes: [WorkType]
    let cellWidth: CGFloat

    var body: some View {
        if workTypes.count == 1 {
            // Single large icon
            Text(workTypes[0].icon)
                .font(.system(size: 20))
        } else if workTypes.count == 2 {
            // Two icons arranged diagonally
            ZStack {
                Text(workTypes[0].icon)
                    .font(.system(size: 13))
                    .position(x: cellWidth * 0.3, y: 10)
                Text(workTypes[1].icon)
                    .font(.system(size: 13))
                    .position(x: cellWidth * 0.6, y: 20)
            }
            .frame(width: cellWidth, height: 24)
        } else if workTypes.count == 3 {
            // Three icons in triangular arrangement
            ZStack {
                Text(workTypes[0].icon)
                    .font(.system(size: 11))
                    .position(x: cellWidth * 0.5, y: 8)
                Text(workTypes[1].icon)
                    .font(.system(size: 11))
                    .position(x: cellWidth * 0.3, y: 18)
                Text(workTypes[2].icon)
                    .font(.system(size: 11))
                    .position(x: cellWidth * 0.7, y: 18)
            }
            .frame(width: cellWidth, height: 24)
        } else if workTypes.count >= 4 {
            // Four icons in 2x2 grid
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Text(workTypes[0].icon)
                        .font(.system(size: 10))
                    Text(workTypes[1].icon)
                        .font(.system(size: 10))
                }
                HStack(spacing: 2) {
                    Text(workTypes[2].icon)
                        .font(.system(size: 10))
                    if workTypes.count > 3 {
                        Text(workTypes[3].icon)
                            .font(.system(size: 10))
                    } else {
                        Spacer().frame(width: 12, height: 12)
                    }
                }
            }
            .frame(width: cellWidth, height: 24)
        }
    }
} 