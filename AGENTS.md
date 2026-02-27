# AGENTS.md

Rules for AI agents (and humans) working on this repo. Follow these to avoid breaking CI.

## Before Every Commit

Run this exact sequence and fix all failures before committing:

```bash
swiftformat .
swiftlint --strict
swift test
```

If swiftformat or swiftlint are not installed:

```bash
brew install swiftformat swiftlint
```

## Before Tagging a Release

Run the Release archive locally — this is what CI does and it is stricter than a regular build:

```bash
xcodebuild \
  -project RateLimited.xcodeproj \
  -scheme RateLimited \
  -configuration Release \
  -destination 'platform=macOS' \
  archive \
  -archivePath /tmp/RateLimited.xcarchive \
  CODE_SIGNING_ALLOWED=NO
```

A plain `build` uses Debug config and will not catch Release-only failures.

## Swift Rules

- **Never use `#Preview` outside `#if DEBUG`**. Preview macros reference debug-only helpers and will fail to compile in Release builds.
- **Never add debug helpers, mocks, or preview factories outside `#if DEBUG`**. The same applies to any extension or method used only in previews or tests.
- **Do not use single-character variable names** (`f`, `n`, etc.). SwiftLint enforces a minimum of 2 characters (`id`, `x`, `y`, `q` are whitelisted exceptions).
- **Do not nest types more than 1 level deep**. SwiftLint enforces `nesting` rule. Pull inner structs/enums out to private top-level declarations.
- **Do not force-unwrap** (`!`) except on compile-time-known-safe literals (e.g. hardcoded URL strings). When force-unwrapping is truly safe, add `// swiftlint:disable:next force_unwrapping` on the preceding line and move the value to a `private static let` constant.
- **`@MainActor` classes have `@MainActor` inits**. Any factory or helper that constructs a `@MainActor` type must itself be annotated `@MainActor`.

## CI Behaviour

| Workflow | Trigger | What it runs |
|---|---|---|
| `macOS Build` | push to main, PRs | swiftformat lint, swiftlint --strict, swift test, xcodebuild build (Debug) |
| `Release Artifact` | push tag `v*` | xcodebuild archive (Release), zip app, attach to GitHub Release |

SwiftLint runs with `--strict`: all warnings become errors.
