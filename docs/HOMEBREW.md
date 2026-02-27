# Homebrew Distribution

RateLimited is a GUI macOS app distributed via a Homebrew Cask.

## Tap

- Tap repo: `max2697/homebrew-tap` (shared tap for all max2697 projects)
- Cask name: `ratelimited`

Install command for users:

```bash
brew install --cask max2697/tap/ratelimited
xattr -d com.apple.quarantine /Applications/RateLimited.app
```

The app is unsigned. Homebrew's `--no-quarantine` flag is deprecated with no replacement, so users must clear the quarantine attribute manually after install.

## Why a Shared Tap

- One tap repo (`homebrew-tap`) for all projects instead of one per app
- Users only need to add the tap once to access any cask from it
- Faster iteration without depending on `homebrew/cask` review

## Requirements for a Good Cask Experience

- Stable versioned release URLs (`RateLimited.app.zip`)
- SHA256 checksums per release

## Template

A starter cask template is included at:

- `packaging/homebrew/ratelimited.rb.example`

The cask lives in the `max2697/homebrew-tap` repo at:

- `Casks/ratelimited.rb`
