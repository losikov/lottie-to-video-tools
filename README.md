# Lottie to Video Tools

Convert Lottie JSON animations to ProRes 4444 MOV files with transparency for use in Final Cut Pro and other video editing software.

## Quick Start

1. **Place your Lottie JSON file** in the `assets/` directory
2. **Run the conversion script:**
   ```bash
   ./scripts/convert-lottie-with-alpha.sh assets/your-animation.json
   ```
3. **Find your video** in the `output/` directory

## Requirements

- Node.js and npm
- ffmpeg (install via `brew install ffmpeg`)
- puppeteer-lottie-cli (installed automatically by scripts)

## Files Structure

```
lottie-to-video-tools/
├── assets/              # Place your Lottie JSON files here
│   └── showtime-tap-indicator.json
├── output/              # Converted MOV files appear here
│   └── showtime-tap-indicator.mov
├── scripts/             # Conversion scripts
│   ├── convert-lottie-with-alpha.sh      # Main conversion script
│   ├── export-frames-for-inspection.sh   # Export PNG frames for manual check
│   ├── check-lottie-frames.sh            # Quick frame count check
│   └── convert-lottie-png-sequence.sh    # Alternative conversion method
└── temp/                 # Temporary files (auto-created, gitignored)
    └── lottie_frames/     # PNG frames during conversion
```

## Usage

### Convert Lottie to Video

```bash
./scripts/convert-lottie-with-alpha.sh assets/your-animation.json
```

This will:
- Export all frames as PNG sequence
- Convert to ProRes 4444 MOV with alpha channel
- Save to `output/your-animation.mov`

### Inspect Frames Manually

```bash
./scripts/export-frames-for-inspection.sh assets/your-animation.json
```

Frames will be saved to `temp/lottie_frames_inspect/` for manual review.

### Check Frame Count

```bash
./scripts/check-lottie-frames.sh assets/your-animation.json
```

Quickly verify how many frames will be exported.

## Output Format

- **Format:** MOV (ProRes 4444)
- **Transparency:** Full alpha channel support
- **Frame Rate:** 60 fps (matches Lottie JSON)
- **Quality:** High (suitable for professional video editing)

## Example: ShowTime Tap Indicator

The included `showtime-tap-indicator.json` demonstrates:
- Orange circle with border
- 20% transparent fill
- 0.3 second animation (18 frames)
- Scale animation: 70% → 150% → 123%

## Troubleshooting

**Issue:** "Only X frames exported instead of Y"
- Check the `op` value in your Lottie JSON (should match expected frame count)
- Verify frame rate (`fr`) is set correctly (usually 60)

**Issue:** "First frame repeats in video"
- This is fixed! Scripts now use proper sequential frame ordering

**Issue:** "No transparency in output"
- Ensure you're using `convert-lottie-with-alpha.sh` (not the simple version)
- Output is ProRes 4444 which supports full alpha channel

## Notes

- Temporary PNG frames are automatically cleaned up after conversion
- Inspection frames in `temp/lottie_frames_inspect/` are kept for manual review
- All scripts are executable and include error handling
