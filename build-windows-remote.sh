#!/bin/bash

# Script to trigger Windows build using GitHub Actions
# This script helps you build Windows binaries remotely

set -e

echo "🚀 Building Windows binaries using GitHub Actions..."
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: This script must be run from within a git repository."
    exit 1
fi

# Check if we have a remote origin
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "❌ Error: No git remote 'origin' found."
    echo "Please push this repository to GitHub first."
    exit 1
fi

REPO_URL=$(git remote get-url origin)
echo "📁 Repository: $REPO_URL"

# Extract owner and repo name from URL
if [[ $REPO_URL =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    REPO="${REPO%.git}"  # Remove .git suffix if present
else
    echo "❌ Error: Could not parse GitHub repository URL: $REPO_URL"
    exit 1
fi

echo "👤 Owner: $OWNER"
echo "📦 Repository: $REPO"
echo ""

# Check if GitHub CLI is available
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI found. Triggering workflow..."
    
    # Check if user is authenticated
    if ! gh auth status &> /dev/null; then
        echo "🔐 Please authenticate with GitHub CLI first:"
        echo "    gh auth login"
        exit 1
    fi
    
    # Trigger the Windows workflow
    echo "🔄 Triggering Windows build workflow..."
    if gh workflow run windows.yaml --repo "$OWNER/$REPO"; then
        echo "✅ Workflow triggered successfully!"
        echo ""
        echo "📊 You can monitor the build progress at:"
        echo "    https://github.com/$OWNER/$REPO/actions"
        echo ""
        echo "⏳ The build typically takes 5-10 minutes."
        echo "📥 Once complete, you can download the artifacts from the Actions page."
    else
        echo "❌ Failed to trigger workflow. Please check:"
        echo "   1. The repository exists on GitHub"
        echo "   2. You have push access to the repository"
        echo "   3. The .github/workflows/windows.yaml file exists"
    fi
else
    echo "⚠️  GitHub CLI not found."
    echo ""
    echo "To build Windows binaries remotely:"
    echo ""
    echo "1. 📤 Push your changes to GitHub:"
    echo "   git add ."
    echo "   git commit -m 'Add Windows support'"
    echo "   git push origin main"
    echo ""
    echo "2. 🌐 Go to your repository on GitHub:"
    echo "   https://github.com/$OWNER/$REPO"
    echo ""
    echo "3. 🔄 Navigate to Actions tab and manually trigger the 'Windows Build' workflow"
    echo ""
    echo "4. 📥 Download the built artifacts once the workflow completes"
    echo ""
    echo "Alternatively, install GitHub CLI to automate this process:"
    echo "   brew install gh  # on macOS"
    echo "   gh auth login"
    echo "   ./build-windows-remote.sh"
fi

echo ""
echo "💡 Tip: You can also build locally using Docker if you have it installed:"
echo "   docker build -f Dockerfile.windows -t tokenizers-windows ."
echo "   docker run --rm -v \$(pwd)/artifacts:/output tokenizers-windows"
