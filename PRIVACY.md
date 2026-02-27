# Privacy

RateLimited reads existing local credentials for Claude and Codex so it can request usage information from vendor APIs.

## What the app reads

- Claude token from macOS Keychain via `/usr/bin/security`
- Codex token from `~/.codex/auth.json`

## What the app sends

- Authenticated HTTPS requests to:
  - `https://api.anthropic.com/api/oauth/usage`
  - `https://chatgpt.com/backend-api/wham/usage`

## What the app stores

- No local database
- No token cache written by the app
- No analytics or telemetry built in

## Logs

The app currently surfaces errors in the UI. If you add logging in future changes, avoid logging tokens or raw credential blobs.

