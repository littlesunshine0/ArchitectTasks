import Foundation

// MARK: - Models

public struct CleanableItem {
    public let path: URL
    public let category: String
    public let size: Int
    
    public init(path: URL, category: String, size: Int) {
        self.path = path
        self.category = category
        self.size = size
    }
}

// MARK: - Spring Clean Core

public struct SpringCleanCore {
    public init() {}
    
    public func scanSystemWideItems() -> [CleanableItem] {
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
    
    public func scanAllUsers() -> [CleanableItem] {
        var items: [CleanableItem] = []
        
        let usersDir = URL(fileURLWithPath: "/Users")
        guard let users = try? FileManager.default.contentsOfDirectory(at: usersDir, includingPropertiesForKeys: nil) else {
            return []
        }
        
        for userDir in users {
            guard userDir.lastPathComponent != "Shared" && userDir.lastPathComponent != ".localized" else { continue }
            
            items.append(contentsOf: scanDirectory(userDir.appendingPathComponent("Library/Developer/Xcode/DerivedData"), category: "Xcode DerivedData (\(userDir.lastPathComponent))"))
            items.append(contentsOf: scanDirectory(userDir.appendingPathComponent("Library/Caches/com.apple.dt.Xcode"), category: "Xcode Caches (\(userDir.lastPathComponent))"))
            items.append(contentsOf: scanDirectory(userDir.appendingPathComponent("Library/Developer/Xcode/Archives"), category: "Xcode Archives (\(userDir.lastPathComponent))"))
            items.append(contentsOf: scanDirectory(userDir.appendingPathComponent("Library/Caches"), category: "User Caches (\(userDir.lastPathComponent))", maxDepth: 1))
            items.append(contentsOf: scanDirectory(userDir.appendingPathComponent(".Trash"), category: "Trash (\(userDir.lastPathComponent))"))
            items.append(contentsOf: scanOldDownloads(userDir.appendingPathComponent("Downloads"), user: userDir.lastPathComponent))
        }
        
        items.append(contentsOf: scanDirectory(URL(fileURLWithPath: "/usr/local/Homebrew/Library/Homebrew/cache"), category: "Homebrew Cache"))
        items.append(contentsOf: scanDirectory(URL(fileURLWithPath: "/Library/Caches"), category: "System Caches", maxDepth: 1))
        items.append(contentsOf: scanDirectory(URL(fileURLWithPath: "/tmp"), category: "System Temp", maxDepth: 1))
        items.append(contentsOf: scanDirectory(URL(fileURLWithPath: "/var/tmp"), category: "System Var Temp", maxDepth: 1))
        
        return items
    }
    
    public func scanDirectory(_ url: URL, category: String, maxDepth: Int = 0) -> [CleanableItem] {
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
    
    public func scanOldDownloads(_ url: URL, user: String) -> [CleanableItem] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        
        var items: [CleanableItem] = []
        let thirtyDaysAgo = Date().addingTimeInterval(-30 * 24 * 60 * 60)
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.creationDateKey, .fileSizeKey])
            
            for item in contents {
                let attrs = try item.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
                if let created = attrs.creationDate, created < thirtyDaysAgo {
                    let size = attrs.fileSize ?? 0
                    items.append(CleanableItem(path: item, category: "Old Downloads (\(user))", size: size))
                }
            }
        } catch {}
        
        return items
    }
    
    public func directorySize(at url: URL) -> Int {
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
    
    public func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    public func checkForUpdates() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/pgrep"
        task.arguments = ["softwareupdated"]
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
    
    public func closeAffectedApps() {
        let appsToClose = ["Xcode", "Terminal", "iTerm"]
        
        for app in appsToClose {
            let script = """
            tell application "\(app)"
                if it is running then
                    quit
                end if
            end tell
            """
            
            NSAppleScript(source: script)?.executeAndReturnError(nil)
        }
    }
}
