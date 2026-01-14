#!/usr/bin/env swift

import Foundation

// Load core logic
let coreFile = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("SpringCleanCore.swift")
let coreCode = try! String(contentsOf: coreFile)
eval(coreCode)

// MARK: - Terminal Interface

struct SpringCleanTerminal {
    let core = SpringCleanCore()
    
    func run() async {
        printHeader()
        
        print("🔍 Scanning your system for cleanable items...\n")
        
        var items = core.scanAllUsers()
        items.append(contentsOf: core.scanSystemWideItems())
        
        if items.isEmpty {
            print("✨ Your system is already clean!")
            return
        }
        
        displayItems(items)
        
        let totalSize = items.reduce(0) { $0 + $1.size }
        print("\n💾 Total potential savings: \(core.formatBytes(totalSize))")
        
        print("\n⚠️  Review items carefully before cleaning")
        print("Would you like to proceed? (y/n): ", terminator: "")
        
        guard let response = readLine()?.lowercased(), response == "y" else {
            print("❌ Cleaning cancelled")
            return
        }
        
        ensureRoot()
        await cleanItems(items)
    }
    
    private func ensureRoot() {
        if getuid() != 0 {
            print("\n⚠️  This script needs to run as root. Please run with 'sudo'.\n")
            exit(1)
        }
    }
    
    private func displayItems(_ items: [CleanableItem]) {
        let grouped = Dictionary(grouping: items, by: { $0.category })
        
        for (category, categoryItems) in grouped.sorted(by: { $0.key < $1.key }) {
            let totalSize = categoryItems.reduce(0) { $0 + $1.size }
            print("\n📁 \(category) (\(core.formatBytes(totalSize)))")
            
            for item in categoryItems.prefix(5) {
                print("   • \(item.path.lastPathComponent) - \(core.formatBytes(item.size))")
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
            let actualSize = core.directorySize(at: item.path)
            
            do {
                try FileManager.default.removeItem(at: item.path)
                cleaned += 1
                totalSaved += actualSize
                print("✅ Removed: \(item.path.lastPathComponent) - \(core.formatBytes(actualSize))")
            } catch let error as NSError {
                let reason = error.localizedDescription
                errors.append((item.path.lastPathComponent, reason))
                print("⚠️  Skipped: \(item.path.lastPathComponent) - \(reason)")
            }
        }
        
        print("\n✨ Cleaning complete!")
        print("   Items removed: \(cleaned)")
        print("   Actual space saved: \(core.formatBytes(totalSaved))")
        
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

// Run
Task {
    await SpringCleanTerminal().run()
    exit(0)
}

RunLoop.main.run()
