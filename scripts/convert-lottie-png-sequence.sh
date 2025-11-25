#!/bin/bash

# Convert Lottie JSON to PNG sequence, then to ProRes 4444 MOV with transparency
# This is the most reliable method for preserving transparency

echo "Converting Lottie animation to video with transparency..."

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
TEMP_DIR="lottie_frames_$$"
mkdir -p "$TEMP_DIR"

# Export as PNG sequence (PNG supports transparency natively)
# puppeteer-lottie exports frames when you specify a pattern
echo "Step 1: Rendering animation as PNG sequence with transparency..."
echo "This may take a moment - rendering 30 frames at 60fps..."

# Export with %d pattern to get all frames (frame-0.png, frame-1.png, etc.)
puppeteer-lottie -i showtime-tap-indicator.json -o "$TEMP_DIR/frame-%d.png" --width 400 --height 400

# Check if PNG files were created and find the pattern
PNG_FILES=$(ls "$TEMP_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')

if [ "$PNG_FILES" -gt 0 ]; then
    echo "Step 2: Found $PNG_FILES PNG frames. Converting to ProRes 4444 MOV..."
    
    # Convert PNG sequence to ProRes 4444 MOV with alpha channel
    # Using glob pattern to match all frame files
    echo "Converting $PNG_FILES frames to ProRes 4444 MOV..."
    ffmpeg -framerate 60 -pattern_type glob -i "$TEMP_DIR/frame-*.png" \
        -c:v prores_ks \
        -profile:v 4444 \
        -pix_fmt yuva444p10le \
        -y \
        showtime-tap-indicator.mov 2>&1 | grep -v "deprecated"
    
    # Clean up temporary PNG files
    rm -rf "$TEMP_DIR"
    
    if [ -f "showtime-tap-indicator.mov" ]; then
        echo ""
        echo "✓ Conversion complete! File saved as: showtime-tap-indicator.mov"
        echo "✓ This file has transparency (alpha channel) - ProRes 4444 format"
        echo "✓ You can now import this into Final Cut Pro with transparent background."
    else
        echo "Error: Failed to create MOV file."
        exit 1
    fi
else
    echo "Error: No PNG frames were created."
    echo "Trying alternative: Direct WebM export..."
    
    # Alternative: Try WebM which supports transparency
    puppeteer-lottie -i showtime-tap-indicator.json -o showtime-tap-indicator.webm --width 400 --height 400
    
    if [ -f "showtime-tap-indicator.webm" ]; then
        echo "Converting WebM to ProRes 4444 MOV..."
        ffmpeg -i showtime-tap-indicator.webm \
            -c:v prores_ks \
            -profile:v 4444 \
            -pix_fmt yuva444p10le \
            -y \
            showtime-tap-indicator.mov
        
        rm showtime-tap-indicator.webm
        echo "✓ Conversion complete via WebM!"
    else
        echo "Error: All conversion methods failed."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
fi
