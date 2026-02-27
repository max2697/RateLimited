# Contributing

## Development Setup

1. Clone the repo.
2. Open `RateLimited.xcodeproj` in Xcode.
3. Build and run the `RateLimited` scheme.
4. Ensure your local Claude and Codex credentials exist before testing live refresh.

## Pull Requests

- Keep changes focused
- Include a short test/verification note
- Prefer small, reviewable commits
- Update docs when behavior changes (tray format, API contract, install steps)

## Code Style

- Follow existing Swift style in the repo
- Keep AppKit integration minimal and UI state in `UsageViewModel`
- Prefer explicit error messages surfaced in the popover

## Local Verification

```bash
swift test
xcodebuild -project RateLimited.xcodeproj -scheme RateLimited -destination 'platform=macOS' build CODE_SIGNING_ALLOWED=NO
```

Optional (if installed):

```bash
swiftformat --lint .
swiftlint --strict
```

