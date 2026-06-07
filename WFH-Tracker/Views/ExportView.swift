import SwiftUI
import OSLog

struct ExportView: View {
    @EnvironmentObject var diContainer: DIContainer

    @Binding var selectedYear: FinancialYear?
    @State private var shareItem: ShareItem?
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingYearPicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Page title
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Export for tax time")
                            .font(.breezeDisplay(26))
                            .foregroundStyle(Color.breezeInk)
                        Text("Download a CSV of your work-from-home record.")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundStyle(Color.breezeInkMuted)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    .padding(.bottom, 16)

                    // Financial year card
                    fyCard
                        .padding(.horizontal, 18)

                    // What's included
                    sectionHeader("What's included")

                    listCard {
                        listRow(
                            icon: "🏠",
                            iconBg: Color.breezeHomeSoft,
                            title: "Home & office hours",
                            subtitle: "Per day, with daily totals"
                        )
                        Divider().overlay(Color.breezeLine).padding(.leading, 65)
                        listRow(
                            icon: "📅",
                            iconBg: Color.breezeHolidaySoft,
                            title: "Weekdays or the full week",
                            subtitle: "Follows your \"Show weekends\" setting"
                        )
                        Divider().overlay(Color.breezeLine).padding(.leading, 65)
                        listRow(
                            icon: "📊",
                            iconBg: Color.breezeOfficeSoft,
                            title: "Days & hours",
                            subtitle: "Both totals, no maths needed"
                        )
                    }

                    // Export button
                    Group {
                        if isLoading {
                            HStack(spacing: 12) {
                                ProgressView().tint(.white)
                                Text("Generating…").font(.system(size: 16, weight: .heavy))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(LinearGradient.breezeBrandGrad.clipShape(Capsule()))
                            .breezeShadowBrand()
                        } else {
                            Button {
                                generateAndExportCSV()
                            } label: {
                                Label("Export CSV", systemImage: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .heavy))
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(selectedYear == nil)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .background(Color.breezeBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(item: $shareItem) { item in ShareSheet(url: item.url) }
            .sheet(isPresented: $showingYearPicker) { yearPickerSheet }
            .alert("Export Error", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                Logger.ui.logInfo("ExportView appeared", context: "ExportView")
            }
        }
    }

    // MARK: - FY card

    private func fyDateRange(_ year: FinancialYear) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "d MMM yyyy"
        return "\(fmt.string(from: year.startDate)) – \(fmt.string(from: year.endDate))"
    }

    private var fyCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SELECTED FINANCIAL YEAR")
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(.white.opacity(0.9))

            HStack(alignment: .center) {
                Text(verbatim: selectedYear.map { "\($0.startYear) – \($0.startYear + 1)" } ?? "—")
                    .font(.breezeDisplay(30))
                    .foregroundStyle(.white)

                Spacer()

                Button { showingYearPicker = true } label: {
                    HStack(spacing: 4) {
                        Text("Change")
                        Image(systemName: "chevron.down")
                    }
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.white.opacity(0.2)))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 6)

            if let year = selectedYear {
                Text(fyDateRange(year))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.92))
                    .padding(.top, 10)
            }
        }
        .padding(22)
        .background(
            LinearGradient.breezeBrandGrad
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        )
        .breezeShadowBrand()
    }

    // MARK: - Year picker sheet

    private var yearPickerSheet: some View {
        NavigationView {
            List {
                ForEach(diContainer.calendarStateManager.financialYears) { year in
                    Button {
                        selectedYear = year
                        showingYearPicker = false
                    } label: {
                        HStack {
                            Text(year.displayString)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color.breezeInk)
                            Spacer()
                            if selectedYear == year {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.breezeBrand)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Financial Year")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingYearPicker = false }
                }
            }
        }
    }

    // MARK: - Shared list helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .heavy))
            .foregroundStyle(Color.breezeInkFaint)
            .tracking(0.8)
            .padding(.horizontal, 24)
            .padding(.top, 22)
            .padding(.bottom, 9)
    }

    private func listCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.breezeSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.breezeLine, lineWidth: 1)
                )
        )
        .breezeShadowSm()
        .padding(.horizontal, 18)
    }

    private func listRow(icon: String, iconBg: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 13) {
            Text(icon)
                .font(.system(size: 16))
                .frame(width: 36, height: 36)
                .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(iconBg))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15.5, weight: .heavy))
                    .foregroundStyle(Color.breezeInk)
                Text(subtitle)
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Color.breezeInkFaint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Export logic

    private func generateAndExportCSV() {
        guard let year = selectedYear else {
            errorMessage = "Please select a financial year to export"
            showingError = true
            return
        }

        isLoading = true

        Task {
            do {
                let csv = await buildCSV(for: year)
                let name = "WFH-Export-\(year.displayString.replacingOccurrences(of: "/", with: "-")).csv"
                let path = FileManager.default.temporaryDirectory.appendingPathComponent(name)
                try csv.write(to: path, atomically: true, encoding: .utf8)
                await MainActor.run {
                    shareItem = ShareItem(url: path)
                    isLoading = false
                    Logger.export.logInfo("CSV exported for \(year.displayString)", context: "ExportView")
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to generate CSV: \(error.localizedDescription)"
                    showingError = true
                    isLoading = false
                }
            }
        }
    }

    private func buildCSV(for year: FinancialYear) async -> String {
        var csv = "date,day of week,home days,office days,holiday days,sick days,home hours,office hours,holiday hours,sick hours\n"
        var current = year.startDate
        let cal = Calendar.current
        while current <= year.endDate {
            let wd = diContainer.calendarStateManager.getWorkDay(for: current)
            let hH = wd?.homeHours ?? 0
            let oH = wd?.officeHours ?? 0
            let holH = wd?.holidayHours ?? 0
            let sH = wd?.sickHours ?? 0
            let row = "\(DateFormatters.csvDate.string(from: current))," +
                      "\(DateFormatters.fullDay.string(from: current))," +
                      "\(round((hH/8)*10)/10),\(round((oH/8)*10)/10)," +
                      "\(round((holH/8)*10)/10),\(round((sH/8)*10)/10)," +
                      "\(hH),\(oH),\(holH),\(sH)\n"
            csv.append(row)
            current = cal.date(byAdding: .day, value: 1, to: current)!
        }
        return csv
    }
}

// MARK: - Supporting types

private struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    struct Wrapper: View {
        @State var year: FinancialYear? = FinancialYear(for: Date())
        var body: some View {
            ExportView(selectedYear: $year).environmentObject(DIContainer.shared)
        }
    }
    return Wrapper()
}
