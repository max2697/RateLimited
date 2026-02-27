# Release Guide

## Release Checklist

1. Update `CHANGELOG.md`
2. Bump version/build in Xcode project settings
3. Build locally
4. Archive app
5. Sign (Developer ID Application)
6. Notarize
7. Staple
8. Zip app and attach to GitHub Release
9. Publish release notes

The repo also includes a GitHub Actions workflow that builds and uploads an unsigned `.app.zip` on tags:

- `.github/workflows/release-artifact.yml`

## Local Build Verification

```bash
xcodebuild -project RateLimited.xcodeproj -scheme RateLimited -destination 'platform=macOS' build CODE_SIGNING_ALLOWED=NO
```

## Archive (Signed Build Example)

```bash
xcodebuild \
  -project RateLimited.xcodeproj \
  -scheme RateLimited \
  -configuration Release \
  -destination 'platform=macOS' \
  archive \
  -archivePath build/RateLimited.xcarchive
```

## Export / Package

For a simple `.app` release, copy:

- `build/RateLimited.xcarchive/Products/Applications/RateLimited.app`

Then zip it:

```bash
ditto -c -k --sequesterRsrc --keepParent \
  build/RateLimited.xcarchive/Products/Applications/RateLimited.app \
  build/RateLimited.app.zip
```

## Notarization (Recommended)

Use `notarytool` with your Apple Developer credentials:

```bash
xcrun notarytool submit build/RateLimited.app.zip --wait --keychain-profile <PROFILE>
xcrun stapler staple build/RateLimited.xcarchive/Products/Applications/RateLimited.app
```

Re-zip after stapling and upload that artifact to GitHub Releases.

## CI Release Artifact (Unsigned)

Tag pushes matching `v*` trigger a workflow that:

- archives the app (Release config)
- zips `RateLimited.app`
- uploads the zip as a GitHub Actions artifact
- attaches the zip to the GitHub Release

For public distribution, replace this with a signed/notarized artifact.


## GitHub Release Notes

Include:

- supported macOS versions
- install instructions / Gatekeeper notes
- tray display behavior changes (if any)
- known issues
