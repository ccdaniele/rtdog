import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permission granted")
                } else if let error = error {
                    print("❌ Notification permission denied: \(error.localizedDescription)")
                } else {
                    print("❌ Notification permission denied by user")
                }
            }
        }
    }
    
    func scheduleNotification(for settings: AppSettings, remainingDays: Int) {
        // First check if notifications are enabled
        guard settings.enableNotifications else {
            print("⚠️ Notifications are disabled in settings")
            return
        }
        
        // Check if we have notification days selected
        guard !settings.notificationDays.isEmpty else {
            print("⚠️ No notification days selected")
            return
        }
        
        // Check permission status
        UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
            guard notificationSettings.authorizationStatus == .authorized else {
                print("⚠️ Notification permission not granted: \(notificationSettings.authorizationStatus)")
                return
            }
            
            // Schedule notifications on main thread
            DispatchQueue.main.async {
                self.scheduleNotificationsInternal(for: settings, remainingDays: remainingDays)
            }
        }
    }
    
    private func scheduleNotificationsInternal(for settings: AppSettings, remainingDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = "rtdog"
        content.body = "Please log your work location for today. You have \(remainingDays) office days left this month."
        content.sound = UNNotificationSound.default
        
        // Add action buttons
        let officeAction = UNNotificationAction(identifier: "office", title: "I worked from the Office", options: [])
        let homeAction = UNNotificationAction(identifier: "home", title: "I worked from Home", options: [])
        
        let category = UNNotificationCategory(identifier: "workLocationCategory", actions: [officeAction, homeAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "workLocationCategory"
        
        // Get notification time components
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: settings.notificationTime)
        let minute = calendar.component(.minute, from: settings.notificationTime)
        
        print("📅 Scheduling notifications for:")
        print("   Time: \(hour):\(String(format: "%02d", minute))")
        print("   Days: \(settings.notificationDays)")
        
        // Schedule for each enabled day
        for dayOfWeek in settings.notificationDays {
            let dateComponents = DateComponents(
                hour: hour,
                minute: minute,
                weekday: dayOfWeek
            )
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "workLocation_\(dayOfWeek)", content: content, trigger: trigger)
            
            // Get the weekday name for better debugging
            let weekdayName = Calendar.current.weekdaySymbols[dayOfWeek - 1]
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling notification for \(weekdayName) (weekday \(dayOfWeek)): \(error.localizedDescription)")
                } else {
                    print("✅ Scheduled notification for \(weekdayName) (weekday \(dayOfWeek)) at \(hour):\(String(format: "%02d", minute))")
                }
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Cancelled all pending notifications")
    }
    
    func rescheduleNotifications(for settings: AppSettings, remainingDays: Int) {
        print("🔄 Rescheduling notifications...")
        cancelAllNotifications()
        if settings.enableNotifications {
            scheduleNotification(for: settings, remainingDays: remainingDays)
        } else {
            print("⚠️ Notifications disabled, not scheduling")
        }
    }
    
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📋 Pending notifications: \(requests.count)")
            for request in requests {
                print("   - \(request.identifier): \(request.trigger?.description ?? "No trigger")")
            }
        }
    }
    
    func testNotification() {
        // Schedule a test notification for 5 seconds from now
        let content = UNMutableNotificationContent()
        content.title = "rtdog - Test Notification"
        content.body = "This is a test notification from rtdog"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling test notification: \(error.localizedDescription)")
            } else {
                print("✅ Test notification scheduled for 5 seconds from now")
            }
        }
    }
} 
