//
//  rtdogApp.swift
//  rtdog
//
//  Created by Daniel Calderon on 7/9/25.
//

import SwiftUI
import UserNotifications

@main
struct rtdogApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(DefaultWindowStyle())
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Settings...") {
                    // Open settings window
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let workDayManager = WorkDayManager()
        
        switch response.actionIdentifier {
        case "office":
            workDayManager.setWorkDay(date: Date(), status: .workFromOffice)
        case "home":
            workDayManager.setWorkDay(date: Date(), status: .workFromHome)
        default:
            break
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
