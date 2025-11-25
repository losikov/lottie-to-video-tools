#!/bin/bash

# Convert Lottie JSON to video with transparency (alpha channel) for Final Cut Pro
# Usage: ./convert-lottie-with-alpha.sh <input-lottie-file>
# Example: ./convert-lottie-with-alpha.sh ../assets/showtime-tap-indicator.json

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
OUTPUT_FILE="$REPO_ROOT/output/${INPUT_BASENAME}.mov"
TEMP_DIR="$REPO_ROOT/temp/lottie_frames"

echo "Converting Lottie animation to video with transparency..."
echo "Input:  $INPUT_FILE"
echo "Output: $OUTPUT_FILE"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Warning: ffmpeg is not installed. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install ffmpeg
    else
        echo "Error: Homebrew not found. Please install ffmpeg manually:"
        echo "  brew install ffmpeg"
        exit 1
    fi
fi

# Install puppeteer-lottie-cli if not already installed
if ! command -v puppeteer-lottie &> /dev/null; then
    echo "Installing puppeteer-lottie-cli..."
    npm install -g puppeteer-lottie-cli
fi

# Create temporary directory for PNG frames
mkdir -p "$TEMP_DIR"

# Export as PNG sequence (PNG supports transparency natively)
echo "Rendering animation as PNG sequence with transparency..."
puppeteer-lottie -i "$INPUT_FILE" -o "$TEMP_DIR/frame-%d.png" --width 400 --height 400

# Check if PNG files were created
PNG_COUNT=$(ls "$TEMP_DIR"/frame-*.png 2>/dev/null | wc -l | tr -d ' ')

if [ "$PNG_COUNT" -gt 0 ]; then
    echo "Found $PNG_COUNT PNG frames"
    echo "Converting to MOV with alpha channel (ProRes 4444)..."
    
    # Convert PNG sequence to ProRes 4444 MOV with alpha channel
    # Use explicit frame pattern with start_number to ensure correct sequential ordering
    mkdir -p "$(dirname "$OUTPUT_FILE")"
    ffmpeg -framerate 60 -i "$TEMP_DIR/frame-%d.png" \
        -start_number 1 \
        -c:v prores_ks \
        -profile:v 4444 \
        -pix_fmt yuva444p10le \
        -y \
        "$OUTPUT_FILE" 2>&1 | grep -v "deprecated"
    
    # Clean up temporary PNG files
    rm -rf "$TEMP_DIR"
    
    if [ -f "$OUTPUT_FILE" ]; then
        echo ""
        echo "✓ Conversion complete!"
        echo "✓ File saved as: $OUTPUT_FILE"
        echo "✓ This file has transparency (alpha channel) - ProRes 4444 format"
        echo "✓ You can now import this into Final Cut Pro with transparent background."
    else
        echo "Error: Failed to create output file."
        exit 1
    fi
else
    echo "Error: Failed to create PNG frames."
    rm -rf "$TEMP_DIR"
    exit 1
fi
