#!/bin/bash
set -e

echo "🔨 Building Spring Clean App..."

# Build
swift build --product SpringClean --configuration release

# Create app bundle
APP_NAME="Spring Clean.app"
BUILD_DIR=".build/release"
APP_DIR="$BUILD_DIR/$APP_NAME"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy executable
cp "$BUILD_DIR/SpringClean" "$APP_DIR/Contents/MacOS/"

# Copy Info.plist
cp "Sources/Info.plist" "$APP_DIR/Contents/"

echo "✅ App bundle created at $APP_DIR"

# Copy to Applications
echo "📦 Installing to /Applications..."
sudo cp -r "$APP_DIR" "/Applications/"

echo "✨ Spring Clean installed!"
echo "   Launch from /Applications/Spring Clean.app"
