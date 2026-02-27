# Install Guide

## Option 1: Homebrew (Recommended)

```bash
brew install --cask max2697/tap/ratelimited
```

This handles download, install, and clears the Gatekeeper quarantine flag automatically.

---

## Option 2: curl (one-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/max2697/RateLimited/main/scripts/install.sh | bash
```

Downloads the latest release from GitHub and installs to `/Applications`.
Also removes the quarantine attribute so macOS does not block the unsigned app.

---

## Option 3: Manual (GitHub Release)

1. Download the latest `RateLimited.app.zip` from the [Releases page](https://github.com/max2697/RateLimited/releases).
2. Unzip and move `RateLimited.app` to `/Applications`.
3. Remove the quarantine flag to avoid Gatekeeper prompts:
   ```bash
   xattr -d com.apple.quarantine /Applications/RateLimited.app
   ```
4. Launch the app.

If you prefer not to run the command above, you can clear the app manually:

1. Try opening the app from Finder — macOS will block it.
2. Open `System Settings` → `Privacy & Security`.
3. Click `Open Anyway` for RateLimited.
4. Confirm and relaunch.

---

## Requirements

- macOS 14 (Sonoma) or later
- Existing local credentials:
  - Claude Code Keychain entry (`Claude Code-credentials`)
  - `~/.codex/auth.json`

## Troubleshooting

- Tray shows `--`: token could not be read yet, or API request failed
- Open the popover to see tool-specific error text
