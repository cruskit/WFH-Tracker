import SwiftUI

struct DayAdvancedEntryView: View {
    let date: Date
    let existingEntry: WorkDayEntry?
    let onSave: (WorkDayEntry) -> Void
    let onCancel: () -> Void

    @State private var hours: [WorkType: Double] = [:]
    @State private var editingType: WorkType?
    @State private var editingText: String = ""
    @FocusState private var fieldFocused: WorkType?

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            // Grab handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.breezeLineStrong)
                .frame(width: 44, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 16)

            Text("Split your day")
                .font(.breezeDisplay(23))
                .foregroundStyle(Color.breezeInk)

            Text(dateFormatter.string(from: date))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.breezeInkMuted)
                .padding(.top, 4)
                .padding(.bottom, 14)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(WorkType.allCases, id: \.self) { type in
                        advancedRow(for: type)
                    }

                    // Day total
                    HStack {
                        Text("Day total")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(Color.breezeBrandInk)
                        Spacer()
                        Text(String(format: "%.1f h", totalHours))
                            .font(.breezeDisplay(22))
                            .foregroundStyle(Color.breezeBrandInk)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.breezeBrandSoft)
                    )
                    .padding(.top, 4)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 12)
            }

            HStack(spacing: 10) {
                Button("Cancel") { onCancel() }
                    .buttonStyle(SecondaryButtonStyle())
                    .frame(maxWidth: .infinity)

                Button("Save day") { saveEntry() }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity)
                    .disabled(!isValid)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 22)
            .padding(.top, 8)
        }
        .background(Color.breezeBackground.ignoresSafeArea())
        .onChange(of: fieldFocused) { _, newValue in
            if newValue == nil, let type = editingType {
                commitEdit(for: type)
            }
        }
        .onAppear { loadExisting() }
    }

    // MARK: - Row

    private func advancedRow(for type: WorkType) -> some View {
        HStack(spacing: 13) {
            // Icon badge
            Text(type.icon)
                .font(.system(size: 22))
                .frame(width: 46, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Color.breezeSurface)
                        .breezeShadowSm()
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(type.displayName)
                    .font(.breezeDisplay(17))
                    .foregroundStyle(type.inkColor)
                Text("hours this day")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.breezeInkFaint)
            }

            Spacer()

            // Stepper
            HStack(spacing: 10) {
                Button {
                    if let editing = editingType { commitEdit(for: editing) }
                    let cur = hours[type] ?? 0
                    hours[type] = max(0, cur - 0.5)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(type.inkColor)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.breezeSurfaceSunken))
                }
                .buttonStyle(.plain)

                Group {
                    if editingType == type {
                        TextField("0", text: $editingText)
                            .font(.breezeDisplay(18))
                            .foregroundStyle(Color.breezeInk)
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .focused($fieldFocused, equals: type)
                            .frame(minWidth: 46)
                    } else {
                        Text(formatHours(hours[type] ?? 0))
                            .font(.breezeDisplay(18))
                            .foregroundStyle(Color.breezeInk)
                            .frame(minWidth: 36, alignment: .center)
                            .contentShape(Rectangle())
                            .onTapGesture { startEditing(type: type) }
                    }
                }

                Button {
                    if let editing = editingType { commitEdit(for: editing) }
                    let cur = hours[type] ?? 0
                    hours[type] = min(24, cur + 0.5)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(type.inkColor)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.breezeSurfaceSunken))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(Color.breezeSurface)
                    .breezeShadowSm()
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(type.softColor)
        )
    }

    // MARK: - Computed

    private var totalHours: Double { hours.values.reduce(0, +) }
    private var isValid: Bool { totalHours > 0 && totalHours <= 24 }

    private func formatHours(_ h: Double) -> String {
        h.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(h))" : String(format: "%.1f", h)
    }

    // MARK: - Edit helpers

    private func startEditing(type: WorkType) {
        if let current = editingType { commitEdit(for: current) }
        editingType = type
        editingText = formatHours(hours[type] ?? 0)
        fieldFocused = type
    }

    private func commitEdit(for type: WorkType) {
        if let value = Double(editingText) {
            let clamped = min(24, max(0, value))
            let rounded = (clamped * 10).rounded() / 10
            hours[type] = rounded
        }
        editingType = nil
        fieldFocused = nil
    }

    // MARK: - Persistence

    private func loadExisting() {
        guard let entry = existingEntry else { return }
        for type in WorkType.allCases {
            hours[type] = entry.workEntries[type] ?? 0
        }
    }

    private func saveEntry() {
        if let type = editingType { commitEdit(for: type) }
        let filtered = hours.filter { $0.value > 0 }
        var entry = WorkDayEntry()
        entry.workEntries = filtered
        entry.isAdvanced = true
        onSave(entry)
    }
}

#Preview {
    DayAdvancedEntryView(date: Date(), existingEntry: nil, onSave: { _ in }, onCancel: {})
}
