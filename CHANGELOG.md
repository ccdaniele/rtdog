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
- Enhanced calendar day interaction with clear mode vs normal mode behavior
- Added visual indicators for selected days during bulk clear operation
- Improved UI organization with conditional header displays

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
- Notification system functionality restored
- Enhanced notification permission handling

### Added
- Test notification functionality for debugging
- Improved logging system for troubleshooting

## [1.0.1] - 2025-07-09

### Fixed
- Settings window now properly sizes and centers content
- Notification system now works correctly with proper permission handling
- Enhanced error handling and logging for notifications

### Added
- Test notification button in Settings for debugging
- Better UI organization with GroupBox components
- Improved notification setup and error handling

## [1.0.0] - 2025-07-09

### Added
- Initial release of rtdog (Office Day Tracker)
- Calendar view with month navigation
- Work day tracking (Work From Office, Work From Home, PTO)
- Quota calculation and summary
- Settings panel with notification preferences
- Notification system for work reminders
- Data persistence using UserDefaults
- Modern SwiftUI interface optimized for macOS

### Features
- **Calendar Interface**: Clean month view with day status indicators
- **Work Status Tracking**: Easy selection of work location and PTO days
- **Quota Management**: Automatic calculation of required office days
- **Notifications**: Configurable reminders for work planning
- **Settings**: Comprehensive preferences for all app features
- **Data Persistence**: Reliable storage of work history and settings 
