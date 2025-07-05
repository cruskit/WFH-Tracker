import SwiftUI

struct DayCell: View {
    let date: Date
    let workDay: WorkDay?
    let isCurrentMonth: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isCurrentMonth ? .primary : .secondary)
                
                if let workDay = workDay, workDay.hasData {
                    VStack(spacing: 1) {
                        if let homeHours = workDay.homeHours, homeHours > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.green)
                                Text(String(format: "%.1f", homeHours))
                                    .font(.system(size: 10))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        if let officeHours = workDay.officeHours, officeHours > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.blue)
                                Text(String(format: "%.1f", officeHours))
                                    .font(.system(size: 10))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .frame(width: 50, height: 60)
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
            onTap: {}
        )
        
        DayCell(
            date: Date(),
            workDay: nil,
            isCurrentMonth: true,
            onTap: {}
        )
        
        DayCell(
            date: Date(),
            workDay: nil,
            isCurrentMonth: false,
            onTap: {}
        )
    }
    .padding()
} 