import SwiftUI

struct WorkHoursEntryView: View {
    let date: Date
    let existingWorkDay: WorkDay?
    let existingWorkDays: [WorkDay]
    let onSave: ([WorkDay]) -> Void
    let onCancel: () -> Void
    
    @State private var weeklyHours: [Date: (home: String, office: String)] = [:]
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()
    
    private let dayNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Weekly Working Hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Week of \(weekStartDateString)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 16)
            
            // Table Header
            HStack(spacing: 0) {
                Text("Day")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading)
                
                Text("🏡 Home")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(width: 120, alignment: .center)
                
                Text("🏢 Office")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(width: 120, alignment: .center)
                
                Spacer()
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 8)
            
            // Table Rows
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(weekDates.enumerated()), id: \.element) { index, date in
                        TableRow(
                            date: date,
                            homeHours: weeklyHours[date]?.home ?? "",
                            officeHours: weeklyHours[date]?.office ?? "",
                            onHomeHoursChange: { newValue in
                                weeklyHours[date] = (home: newValue, office: weeklyHours[date]?.office ?? "")
                            },
                            onOfficeHoursChange: { newValue in
                                weeklyHours[date] = (home: weeklyHours[date]?.home ?? "", office: newValue)
                            },
                            onQuickHome8: {
                                weeklyHours[date] = (home: "8", office: weeklyHours[date]?.office ?? "")
                            },
                            onQuickOffice8: {
                                weeklyHours[date] = (home: weeklyHours[date]?.home ?? "", office: "8")
                            },
                            isLast: index == weekDates.count - 1
                        )
                    }
                }
                .padding(.horizontal, 36)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button("Save") {
                    saveWorkDays()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!isValidInput)
                
                Button("Clear All") {
                    weeklyHours.removeAll()
                }
                .buttonStyle(ClearButtonStyle())
                
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .alert("Invalid Input", isPresented: $showingValidationError) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
        .onAppear {
            print("WorkHoursEntryView appeared for date: \(date)")
            loadExistingData()
        }
        .background(Color(.systemBackground))
    }
    
    private var weekDates: [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        var dates: [Date] = []
        
        for i in 0..<7 {
            if let weekDate = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                dates.append(weekDate)
            }
        }
        
        return dates
    }
    
    private var weekStartDateString: String {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return shortDateFormatter.string(from: startOfWeek)
    }
    
    private var weeklyTotalHours: Int {
        weekDates.reduce(0) { total, date in
            let home = Int(weeklyHours[date]?.home ?? "0") ?? 0
            let office = Int(weeklyHours[date]?.office ?? "0") ?? 0
            return total + home + office
        }
    }
    
    private var isValidInput: Bool {
        for date in weekDates {
            let home = Int(weeklyHours[date]?.home ?? "0") ?? 0
            let office = Int(weeklyHours[date]?.office ?? "0") ?? 0
            
            if home < 0 || office < 0 || home > 24 || office > 24 || (home + office) > 24 {
                return false
            }
        }
        return true
    }
    
    private func loadExistingData() {
        // Load existing data for all days in the week
        for weekDate in weekDates {
            if let workDay = existingWorkDays.first(where: { calendar.isDate($0.date, inSameDayAs: weekDate) }) {
                let homeHours = workDay.homeHours.map { String(Int($0)) } ?? ""
                let officeHours = workDay.officeHours.map { String(Int($0)) } ?? ""
                weeklyHours[weekDate] = (home: homeHours, office: officeHours)
            }
        }
    }
    
    private func saveWorkDays() {
        guard isValidInput else {
            validationMessage = "Please enter valid hours (0-24 per day, 0-24 total per day)"
            showingValidationError = true
            return
        }
        
        var workDaysToSave: [WorkDay] = []
        
        for weekDate in weekDates {
            if let hours = weeklyHours[weekDate] {
                let home = Int(hours.home) ?? 0
                let office = Int(hours.office) ?? 0
                
                // Only save if at least one value is greater than 0
                let homeHoursValue = home > 0 ? Double(home) : nil
                let officeHoursValue = office > 0 ? Double(office) : nil
                
                let workDay = WorkDay(
                    date: weekDate,
                    homeHours: homeHoursValue,
                    officeHours: officeHoursValue
                )
                
                workDaysToSave.append(workDay)
            } else {
                // Explicitly include cleared days with nil values
                let workDay = WorkDay(
                    date: weekDate,
                    homeHours: nil,
                    officeHours: nil
                )
                
                workDaysToSave.append(workDay)
            }
        }
        
        onSave(workDaysToSave)
    }
}

// MARK: - Table Row Component

struct TableRow: View {
    let date: Date
    let homeHours: String
    let officeHours: String
    let onHomeHoursChange: (String) -> Void
    let onOfficeHoursChange: (String) -> Void
    let onQuickHome8: () -> Void
    let onQuickOffice8: () -> Void
    let isLast: Bool
    
    private let calendar = Calendar.current
    private let dayNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Day Column
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayNameFormatter.string(from: date))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(dateFormatter.string(from: date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 80, alignment: .leading)
                
                // Home Hours Column
                HStack(spacing: 4) {
                    TextField("0", text: Binding(
                        get: { homeHours },
                        set: { onHomeHoursChange($0) }
                    ))
                    .keyboardType(.numberPad)
                    .textFieldStyle(TableTextFieldStyle())
                    .frame(width: 60)
                    
                    Button("🏠") {
                        onQuickHome8()
                    }
                    .buttonStyle(IconButtonStyle())
                }
                .frame(width: 120)
                
                // Office Hours Column
                HStack(spacing: 4) {
                    TextField("0", text: Binding(
                        get: { officeHours },
                        set: { onOfficeHoursChange($0) }
                    ))
                    .keyboardType(.numberPad)
                    .textFieldStyle(TableTextFieldStyle())
                    .frame(width: 60)
                    
                    Button("🏢") {
                        onQuickOffice8()
                    }
                    .buttonStyle(IconButtonStyle())
                }
                .frame(width: 120)
            }
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            if !isLast {
                Divider()
                    .padding(.leading, 96)
            }
        }
    }
}

// MARK: - Custom Styles

struct TableTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray6))
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

struct ClearButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red, lineWidth: 2)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    let sampleDate = Date()
    let sampleWorkDay = WorkDay(date: sampleDate, homeHours: 6.5, officeHours: 2.0)
    
    WorkHoursEntryView(
        date: sampleDate,
        existingWorkDay: sampleWorkDay,
        existingWorkDays: [sampleWorkDay],
        onSave: { _ in },
        onCancel: { }
    )
} 