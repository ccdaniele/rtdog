import SwiftUI

struct SettingsView: View {
    @ObservedObject var workDayManager: WorkDayManager
    @State private var settings: AppSettings
    @State private var showingHolidayPicker = false
    @State private var selectedHolidayDate = Date()
    @Environment(\.presentationMode) var presentationMode
    
    init(workDayManager: WorkDayManager) {
        self.workDayManager = workDayManager
        self._settings = State(initialValue: workDayManager.settings)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Notifications Section
                    GroupBox(label: Text("Notifications").font(.headline)) {
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
                                
                                // Test notification button
                                HStack {
                                    Spacer()
                                    Button("Test Notification") {
                                        NotificationManager.shared.testNotification()
                                    }
                                    .buttonStyle(BorderedButtonStyle())
                                    .help("Send a test notification in 5 seconds")
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Weekend Days Section
                    GroupBox(label: Text("Weekend Days").font(.headline)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select which days are considered weekends:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(1...7, id: \.self) { dayOfWeek in
                                    Toggle(weekdayName(for: dayOfWeek), isOn: Binding(
                                        get: { settings.weekendDays.contains(dayOfWeek) },
                                        set: { isOn in
                                            if isOn {
                                                settings.weekendDays.insert(dayOfWeek)
                                            } else {
                                                settings.weekendDays.remove(dayOfWeek)
                                            }
                                        }
                                    ))
                                    .toggleStyle(SwitchToggleStyle())
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Holidays & PTO Section
                    GroupBox(label: Text("Holidays & PTO").font(.headline)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Manage your holidays and PTO days:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button("Add Holiday/PTO Day") {
                                showingHolidayPicker = true
                            }
                            .buttonStyle(BorderedButtonStyle())
                            
                            if !settings.holidays.isEmpty || !settings.ptodays.isEmpty {
                                Divider()
                                
                                let allDates = Array(settings.holidays.union(settings.ptodays)).sorted()
                                
                                if allDates.isEmpty {
                                    Text("No holidays or PTO days added")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .italic()
                                } else {
                                    LazyVStack(spacing: 8) {
                                        ForEach(allDates, id: \.self) { date in
                                            HStack {
                                                Image(systemName: "calendar")
                                                    .foregroundColor(.secondary)
                                                Text(dateFormatter.string(from: date))
                                                    .font(.subheadline)
                                                Spacer()
                                                Button("Remove") {
                                                    settings.holidays.remove(date)
                                                    settings.ptodays.remove(date)
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                                .foregroundColor(.red)
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Settings")
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
            .sheet(isPresented: $showingHolidayPicker) {
                NavigationView {
                    VStack(spacing: 20) {
                        DatePicker("Select Holiday/PTO Date", selection: $selectedHolidayDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                        
                        Spacer()
                    }
                    .padding()
                    .navigationTitle("Add Holiday/PTO")
                    .frame(minWidth: 400, minHeight: 500)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingHolidayPicker = false
                            }
                        }
                        
                        ToolbarItem(placement: .primaryAction) {
                            Button("Add") {
                                let normalizedDate = Calendar.current.startOfDay(for: selectedHolidayDate)
                                settings.holidays.insert(normalizedDate)
                                showingHolidayPicker = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func weekdayName(for dayOfWeek: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.weekdaySymbols[dayOfWeek - 1]
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
} 
