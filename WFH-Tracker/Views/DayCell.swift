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
                
                VStack(spacing: 1) {
                    HStack(spacing: 2) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.green)
                            .opacity(hasHomeHours ? 1.0 : 0.0)
                        Text(homeHoursText)
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                            .opacity(hasHomeHours ? 1.0 : 0.0)
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.blue)
                            .opacity(hasOfficeHours ? 1.0 : 0.0)
                        Text(officeHoursText)
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                            .opacity(hasOfficeHours ? 1.0 : 0.0)
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
    
    private var hasHomeHours: Bool {
        guard let workDay = workDay, workDay.hasData else { return false }
        return workDay.homeHours != nil && workDay.homeHours! > 0
    }
    
    private var hasOfficeHours: Bool {
        guard let workDay = workDay, workDay.hasData else { return false }
        return workDay.officeHours != nil && workDay.officeHours! > 0
    }
    
    private var homeHoursText: String {
        guard let workDay = workDay, let homeHours = workDay.homeHours, homeHours > 0 else {
            return "0.0"
        }
        return String(format: "%.1f", homeHours)
    }
    
    private var officeHoursText: String {
        guard let workDay = workDay, let officeHours = workDay.officeHours, officeHours > 0 else {
            return "0.0"
        }
        return String(format: "%.1f", officeHours)
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