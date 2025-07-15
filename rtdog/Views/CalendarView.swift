import SwiftUI

// MARK: - Color Extensions for Dark Mode Support
extension Color {
    init(light: Color, dark: Color) {
        // Use dynamic color that adapts to appearance
        if #available(macOS 10.15, *) {
            self = Color(NSColor(name: nil, dynamicProvider: { trait in
                if trait.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
                    return NSColor(dark)
                } else {
                    return NSColor(light)
                }
            }))
        } else {
            self = light
        }
    }
}

struct CalendarView: View {
    @ObservedObject var workDayManager: WorkDayManager
    @State private var selectedDate: Date?
    @State private var showingActionSheet = false
    @State private var showingMonthPicker = false
    
    // Bulk clear functionality
    @State private var isInClearMode = false
    @State private var selectedDatesForClearing: Set<Date> = []
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private var dialogTitle: String {
        guard let date = selectedDate else { return "Set work location" }
        let dateString = dateFormatter.string(from: date)
        let isToday = Calendar.current.isDateInToday(date)
        let isPast = date < Calendar.current.startOfDay(for: Date())
        let _ = date > Calendar.current.startOfDay(for: Date())
        
        if isToday {
            return "Set work location for Today (\(dateString))"
        } else if isPast {
            return "Update work location for \(dateString)"
        } else {
            return "Set work location for \(dateString)"
        }
    }
    
    private var isPTOToggleText: String {
        guard let date = selectedDate else { return "Mark as PTO/Holiday" }
        let workDay = workDayManager.getWorkDay(for: date)
        return workDay.isPTO ? "Remove PTO/Holiday" : "Mark as PTO/Holiday"
    }
    
    var body: some View {
        VStack {
            // Month navigation and clear mode header
            if isInClearMode {
                clearModeHeader
            } else {
                normalModeHeader
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Weekday headers
                ForEach(weekdayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
                
                // Calendar days
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            workDay: workDayManager.getWorkDay(for: date),
                            isCurrentMonth: calendar.isDate(date, equalTo: workDayManager.currentMonth, toGranularity: .month),
                            isInClearMode: isInClearMode,
                            isSelectedForClearing: selectedDatesForClearing.contains(date)
                        )
                        .onTapGesture {
                            if isInClearMode {
                                toggleDateSelection(date)
                            } else {
                                selectedDate = date
                                showingActionSheet = true
                            }
                        }
                    } else {
                        // Empty cell for padding
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal)
            
            // Clear Days button section (moved below calendar)
            if !isInClearMode {
                clearDaysButtonSection
                    .padding(.top, 16)
            }
        }
        .confirmationDialog(dialogTitle, isPresented: $showingActionSheet) {
            Button("Work From Office") {
                if let date = selectedDate {
                    workDayManager.setWorkDay(date: date, status: .workFromOffice)
                }
            }
            
            Button("Work From Home") {
                if let date = selectedDate {
                    workDayManager.setWorkDay(date: date, status: .workFromHome)
                }
            }
            
            Button(isPTOToggleText) {
                if let date = selectedDate {
                    workDayManager.togglePTO(for: date)
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingMonthPicker) {
            MonthPickerView(currentMonth: $workDayManager.currentMonth, isPresented: $showingMonthPicker)
        }
    }
    
    // MARK: - Header Views
    
    @ViewBuilder
    private var normalModeHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            VStack {
                Button(action: { showingMonthPicker = true }) {
                    Text(monthYearString)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
                
                HStack(spacing: 16) {
                    if !calendar.isDate(workDayManager.currentMonth, equalTo: Date(), toGranularity: .month) {
                        Button("Today") {
                            jumpToToday()
                        }
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    }
                    
                    Button("Recent") {
                        showingMonthPicker = true
                    }
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }
            }
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    private var clearModeHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Select days to clear")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Cancel") {
                    exitClearMode()
                }
                .foregroundColor(.secondary)
            }
            
            HStack {
                Text("\(selectedDatesForClearing.count) day(s) selected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !selectedDatesForClearing.isEmpty {
                    Button("Clear Selected") {
                        clearSelectedDays()
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
    }
    
    // MARK: - Clear Days Button Section
    
    @ViewBuilder
    private var clearDaysButtonSection: some View {
        VStack(spacing: 8) {
            Button(action: enterClearMode) {
                HStack {
                    Image(systemName: "trash.circle.fill")
                        .font(.title3)
                    Text("Clear Days")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.red.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Select multiple days to clear their work status and PTO")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Clear Mode Functions
    
    private func enterClearMode() {
        isInClearMode = true
        selectedDatesForClearing.removeAll()
    }
    
    private func exitClearMode() {
        isInClearMode = false
        selectedDatesForClearing.removeAll()
    }
    
    private func toggleDateSelection(_ date: Date) {
        if selectedDatesForClearing.contains(date) {
            selectedDatesForClearing.remove(date)
        } else {
            selectedDatesForClearing.insert(date)
        }
    }
    
    private func clearSelectedDays() {
        for date in selectedDatesForClearing {
            let workDay = workDayManager.getWorkDay(for: date)
            
            // Clear work status
            workDayManager.setWorkDay(date: date, status: .unlogged)
            
            // Clear PTO if it's set
            if workDay.isPTO {
                workDayManager.togglePTO(for: date)
            }
        }
        exitClearMode()
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: workDayManager.currentMonth)
    }
    
    private var weekdayHeaders: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }
    
    private var calendarDays: [Date?] {
        let startOfMonth = calendar.startOfDay(for: workDayManager.currentMonth)
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let numberOfDays = range.count
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmptyDays = (firstWeekday - 1)
        
        var days: [Date?] = []
        
        // Add empty days for padding
        for _ in 0..<leadingEmptyDays {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func previousMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: -1, to: workDayManager.currentMonth) {
            // Ensure we're at the start of the month
            let startOfMonth = calendar.dateInterval(of: .month, for: newDate)?.start ?? newDate
            workDayManager.currentMonth = calendar.startOfDay(for: startOfMonth)
        }
    }
    
    private func nextMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: 1, to: workDayManager.currentMonth) {
            // Ensure we're at the start of the month
            let startOfMonth = calendar.dateInterval(of: .month, for: newDate)?.start ?? newDate
            workDayManager.currentMonth = calendar.startOfDay(for: startOfMonth)
        }
    }
    
    private func jumpToToday() {
        let calendar = Calendar.current
        let today = Date()
        // Ensure we're at the start of the current month
        let startOfMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        workDayManager.currentMonth = calendar.startOfDay(for: startOfMonth)
    }
}

struct CalendarDayView: View {
    let date: Date
    let workDay: WorkDay
    let isCurrentMonth: Bool
    let isInClearMode: Bool
    let isSelectedForClearing: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var backgroundColor: Color {
        if isInClearMode && isSelectedForClearing {
            return Color.red.opacity(0.3)
        }
        
        // Always show status colors regardless of month with dark mode support
        switch workDay.effectiveStatus {
        case .workFromOffice:
            return officeBackgroundColor.opacity(isCurrentMonth ? 0.4 : 0.25)
        case .workFromHome:
            return homeBackgroundColor.opacity(isCurrentMonth ? 0.4 : 0.25)
        case .notWorkingDay:
            return ptoBackgroundColor.opacity(isCurrentMonth ? 0.4 : 0.25)
        case .unlogged:
            return isCurrentMonth ? adaptiveUnloggedBackground : Color.clear
        }
    }
    
    // Adaptive colors that work well in both light and dark mode
    private var officeBackgroundColor: Color {
        Color.blue
    }
    
    private var homeBackgroundColor: Color {
        Color.green
    }
    
    private var ptoBackgroundColor: Color {
        Color.secondary
    }
    
    private var adaptiveUnloggedBackground: Color {
        Color(NSColor.controlBackgroundColor)
    }
    
    private var textColor: Color {
        if isInClearMode && isSelectedForClearing {
            return Color.red
        }
        
        let alpha: Double = isCurrentMonth ? 1.0 : 0.7
        
        switch workDay.effectiveStatus {
        case .workFromOffice:
            return adaptiveOfficeTextColor.opacity(alpha)
        case .workFromHome:
            return adaptiveHomeTextColor.opacity(alpha)
        case .notWorkingDay:
            return adaptivePTOTextColor.opacity(alpha)
        case .unlogged:
            return Color.primary.opacity(alpha)
        }
    }
    
    // Adaptive text colors with better contrast for dark mode
    private var adaptiveOfficeTextColor: Color {
        Color(light: Color.blue.opacity(0.8), dark: Color.blue.opacity(0.9))
    }
    
    private var adaptiveHomeTextColor: Color {
        Color(light: Color.green.opacity(0.8), dark: Color.green.opacity(0.9))
    }
    
    private var adaptivePTOTextColor: Color {
        Color.secondary
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .stroke(strokeColor, lineWidth: strokeWidth)
            
            VStack {
                Text(dayNumber)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                
                if !isCurrentMonth && workDay.status != .unlogged {
                    Circle()
                        .fill(statusIndicatorColor)
                        .frame(width: 4, height: 4)
                }
                
                // Selection indicator for clear mode
                if isInClearMode && isSelectedForClearing {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption2)
                }
            }
        }
        .frame(height: 40)
        .scaleEffect(isInClearMode && isSelectedForClearing ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelectedForClearing)
    }
    
    private var strokeColor: Color {
        if isInClearMode && isSelectedForClearing {
            return Color.red
        }
        
        if Calendar.current.isDateInToday(date) {
            return Color.orange
        } else if !isCurrentMonth && workDay.status != .unlogged {
            return Color.secondary.opacity(0.3)
        } else {
            return Color.clear
        }
    }
    
    private var strokeWidth: CGFloat {
        if isInClearMode && isSelectedForClearing {
            return 2
        }
        
        if Calendar.current.isDateInToday(date) {
            return 2
        } else if !isCurrentMonth && workDay.status != .unlogged {
            return 1
        } else {
            return 0
        }
    }
    
    private var statusIndicatorColor: Color {
        switch workDay.status {
        case .workFromOffice:
            return officeBackgroundColor
        case .workFromHome:
            return homeBackgroundColor
        default:
            return Color.clear
        }
    }
}

struct MonthPickerView: View {
    @Binding var currentMonth: Date
    @Binding var isPresented: Bool
    @State private var selectedDate: Date = Date()
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Month & Year")
                    .font(.headline)
                    .padding(.top)
                
                DatePicker(
                    "Month and Year",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Access")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(recentMonths, id: \.self) { date in
                            Button(action: {
                                selectedDate = date
                                applySelection()
                            }) {
                                VStack {
                                    Text(monthFormatter.string(from: date))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text(yearFormatter.string(from: date))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Select Month")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Select") {
                        applySelection()
                    }
                }
            }
        }
        .onAppear {
            // Ensure selectedDate is set to the start of the currentMonth
            let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
            selectedDate = calendar.startOfDay(for: startOfMonth)
        }
    }
    
    private var recentMonths: [Date] {
        let today = Date()
        return (0..<6).compactMap { monthsBack in
            calendar.date(byAdding: .month, value: -monthsBack, to: today)
        }
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }
    
    private var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }
    
    private func applySelection() {
        // Ensure we're setting to the start of the selected month
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        currentMonth = calendar.startOfDay(for: startOfMonth)
        isPresented = false
    }
}
