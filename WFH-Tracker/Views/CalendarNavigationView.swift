import SwiftUI

struct CalendarNavigationView: View {
    @ObservedObject var calendarManager: CalendarStateManager
    @State private var showingMonthPicker = false
    
    var body: some View {
        HStack {
            // Previous month button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    calendarManager.previousMonth()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Current month display with tap to pick
            Button(action: {
                showingMonthPicker = true
            }) {
                VStack(spacing: 2) {
                    Text(calendarManager.currentMonth.monthName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Tap to change")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $showingMonthPicker) {
                MonthPickerView(calendarManager: calendarManager)
            }
            
            Spacer()
            
            // Next month button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    calendarManager.nextMonth()
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct MonthPickerView: View {
    @ObservedObject var calendarManager: CalendarStateManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    
    private let calendar = Calendar.current
    private let currentYear = Calendar.current.component(.year, from: Date())
    
    init(calendarManager: CalendarStateManager) {
        self.calendarManager = calendarManager
        self._selectedYear = State(initialValue: calendarManager.currentMonth.year)
        self._selectedMonth = State(initialValue: calendarManager.currentMonth.month)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Year picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Year")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Year", selection: $selectedYear) {
                        ForEach(currentYear - 5...currentYear + 5, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 120)
                }
                
                // Month picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Month")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(1...12, id: \.self) { month in
                            Button(action: {
                                selectedMonth = month
                            }) {
                                Text(monthName(for: month))
                                    .font(.body)
                                    .fontWeight(selectedMonth == month ? .bold : .regular)
                                    .foregroundColor(selectedMonth == month ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(selectedMonth == month ? Color.blue : Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        applySelection()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func monthName(for month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        let calendar = Calendar.current
        let components = DateComponents(year: 2000, month: month, day: 1)
        let date = calendar.date(from: components) ?? Date()
        
        return dateFormatter.string(from: date)
    }
    
    private func applySelection() {
        let calendar = Calendar.current
        let components = DateComponents(year: selectedYear, month: selectedMonth, day: 1)
        if let newDate = calendar.date(from: components) {
            let newMonth = CalendarMonth(date: newDate)
            withAnimation(.easeInOut(duration: 0.3)) {
                calendarManager.scrollToMonth(newMonth)
            }
        }
    }
}

#Preview {
    let calendarManager = CalendarStateManager()
    
    CalendarNavigationView(calendarManager: calendarManager)
} 