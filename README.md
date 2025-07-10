# rtdog - Office Day Tracker

A native macOS application for tracking your hybrid work schedule and ensuring compliance with your company's office day requirements.

## 🚀 Installation

### One-Click Install (Recommended)

Simply run this command in your terminal to automatically download and install the latest version:

```bash
curl -fsSL https://raw.githubusercontent.com/ccdaniele/rtdog/main/install.sh | bash
```

The installer will:
- ✅ Download the latest release from GitHub
- ✅ Install to your Applications folder
- ✅ Handle macOS security permissions automatically
- ✅ Verify file integrity with SHA256 checksums
- ✅ Launch the app when installation completes

### Alternative Installation Methods

#### Manual Download
1. Visit the [latest release page](https://github.com/ccdaniele/rtdog/releases/latest)
2. Download the `rtdog-[version].zip` file
3. Extract and move `rtdog.app` to your Applications folder
4. Right-click and select "Open" to bypass macOS security on first launch

#### From Source
1. Clone the repository: `git clone https://github.com/ccdaniele/rtdog.git`
2. Open `rtdog.xcodeproj` in Xcode
3. Build and run the project

### System Requirements
- **macOS 15.5 or later**
- **Apple Silicon or Intel Mac**
- **~10MB disk space**
- **Notification permissions** (optional, for daily reminders)

### First Launch
After installation, rtdog will appear in your Applications folder and Launch Pad. The app will automatically:
- Request notification permissions (recommended for daily reminders)
- Set up default settings (notifications enabled at 10:00 AM)
- Display the current month's calendar for immediate use

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
- **Scheduled Reminders**: Daily prompts at customizable times (enabled by default at 10:00 AM)
- **Interactive Buttons**: "I worked from the Office" / "I worked from Home"
- **Smart Context**: Shows remaining office days needed
- **Calendar Integration**: Notification actions automatically update the calendar
- **Customizable Schedule**: Set which days and times to receive notifications
- **Prominent Access**: Dedicated orange "Notifications" button in main interface

### 📄 PDF Reporting System
- **Comprehensive Reports**: Generate detailed work location reports with statistics
- **Multiple Export Formats**: PDF, CSV, and Excel-compatible formats
- **Date Range Selection**: Last Month, This Month, or Custom date range
- **Professional PDF Layout**: App-branded reports with statistics and daily data
- **Real-time Preview**: See statistics before generating reports
- **Data Validation**: Prevents future dates, ensures valid date ranges
- **Weekend Control**: Option to include/exclude weekends from reports
- **Gap Detection**: Warnings for missing data periods (>1 week)
- **Native File Dialog**: macOS-native save dialog for intuitive file management
- **Statistics Dashboard**: Total days, office/home percentages, holidays/PTO breakdown
- **Prominent Access**: Dedicated blue "Reports" button in main interface

### ⚙️ Settings & Customization
- **Notification Preferences**: 
  - Enable/disable notifications (enabled by default)
  - Set notification time (default: 10:00 AM)
  - Choose which days to receive notifications
- **Weekend Configuration**: Customize which days are weekends
- **Holiday Management**: Add/remove holidays and PTO days
- **Data Persistence**: All settings and work logs are saved locally

## How to Use

### Basic Daily Logging
1. **Today's Log**: Click on today's date in the calendar
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
1. **General Settings**: Open settings via gear icon in top-right
   - Set weekend days (default: Saturday, Sunday)
   - Add holidays and PTO days
   - All changes are saved automatically

2. **Notification Settings**: Click the orange "Notifications" button for:
   - Enable/disable notifications
   - Set notification time and days
   - Test notification functionality
   - Auto-permission request and setup guidance

3. **PDF Reports**: Click the blue "Reports" button to:
   - Select date range (Last Month, This Month, or Custom)
   - Choose export format (PDF, CSV, or Excel)
   - Preview statistics before generating
   - Include/exclude weekends as needed
   - Save reports using native macOS file dialog

## Technical Features

### Data Management
- **Local Storage**: All data stored securely on your Mac using UserDefaults
- **Automatic Backup**: Settings and work logs persist between app launches
- **JSON Encoding**: Robust data serialization for reliability
- **Singleton Pattern**: Shared WorkDayManager ensures consistent state across UI and notifications

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

**Disclaimer**: This application is a personal initiative by Datadog employees and is not an official Datadog product. Its sole purpose is to help you conscientiously track your in-office days and ensure good-faith compliance with RTO KPIs. This tool is explicitly not for "gaming" or cheating the system. Please ensure compliance with your organization's work-from-home guidelines. 
