# RateLimited

![RateLimited Icon](docs/assets/icon-512.png)

Menu bar app for macOS that shows current usage limits for Claude and Codex/OpenAI.

## Features

- Menu bar-only app (no Dock icon)
- Shows Codex first, Claude second
- 5-hour and weekly usage bars for both tools
- Auto refresh every 5 minutes
- Manual refresh button
- Reads Claude token via `/usr/bin/security` (no Keychain entitlements)
- Reads Codex token from `~/.codex/auth.json`

## Install

**Homebrew** (recommended):
```bash
brew install --cask max2697/tap/ratelimited
```

**curl**:
```bash
curl -fsSL https://raw.githubusercontent.com/max2697/RateLimited/main/scripts/install.sh | bash
```

**Manual**: download `RateLimited.app.zip` from [Releases](https://github.com/max2697/RateLimited/releases), unzip, move to `/Applications`.

The app is unsigned — it may just work, or macOS may block it on first launch. If blocked, go to `System Settings` → `Privacy & Security` → `Open Anyway`, or run:
```bash
xattr -d com.apple.quarantine /Applications/RateLimited.app
```

Detailed steps: [`docs/INSTALL.md`](docs/INSTALL.md)

## Build From Source

Requirements:

- macOS 14 or later
- Xcode (current stable)

```bash
xcodebuild -project RateLimited.xcodeproj -scheme RateLimited -destination 'platform=macOS' build CODE_SIGNING_ALLOWED=NO
```

## Development (No Credentials Required)

Use mock mode to run the UI without local Claude/Codex tokens:

1. Open `RateLimited.xcodeproj` in Xcode
2. Edit Scheme -> `Run` -> `Arguments`
3. Add environment variable: `RATELIMITED_USE_MOCK_DATA=1`
4. Run the app

The tray/popup will show realistic example usage data without reading tokens or hitting the APIs.

## Usage

- The menu bar shows two values: `Codex Claude`
- Example: `w7% 96%`
  - `w` means the weekly limit is being shown for that tool
  - Weekly is shown only when weekly remaining is under 10%
- Click the menu bar item to open the popover (Codex first, Claude second)

## Credential Sources

Claude:

- Reads secret JSON from Keychain using:
  - `security find-generic-password -s "Claude Code-credentials" -w`
- Extracts `claudeAiOauth.accessToken`

Codex:

- Reads `~/.codex/auth.json`
- Extracts `tokens.access_token`

## Privacy / Security Notes

- Tokens are read locally on your machine
- Tokens are not written to disk by the app
- The app sends authenticated requests only to:
  - `api.anthropic.com`
  - `chatgpt.com`

See [`PRIVACY.md`](PRIVACY.md) and [`SECURITY.md`](SECURITY.md).

## Developer Docs

- [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md)
- [`docs/RELEASE.md`](docs/RELEASE.md)
- [`docs/HOMEBREW.md`](docs/HOMEBREW.md)
- [`CONTRIBUTING.md`](CONTRIBUTING.md)

## License

[MIT](LICENSE)
