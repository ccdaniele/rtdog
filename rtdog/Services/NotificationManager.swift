import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(for settings: AppSettings, remainingDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Work Location Tracker"
        content.body = "Please log your work location for today. You have \(remainingDays) office days left to meet your monthly quota."
        content.sound = UNNotificationSound.default
        
        // Add action buttons
        let officeAction = UNNotificationAction(identifier: "office", title: "I worked from the Office", options: [])
        let homeAction = UNNotificationAction(identifier: "home", title: "I worked from Home", options: [])
        
        let category = UNNotificationCategory(identifier: "workLocationCategory", actions: [officeAction, homeAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "workLocationCategory"
        
        // Schedule for each enabled day
        for dayOfWeek in settings.notificationDays {
            let dateComponents = DateComponents(
                hour: Calendar.current.component(.hour, from: settings.notificationTime),
                minute: Calendar.current.component(.minute, from: settings.notificationTime),
                weekday: dayOfWeek
            )
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "workLocation_\(dayOfWeek)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func rescheduleNotifications(for settings: AppSettings, remainingDays: Int) {
        cancelAllNotifications()
        if settings.enableNotifications {
            scheduleNotification(for: settings, remainingDays: remainingDays)
        }
    }
} 
