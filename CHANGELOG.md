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
- Custom day selection sheet with improved UI and layout
- Always-visible "Clear Status" option in red color for better visibility
- Current day status display in sheet header
- Icons for all day selection options (building, house, plus/minus, xmark)
- Better organized button layout with proper spacing and colors

### Changed
- Replaced `confirmationDialog` with custom `DaySelectionSheet` to overcome button display limitations
- Day selection dialog now shows full date (e.g., "Friday, July 11, 2025")
- Improved visual hierarchy with better button styling and colors
- Enhanced user experience with clearer current status indication

### Fixed
- "Clear Status" button now always visible and properly displayed
- Resolved issue where Clear Status option was not appearing due to dialog button limitations
- Fixed iOS-specific `navigationBarTitleDisplayMode` issue for proper macOS compatibility

## [1.0.4] - 2025-07-09

### Fixed
- Calendar month alignment issue where days were misaligned with their actual months
- Calendar now properly displays correct day ranges for each month (e.g., June 2025 shows June 1-30)
- Month navigation functions now ensure proper start-of-month date setting
- WorkDayManager initialization now starts at beginning of current month instead of current datetime

### Changed
- "Clear Status" option in day selection dialog is now always available instead of only when day has status
- Month picker now properly handles month selection by setting to start of selected month
- All calendar month calculations now use consistent start-of-month logic

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
- Issue where the release script was not properly executing
- Version management in automated release workflow

## [1.0.1] - 2025-07-09

### Added
- Test notification button in Settings for debugging notification issues
- Enhanced logging system for better troubleshooting

### Fixed
- Settings window sizing and layout issues - now properly sized (500x600) with centered content
- Notification functionality not working - improved permission handling and scheduling
- Settings window now uses GroupBox components for better organization
- Notification manager now has proper error handling and detailed logging

### Changed
- Settings UI redesigned with better visual hierarchy and spacing
- Improved notification initialization and permission checking

## [1.0.0] - 2025-07-08

### Added
- Initial release of rtdog (Office Day Tracker)
- Calendar view with month navigation
- Work day tracking (office/home/PTO)
- Notification system for work reminders
- Settings panel for configuration
- Weekend and holiday management
- Monthly quota tracking and summary
- Persistent data storage with UserDefaults
- Complete project management setup with semantic versioning
- Automated release workflow with build scripts
- Professional documentation and contribution guidelines

### Technical Implementation
- Swift/SwiftUI macOS application
- MVVM architecture with ObservableObject
- Calendar integration with proper date handling
- Local notification system with permission management
- Settings persistence with Codable protocols
- Comprehensive error handling and logging
- Professional Git workflow with conventional commits

## Version Format
- **MAJOR.MINOR.PATCH** (e.g., 1.0.0)
- **MAJOR**: Incompatible API changes or major feature overhauls
- **MINOR**: New features that are backwards compatible
- **PATCH**: Bug fixes and small improvements

## Release Types
- **Added**: New features
- **Changed**: Changes to existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Features removed in this version
- **Fixed**: Bug fixes
- **Security**: Security vulnerability fixes 
