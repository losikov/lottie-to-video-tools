#!/bin/bash

# Export Lottie frames as PNG sequence for manual inspection
# Usage: ./export-frames-for-inspection.sh <input-lottie-file>
# Example: ./export-frames-for-inspection.sh ../assets/showtime-tap-indicator.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Get input file
INPUT_FILE="${1:-$REPO_ROOT/assets/showtime-tap-indicator.json}"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found: $INPUT_FILE"
    echo "Usage: $0 <input-lottie-file>"
    exit 1
fi

# Extract filename without extension
INPUT_BASENAME=$(basename "$INPUT_FILE" .json)
TEMP_DIR="$REPO_ROOT/temp/lottie_frames_inspect_${INPUT_BASENAME}"

echo "Exporting Lottie animation frames for manual inspection..."
echo "Input:  $INPUT_FILE"
echo "Output: $TEMP_DIR/"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Install puppeteer-lottie-cli if not already installed
if ! command -v puppeteer-lottie &> /dev/null; then
    echo "Installing puppeteer-lottie-cli..."
    npm install -g puppeteer-lottie-cli
fi

# Create directory for frames (won't be deleted)
mkdir -p "$TEMP_DIR"

# Export as PNG sequence
echo "Exporting frames..."
puppeteer-lottie -i "$INPUT_FILE" -o "$TEMP_DIR/frame-%d.png" --width 400 --height 400

# Count and list frames
FRAME_COUNT=$(ls "$TEMP_DIR"/frame-*.png 2>/dev/null | wc -l | tr -d ' ')

if [ "$FRAME_COUNT" -gt 0 ]; then
    echo ""
    echo "✓ Exported $FRAME_COUNT frames"
    echo "✓ Frames saved in: $TEMP_DIR/"
    echo ""
    echo "Frame list:"
    ls -1 "$TEMP_DIR"/frame-*.png | head -10
    if [ "$FRAME_COUNT" -gt 10 ]; then
        echo "... and $((FRAME_COUNT - 10)) more frames"
    fi
    echo ""
    echo "First frame: $(ls "$TEMP_DIR"/frame-*.png | head -1)"
    echo "Last frame:  $(ls "$TEMP_DIR"/frame-*.png | tail -1)"
    echo ""
    echo "You can now manually inspect the frames in: $TEMP_DIR/"
    echo "Open them in Preview or any image viewer to check the animation progression."
else
    echo "Error: No frames were exported!"
    exit 1
fi
