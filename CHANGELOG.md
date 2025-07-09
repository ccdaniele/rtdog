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
