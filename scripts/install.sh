#!/usr/bin/env bash
# Install RateLimited — downloads the latest GitHub release and removes quarantine
# Usage: curl -fsSL https://raw.githubusercontent.com/max2697/RateLimited/main/scripts/install.sh | bash

set -euo pipefail

REPO="max2697/RateLimited"
APP_NAME="RateLimited.app"
ZIP_NAME="RateLimited.app.zip"
INSTALL_DIR="/Applications"

echo "==> Fetching latest release info..."
RELEASE_URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
  | grep '"browser_download_url"' \
  | grep "${ZIP_NAME}" \
  | sed 's/.*"browser_download_url": "\(.*\)"/\1/')

if [ -z "$RELEASE_URL" ]; then
  echo "Error: Could not find ${ZIP_NAME} in the latest release." >&2
  exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "==> Downloading ${ZIP_NAME}..."
curl -fsSL "$RELEASE_URL" -o "${TMPDIR}/${ZIP_NAME}"

echo "==> Installing to ${INSTALL_DIR}..."
unzip -q "${TMPDIR}/${ZIP_NAME}" -d "$TMPDIR"

if [ -d "${INSTALL_DIR}/${APP_NAME}" ]; then
  echo "==> Removing existing installation..."
  rm -rf "${INSTALL_DIR:?}/${APP_NAME}"
fi

cp -r "${TMPDIR}/${APP_NAME}" "${INSTALL_DIR}/"

echo "==> Removing quarantine attribute (unsigned app)..."
xattr -d com.apple.quarantine "${INSTALL_DIR}/${APP_NAME}" 2>/dev/null || true

echo "==> Done. Launch RateLimited from /Applications or Spotlight."
