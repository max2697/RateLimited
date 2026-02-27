# Install Guide

## Option 1: Homebrew (Recommended)

```bash
brew install --cask max2697/tap/ratelimited
```

Launch from Spotlight or `/Applications`. The app may just open, or macOS may block it on first launch depending on your Gatekeeper settings.

**If blocked (optional step)**, either:
- Go to `System Settings` → `Privacy & Security` → `Open Anyway`
- Or run: `xattr -d com.apple.quarantine /Applications/RateLimited.app`

---

## Option 2: curl (one-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/max2697/RateLimited/main/scripts/install.sh | bash
```

Downloads the latest release from GitHub, installs to `/Applications`, and removes the quarantine flag automatically — no Gatekeeper prompt.

---

## Option 3: Manual (GitHub Release)

1. Download the latest `RateLimited.app.zip` from the [Releases page](https://github.com/max2697/RateLimited/releases).
2. Unzip and move `RateLimited.app` to `/Applications`.
3. Launch the app. If Gatekeeper blocks it, go to `System Settings` → `Privacy & Security` → `Open Anyway`.

---

## Requirements

- macOS 14 (Sonoma) or later
- Existing local credentials:
  - Claude Code Keychain entry (`Claude Code-credentials`)
  - `~/.codex/auth.json`

## Troubleshooting

- Tray shows `--`: token could not be read yet, or API request failed
- Open the popover to see tool-specific error text
