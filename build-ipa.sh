#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")" && pwd)"
build_root="$(mktemp -d -t daily-hydration)"
trap 'rm -rf "$build_root"' EXIT

output="$project_root/artifacts"
if [ "$#" -gt 0 ]; then
  output="$1"
fi
mkdir -p "$output"

xcodebuild -version
xcodebuild \
  -project "$project_root/DailyHydration.xcodeproj" \
  -scheme DailyHydration \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$build_root/DerivedData" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  ARCHS=arm64 \
  ONLY_ACTIVE_ARCH=NO \
  -quiet build

app="$build_root/DerivedData/Build/Products/Release-iphoneos/DailyHydration.app"
/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist"
/usr/bin/lipo -verify_arch arm64 "$app/DailyHydration"
test -f "$app/index.html"
mkdir "$build_root/Payload"
cp -R "$app" "$build_root/Payload/"
/usr/bin/ditto -c -k --norsrc --keepParent "$build_root/Payload" "$output/DailyHydration.ipa"
/usr/bin/unzip -t "$output/DailyHydration.ipa"
/usr/bin/shasum -a 256 "$output/DailyHydration.ipa"
