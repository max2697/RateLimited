# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog.

## [0.2.1] - 2026-04-07

### Fixed

- Subprocess CWD set to `/tmp` so `claude -p` token refresh no longer triggers macOS TCC prompts for Downloads and other protected folders

## [0.2.0] - 2026-03-20

### Added

- CLI presence check: shows "not found, install CLI first" when claude or codex is not installed
- CLI version displayed per tool section in the popover (e.g. v2.1.80)
- App version displayed in the popover header subtitle

### Fixed

- Claude OAuth token refresh: proactively refreshes before API call using `expiresAt` from keychain, eliminating the daily expired-token error
- Claude token retry now triggers on any HTTP 401, not just responses matching a specific error body format

## [0.1.1] - 2026-03-01

### Fixed

- Claude token refresh: use `claude -p "hi"` instead of `claude auth status` which did not actually refresh an expired OAuth token

## [0.1.0] - 2026-02-27

### Added

- Initial macOS menu bar app
- Claude and Codex usage fetching
- Popover UI with 5-hour and weekly bars
- GitHub/release documentation and CI workflow

