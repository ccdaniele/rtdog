import Foundation
import Combine

class WorkDayManager: ObservableObject {
    static let shared = WorkDayManager()
    
    @Published var workDays: [Date: WorkDay] = [:]
    @Published var settings: AppSettings = AppSettings.default
    @Published var currentMonth: Date = {
        let calendar = Calendar.current
        let today = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        return calendar.startOfDay(for: startOfMonth)
    }()
    
    private let userDefaults = UserDefaults.standard
    private let workDaysKey = "workDays"
    private let settingsKey = "appSettings"
    
    private init() {
        loadData()
    }
    
    // MARK: - Data Persistence
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(Array(workDays.values)) {
            userDefaults.set(encoded, forKey: workDaysKey)
        }
        
        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }
    }
    
    private func loadData() {
        if let data = userDefaults.data(forKey: workDaysKey),
           let decoded = try? JSONDecoder().decode([WorkDay].self, from: data) {
            workDays = Dictionary(uniqueKeysWithValues: decoded.map { ($0.date, $0) })
        }
        
        if let data = userDefaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }
    
    // MARK: - Work Day Management
    
    func setWorkDay(date: Date, status: WorkStatus) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        let workDay = WorkDay(
            date: normalizedDate,
            status: status,
            isWeekend: settings.isWeekend(normalizedDate),
            isHoliday: settings.isHoliday(normalizedDate),
            isPTO: settings.isPTO(normalizedDate)
        )
        workDays[normalizedDate] = workDay
        saveData()
    }
    
    func getWorkDay(for date: Date) -> WorkDay {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        return workDays[normalizedDate] ?? WorkDay(
            date: normalizedDate,
            status: .unlogged,
            isWeekend: settings.isWeekend(normalizedDate),
            isHoliday: settings.isHoliday(normalizedDate),
            isPTO: settings.isPTO(normalizedDate)
        )
    }
    
    func togglePTO(for date: Date) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        var newPTODays = settings.ptodays
        
        if settings.isPTO(normalizedDate) {
            newPTODays.remove(normalizedDate)
        } else {
            newPTODays.insert(normalizedDate)
        }
        
        settings.ptodays = newPTODays
        
        // Update the work day
        if var workDay = workDays[normalizedDate] {
            workDay.isPTO = settings.isPTO(normalizedDate)
            workDays[normalizedDate] = workDay
        }
        
        saveData()
    }
    
    // MARK: - Monthly Quota Calculation
    
    func getMonthlyQuota(for month: Date) -> MonthlyQuota {
        let calendar = Calendar.current
        
        // Calculate A: Total business days for the month using week-based calculation
        let totalBusinessDays = getBusinessDaysForMonth(month)
        
        // Calculate B: Holidays and PTO days in the month
        let holidayAndPTODays = getHolidayAndPTODaysInMonth(month)
        
        // Apply the formula: (A - B) * 0.6
        let adjustedBusinessDays = totalBusinessDays - holidayAndPTODays
        let requiredOfficeDays = Int(Double(adjustedBusinessDays) * 0.6)
        
        // Calculate completed office days and banked days
        var completedOfficeDays = 0
        let monthRange = calendar.range(of: .day, in: .month, for: month)!
        
        for day in 1...monthRange.count {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: calendar.startOfDay(for: month)) else { continue }
            
            let workDay = getWorkDay(for: date)
            if workDay.status == .workFromOffice {
                completedOfficeDays += 1
            }
        }
        
        // Calculate banked days and remaining office days
        let bankedDays = max(0, completedOfficeDays - requiredOfficeDays)
        let remainingOfficeDays = max(0, requiredOfficeDays - completedOfficeDays)
        
        return MonthlyQuota(
            requiredOfficeDays: requiredOfficeDays,
            completedOfficeDays: completedOfficeDays,
            remainingOfficeDays: remainingOfficeDays,
            bankedDays: bankedDays
        )
    }
    
    // MARK: - Week-Based Business Day Calculation
    
    private func getBusinessDaysForMonth(_ targetMonth: Date) -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: targetMonth)
        let monthNumber = calendar.component(.month, from: targetMonth)
        
        var businessDays = 0
        
        // Get all weeks that intersect with this month
        let firstDayOfMonth = calendar.date(from: DateComponents(year: year, month: monthNumber, day: 1))!
        let lastDayOfMonth = calendar.date(from: DateComponents(year: year, month: monthNumber + 1, day: 0))!
        
        // Find the Monday of the week containing the first day of the month
        let firstWeekStart = getMonday(for: firstDayOfMonth)
        
        // Find the Monday of the week containing the last day of the month
        let lastWeekStart = getMonday(for: lastDayOfMonth)
        
        // Iterate through each week that intersects with this month
        var currentWeekStart = firstWeekStart
        while currentWeekStart <= lastWeekStart {
            let weekOwner = determineWeekOwner(weekStart: currentWeekStart, year: year)
            
            if weekOwner == monthNumber {
                businessDays += 5 // Each week contributes 5 business days
            }
            
            currentWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart)!
        }
        
        return businessDays
    }
    
    private func getMonday(for date: Date) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        // Convert to Monday-based weekday (Monday = 1, Sunday = 7)
        let mondayBasedWeekday = (weekday == 1) ? 7 : weekday - 1
        
        // Calculate days to subtract to get to Monday
        let daysToSubtract = mondayBasedWeekday - 1
        
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: date)!
    }
    
    private func determineWeekOwner(weekStart: Date, year: Int) -> Int {
        let calendar = Calendar.current
        
        // Check each month to see if this week should belong to it
        for month in 1...12 {
            let firstDayOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
            let lastDayOfMonth = calendar.date(from: DateComponents(year: year, month: month + 1, day: 0))!
            
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            
            // Check if this week contains the first day of this month
            if firstDayOfMonth >= weekStart && firstDayOfMonth <= weekEnd {
                let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
                let mondayBasedWeekday = (firstDayWeekday == 1) ? 7 : firstDayWeekday - 1
                
                if mondayBasedWeekday <= 3 { // Mon, Tue, Wed
                    return month
                } else { // Thu, Fri, Sat, Sun
                    return month == 1 ? 12 : month - 1 // Previous month
                }
            }
            
            // Check if this week contains the last day of this month
            if lastDayOfMonth >= weekStart && lastDayOfMonth <= weekEnd {
                let lastDayWeekday = calendar.component(.weekday, from: lastDayOfMonth)
                let mondayBasedWeekday = (lastDayWeekday == 1) ? 7 : lastDayWeekday - 1
                
                if mondayBasedWeekday <= 2 { // Mon, Tue
                    return month == 12 ? 1 : month + 1 // Next month
                } else { // Wed, Thu, Fri, Sat, Sun
                    return month
                }
            }
        }
        
        // If the week doesn't contain the first or last day of any month,
        // it's entirely within a month - determine which month from the week's middle
        let midWeek = calendar.date(byAdding: .day, value: 2, to: weekStart)! // Wednesday
        return calendar.component(.month, from: midWeek)
    }
    
    private func getHolidayAndPTODaysInMonth(_ month: Date) -> Int {
        let calendar = Calendar.current
        let monthRange = calendar.range(of: .day, in: .month, for: month)!
        var holidayPTOCount = 0
        
        for day in 1...monthRange.count {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: calendar.startOfDay(for: month)) else { continue }
            
            // Only count holidays and PTO on business days (Monday-Friday)
            let weekday = calendar.component(.weekday, from: date)
            let isBusinessDay = weekday >= 2 && weekday <= 6 // Monday to Friday
            
            if isBusinessDay && (settings.isHoliday(date) || settings.isPTO(date)) {
                holidayPTOCount += 1
            }
        }
        
        return holidayPTOCount
    }
    
    // MARK: - Settings Management
    
    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        
        // Recalculate all work days with new settings
        for (date, workDay) in workDays {
            var updatedWorkDay = workDay
            updatedWorkDay.isWeekend = settings.isWeekend(date)
            updatedWorkDay.isHoliday = settings.isHoliday(date)
            updatedWorkDay.isPTO = settings.isPTO(date)
            workDays[date] = updatedWorkDay
        }
        
        saveData()
    }
    
    // MARK: - Utility Methods
    
    func getDaysInMonth(_ date: Date) -> [Date] {
        let calendar = Calendar.current
        let monthRange = calendar.range(of: .day, in: .month, for: date)!
        let startOfMonth = calendar.startOfDay(for: date)
        
        return monthRange.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    func getWorkingDaysRemaining() -> Int {
        let today = Date()
        let calendar = Calendar.current
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: calendar.startOfDay(for: today))!
        
        var workingDays = 0
        var currentDate = calendar.startOfDay(for: today)
        
        while currentDate < endOfMonth {
            let workDay = getWorkDay(for: currentDate)
            if workDay.isWorkingDay && workDay.status == .unlogged {
                workingDays += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return workingDays
    }
} 
