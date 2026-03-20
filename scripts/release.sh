#!/usr/bin/env bash
# Usage: scripts/release.sh <version>
# Example: scripts/release.sh 0.2.1
set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."

cd "$ROOT"

echo "==> Releasing $VERSION"

# ── 1. Verify tools ───────────────────────────────────────────────────────────
echo "==> Checking tools..."
for tool in swiftformat swiftlint swift git; do
  if ! command -v "$tool" &>/dev/null; then
    echo "Error: $tool not found. Run: brew install swiftformat swiftlint" >&2
    exit 1
  fi
done
echo "    SwiftFormat $(swiftformat --version)"
echo "    SwiftLint   $(swiftlint version)"

# ── 2. Check working tree is clean ────────────────────────────────────────────
echo "==> Checking working tree..."
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: working tree is dirty. Commit or stash changes before releasing." >&2
  git status --short
  exit 1
fi

# ── 3. Lint ───────────────────────────────────────────────────────────────────
echo "==> SwiftFormat lint..."
swiftformat --lint .

echo "==> SwiftLint..."
swiftlint --strict

# ── 4. Tests ──────────────────────────────────────────────────────────────────
echo "==> Swift tests..."
swift test

# ── 5. Release build ──────────────────────────────────────────────────────────
echo "==> Release archive build..."
xcodebuild \
  -project RateLimited.xcodeproj \
  -scheme RateLimited \
  -configuration Release \
  -destination 'platform=macOS' \
  archive \
  -archivePath /tmp/RateLimited-preflight.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  -quiet

# ── 6. Bump version ───────────────────────────────────────────────────────────
echo "==> Bumping version to $VERSION..."

XCCONFIG="Config/Base.xcconfig"
PBXPROJ="RateLimited.xcodeproj/project.pbxproj"

sed -i '' "s/^MARKETING_VERSION = .*/MARKETING_VERSION = $VERSION/" "$XCCONFIG"
sed -i '' "s/MARKETING_VERSION = [^;]*;/MARKETING_VERSION = $VERSION;/g" "$PBXPROJ"

# ── 7. Verify CHANGELOG has an entry for this version ─────────────────────────
echo "==> Checking CHANGELOG..."
if ! grep -q "## \[$VERSION\]" CHANGELOG.md; then
  echo "Error: no entry for $VERSION found in CHANGELOG.md." >&2
  echo "Add a '## [$VERSION] - $(date +%Y-%m-%d)' section and re-run." >&2
  exit 1
fi

# ── 8. Commit, tag, push ──────────────────────────────────────────────────────
echo "==> Committing..."
git add "$XCCONFIG" "$PBXPROJ"
git commit -m "Release $VERSION"

echo "==> Tagging v$VERSION..."
git tag "v$VERSION"

echo "==> Pushing..."
git push origin main --tags

echo ""
echo "✓ Released $VERSION — CI will build the artifact and attach it to the GitHub Release."
echo "  Once the zip is attached, run:"
echo "    curl -fsSL <zip-url> | shasum -a 256"
echo "  and update the Homebrew cask."
