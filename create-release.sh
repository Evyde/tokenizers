#!/bin/bash

# Script to create a release with all platform libraries

set -e

VERSION=${1:-"v1.0.0"}
echo "Creating release $VERSION..."

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is required but not installed."
    echo "Install it with: brew install gh"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Please authenticate with GitHub CLI first:"
    echo "    gh auth login"
    exit 1
fi

echo "🚀 Triggering release workflow for version $VERSION..."

# Trigger the release workflow
gh workflow run release.yaml --field tag="$VERSION"

echo "✅ Release workflow triggered!"
echo ""
echo "📊 You can monitor the progress at:"
echo "    https://github.com/$(gh repo view --json owner,name -q '.owner.login + "/" + .name')/actions"
echo ""
echo "⏳ The build typically takes 15-20 minutes for all platforms."
echo "📦 Once complete, the release will be automatically created with all platform libraries."
echo ""
echo "🎯 The release will include:"
echo "   - Windows x86_64 (libtokenizers-windows-amd64.zip)"
echo "   - macOS x86_64 (libtokenizers-darwin-amd64.tar.gz)"
echo "   - macOS ARM64 (libtokenizers-darwin-arm64.tar.gz)"
echo "   - Linux x86_64 (libtokenizers-linux-amd64.tar.gz)"
echo "   - Linux ARM64 (libtokenizers-linux-arm64.tar.gz)"
