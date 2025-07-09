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

## [1.0.1] - 2025-07-09

### Added
- Test notification button in Settings for debugging notification functionality
- Enhanced notification logging with detailed status messages
- Better error handling for notification permissions
- Improved notification scheduling with proper permission checks

### Changed
- Redesigned Settings view layout with GroupBox components for better organization
- Replaced Form-based layout with ScrollView for better window sizing
- Enhanced notification scheduling with better debugging information
- Improved notification initialization with proper timing

### Fixed
- Settings window sizing issue - content now properly fits and is centered
- Notification functionality - notifications now work correctly when scheduled
- Settings view layout issues with proper frame constraints (500x600 minimum)
- Notification permission handling with better error reporting
- Enhanced notification scheduling with proper weekday calculation

## [1.0.0] - 2025-07-09

### Added
- Initial release of rtdog (Office Day Tracker)
- Monthly calendar view with color-coded work status
- Interactive notifications for daily work location prompts
- Support for Work From Office, Work From Home, and PTO days
- Office day quota tracking with 3-day per week average
- Banking system for surplus office days within the month
- Settings panel for notification times and preferences
- Historical data editing for past dates
- Month navigation with date picker
- Recent days quick-entry interface for unlogged working days
- Custom rtdog application icon
- Data persistence using UserDefaults
- macOS Sequoia 15.5+ support
- Native Swift/SwiftUI implementation

### Technical Details
- Bundle ID: tse-coders.rtdog
- Minimum macOS: 15.5
- Architecture: Universal (Intel + Apple Silicon)
- Framework: SwiftUI
- Notifications: UNUserNotificationCenter
- Data Storage: Local (UserDefaults)

---

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
