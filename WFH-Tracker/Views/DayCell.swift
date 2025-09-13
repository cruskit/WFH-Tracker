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
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                // Date header (always at the top)
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isCurrentMonth ? .primary : .secondary)
                
                // Work location emojis (if any)
                if let workDay = workDay, workDay.hasData {
                    if hasHomeHours && hasOfficeHours {
                        ZStack {
                            Text("🏠")
                                .font(.system(size: 13))
                                .position(x: 15, y: 10)
                            Text("🏢")
                                .font(.system(size: 13))
                                .position(x: 30, y: 20)
                        }
                        .frame(width: 50, height: 24)
                    } else if hasHomeHours {
                        Text("🏠")
                            .font(.system(size: 20))
                    } else if hasOfficeHours {
                        Text("🏢")
                            .font(.system(size: 20))
                    }
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
    
    private var hasHomeHours: Bool {
        guard let workDay = workDay, workDay.hasData else { return false }
        return workDay.homeHours != nil && workDay.homeHours! > 0
    }
    
    private var hasOfficeHours: Bool {
        guard let workDay = workDay, workDay.hasData else { return false }
        return workDay.officeHours != nil && workDay.officeHours! > 0
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