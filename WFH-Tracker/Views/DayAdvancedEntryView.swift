import SwiftUI

struct DayAdvancedEntryView: View {
    let date: Date
    let existingEntry: WorkDayEntry?
    let onSave: (WorkDayEntry) -> Void
    let onCancel: () -> Void

    @State private var workEntries: [WorkType: String] = [:]
    @State private var showingValidationError = false
    @State private var validationMessage = ""

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Advanced Entry")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(dateFormatter.string(from: date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 16)

                // Hour Entry Fields
                VStack(spacing: 16) {
                    ForEach(WorkType.allCases, id: \.self) { workType in
                        WorkTypeEntryRow(
                            workType: workType,
                            hours: workEntries[workType] ?? "",
                            onHoursChanged: { newValue in
                                workEntries[workType] = newValue
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)

                // Summary
                if totalHours > 0 {
                    VStack(spacing: 4) {
                        Text("Total: \(String(format: "%.1f", totalHours)) hours")
                            .font(.headline)
                            .foregroundColor(.primary)

                        if totalHours > 24 {
                            Text("⚠️ Total exceeds 24 hours")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.top, 8)
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    Button("Save") {
                        saveEntry()
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
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("Invalid Input", isPresented: $showingValidationError) {
                Button("OK") { }
            } message: {
                Text(validationMessage)
            }
        }
        .onAppear {
            loadExistingData()
        }
        .background(Color(.systemBackground))
    }

    private var totalHours: Double {
        workEntries.values.compactMap { Double($0) }.reduce(0, +)
    }

    private var isValidInput: Bool {
        let entries = workEntries.compactMapValues { Double($0) }

        for (_, hours) in entries {
            if hours < 0 || hours > 24 {
                return false
            }
        }

        return totalHours <= 24
    }

    private func loadExistingData() {
        if let existingEntry = existingEntry {
            for workType in WorkType.allCases {
                if let hours = existingEntry.workEntries[workType] {
                    workEntries[workType] = String(format: "%.1f", hours)
                }
            }
        }
    }

    private func saveEntry() {
        guard isValidInput else {
            validationMessage = "Please enter valid hours (0-24 per type, 0-24 total per day)"
            showingValidationError = true
            return
        }

        // Convert string entries to double entries, filtering out empty/zero values
        let doubleEntries = workEntries.compactMapValues { stringValue -> Double? in
            guard let doubleValue = Double(stringValue), doubleValue > 0 else {
                return nil
            }
            return doubleValue
        }

        var newEntry = WorkDayEntry()
        newEntry.workEntries = doubleEntries
        newEntry.isAdvanced = true

        onSave(newEntry)
    }
}

// MARK: - Work Type Entry Row Component

struct WorkTypeEntryRow: View {
    let workType: WorkType
    let hours: String
    let onHoursChanged: (String) -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Work Type Icon and Label
            HStack(spacing: 8) {
                Text(workType.icon)
                    .font(.system(size: 20))

                Text(workType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(width: 60, alignment: .leading)
            }

            Spacer()

            // Hours Input Field
            TextField("0.0", text: Binding(
                get: { hours },
                set: { onHoursChanged($0) }
            ))
            .keyboardType(.decimalPad)
            .textFieldStyle(AdvancedTextFieldStyle())
            .frame(width: 80)

            Text("hours")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(workType.backgroundColor.opacity(0.3))
        )
    }
}

// MARK: - Custom Text Field Style

struct AdvancedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            )
    }
}

#Preview {
    let sampleEntry = WorkDayEntry()

    DayAdvancedEntryView(
        date: Date(),
        existingEntry: sampleEntry,
        onSave: { _ in },
        onCancel: { }
    )
}