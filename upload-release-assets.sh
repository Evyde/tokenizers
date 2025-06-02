#!/bin/bash

# Script to upload release assets to GitHub
# Usage: ./upload-release-assets.sh v1.0.2

set -e

VERSION=${1:-"v1.0.2"}
echo "📦 Uploading release assets for version $VERSION..."

# Check if release exists
if ! gh release view "$VERSION" &> /dev/null; then
    echo "❌ Release $VERSION does not exist. Please create it first at:"
    echo "    https://github.com/Evyde/tokenizers/releases/new"
    echo ""
    echo "📋 Use this information for the release:"
    echo "    Tag: $VERSION"
    echo "    Title: Tokenizers Go Library $VERSION - Multi-Platform Release"
    echo ""
    echo "📝 Release notes:"
    cat RELEASE_v1.0.2_SUMMARY.md
    exit 1
fi

echo "✅ Release $VERSION found. Uploading assets..."

# Upload each platform's library
echo "🍎 Uploading macOS x86_64 library..."
if [ -f "libtokenizers-darwin-amd64/libtokenizers-darwin-amd64.tar.gz" ]; then
    gh release upload "$VERSION" "libtokenizers-darwin-amd64/libtokenizers-darwin-amd64.tar.gz" --clobber
    echo "   ✅ macOS x86_64 uploaded"
else
    echo "   ❌ macOS x86_64 file not found"
fi

echo "🍎 Uploading macOS ARM64 library..."
if [ -f "libtokenizers-darwin-arm64/libtokenizers-darwin-arm64.tar.gz" ]; then
    gh release upload "$VERSION" "libtokenizers-darwin-arm64/libtokenizers-darwin-arm64.tar.gz" --clobber
    echo "   ✅ macOS ARM64 uploaded"
else
    echo "   ❌ macOS ARM64 file not found"
fi

echo "🐧 Uploading Linux x86_64 library..."
if [ -f "libtokenizers-linux-amd64/libtokenizers-linux-amd64.tar.gz" ]; then
    gh release upload "$VERSION" "libtokenizers-linux-amd64/libtokenizers-linux-amd64.tar.gz" --clobber
    echo "   ✅ Linux x86_64 uploaded"
else
    echo "   ❌ Linux x86_64 file not found"
fi

echo "🪟 Uploading Windows x86_64 library..."
if [ -f "libtokenizers-windows-amd64.zip" ]; then
    gh release upload "$VERSION" "libtokenizers-windows-amd64.zip" --clobber
    echo "   ✅ Windows x86_64 uploaded"
else
    echo "   ❌ Windows x86_64 file not found"
fi

echo ""
echo "🎉 All available assets uploaded successfully!"
echo "📊 Release summary:"
gh release view "$VERSION"
echo ""
echo "🔗 View the release at:"
echo "    https://github.com/Evyde/tokenizers/releases/tag/$VERSION"
