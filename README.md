# ArchitectTasks

Task-driven code intelligence for Swift projects.

## Quick Start

```bash
make setup
```

This launches a guided setup wizard that will:
1. ✨ Welcome you to ArchitectTasks
2. 🔐 Request necessary permissions
3. 🔨 Build and install the Xcode extension
4. ⚙️ Open System Settings for final activation

## Storage Optimization

```bash
make optimize
```

Cleans and optimizes your project:
- 🗑️ Removes build artifacts (.build, DerivedData)
- 🔍 Deduplicates identical files
- 🔗 Merges multiple Xcode projects
- 💾 Reports space saved

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

## Requirements

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+
