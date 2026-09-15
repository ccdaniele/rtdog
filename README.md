# rtdog

macOS app for logging hybrid workdays and tracking a monthly in-office quota.

rtdog was built as a personal product to solve a concrete problem: remember which days were in the office, and see whether the month still meets a 3-day-per-week office target. It is a native SwiftUI app with local storage, calendar-based logging, and a small release pipeline that publishes GitHub builds.

## Features

- Monthly calendar to mark days as office, home, holiday/PTO, or unlogged
- Quota panel for required, completed, remaining, and banked office days
- Catch-up UI for recent unlogged working days
- Optional daily notifications with Office / Home actions
- PDF and CSV reports for a date range
- Settings for weekends, holidays, PTO, and notification schedule

All data stays on the Mac (`UserDefaults`). There is no account, no server, and no network requirement after install.

## Quota algorithm

The current formula is a 60% office target (three days in a five-day week):

```text
required days = ceil((assigned business days − holidays/PTO) × 0.6)
```

Business days are assigned by week, not by calendar-month day count. Each Monday–Friday week belongs to one month, including weeks that cross a month boundary. Required days, completed office days, holidays, and PTO all use that same assignment so the numbers stay consistent.

The formula lives in `WorkDayManager` and can be changed for a different organization’s policy.

## Requirements

- macOS 15.5 or later
- Notification permission only if you want reminders

## Install

Download the latest `.zip` from [Releases](https://github.com/ccdaniele/rtdog/releases/latest), or:

```bash
curl -fsSL https://raw.githubusercontent.com/ccdaniele/rtdog/main/install.sh | bash
```

The script installs `rtdog.app` into `/Applications`.

## Build from source

1. Clone the repo and open `rtdog.xcodeproj` in Xcode.
2. Select the `rtdog` scheme.
3. Build and run.

Tagging `v*.*.*` triggers GitHub Actions: archive the Mac app, zip it, attach SHA256 checksums, and publish a release from `CHANGELOG.md`.

## Project layout

```text
rtdog/           SwiftUI app (models, views, notifications, reports)
scripts/         Local release helpers
install.sh       One-line installer
.github/         Release workflow
```

## License

MIT. Author: Daniel Calderon.
