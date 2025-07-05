import SwiftUI

struct WorkHoursEntryView: View {
    let date: Date
    let existingWorkDay: WorkDay?
    let onSave: (WorkDay) -> Void
    let onCancel: () -> Void
    
    @State private var homeHours: String = ""
    @State private var officeHours: String = ""
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 24) {
            // Date Header
            VStack(spacing: 8) {
                Text("Working Location Hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(dateFormatter.string(from: date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 16)
                
                // Hours Input Section
                VStack(spacing: 20) {
                    // Home Hours
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "house.fill")
                                .foregroundColor(.green)
                            Text("Home Hours")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            TextField("0.0", text: $homeHours)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                            
                            Button("8") {
                                homeHours = "8.0"
                            }
                            .buttonStyle(QuickButtonStyle())
                        }
                    }
                    
                    // Office Hours
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.blue)
                            Text("Office Hours")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            TextField("0.0", text: $officeHours)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                            
                            Button("8") {
                                officeHours = "8.0"
                            }
                            .buttonStyle(QuickButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Total Hours Display
                VStack(spacing: 8) {
                    Text("Total Hours")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.1f", totalHours))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Save") {
                        saveWorkDay()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!isValidInput)
                    
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
    
    private var totalHours: Double {
        let home = Double(homeHours) ?? 0
        let office = Double(officeHours) ?? 0
        return home + office
    }
    
    private var isValidInput: Bool {
        let home = Double(homeHours) ?? 0
        let office = Double(officeHours) ?? 0
        
        return home >= 0 && office >= 0 && 
               home <= 24 && office <= 24 && 
               totalHours <= 24
    }
    
    private func loadExistingData() {
        if let workDay = existingWorkDay {
            homeHours = workDay.homeHours.map { String(format: "%.1f", $0) } ?? ""
            officeHours = workDay.officeHours.map { String(format: "%.1f", $0) } ?? ""
        }
    }
    
    private func incrementHours(for field: inout String, by amount: Double) {
        let currentValue = Double(field) ?? 0
        let newValue = currentValue + amount
        if newValue <= 24 {
            field = String(format: "%.1f", newValue)
        }
    }
    
    private func saveWorkDay() {
        guard isValidInput else {
            validationMessage = "Please enter valid hours (0-24 total)"
            showingValidationError = true
            return
        }
        
        let home = Double(homeHours) ?? 0
        let office = Double(officeHours) ?? 0
        
        // Only save if at least one value is greater than 0
        let homeHoursValue = home > 0 ? home : nil
        let officeHoursValue = office > 0 ? office : nil
        
        let workDay = WorkDay(
            date: date,
            homeHours: homeHoursValue,
            officeHours: officeHoursValue
        )
        
        onSave(workDay)
    }
}

// MARK: - Custom Button Styles

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

struct QuickButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(.blue)
            .frame(width: 60, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

#Preview {
    let sampleDate = Date()
    let sampleWorkDay = WorkDay(date: sampleDate, homeHours: 6.5, officeHours: 2.0)
    
    WorkHoursEntryView(
        date: sampleDate,
        existingWorkDay: sampleWorkDay,
        onSave: { _ in },
        onCancel: { }
    )
} 