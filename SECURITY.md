# Security Policy

## Supported Versions

Only the latest release is supported with security updates.

## Reporting a Vulnerability

Please report security issues privately before opening a public issue.

Include:

- macOS version
- RateLimited version
- What credential source or API path is involved
- Reproduction steps (if possible)

## Scope Notes

This app reads local auth tokens and makes outbound API calls to vendor endpoints. Security issues involving token leakage, logging, or unintended persistence should be treated as high priority.

