#!/bin/bash

# Quick script to check how many frames puppeteer-lottie exports
# Usage: ./check-lottie-frames.sh <input-lottie-file>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Get input file
INPUT_FILE="${1:-$REPO_ROOT/assets/showtime-tap-indicator.json}"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found: $INPUT_FILE"
    echo "Usage: $0 <input-lottie-file>"
    exit 1
fi

echo "Checking Lottie animation frame export..."
echo "Input: $INPUT_FILE"

if ! command -v puppeteer-lottie &> /dev/null; then
    echo "Installing puppeteer-lottie-cli..."
    npm install -g puppeteer-lottie-cli
fi

TEMP_DIR="$REPO_ROOT/temp/test_frames_$$"
mkdir -p "$TEMP_DIR"

echo "Exporting frames..."
puppeteer-lottie -i "$INPUT_FILE" -o "$TEMP_DIR/frame-%d.png" --width 400 --height 400

FRAME_COUNT=$(ls "$TEMP_DIR"/frame-*.png 2>/dev/null | wc -l | tr -d ' ')
echo ""
echo "Exported frame count: $FRAME_COUNT"

# Try to read expected frame count from JSON
EXPECTED_FRAMES=$(grep -o '"op":\s*[0-9]*' "$INPUT_FILE" | grep -o '[0-9]*' | head -1)
if [ -n "$EXPECTED_FRAMES" ]; then
    echo "Expected (from JSON op): $EXPECTED_FRAMES frames"
    echo ""
    if [ "$FRAME_COUNT" -lt "$EXPECTED_FRAMES" ]; then
        PERCENTAGE=$((FRAME_COUNT * 100 / EXPECTED_FRAMES))
        echo "⚠️  ISSUE: Only $FRAME_COUNT frames exported instead of $EXPECTED_FRAMES!"
        echo "   This explains why only ${PERCENTAGE}% of the animation plays."
    else
        echo "✓ Frame count matches expected duration"
    fi
else
    echo "Could not determine expected frame count from JSON"
fi

echo ""
if [ "$FRAME_COUNT" -gt 0 ]; then
    echo "First frame: $(ls "$TEMP_DIR"/frame-*.png | head -1)"
    echo "Last frame:  $(ls "$TEMP_DIR"/frame-*.png | tail -1)"
fi

rm -rf "$TEMP_DIR"
