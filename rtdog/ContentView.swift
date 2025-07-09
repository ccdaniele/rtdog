//
//  ContentView.swift
//  rtdog
//
//  Created by Daniel Calderon on 7/9/25.
//

import SwiftUI
import AppKit
import UserNotifications

struct ContentView: View {
    @StateObject private var workDayManager = WorkDayManager()
    @State private var showingSettings = false
    @State private var showingQuickLog = false
    @State private var showingRecentDaysLog = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("rtdog")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Track your hybrid work schedule - Don't forget the office is still there")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Quick log buttons
                    HStack(spacing: 12) {
                        Button(action: { showingQuickLog = true }) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Log Today")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(BorderedButtonStyle())
                        
                        if hasRecentUnloggedDays {
                            Button(action: { showingRecentDaysLog = true }) {
                                VStack {
                                    Image(systemName: "clock.fill")
                                        .font(.title2)
                                    Text("Recent Days")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(BorderedButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)
                
                // Main content area
                HStack(alignment: .top, spacing: 20) {
                    // Calendar section
                    VStack {
                        CalendarView(workDayManager: workDayManager)
                    }
                    .frame(minWidth: 400)
                    
                    // Quota summary section
                    VStack {
                        QuotaSummaryView(workDayManager: workDayManager)
                        
                        Spacer()
                    }
                    .frame(width: 300)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Disclaimer at the bottom
                VStack(spacing: 8) {
                    Text("**Disclaimer:** This application is a personal initiative by Datadog employees and is not an official Datadog product. Its sole purpose is to help you conscientiously track your in-office days and ensure good-faith compliance with RTO KPIs. This tool is explicitly not for \"gaming\" or cheating the system.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 8)
                }
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .background(Color(NSColor.windowBackgroundColor))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(workDayManager: workDayManager)
            }
            .confirmationDialog("Log work location for today", isPresented: $showingQuickLog) {
                Button("I worked from the Office") {
                    workDayManager.setWorkDay(date: Date(), status: .workFromOffice)
                }
                
                Button("I worked from Home") {
                    workDayManager.setWorkDay(date: Date(), status: .workFromHome)
                }
                
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showingRecentDaysLog) {
                RecentDaysLogView(workDayManager: workDayManager, isPresented: $showingRecentDaysLog)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            setupNotifications()
        }
    }
    
    private func setupNotifications() {
        NSLog("🚀 Setting up notifications...")
        
        // Check current permission status first
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    // First time - request permission
                    NSLog("📱 First time - requesting notification permission")
                    NotificationManager.shared.requestNotificationPermission()
                    
                case .denied:
                    // Show user-friendly dialog to enable manually
                    NSLog("📱 Notifications denied - showing user guidance")
                    self.showNotificationPermissionDialog()
                    
                case .authorized:
                    // All good - schedule notifications
                    NSLog("📱 Notifications authorized - scheduling")
                    self.scheduleNotificationsIfEnabled()
                    
                case .provisional, .ephemeral:
                    // Limited permissions - try to upgrade
                    NSLog("📱 Limited permissions - requesting full access")
                    NotificationManager.shared.requestNotificationPermission()
                    
                @unknown default:
                    NSLog("📱 Unknown permission status - requesting")
                    NotificationManager.shared.requestNotificationPermission()
                }
            }
        }
    }
    
    private func showNotificationPermissionDialog() {
        let alert = NSAlert()
        alert.messageText = "Enable Notifications for rtdog"
        alert.informativeText = """
        To receive reminders to log your work location, please enable notifications:
        
        1. Open System Preferences
        2. Go to Notifications & Focus
        3. Find "rtdog" in the sidebar
        4. Turn ON "Allow Notifications"
        5. Set delivery to "Alerts"
        
        Would you like to open System Preferences now?
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Maybe Later")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Open System Preferences to Notifications
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    private func scheduleNotificationsIfEnabled() {
        // Give a small delay to ensure permission is processed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Schedule notifications with current settings
            let quota = self.workDayManager.getMonthlyQuota(for: Date())
            NotificationManager.shared.rescheduleNotifications(
                for: self.workDayManager.settings,
                remainingDays: quota.remainingOfficeDays
            )
            
            // Check what notifications are scheduled
            NotificationManager.shared.checkPendingNotifications()
        }
    }
    
    private var hasRecentUnloggedDays: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check past 7 days for unlogged working days
        for i in 1...7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let workDay = workDayManager.getWorkDay(for: date)
                if workDay.isWorkingDay && workDay.status == .unlogged {
                    return true
                }
            }
        }
        return false
    }
}

struct RecentDaysLogView: View {
    @ObservedObject var workDayManager: WorkDayManager
    @Binding var isPresented: Bool
    
    private var recentUnloggedDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var days: [Date] = []
        for i in 1...14 { // Check past 2 weeks
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let workDay = workDayManager.getWorkDay(for: date)
                if workDay.isWorkingDay && workDay.status == .unlogged {
                    days.append(date)
                }
            }
        }
        return days
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Log Recent Working Days")
                    .font(.headline)
                    .padding(.top)
                
                if recentUnloggedDays.isEmpty {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                        Text("All recent working days are logged!")
                            .font(.headline)
                        Text("You're up to date with your work location tracking.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(recentUnloggedDays, id: \.self) { date in
                                RecentDayRow(
                                    date: date,
                                    workDayManager: workDayManager,
                                    dateFormatter: dateFormatter,
                                    shortDateFormatter: shortDateFormatter
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Recent Days")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

struct RecentDayRow: View {
    let date: Date
    @ObservedObject var workDayManager: WorkDayManager
    let dateFormatter: DateFormatter
    let shortDateFormatter: DateFormatter
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dateFormatter.string(from: date))
                    .font(.headline)
                Text("\(daysAgo) days ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button("Office") {
                    workDayManager.setWorkDay(date: date, status: .workFromOffice)
                }
                .buttonStyle(BorderedButtonStyle())
                .controlSize(.small)
                
                Button("Home") {
                    workDayManager.setWorkDay(date: date, status: .workFromHome)
                }
                .buttonStyle(BorderedButtonStyle())
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var daysAgo: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayDate = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: dayDate, to: today).day ?? 0
    }
}

#Preview {
    ContentView()
}
