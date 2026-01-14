# ArchitectTasks

Task-driven code intelligence for Swift projects.

## Quick Start

```bash
make build-installers
```

Or open `Package.swift` in Xcode and build. This will automatically create:
- 📱 **ArchitectTasks Setup.app** - Guided installation wizard
- 🌸 **Spring Clean.app** - System storage cleaner
- 💿 **ArchitectTasks-Installer.dmg** - Complete installer package

Double-click the DMG and run the setup app to install.

## Storage Optimization

```bash
make optimize
```

Cleans and optimizes your project:
- 🗑️ Removes build artifacts (.build, DerivedData)
- 🔍 Deduplicates identical files
- 🔗 Merges multiple Xcode projects
- 💾 Reports space saved

## System Spring Cleaning

### Terminal:
```bash
make spring-clean
```

### GUI App:
```bash
make spring-clean-gui
```

Then launch from `/Applications/Spring Clean.app`

Safely cleans your entire system:
- 📦 Xcode DerivedData and caches (all users)
- 📚 Xcode Archives
- 🍺 Homebrew caches
- 📁 System caches
- 🗑️ Trash (all users)
- 📥 Old downloads (30+ days)
- ⚠️ Interactive prompts before deletion
- 🔒 Automatic app closing (Xcode, Terminal)
- 🛡️ System update detection
- 🔐 Privileged deletion with admin password

## What It Does

- **Analyzes** your Swift code for issues
- **Suggests** automated improvements
- **Applies** refactorings with your approval

## Usage

After setup, access via **Xcode > Editor > ArchitectTasks**:

- **Analyze Current File** - Scan for issues
- **Fix All Issues** - Apply all fixes
- **Show Task Panel** - Manage tasks

## Manual Installation

```bash
make install  # Skip wizard, direct install
```

## Uninstall

```bash
make uninstall
```

## Architecture

- **ArchitectCore** - Models and protocols
- **ArchitectAnalysis** - Code analyzers
- **ArchitectPlanner** - Task generation
- **ArchitectExecutor** - Code transforms
- **ArchitectHost** - Orchestration layer
- **ArchitectXcodeExtension** - Xcode integration
- **SpringClean** - System storage cleaner

## Requirements

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+
