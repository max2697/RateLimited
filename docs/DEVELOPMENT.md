# Development

## Architecture

The app is split by responsibility under `RateLimited/`:

- `App/`
  - `RateLimitedApp.swift`: app entry point
  - `StatusBarAppDelegate.swift`: status item + popover lifecycle + refresh timer
  - `AppEnvironment.swift`: composition root for mock/live service wiring
- `UI/`
  - `UsagePopoverView.swift`: popover SwiftUI UI
- `Core/`
  - `Models/UsageModels.swift`: snapshot/state models
  - `Formatting/UsageFormatting.swift`: tray label + time remaining formatting
  - `Parsing/*`: token extractors, auth error classification, usage decoders, shared parse helpers/errors
  - `ViewModel/UsageViewModel.swift`: refresh orchestration and UI state
  - `Mocks/MockUsageData.swift`: deterministic mock data/services
  - `Time/Clock.swift`: injectable clock abstraction
- `Infrastructure/`
  - `UsageAPIs/*`: Claude/Codex API clients + shared auth-retry flow
  - `Auth/AuthSupport.swift`: token providers + CLI auth refresh helper
  - `HTTP/HTTPClient.swift`: HTTP protocol + URLSession implementation
  - `Process/CommandRunner.swift`: process execution abstraction

## API Contracts

### Claude

- Endpoint: `GET https://api.anthropic.com/api/oauth/usage`
- Headers:
  - `Authorization: Bearer <token>`
  - `anthropic-beta: oauth-2025-04-20`
  - `User-Agent: claude-code/2.0.32`

Fields used:

- `five_hour.utilization`
- `five_hour.resets_at`
- `seven_day.utilization`
- `seven_day.resets_at`

### Codex

- Endpoint: `GET https://chatgpt.com/backend-api/wham/usage`
- Header:
  - `Authorization: Bearer <token>`

Fields used:

- `rate_limit.primary_window.used_percent`
- `rate_limit.primary_window.reset_after_seconds`
- `rate_limit.secondary_window.used_percent`
- `rate_limit.secondary_window.reset_after_seconds`

## Live Testing

The app depends on real local credentials. For UI-only changes, you can still build and launch the app, but usage values may show errors if credentials are missing.

## Mock Mode

Set `RATELIMITED_USE_MOCK_DATA=1` to bypass token reads and network calls. The app will render deterministic sample values for Codex/Claude.

In Xcode:

1. `Product` -> `Scheme` -> `Edit Scheme...`
2. `Run` -> `Arguments`
3. Add `RATELIMITED_USE_MOCK_DATA` = `1`

This is useful for:

- UI work
- screenshots
- onboarding contributors without local AI CLI auth setup

## Tray Formatting Rule

- Two values, `Codex` then `Claude`
- Show weekly value only when weekly remaining is under 10%
- Prefix weekly display with `w`

## Testable Core Logic

Core logic in `RateLimited/Core` is exposed as a SwiftPM target (`RateLimitedCore`) so CI can run `swift test` quickly without building the app UI target.
