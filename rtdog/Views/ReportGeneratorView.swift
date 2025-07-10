import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import AppKit

struct ReportGeneratorView: View {
    @ObservedObject var workDayManager: WorkDayManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedPeriod: ReportPeriod = .thisMonth
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var includeWeekends = true
    @State private var selectedFormat: ExportFormat = .pdf
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var showingPermissionInfo = false
    
    enum ReportPeriod: String, CaseIterable {
        case lastMonth = "Last Month"
        case thisMonth = "This Month"
        case custom = "Custom Range"
    }
    
    enum ExportFormat: String, CaseIterable {
        case pdf = "PDF"
        case csv = "CSV"
        case excel = "Excel"
        
        var fileExtension: String {
            switch self {
            case .pdf: return "pdf"
            case .csv: return "csv"
            case .excel: return "xlsx"
            }
        }
        
        var utType: UTType {
            switch self {
            case .pdf: return .pdf
            case .csv: return .commaSeparatedText
            case .excel: return UTType(filenameExtension: "xlsx") ?? .data
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Report Settings
                    GroupBox(label: Text("Report Settings").font(.headline)) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Time Period:")
                                    .font(.subheadline)
                                Spacer()
                                Picker("Period", selection: $selectedPeriod) {
                                    ForEach(ReportPeriod.allCases, id: \.self) { period in
                                        Text(period.rawValue).tag(period)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .onChange(of: selectedPeriod) { _, _ in
                                    updateDatesForPeriod()
                                }
                            }
                            
                            if selectedPeriod == .custom {
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Custom Date Range")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    HStack {
                                        Text("Start Date:")
                                        Spacer()
                                        DatePicker("", selection: $startDate, in: ...Date(), displayedComponents: .date)
                                            .labelsHidden()
                                            .datePickerStyle(CompactDatePickerStyle())
                                    }
                                    
                                    HStack {
                                        Text("End Date:")
                                        Spacer()
                                        DatePicker("", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
                                            .labelsHidden()
                                            .datePickerStyle(CompactDatePickerStyle())
                                    }
                                }
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Export Format:")
                                    .font(.subheadline)
                                Spacer()
                                Picker("Format", selection: $selectedFormat) {
                                    ForEach(ExportFormat.allCases, id: \.self) { format in
                                        Text(format.rawValue).tag(format)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            Toggle("Include Weekends", isOn: $includeWeekends)
                        }
                        .padding()
                    }
                    
                    // Report Preview
                    GroupBox(label: Text("Report Preview").font(.headline)) {
                        if let preview = generateReportPreview() {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Report Summary")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Total Days:")
                                        Spacer()
                                        Text("\(preview.totalDays)")
                                    }
                                    
                                    HStack {
                                        Text("Office Days:")
                                        Spacer()
                                        Text("\(preview.officeDays) (\(String(format: "%.1f", preview.officePercentage))%)")
                                    }
                                    
                                    HStack {
                                        Text("Home Days:")
                                        Spacer()
                                        Text("\(preview.homeDays) (\(String(format: "%.1f", preview.homePercentage))%)")
                                    }
                                    
                                    HStack {
                                        Text("Holidays:")
                                        Spacer()
                                        Text("\(preview.holidays)")
                                    }
                                    
                                    HStack {
                                        Text("PTO Days:")
                                        Spacer()
                                        Text("\(preview.ptoDays)")
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                
                                Divider()
                                
                                Text("Date Range: \(formattedDate(currentStartDate)) - \(formattedDate(currentEndDate))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text("No data available for the selected period")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding()
                    
                    // Export Options
                    GroupBox(label: Text("Export").font(.headline)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Generate your work location report in the selected format:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button(action: generateReport) {
                                HStack {
                                    Image(systemName: "doc.badge.arrow.up")
                                    Text("Generate \(selectedFormat.rawValue) Report")
                                }
                            }
                            .buttonStyle(BorderedProminentButtonStyle())
                            .frame(maxWidth: .infinity)
                            .disabled(isGenerating || generateReportPreview() == nil)
                            .help("Generate and save the report to your chosen location")
                        }
                        .padding()
                    }
                    
                    // Information section
                    GroupBox(label: Text("Information").font(.headline)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reports include your work location for each day with comprehensive statistics.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Export formats:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• PDF: Professional report with app branding and statistics")
                                Text("• CSV: Structured data for analysis and spreadsheet import")
                                Text("• Excel: Excel-compatible format for advanced data manipulation")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("File Access")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text("macOS will ask you to choose where to save your report. This is normal sandbox behavior to keep your data secure.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Reports")
            .frame(minWidth: 500, minHeight: 600)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
            .alert("File Access Permissions", isPresented: $showingPermissionInfo) {
                Button("Got it!") {
                    UserDefaults.standard.set(true, forKey: "ReportsPermissionInfoShown")
                }
            } message: {
                Text("When you generate your first report, macOS will ask you to choose where to save it. This is normal - rtdog needs permission to save files to your chosen location. Your data stays private and secure on your Mac.")
            }
        }
        .onAppear {
            updateDatesForPeriod()
            checkFirstTimeUser()
        }
    }
    
    // MARK: - Helper Properties
    
    private var currentStartDate: Date {
        selectedPeriod == .custom ? startDate : periodStartDate
    }
    
    private var currentEndDate: Date {
        selectedPeriod == .custom ? endDate : periodEndDate
    }
    
    private var periodStartDate: Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .thisMonth:
            return calendar.dateInterval(of: .month, for: now)?.start ?? now
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return calendar.dateInterval(of: .month, for: lastMonth)?.start ?? now
        case .custom:
            return startDate
        }
    }
    
    private var periodEndDate: Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .thisMonth:
            return calendar.dateInterval(of: .month, for: now)?.end ?? now
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return calendar.dateInterval(of: .month, for: lastMonth)?.end ?? now
        case .custom:
            return endDate
        }
    }
    
    private var defaultFilename: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startStr = formatter.string(from: currentStartDate)
        let endStr = formatter.string(from: currentEndDate)
        return "rtdog-report-\(startStr)-to-\(endStr).\(selectedFormat.fileExtension)"
    }
    
    // MARK: - Helper Methods
    
    private func updateDatesForPeriod() {
        if selectedPeriod != .custom {
            startDate = periodStartDate
            endDate = periodEndDate
        }
    }
    
    private func checkFirstTimeUser() {
        if !UserDefaults.standard.bool(forKey: "ReportsPermissionInfoShown") {
            // Show permission info after a brief delay to let the view settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingPermissionInfo = true
            }
        }
    }
    
    private func generateReportPreview() -> ReportPreview? {
        let data = generateReportData()
        guard !data.isEmpty else { return nil }
        return ReportPreview(from: data, includeWeekends: includeWeekends)
    }
    
    private func generateReportData() -> [ReportDay] {
        var reportDays: [ReportDay] = []
        let calendar = Calendar.current
        
        print("DEBUG: generateReportData called")
        print("DEBUG: Start date: \(currentStartDate)")
        print("DEBUG: End date: \(currentEndDate)")
        print("DEBUG: Include weekends: \(includeWeekends)")
        
        var currentDate = currentStartDate
        while currentDate <= currentEndDate {
            // Add the day to report if weekends are included OR if it's not a weekend
            if includeWeekends || !calendar.isDateInWeekend(currentDate) {
                let workDay = workDayManager.workDays[currentDate]
                let reportDay = ReportDay(
                    date: currentDate,
                    workLocation: workDay?.status,
                    isWeekend: calendar.isDateInWeekend(currentDate),
                    isHoliday: workDay?.isHoliday ?? false,
                    isPTO: workDay?.isPTO ?? false
                )
                reportDays.append(reportDay)
            }
            
            // Always increment the date by one day - this should only happen once per iteration
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        print("DEBUG: Generated \(reportDays.count) report days")
        if let firstDay = reportDays.first, let lastDay = reportDays.last {
            print("DEBUG: Actual range: \(firstDay.date) to \(lastDay.date)")
        }
        
        return reportDays
    }
    
    private func generateReport() {
        print("DEBUG: Generate report button pressed!")
        print("DEBUG: Selected format: \(selectedFormat.rawValue)")
        print("DEBUG: Date range: \(currentStartDate) to \(currentEndDate)")
        
        isGenerating = true
        showSaveDialog()
    }
    
    private func showSaveDialog() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [selectedFormat.utType]
        savePanel.nameFieldStringValue = defaultFilename
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save Report"
        savePanel.message = "Choose where to save your rtdog work report"
        
        // Get the key window for proper presentation
        guard let window = NSApplication.shared.keyWindow else {
            print("ERROR: No key window available for save panel")
            DispatchQueue.main.async {
                self.isGenerating = false
                self.errorMessage = "Unable to show save dialog. Please make sure the app window is active and try again."
                self.showingError = true
            }
            return
        }
        
        print("DEBUG: Showing save panel...")
        savePanel.beginSheetModal(for: window) { result in
            DispatchQueue.main.async {
                print("DEBUG: Save panel completed with result: \(result.rawValue)")
                self.isGenerating = false
                
                if result == .OK, let url = savePanel.url {
                    print("DEBUG: User selected URL: \(url)")
                    self.saveReportToURL(url)
                } else {
                    print("DEBUG: User cancelled save dialog")
                }
            }
        }
    }
    
    private func saveReportToURL(_ url: URL) {
        print("DEBUG: Starting to save report to: \(url)")
        let data = generateReportData()
        print("DEBUG: Generated \(data.count) report days")
        
        do {
            switch selectedFormat {
            case .pdf:
                print("DEBUG: Generating PDF report...")
                let pdfData = generatePDFReport(from: data)
                print("DEBUG: PDF data size: \(pdfData.count) bytes")
                try pdfData.write(to: url)
                print("DEBUG: PDF successfully saved to \(url)")
            case .csv, .excel:
                print("DEBUG: Generating CSV report...")
                let csvData = generateCSVReport(from: data)
                print("DEBUG: CSV data size: \(csvData.count) characters")
                try csvData.write(to: url, atomically: true, encoding: .utf8)
                print("DEBUG: CSV successfully saved to \(url)")
            }
            
            // Show success message
            DispatchQueue.main.async {
                // You could add a success alert here if desired
                print("SUCCESS: Report saved successfully!")
            }
            
        } catch {
            print("ERROR: Failed to save report: \(error)")
            DispatchQueue.main.async {
                if error.localizedDescription.contains("permission") || error.localizedDescription.contains("access") {
                    self.errorMessage = "Permission denied. Please try saving to a different location like Documents or Desktop, or check your file permissions."
                } else {
                    self.errorMessage = "Failed to save report: \(error.localizedDescription)"
                }
                self.showingError = true
            }
        }
    }
    
    private func generatePDFReport(from data: [ReportDay]) -> Data {
        let pdfData = NSMutableData()
        let pageRect = NSRect(x: 0, y: 0, width: 612, height: 792)
        
        guard let dataConsumer = CGDataConsumer(data: pdfData) else {
            return Data()
        }
        
        var mediaBox = pageRect
        guard let pdfContext = CGContext(consumer: dataConsumer, mediaBox: &mediaBox, nil) else {
            return Data()
        }
        
        let nsContext = NSGraphicsContext(cgContext: pdfContext, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = nsContext
        
        pdfContext.beginPDFPage(nil)
        
        let preview = ReportPreview(from: data, includeWeekends: includeWeekends)
        
        // Title
        let titleRect = NSRect(x: 50, y: 742, width: 512, height: 40)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 24),
            .foregroundColor: NSColor.black
        ]
        "rtdog Work Report".draw(in: titleRect, withAttributes: titleAttributes)
        
        // Date range
        let dateRect = NSRect(x: 50, y: 692, width: 512, height: 20)
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.gray
        ]
        "Period: \(formattedDate(currentStartDate)) - \(formattedDate(currentEndDate))".draw(in: dateRect, withAttributes: dateAttributes)
        
        // Statistics
        var yPosition: CGFloat = 642
        let statAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14),
            .foregroundColor: NSColor.black
        ]
        
        let stats = [
            "Total Days: \(preview.totalDays)",
            "Office Days: \(preview.officeDays) (\(String(format: "%.1f", preview.officePercentage))%)",
            "Home Days: \(preview.homeDays) (\(String(format: "%.1f", preview.homePercentage))%)",
            "Holidays: \(preview.holidays)",
            "PTO Days: \(preview.ptoDays)"
        ]
        
        for stat in stats {
            let statRect = NSRect(x: 50, y: yPosition, width: 512, height: 20)
            stat.draw(in: statRect, withAttributes: statAttributes)
            yPosition -= 25
        }
        
        // Daily data
        yPosition -= 20
        let headerRect = NSRect(x: 50, y: yPosition, width: 512, height: 20)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 14),
            .foregroundColor: NSColor.black
        ]
        "Daily Work Data".draw(in: headerRect, withAttributes: headerAttributes)
        yPosition -= 30
        
        let dayAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10),
            .foregroundColor: NSColor.black
        ]
        
        for day in data {
            if yPosition < 50 { // Start new page if needed
                pdfContext.endPDFPage()
                pdfContext.beginPDFPage(nil)
                yPosition = 742
            }
            
            let dayRect = NSRect(x: 50, y: yPosition, width: 512, height: 15)
            let dayText = "\(formattedDate(day.date)): \(day.displayStatus)"
            dayText.draw(in: dayRect, withAttributes: dayAttributes)
            yPosition -= 18
        }
        
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        NSGraphicsContext.restoreGraphicsState()
        
        return pdfData as Data
    }
    
    private func generateCSVReport(from data: [ReportDay]) -> String {
        var csv = "Date,Work Location,Weekend,Holiday,PTO\n"
        
        for day in data {
            let dateStr = formattedDate(day.date)
            let location = day.displayStatus
            let weekend = day.isWeekend ? "Yes" : "No"
            let holiday = day.isHoliday ? "Yes" : "No"
            let pto = day.isPTO ? "Yes" : "No"
            
            csv += "\(dateStr),\(location),\(weekend),\(holiday),\(pto)\n"
        }
        
        return csv
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Types

struct ReportDay {
    let date: Date
    let workLocation: WorkStatus?
    let isWeekend: Bool
    let isHoliday: Bool
    let isPTO: Bool
    
    var displayStatus: String {
        if isHoliday { return "Holiday" }
        if isPTO { return "PTO" }
        if let status = workLocation {
            switch status {
            case .workFromOffice: return "Office"
            case .workFromHome: return "Home"
            case .notWorkingDay: return "Not Working"
            case .unlogged: return "Not Logged"
            }
        }
        return isWeekend ? "Weekend" : "Not Logged"
    }
}

struct ReportPreview {
    let totalDays: Int
    let officeDays: Int
    let homeDays: Int
    let holidays: Int
    let ptoDays: Int
    
    var officePercentage: Double {
        totalDays > 0 ? Double(officeDays) / Double(totalDays) * 100 : 0
    }
    
    var homePercentage: Double {
        totalDays > 0 ? Double(homeDays) / Double(totalDays) * 100 : 0
    }
    
    init(from data: [ReportDay], includeWeekends: Bool) {
        let filteredData = includeWeekends ? data : data.filter { !$0.isWeekend }
        
        totalDays = filteredData.count
        officeDays = filteredData.filter { $0.workLocation == .workFromOffice }.count
        homeDays = filteredData.filter { $0.workLocation == .workFromHome }.count
        holidays = filteredData.filter { $0.isHoliday }.count
        ptoDays = filteredData.filter { $0.isPTO }.count
    }
}

struct ReportGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        ReportGeneratorView(workDayManager: WorkDayManager.shared)
    }
} 
