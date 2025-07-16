#!/bin/bash
# Build script for generating TwemojiCountryFlags.woff2
# 
# This script processes a source Twemoji TTF file and creates a subset containing
# only country flag emojis in WOFF2 format.
#
# Dependencies: fonttools (specifically pyftsubset command)
# 
# Expected input: twemoji-source.ttf in the same directory as this script
# Output: TwemojiCountryFlags.woff2 in ../dist/ directory
#
# The GitHub Action downloads the source TTF file from https://github.com/JoeBlakeB/ttf-twemoji-aur/releases and places it at build/twemoji-source.ttf
# before running this script.

set -e  # Exit on any error

# Define the source TTF file path (downloaded by GitHub Action)
SOURCE_TTF="./twemoji-source.ttf"

# Verify that the source TTF file exists
if [ ! -f "$SOURCE_TTF" ]; then
    echo "Error: Source TTF file not found at $SOURCE_TTF"
    echo "This file should be downloaded by the GitHub Action before running this script."
    exit 1
fi

echo "Processing source TTF file: $SOURCE_TTF"
echo "File size: $(stat -c%s "$SOURCE_TTF") bytes"

# Ensure that the output directory exists
mkdir -p ../dist

echo "Creating country flags subset..."

# Create a subset containing only country flag emojis and save as WOFF2
#
# Technical details:
# - We drop the "FFTM" table because it's FontForge metadata that pyftsubset
#   can't handle and generates warnings. We don't need this metadata.
# - The --unicodes parameter specifies which Unicode ranges to include:
#
#   Unicode ranges for country flags:
#   • U+1F1E6-1F1FF: Regional Indicator Symbols (A-Z)
#     These combine in pairs to create standard country flags (e.g., 🇺🇸 = 🇺 + 🇸)
#   
#   Unicode ranges for subdivision flags (England, Scotland, Wales, etc.):
#   • U+1F3F4: Waving Black Flag (base flag for subdivisions)
#   • U+E0061-E007A: Tag Latin Small Letters (a-z in tag form)
#   • U+E007F: Cancel Tag (terminates the tag sequence)
#   
#   Example: England flag 🏴󠁧󠁢󠁥󠁮󠁧󠁿 = 🏴 + tag sequence for "gbeng"
#
# - --flavor=woff2 generates the modern WOFF2 format (better compression than WOFF)
pyftsubset "$SOURCE_TTF" \
  --no-subset-tables+=FFTM \
  --unicodes=U+1F1E6-1F1FF,U+1F3F4,U+E0061-E007A,U+E007F \
  --output-file=../dist/TwemojiCountryFlags.woff2 \
  --flavor=woff2

# Verify the output file was created
if [ ! -f "../dist/TwemojiCountryFlags.woff2" ]; then
    echo "Error: Failed to generate output font file"
    exit 1
fi

# Clean up: remove the source TTF file (no longer needed)
rm "$SOURCE_TTF"

echo "Font generation completed successfully!"
echo "Output file: ../dist/TwemojiCountryFlags.woff2"
echo "Output size: $(stat -c%s "../dist/TwemojiCountryFlags.woff2") bytes"

# Display some basic info about the generated font
echo ""
echo "Font subset summary:"
echo "- Contains only country flag emojis (regional indicators + subdivision flags)"
echo "- Format: WOFF2 (optimized for web use)"
echo "- Ready for deployment to GitHub Pages"
