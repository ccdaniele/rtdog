import Foundation
import Combine

class WorkDayManager: ObservableObject {
    @Published var workDays: [Date: WorkDay] = [:]
    @Published var settings: AppSettings = AppSettings.default
    @Published var currentMonth: Date = Date()
    
    private let userDefaults = UserDefaults.standard
    private let workDaysKey = "workDays"
    private let settingsKey = "appSettings"
    
    init() {
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
        let monthRange = calendar.range(of: .day, in: .month, for: month)!
        let daysInMonth = monthRange.count
        
        var workingDays = 0
        var completedOfficeDays = 0
        var bankedDays = 0
        
        // Calculate for each day in the month
        for day in 1...daysInMonth {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: calendar.startOfDay(for: month)) else { continue }
            
            let workDay = getWorkDay(for: date)
            
            if workDay.isWorkingDay {
                workingDays += 1
                
                if workDay.status == .workFromOffice {
                    completedOfficeDays += 1
                }
            }
        }
        
        // Calculate required office days (3 days per week average)
        let requiredOfficeDays = Int((Double(workingDays) / 5.0) * 3.0)
        
        // Calculate banked days from previous weeks in the same month
        bankedDays = max(0, completedOfficeDays - requiredOfficeDays)
        
        let remainingOfficeDays = max(0, requiredOfficeDays - completedOfficeDays)
        
        return MonthlyQuota(
            requiredOfficeDays: requiredOfficeDays,
            completedOfficeDays: completedOfficeDays,
            remainingOfficeDays: remainingOfficeDays,
            bankedDays: bankedDays
        )
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
