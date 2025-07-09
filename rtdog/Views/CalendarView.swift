import SwiftUI

struct CalendarView: View {
    @ObservedObject var workDayManager: WorkDayManager
    @State private var selectedDate: Date?
    @State private var showingActionSheet = false
    @State private var showingMonthPicker = false
    
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
            // Month navigation
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
                            isCurrentMonth: calendar.isDate(date, equalTo: workDayManager.currentMonth, toGranularity: .month)
                        )
                        .onTapGesture {
                            selectedDate = date
                            showingActionSheet = true
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
            
            // Always show Clear Status option
            Button("Clear Status", role: .destructive) {
                if let date = selectedDate {
                    workDayManager.setWorkDay(date: date, status: .unlogged)
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingMonthPicker) {
            MonthPickerView(currentMonth: $workDayManager.currentMonth, isPresented: $showingMonthPicker)
        }
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
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var backgroundColor: Color {
        // Always show status colors regardless of month
        switch workDay.effectiveStatus {
        case .workFromOffice:
            return Color.blue.opacity(isCurrentMonth ? 0.3 : 0.2)
        case .workFromHome:
            return Color.green.opacity(isCurrentMonth ? 0.3 : 0.2)
        case .notWorkingDay:
            return Color.gray.opacity(isCurrentMonth ? 0.3 : 0.2)
        case .unlogged:
            return isCurrentMonth ? Color.white : Color.gray.opacity(0.05)
        }
    }
    
    private var textColor: Color {
        let alpha: Double = isCurrentMonth ? 1.0 : 0.7
        
        switch workDay.effectiveStatus {
        case .workFromOffice:
            return Color.blue.opacity(alpha)
        case .workFromHome:
            return Color.green.opacity(alpha)
        case .notWorkingDay:
            return Color.gray.opacity(alpha)
        case .unlogged:
            return Color.primary.opacity(alpha)
        }
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
            }
        }
        .frame(height: 40)
    }
    
    private var strokeColor: Color {
        if Calendar.current.isDateInToday(date) {
            return Color.orange
        } else if !isCurrentMonth && workDay.status != .unlogged {
            return Color.secondary.opacity(0.3)
        } else {
            return Color.clear
        }
    }
    
    private var strokeWidth: CGFloat {
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
            return Color.blue
        case .workFromHome:
            return Color.green
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
                                .background(Color.gray.opacity(0.1))
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
