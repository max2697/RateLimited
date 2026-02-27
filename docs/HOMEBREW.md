# Homebrew Distribution

RateLimited is a GUI macOS app distributed via a Homebrew Cask.

## Tap

- Tap repo: `max2697/homebrew-tap` (shared tap for all max2697 projects)
- Cask name: `ratelimited`

Install command for users:

```bash
brew install --cask --no-quarantine max2697/tap/ratelimited
```

`--no-quarantine` is required because the app is unsigned. Without it macOS will block the app on first launch.

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
