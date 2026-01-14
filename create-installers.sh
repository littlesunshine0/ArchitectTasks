#!/bin/bash
set -e

echo "🚀 ArchitectTasks Post-Build Installer"
echo "======================================"
echo ""

# Check if running from Xcode build
if [ -z "$BUILD_DIR" ]; then
    BUILD_DIR=".build/release"
fi

echo "📦 Build directory: $BUILD_DIR"
echo ""

# Function to create app bundle
create_app_bundle() {
    local APP_NAME="$1"
    local EXECUTABLE="$2"
    local BUNDLE_ID="$3"
    
    echo "📱 Creating $APP_NAME..."
    
    local APP_PATH="$BUILD_DIR/$APP_NAME.app"
    
    # Create bundle structure
    mkdir -p "$APP_PATH/Contents/MacOS"
    mkdir -p "$APP_PATH/Contents/Resources"
    
    # Copy executable
    if [ -f "$BUILD_DIR/$EXECUTABLE" ]; then
        cp "$BUILD_DIR/$EXECUTABLE" "$APP_PATH/Contents/MacOS/"
        chmod +x "$APP_PATH/Contents/MacOS/$EXECUTABLE"
    else
        echo "⚠️  Executable $EXECUTABLE not found, skipping..."
        return
    fi
    
    # Create Info.plist
    cat > "$APP_PATH/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$EXECUTABLE</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
</dict>
</plist>
EOF
    
    echo "   ✅ Created $APP_PATH"
}

# Create installers
echo "🔨 Creating application bundles..."
echo ""

create_app_bundle "ArchitectTasks Setup" "architect-setup" "com.architect.setup"
create_app_bundle "Spring Clean" "SpringClean" "com.architect.springclean"

echo ""
echo "📋 Creating installer packages..."
echo ""

# Create DMG installer
if command -v hdiutil &> /dev/null; then
    DMG_NAME="ArchitectTasks-Installer.dmg"
    DMG_PATH="$BUILD_DIR/$DMG_NAME"
    
    echo "💿 Creating DMG installer..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    
    # Copy apps to temp directory
    if [ -d "$BUILD_DIR/ArchitectTasks Setup.app" ]; then
        cp -R "$BUILD_DIR/ArchitectTasks Setup.app" "$TEMP_DIR/"
    fi
    
    if [ -d "$BUILD_DIR/Spring Clean.app" ]; then
        cp -R "$BUILD_DIR/Spring Clean.app" "$TEMP_DIR/"
    fi
    
    # Create README
    cat > "$TEMP_DIR/README.txt" << 'EOF'
ArchitectTasks Installation
===========================

1. Double-click "ArchitectTasks Setup.app" to begin installation
2. Follow the setup wizard
3. Enable the extension in System Settings
4. Restart Xcode

Optional:
- Double-click "Spring Clean.app" to clean system storage

For more information, visit:
https://github.com/littlesunshine0/ArchitectTasks
EOF
    
    # Create DMG
    hdiutil create -volname "ArchitectTasks" -srcfolder "$TEMP_DIR" -ov -format UDZO "$DMG_PATH" 2>/dev/null
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    
    echo "   ✅ Created $DMG_PATH"
else
    echo "   ⚠️  hdiutil not found, skipping DMG creation"
fi

echo ""
echo "✨ Installation packages created!"
echo ""
echo "📍 Location: $BUILD_DIR"
echo ""
echo "To install:"
echo "  1. Open: $BUILD_DIR/ArchitectTasks-Installer.dmg"
echo "  2. Run: ArchitectTasks Setup.app"
echo ""
