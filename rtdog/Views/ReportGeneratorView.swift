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
    @State private var showingFilePicker = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
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
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Generate Work Report")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Create a detailed report of your work locations, statistics, and compliance data.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Period Selection
                    GroupBox(label: Text("Report Period").font(.headline)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Period", selection: $selectedPeriod) {
                                ForEach(ReportPeriod.allCases, id: \.self) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: selectedPeriod) { _, _ in
                                updateDatesForPeriod()
                            }
                            
                            if selectedPeriod == .custom {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Start Date")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            DatePicker("", selection: $startDate, in: ...Date(), displayedComponents: .date)
                                                .labelsHidden()
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .leading) {
                                            Text("End Date")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            DatePicker("", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
                                                .labelsHidden()
                                        }
                                    }
                                    
                                    if !isValidDateRange {
                                        Text("⚠️ Start date must be before end date")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                            } else {
                                HStack {
                                    Text("From: \(formattedDate(currentStartDate))")
                                    Spacer()
                                    Text("To: \(formattedDate(currentEndDate))")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Options
                    GroupBox(label: Text("Report Options").font(.headline)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Include Weekends", isOn: $includeWeekends)
                            
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
                                .frame(width: 100)
                            }
                        }
                    }
                    
                    // Report Preview
                    if let preview = generateReportPreview() {
                        GroupBox(label: Text("Report Preview").font(.headline)) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Period:")
                                    Spacer()
                                    Text("\(formattedDate(currentStartDate)) - \(formattedDate(currentEndDate))")
                                        .foregroundColor(.secondary)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Total Days:")
                                    Spacer()
                                    Text("\(preview.totalDays)")
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Text("Office Days:")
                                    Spacer()
                                    Text("\(preview.officeDays) (\(preview.officePercentage)%)")
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Text("Home Days:")
                                    Spacer()
                                    Text("\(preview.homeDays) (\(preview.homePercentage)%)")
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Text("Holidays/PTO:")
                                    Spacer()
                                    Text("\(preview.holidayPtoDays) (\(preview.holidayPtoPercentage)%)")
                                        .foregroundColor(.secondary)
                                }
                                
                                if preview.hasLongGaps {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                        Text("Contains periods with no data logged for more than 1 week")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Reports")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Generate Report") {
                        generateReport()
                    }
                    .disabled(!canGenerateReport || isGenerating)
                }
            }
        }
        .onAppear {
            updateDatesForPeriod()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .onChange(of: showingFilePicker) { _, showing in
            if showing {
                showSaveDialog()
            }
        }
    }
    
    private var isValidDateRange: Bool {
        startDate <= endDate && endDate <= Date()
    }
    
    private var canGenerateReport: Bool {
        return isValidDateRange && !isGenerating
    }
    
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
            return min(calendar.dateInterval(of: .month, for: now)?.end ?? now, now)
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return calendar.dateInterval(of: .month, for: lastMonth)?.end ?? now
        case .custom:
            return endDate
        }
    }
    
    private var defaultFilename: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM-yyyy"
        
        let dateString = formatter.string(from: currentStartDate)
        return "rtdog-report-\(dateString).\(selectedFormat.fileExtension)"
    }
    
    private func updateDatesForPeriod() {
        if selectedPeriod != .custom {
            startDate = periodStartDate
            endDate = periodEndDate
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func generateReportPreview() -> ReportPreview? {
        let data = generateReportData()
        return ReportPreview(from: data, includeWeekends: includeWeekends)
    }
    
    private func generateReportData() -> [ReportDay] {
        var reportDays: [ReportDay] = []
        let calendar = Calendar.current
        
        var currentDate = currentStartDate
        while currentDate <= currentEndDate {
            // Skip weekends if not included
            if !includeWeekends && calendar.isDateInWeekend(currentDate) {
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                continue
            }
            
            let workDay = workDayManager.workDays[currentDate]
            let reportDay = ReportDay(
                date: currentDate,
                workLocation: workDay?.status,
                isWeekend: calendar.isDateInWeekend(currentDate),
                isHoliday: workDay?.isHoliday ?? false,
                isPTO: workDay?.isPTO ?? false
            )
            reportDays.append(reportDay)
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return reportDays
    }
    
    private func generateReport() {
        isGenerating = true
        showingFilePicker = true
    }
    
    private func showSaveDialog() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [selectedFormat.utType]
        savePanel.nameFieldStringValue = defaultFilename
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save Report"
        savePanel.message = "Choose where to save your rtdog work report"
        
        savePanel.begin { result in
            DispatchQueue.main.async {
                self.showingFilePicker = false
                
                if result == .OK, let url = savePanel.url {
                    self.saveReportToURL(url)
                } else {
                    self.isGenerating = false
                }
            }
        }
    }
    
    private func saveReportToURL(_ url: URL) {
        let reportData = generateReportData()
        
        do {
            switch selectedFormat {
            case .pdf:
                let pdfData = generatePDFReport(from: reportData)
                try pdfData.write(to: url)
            case .csv:
                let csvData = generateCSVReport(from: reportData)
                try csvData.write(to: url, atomically: true, encoding: .utf8)
            case .excel:
                // For now, we'll export as CSV and rename to xlsx
                let csvData = generateCSVReport(from: reportData)
                try csvData.write(to: url, atomically: true, encoding: .utf8)
            }
            
            isGenerating = false
            presentationMode.wrappedValue.dismiss()
            
        } catch {
            errorMessage = "Failed to save report: \(error.localizedDescription)"
            showingError = true
            isGenerating = false
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
            .font: NSFont.systemFont(ofSize: 14),
            .foregroundColor: NSColor.gray
        ]
        "Period: \(formattedDate(currentStartDate)) - \(formattedDate(currentEndDate))".draw(in: dateRect, withAttributes: dateAttributes)
        
        // Statistics
        var yPos = 642
        let stats = [
            "Total Days: \(preview.totalDays)",
            "Office Days: \(preview.officeDays) (\(preview.officePercentage)%)",
            "Home Days: \(preview.homeDays) (\(preview.homePercentage)%)",
            "Holidays/PTO: \(preview.holidayPtoDays) (\(preview.holidayPtoPercentage)%)"
        ]
        
        let statAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.black
        ]
        
        for stat in stats {
            let rect = NSRect(x: 50, y: yPos, width: 512, height: 20)
            stat.draw(in: rect, withAttributes: statAttributes)
            yPos -= 25
        }
        
        // Daily data
        yPos -= 30
        let headerRect = NSRect(x: 50, y: yPos, width: 512, height: 20)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 16),
            .foregroundColor: NSColor.black
        ]
        "Daily Work Locations".draw(in: headerRect, withAttributes: headerAttributes)
        yPos -= 30
        
        let dayAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10),
            .foregroundColor: NSColor.darkGray
        ]
        
        for day in data {
            if yPos < 50 { // Start new page if needed
                pdfContext.endPDFPage()
                pdfContext.beginPDFPage(nil)
                yPos = 742
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dayText = "\(dateFormatter.string(from: day.date)): \(day.displayStatus)"
            
            let rect = NSRect(x: 50, y: yPos, width: 512, height: 15)
            dayText.draw(in: rect, withAttributes: dayAttributes)
            yPos -= 18
        }
        
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        NSGraphicsContext.restoreGraphicsState()
        
        return pdfData as Data
    }
    
    private func generateCSVReport(from data: [ReportDay]) -> String {
        var csv = "Date,Work Location,Weekend,Holiday,PTO\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        for day in data {
            let date = dateFormatter.string(from: day.date)
            let location = day.displayStatus
            let weekend = day.isWeekend ? "Yes" : "No"
            let holiday = day.isHoliday ? "Yes" : "No"
            let pto = day.isPTO ? "Yes" : "No"
            
            csv += "\(date),\(location),\(weekend),\(holiday),\(pto)\n"
        }
        
        return csv
    }
}

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
    let holidayPtoDays: Int
    let officePercentage: Int
    let homePercentage: Int
    let holidayPtoPercentage: Int
    let hasLongGaps: Bool
    
    init(from data: [ReportDay], includeWeekends: Bool) {
        let relevantDays = includeWeekends ? data : data.filter { !$0.isWeekend }
        
        self.totalDays = relevantDays.count
        self.officeDays = relevantDays.filter { $0.workLocation == .workFromOffice }.count
        self.homeDays = relevantDays.filter { $0.workLocation == .workFromHome }.count
        self.holidayPtoDays = relevantDays.filter { $0.isHoliday || $0.isPTO }.count
        
        if totalDays > 0 {
            self.officePercentage = Int(round(Double(officeDays) / Double(totalDays) * 100))
            self.homePercentage = Int(round(Double(homeDays) / Double(totalDays) * 100))
            self.holidayPtoPercentage = Int(round(Double(holidayPtoDays) / Double(totalDays) * 100))
        } else {
            self.officePercentage = 0
            self.homePercentage = 0
            self.holidayPtoPercentage = 0
        }
        
        // Check for gaps longer than 1 week
        self.hasLongGaps = Self.hasLongDataGaps(in: data)
    }
    
    private static func hasLongDataGaps(in data: [ReportDay]) -> Bool {
        let workDays = data.filter { !$0.isWeekend }
        var consecutiveEmptyDays = 0
        
        for day in workDays {
            if day.workLocation == nil && !day.isHoliday && !day.isPTO {
                consecutiveEmptyDays += 1
                if consecutiveEmptyDays > 5 { // More than 1 week of work days
                    return true
                }
            } else {
                consecutiveEmptyDays = 0
            }
        }
        
        return false
    }
} 
