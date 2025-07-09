# rtdog - Office Day Tracker

A native macOS application for tracking your hybrid work schedule and ensuring compliance with your company's office day requirements.

## Features

### 📅 Monthly Calendar View
- Visual calendar showing your work location for each day
- Color-coded days:
  - **Blue**: Work From Office (WFO)
  - **Green**: Work From Home (WFH)
  - **Grey**: Non-working days (weekends, holidays, PTO)
  - **White**: Unlogged working days
- Today's date is highlighted with an orange border
- **Past dates are fully editable** - click on any day to modify its status
- Visual indicators for logged past dates outside the current month

### 🕐 Past Date Editing
- **Full Historical Editing**: Modify work location for any past date
- **Smart Dialog Text**: Context-aware confirmation dialogs
  - "Set work location for Today" (current day)
  - "Update work location for [date]" (past dates)
  - "Set work location for [date]" (future dates)
- **Clear Status Option**: Remove logged status from any day
- **Month Navigation**: Easy navigation to previous months
- **Quick Month Access**: 
  - Click on month/year title to open month picker
  - "Jump to Today" button when viewing past months
  - Quick access buttons for recent 6 months

### 🔄 Recent Days Quick Log
- **Automatic Detection**: App detects unlogged working days from the past 2 weeks
- **Recent Days Button**: Appears in main interface when past unlogged days exist
- **Batch Logging**: Quick interface to log multiple recent days at once
- **Days Ago Indicator**: Shows how many days ago each unlogged day was
- **One-Click Logging**: "Office" and "Home" buttons for quick status setting

### 📊 Monthly Quota Summary
- **Required Office Days**: Target number of WFO days based on 3-day/week average
- **Completed Office Days**: Current count of logged WFO days
- **Remaining Office Days**: Number of WFO days still needed
- **Banked Days**: Surplus WFO days that can be used later in the month

### 🔔 Interactive Notifications
- **Scheduled Reminders**: Daily prompts at customizable times
- **Interactive Buttons**: "I worked from the Office" / "I worked from Home"
- **Smart Context**: Shows remaining office days needed
- **Customizable Schedule**: Set which days and times to receive notifications

### ⚙️ Settings & Customization
- **Notification Preferences**: 
  - Enable/disable notifications
  - Set notification time (default: 4:30 PM)
  - Choose which days to receive notifications
- **Weekend Configuration**: Customize which days are weekends
- **Holiday Management**: Add/remove holidays and PTO days
- **Data Persistence**: All settings and work logs are saved locally

## How to Use

### Basic Daily Logging
1. **Today's Log**: Click "Log Today" button in main interface
2. **Past Days**: Navigate to previous months using arrow buttons
3. **Any Date**: Click on any calendar day to set/modify its status
4. **Recent Catch-up**: Use "Recent Days" button to quickly log past unlogged days

### Monthly Navigation
1. **Arrow Navigation**: Use left/right arrows to navigate months
2. **Quick Jump**: Click on month/year title to open month picker
3. **Today Button**: Quickly return to current month
4. **Recent Access**: Use quick access buttons for recent months

### Status Options
- **Work From Office**: Blue color coding
- **Work From Home**: Green color coding  
- **PTO/Holiday**: Grey color coding
- **Clear Status**: Remove any previously set status

### Settings Configuration
1. Open settings via gear icon in top-right
2. Configure notification preferences
3. Set weekend days (default: Saturday, Sunday)
4. Add holidays and PTO days
5. All changes are saved automatically

## Technical Features

### Data Management
- **Local Storage**: All data stored securely on your Mac using UserDefaults
- **Automatic Backup**: Settings and work logs persist between app launches
- **JSON Encoding**: Robust data serialization for reliability

### Smart Calculations
- **Working Days**: Automatically excludes weekends, holidays, and PTO
- **Quota Logic**: Calculates required office days based on 3-day/week average
- **Banking System**: Tracks surplus office days within the month

### Visual Indicators
- **Color Coding**: Instant visual feedback for all day types
- **Current Month**: Full opacity for current month days
- **Past Months**: Slightly transparent with small status indicators
- **Today Highlight**: Orange border around today's date

## System Requirements

- macOS 15.5 or later
- Notification permissions (optional, for daily reminders)

## Privacy

- All data is stored locally on your Mac
- No internet connection required
- No data is transmitted to external servers
- Full control over your work tracking data

## Development

Built with:
- Swift 5
- SwiftUI for modern macOS interface
- UserNotifications framework for interactive notifications
- Native macOS design patterns

## Support

For issues or feature requests, please check the project repository or contact the development team.

---

**Note**: This application is designed for personal productivity tracking and is not affiliated with any specific company's attendance policies. Please ensure compliance with your organization's work-from-home guidelines. 
