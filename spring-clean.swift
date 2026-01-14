#!/usr/bin/env swift

import Foundation

// MARK: - Models

struct CleanableItem {
    let path: URL
    let category: String
    let size: Int
}

// MARK: - Spring Cleaner

struct SpringCleaner {
    private var isRoot: Bool {
        return getuid() == 0
    }

    private func ensureRoot() {
        if !isRoot {
            print("\n⚠️  This script needs to run as root to clean systemwide files. Please run with 'sudo'.\n")
            exit(1)
        }
    }
    
    func run() async {
        printHeader()
        
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        
        print("🔍 Scanning your system for cleanable items...\n")
        
        var items = await scanForCleanableItems(in: homeDir)
        items.append(contentsOf: scanSystemWideItems())
        
        if items.isEmpty {
            print("✨ Your system is already clean!")
            return
        }
        
        displayItems(items)
        
        let totalSize = items.reduce(0) { $0 + $1.size }
        print("\n💾 Total potential savings: \(formatBytes(totalSize))")
        
        print("\n⚠️  Review items carefully before cleaning")
        print("Would you like to proceed? (y/n): ", terminator: "")
        
        guard let response = readLine()?.lowercased(), response == "y" else {
            print("❌ Cleaning cancelled")
            return
        }
        
        ensureRoot()
        await cleanItems(items)
    }
    
    private func scanSystemWideItems() -> [CleanableItem] {
        var items: [CleanableItem] = []
        let systemDirs: [(String, String)] = [
            ("/tmp", "System /tmp"),
            ("/var/tmp", "System /var/tmp"),
            ("/Library/Caches", "System Library Caches")
        ]
        for (path, category) in systemDirs {
            items.append(contentsOf: scanDirectory(URL(fileURLWithPath: path), category: category, maxDepth: 1))
        }
        return items
    }
    
    private func scanForCleanableItems(in homeDir: URL) async -> [CleanableItem] {
        var items: [CleanableItem] = []
        
        let usersDir = URL(fileURLWithPath: "/Users")
        if let users = try? FileManager.default.contentsOfDirectory(at: usersDir, includingPropertiesForKeys: nil) {
            for userDir in users {
                guard userDir.lastPathComponent != "Shared" && userDir.lastPathComponent != ".localized" else { continue }
                
                items.append(contentsOf: scanDirectory(userDir.appendingPathComponent("Library/Developer/Xcode/DerivedData"), category: "Xcode DerivedData (\(userDir.lastPathComponent))"))
                items.append(contentsOf: scanDirectory(userDir.appendingPathComponent("Library/Caches/com.apple.dt.Xcode"), category: "Xcode Caches (\(userDir.lastPathComponent))"))
                items.append(contentsOf: scanDirectory(userDir.appendingPathComponent("Library/Developer/Xcode/Archives"), category: "Xcode Archives (\(userDir.lastPathComponent))"))
                items.append(contentsOf: scanDirectory(userDir.appendingPathComponent("Library/Caches"), category: "User Caches (\(userDir.lastPathComponent))", maxDepth: 1))
                items.append(contentsOf: scanDirectory(userDir.appendingPathComponent(".Trash"), category: "Trash (\(userDir.lastPathComponent))"))
                items.append(contentsOf: scanOldDownloads(userDir.appendingPathComponent("Downloads")))
            }
        }
        
        items.append(contentsOf: scanDirectory(URL(fileURLWithPath: "/usr/local/Homebrew/Library/Homebrew/cache"), category: "Homebrew Cache"))
        items.append(contentsOf: scanDirectory(URL(fileURLWithPath: "/Library/Caches"), category: "System Caches", maxDepth: 1))
        items.append(contentsOf: scanDirectory(URL(fileURLWithPath: "/tmp"), category: "System Temp", maxDepth: 1))
        items.append(contentsOf: scanDirectory(URL(fileURLWithPath: "/var/tmp"), category: "System Var Temp", maxDepth: 1))
        
        return items
    }
    
    private func scanDirectory(_ url: URL, category: String, maxDepth: Int = 0) -> [CleanableItem] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        
        var items: [CleanableItem] = []
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey])
            
            for item in contents {
                let size = directorySize(at: item)
                if size > 0 {
                    items.append(CleanableItem(path: item, category: category, size: size))
                }
            }
        } catch {}
        
        return items
    }
    
    private func scanOldDownloads(_ url: URL) -> [CleanableItem] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        
        var items: [CleanableItem] = []
        let thirtyDaysAgo = Date().addingTimeInterval(-30 * 24 * 60 * 60)
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.creationDateKey, .fileSizeKey])
            
            for item in contents {
                let attrs = try item.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
                if let created = attrs.creationDate, created < thirtyDaysAgo {
                    let size = attrs.fileSize ?? 0
                    items.append(CleanableItem(path: item, category: "Old Downloads (30+ days)", size: size))
                }
            }
        } catch {}
        
        return items
    }
    
    private func directorySize(at url: URL) -> Int {
        var size = 0
        let fm = FileManager.default
        
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: url.path, isDirectory: &isDir) else { return 0 }
        
        if !isDir.boolValue {
            if let attrs = try? fm.attributesOfItem(atPath: url.path),
               let fileSize = attrs[.size] as? Int {
                return fileSize
            }
            return 0
        }
        
        if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let allocatedSize = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize {
                    size += allocatedSize
                } else if let allocatedSize = try? fileURL.resourceValues(forKeys: [.fileAllocatedSizeKey]).fileAllocatedSize {
                    size += allocatedSize
                }
            }
        }
        
        return size
    }
    
    private func displayItems(_ items: [CleanableItem]) {
        let grouped = Dictionary(grouping: items, by: { $0.category })
        
        for (category, categoryItems) in grouped.sorted(by: { $0.key < $1.key }) {
            let totalSize = categoryItems.reduce(0) { $0 + $1.size }
            print("\n📁 \(category) (\(formatBytes(totalSize)))")
            
            for item in categoryItems.prefix(5) {
                print("   • \(item.path.lastPathComponent) - \(formatBytes(item.size))")
            }
            
            if categoryItems.count > 5 {
                print("   ... and \(categoryItems.count - 5) more items")
            }
        }
    }
    
    private func cleanItems(_ items: [CleanableItem]) async {
        print("\n🧹 Cleaning...")
        
        var cleaned = 0
        var totalSaved = 0
        var errors: [(String, String)] = []
        
        for item in items {
            let actualSize = directorySize(at: item.path)
            
            do {
                try FileManager.default.removeItem(at: item.path)
                cleaned += 1
                totalSaved += actualSize
                print("✅ Removed: \(item.path.lastPathComponent) - \(formatBytes(actualSize))")
            } catch let error as NSError {
                let reason = error.localizedDescription
                errors.append((item.path.lastPathComponent, reason))
                print("⚠️  Skipped: \(item.path.lastPathComponent) - \(reason)")
            }
        }
        
        print("\n✨ Cleaning complete!")
        print("   Items removed: \(cleaned)")
        print("   Actual space saved: \(formatBytes(totalSaved))")
        
        if !errors.isEmpty {
            print("\n⚠️  Issues encountered (\(errors.count)):")
            for (file, reason) in errors.prefix(10) {
                print("   • \(file): \(reason)")
            }
            if errors.count > 10 {
                print("   ... and \(errors.count - 10) more errors")
            }
        }
    }
    
    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    private func printHeader() {
        print("""
        
        🌸 Spring Cleaning Tool
        ═══════════════════════
        
        Safely clean up:
        • Xcode build artifacts
        • System caches
        • Old downloads
        • Homebrew caches
        • Trash
        
        """)
    }
}

// MARK: - Run

Task {
    await SpringCleaner().run()
    exit(0)
}

RunLoop.main.run()
