#!/bin/bash
set -e

echo "🔨 ArchitectTasks Xcode Extension Installer"
echo "==========================================="
echo ""

# Build extension
echo "📦 Building extension..."
xcodebuild -scheme ArchitectXcodeExtension -configuration Release -derivedDataPath .build

# Find built app
APP_PATH=$(find .build -name "ArchitectTasks.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo "❌ Build failed - app not found"
    exit 1
fi

echo "✅ Build complete"
echo ""

# Copy to Applications
echo "📂 Installing to /Applications..."
sudo cp -r "$APP_PATH" /Applications/

echo "✅ Installed to /Applications/ArchitectTasks.app"
echo ""

# Open Xcode Extensions settings
echo "⚙️  Opening Xcode Extensions settings..."
open "x-apple.systempreferences:com.apple.preference.extensions?Xcode Source Editor"

echo ""
echo "📋 Next Steps:"
echo "1. In the window that opened, check ✓ ArchitectTasks"
echo "2. Restart Xcode if it's running"
echo "3. Access via Editor > ArchitectTasks menu"
echo ""
echo "✨ Installation complete!"
