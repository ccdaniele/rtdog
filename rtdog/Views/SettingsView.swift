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
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $settings.enableNotifications)
                    
                    if settings.enableNotifications {
                        DatePicker("Notification Time", selection: $settings.notificationTime, displayedComponents: .hourAndMinute)
                        
                        VStack(alignment: .leading) {
                            Text("Notification Days")
                                .font(.headline)
                            
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
                            }
                        }
                    }
                }
                
                Section(header: Text("Weekend Days")) {
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
                    }
                }
                
                Section(header: Text("Holidays & PTO")) {
                    Button("Add Holiday/PTO Day") {
                        showingHolidayPicker = true
                    }
                    
                    if !settings.holidays.isEmpty || !settings.ptodays.isEmpty {
                        ForEach(Array(settings.holidays.union(settings.ptodays)).sorted(), id: \.self) { date in
                            HStack {
                                Text(dateFormatter.string(from: date))
                                Spacer()
                                Button("Remove") {
                                    settings.holidays.remove(date)
                                    settings.ptodays.remove(date)
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
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
                    DatePicker("Select Holiday/PTO Date", selection: $selectedHolidayDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .navigationTitle("Add Holiday/PTO")
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
