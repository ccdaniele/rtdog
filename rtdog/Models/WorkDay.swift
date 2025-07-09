import Foundation

enum WorkStatus: String, CaseIterable, Codable {
    case workFromOffice = "WFO"
    case workFromHome = "WFH"
    case notWorkingDay = "NOT_WORKING"
    case unlogged = "UNLOGGED"
    
    var color: String {
        switch self {
        case .workFromOffice: return "blue"
        case .workFromHome: return "green"
        case .notWorkingDay: return "gray"
        case .unlogged: return "white"
        }
    }
    
    var displayName: String {
        switch self {
        case .workFromOffice: return "Work From Office"
        case .workFromHome: return "Work From Home"
        case .notWorkingDay: return "Not Working Day"
        case .unlogged: return "Unlogged"
        }
    }
}

struct WorkDay: Codable, Identifiable {
    var id = UUID()
    let date: Date
    var status: WorkStatus
    var isWeekend: Bool
    var isHoliday: Bool
    var isPTO: Bool
    
    var isWorkingDay: Bool {
        return !isWeekend && !isHoliday && !isPTO
    }
    
    var effectiveStatus: WorkStatus {
        if !isWorkingDay {
            return .notWorkingDay
        }
        return status
    }
    
    init(date: Date, status: WorkStatus = .unlogged, isWeekend: Bool = false, isHoliday: Bool = false, isPTO: Bool = false) {
        self.date = date
        self.status = status
        self.isWeekend = isWeekend
        self.isHoliday = isHoliday
        self.isPTO = isPTO
    }
}

struct MonthlyQuota {
    let requiredOfficeDays: Int
    let completedOfficeDays: Int
    let remainingOfficeDays: Int
    let bankedDays: Int
    
    var isQuotaMet: Bool {
        return remainingOfficeDays <= 0
    }
} 
