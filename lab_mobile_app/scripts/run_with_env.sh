#!/usr/bin/env bash
# Load lab_mobile_app/.env and run Flutter with matching --dart-define flags.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env ]]; then
  echo "Missing .env — copy .env.example to .env and fill in passwords."
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

DART_DEFINES=(
  --dart-define=LAB_API_BASE_URL="${LAB_API_BASE_URL:-https://api.mywaitime.com/lab}"
  --dart-define=LAB_API_BASE_BACKUP="${LAB_API_BASE_BACKUP:-http://208.109.215.53:3015/lab}"
  --dart-define=LAB_ADMIN_USERNAME="${LAB_ADMIN_USERNAME:-admin}"
  --dart-define=LAB_ADMIN_PASSWORD="${LAB_ADMIN_PASSWORD:-admin123}"
  --dart-define=LAB_ADMIN_USER_ID="${LAB_ADMIN_USER_ID:-1}"
  --dart-define=LAB_DEMO_DOCTOR_USERNAME="${LAB_DEMO_DOCTOR_USERNAME:-labdoctor}"
  --dart-define=LAB_DEMO_DOCTOR_PASSWORD="${LAB_DEMO_DOCTOR_PASSWORD:-labdoctor123}"
  --dart-define=LAB_STAFF_DEFAULT_PASSWORD="${LAB_STAFF_DEFAULT_PASSWORD:-Staff@2026}"
  --dart-define=STRIPE_PUBLISHABLE_KEY="${STRIPE_PUBLISHABLE_KEY:-}"
  --dart-define=STRIPE_PUBLISHABLE_KEY_BACKUP="${STRIPE_PUBLISHABLE_KEY_BACKUP:-}"
  --dart-define=LAB_SUBSCRIPTION_PRODUCT_ID="${LAB_SUBSCRIPTION_PRODUCT_ID:-com.mywaitime.lab.monthly}"
)

if [[ "${1:-}" == "--build-release" ]]; then
  shift
  VERSION="$(grep '^version:' pubspec.yaml | awk '{print $2}')"
  echo "Building Saeed Lab release ${VERSION}..."
  flutter pub get
  echo "→ Android APK (release)..."
  flutter build apk --release "${DART_DEFINES[@]}" "$@"
  echo "→ Android App Bundle (Play Store)..."
  flutter build appbundle --release "${DART_DEFINES[@]}" "$@"
  echo "→ iOS IPA (App Store)..."
  flutter build ipa --release "${DART_DEFINES[@]}" "$@"
  OUT="$ROOT/build/release-submission"
  mkdir -p "$OUT"
  cp -f build/app/outputs/flutter-apk/app-release.apk "$OUT/SaeedLab-${VERSION}.apk" 2>/dev/null \
    || cp -f build/app/outputs/apk/release/app-release.apk "$OUT/SaeedLab-${VERSION}.apk"
  cp -f build/app/outputs/bundle/release/app-release.aab "$OUT/SaeedLab-${VERSION}.aab"
  if [[ -f build/app/outputs/mapping/release/mapping.txt ]]; then
    cp -f build/app/outputs/mapping/release/mapping.txt "$OUT/SaeedLab-${VERSION}-mapping.txt"
    echo "→ Upload mapping file to Play Console: App bundle explorer → Downloads → mapping.txt"
  fi
  cp -f build/ios/ipa/*.ipa "$OUT/SaeedLab-${VERSION}.ipa" 2>/dev/null \
    || cp -f build/ios/ipa/lab_mobile_app.ipa "$OUT/SaeedLab-${VERSION}.ipa"
  echo ""
  echo "Release artifacts (${VERSION}):"
  ls -lh "$OUT"
  exit 0
fi

exec flutter run "${DART_DEFINES[@]}" "$@"
