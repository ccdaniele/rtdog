# Changelog

All notable changes to rtdog will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Nothing yet

### Changed
- Nothing yet

### Deprecated
- Nothing yet

### Removed
- Nothing yet

### Fixed
- Nothing yet

### Security
- Nothing yet

## [1.1.2] - 2025-07-10

### Fixed
- **🚨 CRITICAL BUG FIX**: Fixed inconsistent week-based business day assignment between required and completed office days
  - **Problem**: Required office days used week-based calculation, but completed office days used calendar-month calculation
  - **Impact**: Cross-month weeks (e.g., July 28-Aug 1, 2025) were assigned to one month for requirements but counted in calendar months for completion
  - **Example**: Week July 28-Aug 1 was assigned to July for requirements, but August 1 office days counted towards August instead of July
  - **Solution**: Implemented consistent week-based calculation for both required and completed office days
  - **Result**: If a week is assigned to a month, ALL aspects (required days, completed days, holidays, PTO) are now consistently attributed to that month

### Technical Changes
- **New Function**: `getCompletedOfficeDaysForMonth()` - uses same week-based logic as required days calculation
- **Enhanced Function**: `getHolidayAndPTODaysInMonth()` - now uses week-based calculation for consistency with business day assignment
- **Debug Helper**: Added `debugWeekAssignments()` function for troubleshooting week assignment logic
- **Maintained Compatibility**: All existing week assignment rules preserved (Mon/Tue/Wed start = current month, Thu/Fri/Sat/Sun start = previous month)

## [1.1.1] - 2025-07-09

### Changed
- **Updated App Icons**: Refreshed all app icons (16x16 to 1024x1024) with latest rtdog.png design
- **Visual Consistency**: All icon sizes now reflect the most current brand visual identity
- **Icon Generation**: Regenerated complete icon set using macOS sips tool for optimal quality

### Technical
- Updated source rtdog.png file with new design
- Regenerated all 11 required macOS app icon sizes including @2x retina variants
- Maintained macOS native .icns format compatibility for all system integrations

## [1.1.0] - 2025-07-09

### Added
- **📄 PDF Reporting Feature**: Complete work location reporting system with multiple export formats
  - **Date Range Selection**: Last Month, This Month, or Custom date range with validation
  - **PDF Generation**: Professional reports with app branding, statistics, and daily work data
  - **CSV Export**: Structured data export with Date, Work Location, Weekend, Holiday, PTO columns
  - **Excel Export**: Excel-compatible format for advanced data analysis
  - **Native File Dialog**: macOS NSSavePanel for intuitive file saving experience
  - **Statistics Dashboard**: Total days, office/home percentages, holidays/PTO breakdown
  - **Data Validation**: Prevents future date selection, ensures start < end date
  - **Weekend Control**: Option to include/exclude weekends from reports
  - **Gap Detection**: Warns when data is missing for more than 1 week continuously
  - **Report Preview**: Real-time preview of statistics before generation
  - **Blue Reports Button**: Prominent button in main UI for easy access

### Fixed
- **macOS Compatibility**: Fixed PDF generation using NSGraphicsContext instead of UIKit
- **SwiftUI Deprecation**: Updated onChange API calls for macOS compatibility
- **Navigation Issues**: Removed iOS-specific navigationBarTitleDisplayMode

### Technical
- **Multi-page PDFs**: Automatic page breaks for large datasets
- **File Type Support**: Proper UTType definitions for all export formats
- **Error Handling**: Comprehensive error messages and user feedback
- **Performance**: Efficient data processing for large date ranges

## [1.0.11] - 2025-07-09

### Changed
- **Default Notification Time**: Changed from 4:30 PM to 10:00 AM for better user experience
- **Notifications Enabled by Default**: New users now have notifications enabled by default
- **Streamlined UI**: Removed "Log Today" button from main interface (functionality available by clicking calendar dates)

### Fixed
- **App Icon Display**: Fixed dock icon display issue by ensuring proper 1024x1024 icon configuration
- **README Accuracy**: Updated documentation to reflect current app state and features

### Documentation
- **Updated README**: Comprehensive updates to reflect new notification defaults and UI changes
- **Settings Documentation**: Updated to reflect new notification UI structure
- **Disclaimer Updates**: Aligned with current app branding

## [1.0.10] - 2025-07-09

### Added
- **Major UI Improvements**: Comprehensive user interface and experience enhancements
- **Notification Action Fix**: Fixed critical issue where notification banner actions weren't updating calendar
- **Dedicated Notification Settings**: New standalone notification settings view accessible via orange button
- **Prominent Notifications Button**: Orange "Notifications" button with distinct styling in main UI

### Fixed
- **Notification Actions Now Update Calendar**: Fixed critical issue using WorkDayManager singleton pattern
- **UI Layout Issues**: Removed problematic NavigationView that caused two-column layout problems
- **Settings Organization**: Separated notification settings from general settings for better user experience

### Changed
- **Main UI Structure**: Removed NavigationView wrapper and restructured layout for cleaner design
- **WorkDayManager Architecture**: Converted to singleton pattern for data consistency
- **Settings Separation**: Moved notification-related settings to dedicated view

### Technical
- Implemented singleton pattern for WorkDayManager to fix notification action handling
- Created dedicated NotificationSettingsView with comprehensive controls
- Improved UI architecture by removing NavigationView complexity

## [1.0.9] - 2025-07-09

### Added
- **Dedicated Notification Settings UI**: New standalone notification settings view accessible via orange button in main UI
- **Prominent Notifications Button**: Orange "Notifications" button with distinct styling in main UI for easy access
- **Comprehensive Notification Information**: Added detailed explanations about notification functionality and usage
- **Enhanced Testing Tools**: Organized debugging and testing tools in dedicated section
- **Improved Button Organization**: Restructured main UI header with better button layout and styling

### Fixed
- **Notification Actions Now Update Calendar**: Fixed critical issue where notification banner actions weren't updating day status by implementing WorkDayManager singleton pattern
- **UI Layout Issues**: Removed problematic NavigationView that caused two-column layout problems
- **Settings Organization**: Separated notification settings from general settings for better user experience

### Changed
- **Main UI Structure**: Removed NavigationView wrapper and restructured layout for cleaner, single-column design
- **WorkDayManager Architecture**: Converted to singleton pattern (`WorkDayManager.shared`) to ensure data consistency across app and notifications
- **Settings Separation**: Moved all notification-related settings to dedicated view, leaving general settings focused on core app configuration
- **Button Styling**: Enhanced button organization and visual hierarchy in main UI

### Technical
- Implemented singleton pattern for WorkDayManager to fix notification action handling
- Created dedicated NotificationSettingsView with comprehensive controls and information
- Improved UI architecture by removing NavigationView complexity
- Enhanced notification system reliability with shared data model

## [1.0.8] - 2025-07-09

### Added
- **Auto-Permission Request**: App now automatically requests notification permissions on startup
- **User-Friendly Permission Dialog**: Shows helpful guidance when notifications are disabled with option to open System Preferences
- **Enhanced Debugging**: Added comprehensive Console-visible NSLog statements for notification troubleshooting
- **Test Scheduled Button**: Added debugging button in Settings to test scheduled notifications
- **Calendar Entitlement**: Added calendar access entitlement for improved notification scheduling

### Fixed
- **Notification Permission Handling**: Fixed permission request flow and status checking
- **Scheduled Notification Logic**: Completely rewrote notification scheduling with improved date calculation
- **UserNotifications Import**: Fixed missing import that prevented notification permission checking
- **Weekly Notification Scheduling**: Implemented dual approach (immediate next occurrence + weekly repeating) for reliable scheduling

### Changed
- **Notification System**: Rewritten notification system with automatic permission management
- **Permission Flow**: Streamlined user experience for enabling notifications with clear guidance
- **Debug Logging**: Enhanced logging throughout notification system for better troubleshooting

### Technical
- Fixed compilation error with missing UserNotifications import in ContentView.swift
- Improved notification scheduling algorithm with better date handling
- Enhanced permission status checking with proper async handling

## [1.0.7] - 2025-07-09

### Added
- **New App Icons**: Updated all app icons (16x16 to 1024x1024) based on new rtdog.png design
- **Professional Disclaimer**: Added comprehensive disclaimer at bottom of application explaining:
  - Personal initiative by Datadog employees, not an official Datadog product
  - Purpose is conscientious compliance with RTO KPIs, not gaming the system
  - Styled with subtle background and proper spacing for visibility
- **Enhanced Subtitle Message**: Added "Don't forget the office is still there" to the app subtitle

### Changed
- **App Title**: Changed from "Office Day Tracker" to "rtdog" across all interfaces
- **Notification Branding**: Updated notification titles to use "rtdog" instead of "Office Day Tracker"
- **App Identity**: Complete rebranding with new visual identity and messaging
- **User Experience**: Professional disclaimer provides clear context about app purpose and origin

### Technical
- Updated all icon sizes from new rtdog.png source file
- Maintained universal binary compatibility (Intel + Apple Silicon)
- All branding updates applied consistently across UI and notifications

## [1.0.6] - 2025-07-09

### Fixed
- **Bulk Clear Functionality**: Now properly clears PTO/holidays in addition to work status
- **Clear Days Button Position**: Moved below calendar with prominent red gradient styling for better visibility
- **UI Clarity**: Button no longer blends with month navigation, includes descriptive text and trash icon
- **Comprehensive Clearing**: All day statuses (work location, PTO, holidays) are now properly reset during bulk clear

### Changed
- Improved bulk clear user experience with better visual feedback and positioning
- Enhanced button styling with gradient background, shadow, and clear visual hierarchy

## [1.0.5] - 2025-07-09

### Added
- **Bulk Clear Functionality**: New "Clear Days" button in main calendar UI for bulk day status reset
- Multi-day selection interface with visual feedback (red borders, checkmarks)
- Clear mode header showing selection count and "Clear Selected" action button
- Improved day selection workflow with better user experience

### Fixed
- SwiftUI `confirmationDialog` button limit issue that prevented "Clear Status" option from appearing
- Individual day clearing now works through bulk clear interface instead of hidden dialog option

### Changed
- Enhanced calendar day interaction with clear mode toggle
- Improved visual feedback for selected days in clear mode

## [1.0.4] - 2025-07-09

### Fixed
- Calendar month alignment issue where days were misaligned with their actual months
- Calendar now properly displays correct day ranges for each month (e.g., June 2025 shows June 1-30)
- Month navigation functions now ensure proper start-of-month date setting
- WorkDayManager initialization now starts at beginning of current month instead of current datetime

### Changed
- "Clear Status" option in day selection dialog is now always available instead of only when day has status
- Month picker now properly handles month selection by setting to start of selected month
- All calendar navigation functions now use consistent start-of-month calculations

## [1.0.3] - 2025-07-09

### Added
- New week-based calculation formula for office day requirements: `(A - B) * 0.60`
  - A = Total business days in month using week assignment rules
  - B = Holidays and PTO days on business days
  - Week assignment based on where first/last day of month falls within the week
  - First week belongs to month if month starts on Mon/Tue/Wed, otherwise previous month
  - Last week belongs to month if month ends on Wed/Thu/Fri/Sat/Sun, otherwise next month
  - Each assigned week contributes exactly 5 business days to the month

### Changed
- Office day calculation now uses precise week-based business day counting instead of calendar day counting
- Required office days now calculated as 60% of adjusted business days

## [1.0.2] - 2025-07-09

### Fixed
- Settings window sizing and layout issues
- Notification system not working correctly
- Improved notification debugging and logging

### Changed
- Enhanced settings UI with better organization
- Improved notification handling and error reporting

## [1.0.1] - 2025-07-09

### Fixed
- Initial bug fixes for settings and notifications

## [1.0.0] - 2025-07-09

### Added
- Initial release of Office Day Tracker
- Calendar view with work day tracking
- Monthly quota calculation and display
- PTO and holiday management
- Notification system for office day reminders
- Settings panel for configuration
- macOS native application with proper UI 
