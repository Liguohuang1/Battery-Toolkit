#!/usr/bin/env bash

set -euo pipefail

PROJECT_NAME="Battery Toolkit"
SCHEME="Battery Toolkit"
UPSTREAM_TEAM_ID="EMH49F8A2Y"
UPSTREAM_CODESIGN_CN="Apple Development: Marvin Häuser (87DYA6FH9K)"
UPSTREAM_DAEMON_CONN="${UPSTREAM_TEAM_ID}.me.mhaeuser.batterytoolkitd"
DAEMON_ID="me.mhaeuser.batterytoolkitd"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUT_DIR="${REPO_ROOT}/build"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/battery-toolkit-release.XXXXXX")"

cleanup() {
    rm -rf "${WORK_DIR}"
}
trap cleanup EXIT

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required command: $1" >&2
        exit 1
    fi
}

require_command xcodebuild
require_command security
require_command openssl
require_command python3
require_command ditto
require_command hdiutil
require_command rsync

IDENTITY_LINE="${BT_LOCAL_IDENTITY:-$(security find-identity -v -p codesigning | sed -n 's/.*"\(Apple Development:.*\)"/\1/p' | head -n 1)}"
if [[ -z "${IDENTITY_LINE}" ]]; then
    echo "No usable Apple Development signing identity found." >&2
    echo "Run: security find-identity -v -p codesigning" >&2
    exit 1
fi

CERT_PEM_FILE="${WORK_DIR}/apple-development.pem"
security find-certificate -c "${IDENTITY_LINE}" -p "${HOME}/Library/Keychains/login.keychain-db" > "${CERT_PEM_FILE}"
if [[ ! -s "${CERT_PEM_FILE}" ]]; then
    echo "Failed to export certificate for identity: ${IDENTITY_LINE}" >&2
    exit 1
fi

TEAM_ID="${BT_LOCAL_TEAM_ID:-$(openssl x509 -in "${CERT_PEM_FILE}" -noout -subject -nameopt RFC2253 | sed -n 's/.*OU=\([^,]*\).*/\1/p')}"
if [[ -z "${TEAM_ID}" ]]; then
    echo "Failed to determine DEVELOPMENT_TEAM from certificate subject." >&2
    exit 1
fi

DAEMON_CONN="${BT_LOCAL_DAEMON_CONN:-${TEAM_ID}.${DAEMON_ID}}"
VERSION="${BT_VERSION:-$(xcodebuild -project "${REPO_ROOT}/${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME}" -showBuildSettings | awk '/MARKETING_VERSION = / { print $3; exit }')}"
if [[ -z "${VERSION}" ]]; then
    VERSION="local"
fi

RELEASE_ROOT="${WORK_DIR}/repo"
mkdir -p "${RELEASE_ROOT}"
rsync -a \
    --exclude '.git' \
    --exclude 'build' \
    --exclude '.DS_Store' \
    "${REPO_ROOT}/" "${RELEASE_ROOT}/"

python3 - "${RELEASE_ROOT}" "${TEAM_ID}" "${IDENTITY_LINE}" "${DAEMON_CONN}" "${UPSTREAM_TEAM_ID}" "${UPSTREAM_CODESIGN_CN}" "${UPSTREAM_DAEMON_CONN}" <<'PY'
from pathlib import Path
import sys

repo = Path(sys.argv[1])
team_id = sys.argv[2]
codesign_cn = sys.argv[3]
daemon_conn = sys.argv[4]
upstream_team = sys.argv[5]
upstream_cn = sys.argv[6]
upstream_conn = sys.argv[7]

pbxproj = repo / "Battery Toolkit.xcodeproj" / "project.pbxproj"
text = pbxproj.read_text()
text = text.replace(f"DEVELOPMENT_TEAM = {upstream_team};", f"DEVELOPMENT_TEAM = {team_id};")
text = text.replace(f'BT_CODESIGN_CN = "{upstream_cn}";', f'BT_CODESIGN_CN = "{codesign_cn}";')
text = text.replace(f"BT_DAEMON_CONN = {upstream_conn};", f"BT_DAEMON_CONN = {daemon_conn};")
pbxproj.write_text(text)

(repo / "BatteryToolkit" / "BatteryToolkit.entitlements").write_text(
    """<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict/>\n</plist>\n"""
)

for relative in (
    Path("me.mhaeuser.batterytoolkitd/launchd.plist"),
    Path("me.mhaeuser.batterytoolkitd/me.mhaeuser.batterytoolkitd.plist"),
):
    file = repo / relative
    file.write_text(file.read_text().replace(upstream_conn, daemon_conn))
PY

ARCHIVE_PATH="${OUT_DIR}/BatteryToolkit.xcarchive"
ZIP_PATH="${OUT_DIR}/Battery-Toolkit-${VERSION}.zip"
DMG_PATH="${OUT_DIR}/Battery-Toolkit-${VERSION}.dmg"
DMG_STAGE="${WORK_DIR}/dmg-root"
APP_PATH="${ARCHIVE_PATH}/Products/Applications/${PROJECT_NAME}.app"

rm -rf "${ARCHIVE_PATH}" "${DMG_STAGE}"
mkdir -p "${OUT_DIR}" "${DMG_STAGE}"

xcodebuild \
    -project "${RELEASE_ROOT}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration Release \
    archive \
    -archivePath "${ARCHIVE_PATH}" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="${TEAM_ID}" \
    BT_CODESIGN_CN="${IDENTITY_LINE}" \
    BT_DAEMON_CONN="${DAEMON_CONN}" \
    -allowProvisioningUpdates

if [[ ! -d "${APP_PATH}" ]]; then
    echo "Archive succeeded but app bundle is missing: ${APP_PATH}" >&2
    exit 1
fi

rm -f "${ZIP_PATH}" "${DMG_PATH}"
ditto -c -k --sequesterRsrc --keepParent "${APP_PATH}" "${ZIP_PATH}"

cp -R "${APP_PATH}" "${DMG_STAGE}/"
ln -s /Applications "${DMG_STAGE}/Applications"
hdiutil create -volname "${PROJECT_NAME}" -srcfolder "${DMG_STAGE}" -ov -format UDZO "${DMG_PATH}" >/dev/null

echo "Built release artifacts:"
echo "  Archive: ${ARCHIVE_PATH}"
echo "  ZIP:     ${ZIP_PATH}"
echo "  DMG:     ${DMG_PATH}"
echo "  Team ID: ${TEAM_ID}"
echo "  Signer:  ${IDENTITY_LINE}"
echo
shasum -a 256 "${ZIP_PATH}" "${DMG_PATH}"
