# AGENTS.md

Rules for AI agents (and humans) working on this repo. Follow these to avoid breaking CI.

## Commits

- **Always ask the user for approval before committing.** Show what files will be included and the intended message, then wait for a yes.
- **Do not add `Co-Authored-By` lines** to commit messages.

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

## Releasing a New Version

When the user says "release X.Y.Z" or "bump version to X.Y.Z", do all of the following in order:

1. **Update `MARKETING_VERSION`** in two places:
   - `Config/Base.xcconfig`: `MARKETING_VERSION = X.Y.Z`
   - `RateLimited.xcodeproj/project.pbxproj`: both occurrences of `MARKETING_VERSION` (the project file overrides the xcconfig if left stale)

2. **Add a CHANGELOG entry** at the top of `CHANGELOG.md`:
   ```
   ## X.Y.Z – YYYY-MM-DD
   - <summary of changes since last release>
   ```

3. **Run the pre-commit checks** (see *Before Every Commit* below) and fix any failures.

4. **Ask the user for approval before committing.** Show the list of changed files and the intended commit message, then wait for explicit confirmation.

5. **Commit** all changes with message `Release X.Y.Z` (no Co-Authored-By line).

6. **Tag** the commit:
   ```bash
   git tag vX.Y.Z
   git push origin main --tags
   ```
   The `v*` tag triggers the CI release artifact workflow.

7. **Update the Homebrew cask** (if applicable):
   - Wait for the GitHub Release artifact to be attached by CI
   - Update the version and `sha256` in the cask file (see *Homebrew Cask Rules* below)

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

## Homebrew Cask Rules

- **Do not use `quarantine false`** in cask files — it is not a valid Homebrew Cask directive.
- **Do not use `--no-quarantine`** — it is deprecated in Homebrew with no replacement.
- For unsigned apps, users must clear quarantine manually after install: `xattr -d com.apple.quarantine /Applications/<AppName>.app`
- Install command: `brew install --cask max2697/tap/<cask-name>` followed by the `xattr` command above.
- After updating a cask version, always update `sha256` with: `curl -fsSL <zip-url> | shasum -a 256`
