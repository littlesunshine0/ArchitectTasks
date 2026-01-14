# Spring Clean

System-wide storage cleaning tool for macOS.

## Quick Start

### Terminal:
```bash
sudo ./spring-clean.swift
```

### GUI App:
```bash
./build.sh
```

Then launch from `/Applications/Spring Clean.app`

## What It Cleans

- 📦 **Xcode DerivedData** - Build caches for all users
- 📚 **Xcode Archives** - Old app archives
- 🍺 **Homebrew Cache** - Package manager caches
- 📁 **System Caches** - User and system caches
- 🗑️ **Trash** - Items in trash for all users
- 📥 **Old Downloads** - Files 30+ days old

## Features

✅ **Multi-user** - Cleans all users on the system
✅ **Accurate sizing** - Uses allocated disk space
✅ **Safe** - Requires confirmation before deletion
✅ **Update detection** - Blocks if system updating
✅ **Auto app closing** - Closes Xcode, Terminal, iTerm
✅ **Error reporting** - Shows what couldn't be deleted
✅ **Actual savings** - Reports real space freed

## Requirements

- macOS 14.0+
- Admin privileges (for system-wide cleaning)
