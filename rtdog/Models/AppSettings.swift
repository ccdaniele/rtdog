import Foundation

struct AppSettings: Codable {
    var notificationTime: Date
    var notificationDays: Set<Int> // 1 = Sunday, 2 = Monday, etc.
    var weekendDays: Set<Int>
    var holidays: Set<Date>
    var ptodays: Set<Date>
    var enableNotifications: Bool
    
    static let `default` = AppSettings(
        notificationTime: Calendar.current.date(bySettingHour: 16, minute: 30, second: 0, of: Date()) ?? Date(),
        notificationDays: Set([2, 3, 4, 5, 6]), // Monday to Friday
        weekendDays: Set([1, 7]), // Sunday and Saturday
        holidays: Set<Date>(),
        ptodays: Set<Date>(),
        enableNotifications: true
    )
    
    func isWeekend(_ date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekendDays.contains(weekday)
    }
    
    func isHoliday(_ date: Date) -> Bool {
        return holidays.contains(Calendar.current.startOfDay(for: date))
    }
    
    func isPTO(_ date: Date) -> Bool {
        return ptodays.contains(Calendar.current.startOfDay(for: date))
    }
    
    func shouldSendNotification(for date: Date) -> Bool {
        guard enableNotifications else { return false }
        let weekday = Calendar.current.component(.weekday, from: date)
        return notificationDays.contains(weekday)
    }
} 
