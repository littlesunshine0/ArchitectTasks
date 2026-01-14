# ArchitectTasks Xcode Extension

Integrates ArchitectTasks directly into Xcode's Editor menu.

## Quick Install

```bash
make install
```

That's it! The installer will:
1. ✅ Build the extension
2. ✅ Copy to /Applications (asks for password)
3. ✅ Open System Settings for you
4. ✅ Show next steps

## Manual Installation

```bash
./install-extension.sh
```

Or step by step:

```bash
# Build
xcodebuild -scheme ArchitectXcodeExtension -configuration Release

# Install
sudo cp -r .build/Release/ArchitectTasks.app /Applications/

# Enable
open "x-apple.systempreferences:com.apple.preference.extensions?Xcode Source Editor"
```

## Uninstall

```bash
make uninstall
```

## Usage

Access commands via **Editor > ArchitectTasks**:

- **Analyze Current File** - Scans for issues and adds inline annotations
- **Fix All Issues** - Applies all automated fixes
- **Show Task Panel** - Opens task management interface

## After Installation

1. Check ✓ **ArchitectTasks** in System Settings
2. Restart Xcode if running
3. Commands appear in **Editor > ArchitectTasks** menu
