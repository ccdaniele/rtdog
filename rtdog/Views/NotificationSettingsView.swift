import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var workDayManager: WorkDayManager
    @State private var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    
    init(workDayManager: WorkDayManager) {
        self.workDayManager = workDayManager
        self._settings = State(initialValue: workDayManager.settings)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Main notification settings
                    GroupBox(label: Text("Notification Settings").font(.headline)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Enable Notifications", isOn: $settings.enableNotifications)
                            
                            if settings.enableNotifications {
                                Divider()
                                
                                HStack {
                                    Text("Notification Time:")
                                        .font(.subheadline)
                                    Spacer()
                                    DatePicker("", selection: $settings.notificationTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .datePickerStyle(CompactDatePickerStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notification Days")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                        ForEach(1...7, id: \.self) { dayOfWeek in
                                            Toggle(weekdayName(for: dayOfWeek), isOn: Binding(
                                                get: { settings.notificationDays.contains(dayOfWeek) },
                                                set: { isOn in
                                                    if isOn {
                                                        settings.notificationDays.insert(dayOfWeek)
                                                    } else {
                                                        settings.notificationDays.remove(dayOfWeek)
                                                    }
                                                }
                                            ))
                                            .toggleStyle(SwitchToggleStyle())
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Notification testing and debugging
                    GroupBox(label: Text("Testing & Debugging").font(.headline)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Use these buttons to test and debug notification functionality:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 8) {
                                Button("Debug Notifications") {
                                    NotificationManager.shared.debugNotificationStatus()
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .frame(maxWidth: .infinity)
                                .help("Check notification permissions and system status")
                                
                                Button("Test Notification") {
                                    NotificationManager.shared.testNotification()
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .frame(maxWidth: .infinity)
                                .help("Send a test notification in 2 seconds")
                                
                                Button("Test Scheduled") {
                                    NotificationManager.shared.testScheduledNotification()
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .frame(maxWidth: .infinity)
                                .help("Schedule a test notification for next minute")
                            }
                        }
                        .padding()
                    }
                    
                    // Information section
                    GroupBox(label: Text("Information").font(.headline)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notifications help you remember to log your work location each day.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("When you receive a notification, you can:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Click \"I worked from the Office\" to log office day")
                                Text("• Click \"I worked from Home\" to log home day")
                                Text("• Dismiss to log manually later")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Notification Settings")
            .frame(minWidth: 500, minHeight: 600)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        workDayManager.updateSettings(settings)
                        NotificationManager.shared.rescheduleNotifications(
                            for: settings,
                            remainingDays: workDayManager.getMonthlyQuota(for: Date()).remainingOfficeDays
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func weekdayName(for dayOfWeek: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(weekday: dayOfWeek))!
        return dateFormatter.string(from: date)
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView(workDayManager: WorkDayManager.shared)
    }
} 
