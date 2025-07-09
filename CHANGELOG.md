# Changelog

All notable changes to rtdog will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Planning for automated build and distribution

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
