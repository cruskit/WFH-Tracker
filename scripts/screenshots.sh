#!/usr/bin/env bash
# Run this script to (re)generate all App Store screenshots.
# Output: screenshots/ in the project root, 4 PNG files at device native resolution.
#
# Requirements:
#   - Xcode installed with an iPhone 17 Pro Max simulator (6.9" / 1320×2868 px)
#   - Run from any directory; the script locates itself
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$PROJECT_DIR/screenshots"
TMPSCREENS="/tmp/wfh-screenshots"

# Find iPhone 17 Pro Max UDID — required App Store size for 6.9" display class
UDID=$(xcrun simctl list devices available -j | python3 -c "
import json, sys
d = json.load(sys.stdin)
for devs in d['devices'].values():
    for dev in devs:
        if 'iPhone 17 Pro Max' in dev['name']:
            print(dev['udid']); exit()
" 2>/dev/null || true)

if [ -z "$UDID" ]; then
    echo "ERROR: No available iPhone 17 Pro Max simulator found."
    echo "Available devices:"
    xcrun simctl list devices available | grep -i iphone
    exit 1
fi
echo "Using simulator: iPhone 17 Pro Max ($UDID)"

# Boot if needed
if xcrun simctl list devices | grep "$UDID" | grep -q Shutdown; then
    echo "Booting simulator..."
    xcrun simctl boot "$UDID"
    sleep 3
fi

# Clear previous output
rm -rf "$TMPSCREENS"

echo "Building and running screenshot tests..."
xcodebuild test \
    -project "$PROJECT_DIR/WFH-Tracker.xcodeproj" \
    -scheme "WFH-Tracker" \
    -destination "platform=iOS Simulator,id=$UDID" \
    -only-testing "WFH-TrackerUITests/WFH_TrackerUITests/testTakeScreenshots" \
    CODE_SIGNING_ALLOWED=NO \
    2>&1 | grep -E "Test Suite|Test Case|error:|warning:|PASS|FAIL|screenshot" || true

# Copy output to screenshots/ in project root
if [ -d "$TMPSCREENS" ] && ls "$TMPSCREENS"/*.png 1>/dev/null 2>&1; then
    mkdir -p "$OUTPUT_DIR"
    cp "$TMPSCREENS"/*.png "$OUTPUT_DIR/"
    echo ""
    echo "Done. Screenshots saved to: $OUTPUT_DIR"
    ls -lh "$OUTPUT_DIR"/*.png
else
    echo ""
    echo "ERROR: No screenshots found at $TMPSCREENS"
    echo "Check test output above for failures."
    exit 1
fi
