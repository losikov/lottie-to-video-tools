#!/bin/bash

# Simple alternative: Use online LottieFiles converter
# This script opens the LottieFiles converter in your browser

echo "Opening LottieFiles online converter..."
echo ""
echo "Instructions:"
echo "1. Upload: showtime-tap-indicator.json"
echo "2. Format: MOV (ProRes 422)"
echo "3. Resolution: 400x400 or higher"
echo "4. Frame rate: 60 fps"
echo "5. Download and import into Final Cut Pro"
echo ""

# Open the converter URL
open "https://lottiefiles.com/tools/lottie-to-video"

echo "Browser opened! Follow the instructions above."
