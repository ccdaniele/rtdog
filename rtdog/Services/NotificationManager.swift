import Foundation
import UserNotifications
import AppKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    NSLog("✅ Notification permission granted")
                    // Also check the actual settings after permission is granted
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        NSLog("📱 Permission granted - Status: \(settings.authorizationStatus.rawValue)")
                        NSLog("🔔 Alert setting: \(settings.alertSetting.rawValue)")
                    }
                } else if let error = error {
                    NSLog("❌ Notification permission denied: \(error.localizedDescription)")
                } else {
                    NSLog("❌ Notification permission denied by user")
                }
            }
        }
    }
    
    func scheduleNotification(for settings: AppSettings, remainingDays: Int) {
        // First check if notifications are enabled
        guard settings.enableNotifications else {
            NSLog("⚠️ Notifications are disabled in settings")
            return
        }
        
        // Check if we have notification days selected
        guard !settings.notificationDays.isEmpty else {
            NSLog("⚠️ No notification days selected")
            return
        }
        
        // Check permission status
        UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
            guard notificationSettings.authorizationStatus == .authorized else {
                NSLog("⚠️ Notification permission not granted: \(notificationSettings.authorizationStatus)")
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
        
        NSLog("📅 Scheduling notifications for:")
        NSLog("   Time: \(hour):\(String(format: "%02d", minute))")
        NSLog("   Days: \(settings.notificationDays)")
        NSLog("   Enabled: \(settings.enableNotifications)")
        
        // Schedule for each enabled day - using a more reliable approach
        for dayOfWeek in settings.notificationDays {
            // Find the next occurrence of this weekday at the specified time
            let nextDate = nextOccurrenceOfWeekday(dayOfWeek, hour: hour, minute: minute)
            
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "workLocation_\(dayOfWeek)", content: content, trigger: trigger)
            
            // Get the weekday name for better debugging
            let weekdayName = Calendar.current.weekdaySymbols[dayOfWeek - 1]
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    NSLog("❌ Error scheduling notification for \(weekdayName) (weekday \(dayOfWeek)): \(error.localizedDescription)")
                } else {
                    NSLog("✅ Scheduled notification for \(weekdayName) (weekday \(dayOfWeek)) at \(dateFormatter.string(from: nextDate))")
                }
            }
        }
        
        // Schedule repeating weekly notifications
        scheduleWeeklyRepeatingNotifications(for: settings, content: content)
    }
    
    private func nextOccurrenceOfWeekday(_ weekday: Int, hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Try today first
        if let todayAtTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) {
            let todayWeekday = calendar.component(.weekday, from: now)
            
            // If it's the right day and the time hasn't passed yet
            if todayWeekday == weekday && todayAtTime > now {
                return todayAtTime
            }
        }
        
        // Find next occurrence of this weekday
        var nextDate = now
        for _ in 0..<7 {
            if let candidateDate = calendar.date(byAdding: .day, value: 1, to: nextDate) {
                nextDate = candidateDate
                let candidateWeekday = calendar.component(.weekday, from: nextDate)
                
                if candidateWeekday == weekday {
                    if let finalDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: nextDate) {
                        return finalDate
                    }
                }
            }
        }
        
        // Fallback - just add a day
        return calendar.date(byAdding: .day, value: 1, to: now) ?? now
    }
    
    private func scheduleWeeklyRepeatingNotifications(for settings: AppSettings, content: UNMutableNotificationContent) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: settings.notificationTime)
        let minute = calendar.component(.minute, from: settings.notificationTime)
        
        NSLog("📅 Setting up weekly repeating notifications...")
        
        for dayOfWeek in settings.notificationDays {
            let dateComponents = DateComponents(
                hour: hour,
                minute: minute,
                weekday: dayOfWeek
            )
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "weekly_\(dayOfWeek)", content: content, trigger: trigger)
            
            let weekdayName = Calendar.current.weekdaySymbols[dayOfWeek - 1]
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    NSLog("❌ Error scheduling weekly notification for \(weekdayName): \(error.localizedDescription)")
                } else {
                    NSLog("✅ Scheduled weekly repeating notification for \(weekdayName) at \(hour):\(String(format: "%02d", minute))")
                }
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        NSLog("🗑️ Cancelled all pending notifications")
    }
    
    func rescheduleNotifications(for settings: AppSettings, remainingDays: Int) {
        NSLog("🔄 Rescheduling notifications...")
        cancelAllNotifications()
        if settings.enableNotifications {
            scheduleNotification(for: settings, remainingDays: remainingDays)
        } else {
            NSLog("⚠️ Notifications disabled, not scheduling")
        }
    }
    
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            NSLog("📋 Pending notifications: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let components = trigger.dateComponents
                    NSLog("   - \(request.identifier): weekday=\(components.weekday ?? -1), hour=\(components.hour ?? -1), minute=\(components.minute ?? -1), repeats=\(trigger.repeats)")
                } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    NSLog("   - \(request.identifier): interval=\(trigger.timeInterval)s, repeats=\(trigger.repeats)")
                } else {
                    NSLog("   - \(request.identifier): \(request.trigger?.description ?? "No trigger")")
                }
            }
        }
    }
    
    func testNotification() {
        NSLog("🧪 === TEST NOTIFICATION STARTING ===")
        
        // First check permission before trying to send
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            NSLog("🧪 Test Notification - Permission Status: \(settings.authorizationStatus.rawValue)")
            
            if settings.authorizationStatus != .authorized {
                NSLog("❌ Cannot send test notification - permission not granted")
                NSLog("💡 Try: System Preferences > Notifications & Focus > rtdog > Allow Notifications")
                
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Notification Permission Required"
                    alert.informativeText = "Notifications are not authorized. Please enable them in System Preferences > Notifications & Focus > rtdog > Allow Notifications"
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
                return
            }
            
            NSLog("✅ Permission granted - scheduling test notification")
            
            // Schedule a test notification for 2 seconds from now (reduced time)
            let content = UNMutableNotificationContent()
            content.title = "rtdog - Test Notification"
            content.body = "This is a test notification from rtdog"
            content.sound = UNNotificationSound.default
            
            // Add action buttons to test the category system
            let testAction = UNNotificationAction(identifier: "test_action", title: "Test Action", options: [])
            let category = UNNotificationCategory(identifier: "testCategory", actions: [testAction], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
            content.categoryIdentifier = "testCategory"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
            let request = UNNotificationRequest(identifier: "test_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    NSLog("❌ Error scheduling test notification: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "Test Notification Failed"
                        alert.informativeText = "Error: \(error.localizedDescription)"
                        alert.alertStyle = .critical
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                } else {
                    NSLog("✅ Test notification scheduled for 2 seconds from now")
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "Test Notification Scheduled"
                        alert.informativeText = "A test notification should appear in 2 seconds. Check your notification center if it doesn't appear as a banner."
                        alert.alertStyle = .informational
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                }
            }
        }
        
        NSLog("🧪 === TEST NOTIFICATION SETUP COMPLETE ===")
    }
    
    func testScheduledNotification() {
        NSLog("🧪 === TEST SCHEDULED NOTIFICATION STARTING ===")
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                NSLog("❌ Cannot send scheduled test notification - permission not granted")
                return
            }
            
            NSLog("✅ Permission granted - scheduling test notification for next minute")
            
            let calendar = Calendar.current
            let now = Date()
            
            // Schedule for next minute
            if let nextMinute = calendar.date(byAdding: .minute, value: 1, to: now) {
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextMinute)
                
                let content = UNMutableNotificationContent()
                content.title = "rtdog - Scheduled Test"
                content.body = "This is a test of scheduled notifications"
                content.sound = UNNotificationSound.default
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: "scheduledTest_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
                
                let formatter = DateFormatter()
                formatter.timeStyle = .medium
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        NSLog("❌ Error scheduling test notification: \(error.localizedDescription)")
                    } else {
                        NSLog("✅ Scheduled test notification for \(formatter.string(from: nextMinute))")
                    }
                }
            }
        }
        
        NSLog("🧪 === TEST SCHEDULED NOTIFICATION SETUP COMPLETE ===")
    }
    
    func debugNotificationStatus() {
        NSLog("🔍 === NOTIFICATION DEBUG INFORMATION ===")
        
        // Check permission status
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                NSLog("📱 Authorization Status: \(settings.authorizationStatus.rawValue)")
                let statusMessage: String
                switch settings.authorizationStatus {
                case .notDetermined:
                    statusMessage = "Not determined - need to request permission"
                    NSLog("   → Not determined - need to request permission")
                case .denied:
                    statusMessage = "DENIED - user needs to enable in System Preferences"
                    NSLog("   → DENIED - user needs to enable in System Preferences")
                case .authorized:
                    statusMessage = "✅ Authorized"
                    NSLog("   → ✅ Authorized")
                case .provisional:
                    statusMessage = "Provisional authorization"
                    NSLog("   → Provisional authorization")
                case .ephemeral:
                    statusMessage = "Ephemeral authorization"
                    NSLog("   → Ephemeral authorization")
                @unknown default:
                    statusMessage = "Unknown status"
                    NSLog("   → Unknown status")
                }
                
                NSLog("🔔 Alert Setting: \(settings.alertSetting.rawValue)")
                NSLog("🔊 Sound Setting: \(settings.soundSetting.rawValue)")
                NSLog("🏷️ Badge Setting: \(settings.badgeSetting.rawValue)")
                NSLog("📣 Notification Center Setting: \(settings.notificationCenterSetting.rawValue)")
                NSLog("🔒 Lock Screen Setting: \(settings.lockScreenSetting.rawValue)")
                NSLog("🚨 Critical Alert Setting: \(settings.criticalAlertSetting.rawValue)")
                
                if #available(macOS 12.0, *) {
                    NSLog("⏰ Time Sensitive Setting: \(settings.timeSensitiveSetting.rawValue)")
                }
                
                NSLog("🎯 Scheduled Delivery Setting: \(settings.scheduledDeliverySetting.rawValue)")
                
                // Show alert with key information
                let alertMessage = """
                Authorization Status: \(settings.authorizationStatus.rawValue) (\(statusMessage))
                Alert Setting: \(settings.alertSetting.rawValue)
                Sound Setting: \(settings.soundSetting.rawValue)
                
                Check Console app for full details!
                """
                
                // Show alert on macOS
                let alert = NSAlert()
                alert.messageText = "Notification Debug Info"
                alert.informativeText = alertMessage
                alert.alertStyle = .informational
                alert.addButton(withTitle: "OK")
                alert.runModal()
                
                // List pending notifications
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    NSLog("📋 Pending Notifications: \(requests.count)")
                    for request in requests {
                        NSLog("   - ID: \(request.identifier)")
                        NSLog("     Title: \(request.content.title)")
                        NSLog("     Body: \(request.content.body)")
                        if let trigger = request.trigger {
                            NSLog("     Trigger: \(trigger)")
                        }
                    }
                }
                
                // List delivered notifications
                UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                    NSLog("📬 Delivered Notifications: \(notifications.count)")
                    for notification in notifications {
                        NSLog("   - ID: \(notification.request.identifier)")
                        NSLog("     Title: \(notification.request.content.title)")
                        NSLog("     Date: \(notification.date)")
                    }
                }
                
                NSLog("🔍 === END DEBUG INFORMATION ===")
            }
        }
    }
} 
