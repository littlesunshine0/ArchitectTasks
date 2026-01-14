import SwiftUI

// MARK: - Spring Clean App

@main
struct SpringCleanApp: App {
    var body: some Scene {
        WindowGroup {
            SpringCleanView()
        }
        .windowResizability(.contentSize)
    }
}

// MARK: - Main View

struct SpringCleanView: View {
    @StateObject private var cleaner = SystemCleaner()
    @State private var showConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                Text("Spring Clean")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Safely clean your system storage")
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
            
            // Content
            if cleaner.isScanning {
                ProgressView("Scanning system...")
                    .padding()
            } else if cleaner.items.isEmpty && !cleaner.isScanning {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    Text("Your system is clean!")
                        .font(.headline)
                    
                    if cleaner.actualSaved > 0 {
                        Text("Cleaned \(cleaner.formattedActualSaved)")
                            .foregroundColor(.secondary)
                    }
                    
                    if !cleaner.errors.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("⚠️ Issues (\(cleaner.errors.count)):")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            ForEach(cleaner.errors.prefix(5)) { error in
                                Text("• \(error.message)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if cleaner.errors.count > 5 {
                                Text("... and \(cleaner.errors.count - 5) more")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            } else {
                CleanableItemsList(items: cleaner.groupedItems, totalSize: cleaner.totalSize)
            }
            
            // Actions
            HStack(spacing: 12) {
                if !cleaner.items.isEmpty {
                    Button("Scan Again") {
                        Task { await cleaner.scan() }
                    }
                    .buttonStyle(.bordered)
                }
                
                if cleaner.isScanning {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if !cleaner.items.isEmpty {
                    Button("Clean (\(cleaner.formattedTotalSize))") {
                        showConfirmation = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                }
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 700, height: 600)
        .onAppear {
            Task { await cleaner.scan() }
        }
        .alert("Confirm Cleaning", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clean", role: .destructive) {
                Task { await cleaner.clean() }
            }
        } message: {
            Text("This will delete \(cleaner.items.count) items and free up approximately \(cleaner.formattedTotalSize). Actual savings may vary due to file system overhead. This action cannot be undone.")
        }
    }
}

// MARK: - Items List

struct CleanableItemsList: View {
    let items: [String: [CleanableItem]]
    let totalSize: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(items.keys.sorted(), id: \.self) { category in
                    CategorySection(category: category, items: items[category] ?? [])
                }
            }
            .padding()
        }
    }
}

// MARK: - Category Section

struct CategorySection: View {
    let category: String
    let items: [CleanableItem]
    @State private var isExpanded = true
    
    var categorySize: Int {
        items.reduce(0) { $0 + $1.size }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    Image(systemName: categoryIcon)
                        .foregroundColor(.purple)
                    Text(category)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(formatBytes(categorySize))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(items.prefix(10)) { item in
                        HStack {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(item.path.lastPathComponent)
                                .lineLimit(1)
                            Spacer()
                            Text(formatBytes(item.size))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 24)
                    }
                    
                    if items.count > 10 {
                        Text("... and \(items.count - 10) more items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 24)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var categoryIcon: String {
        switch category {
        case let c where c.contains("Xcode"): return "hammer.fill"
        case let c where c.contains("Homebrew"): return "cube.fill"
        case let c where c.contains("Cache"): return "folder.fill"
        case let c where c.contains("Trash"): return "trash.fill"
        case let c where c.contains("Download"): return "arrow.down.circle.fill"
        default: return "folder.fill"
        }
    }
    
    private func formatBytes(_ bytes: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }
}

// MARK: - System Cleaner

@MainActor
class SystemCleaner: ObservableObject {
    @Published var items: [CleanableItem] = []
    @Published var isScanning = false
    @Published var isUpdateRunning = false
    @Published var errors: [CleaningError] = []
    @Published var actualSaved = 0
    
    var groupedItems: [String: [CleanableItem]] {
        Dictionary(grouping: items, by: { $0.category })
    }
    
    var totalSize: Int {
        items.reduce(0) { $0 + $1.size }
    }
    
    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .file)
    }
    
    var formattedActualSaved: String {
        ByteCountFormatter.string(fromByteCount: Int64(actualSaved), countStyle: .file)
    }
    
    func scan() async {
        isScanning = true
        items = []
        
        // Check for system updates
        if await checkForUpdates() {
            isUpdateRunning = true
            isScanning = false
            return
        }
        
        // Close affected apps
        await closeAffectedApps()
        
        var scannedItems: [CleanableItem] = []
        
        // Scan all user directories
        let usersDir = URL(fileURLWithPath: "/Users")
        if let users = try? FileManager.default.contentsOfDirectory(at: usersDir, includingPropertiesForKeys: nil) {
            for userDir in users {
                guard userDir.lastPathComponent != "Shared" && userDir.lastPathComponent != ".localized" else { continue }
                
                scannedItems.append(contentsOf: await scanDirectory(userDir.appendingPathComponent("Library/Developer/Xcode/DerivedData"), category: "Xcode DerivedData (\(userDir.lastPathComponent))"))
                scannedItems.append(contentsOf: await scanDirectory(userDir.appendingPathComponent("Library/Caches/com.apple.dt.Xcode"), category: "Xcode Caches (\(userDir.lastPathComponent))"))
                scannedItems.append(contentsOf: await scanDirectory(userDir.appendingPathComponent("Library/Developer/Xcode/Archives"), category: "Xcode Archives (\(userDir.lastPathComponent))"))
                scannedItems.append(contentsOf: await scanDirectory(userDir.appendingPathComponent("Library/Caches"), category: "User Caches (\(userDir.lastPathComponent))", maxDepth: 1))
                scannedItems.append(contentsOf: await scanDirectory(userDir.appendingPathComponent(".Trash"), category: "Trash (\(userDir.lastPathComponent))"))
                scannedItems.append(contentsOf: await scanOldDownloads(userDir.appendingPathComponent("Downloads"), user: userDir.lastPathComponent))
            }
        }
        
        // System-wide locations
        scannedItems.append(contentsOf: await scanDirectory(URL(fileURLWithPath: "/usr/local/Homebrew/Library/Homebrew/cache"), category: "Homebrew Cache"))
        scannedItems.append(contentsOf: await scanDirectory(URL(fileURLWithPath: "/Library/Caches"), category: "System Caches", maxDepth: 1))
        scannedItems.append(contentsOf: await scanDirectory(URL(fileURLWithPath: "/tmp"), category: "System Temp", maxDepth: 1))
        scannedItems.append(contentsOf: await scanDirectory(URL(fileURLWithPath: "/var/tmp"), category: "System Var Temp", maxDepth: 1))
        
        items = scannedItems
        isScanning = false
    }
    
    func clean() async {
        errors = []
        actualSaved = 0
        var itemsToDelete: [(URL, Int)] = []
        
        // Measure actual sizes before deletion
        for item in items {
            let actualSize = directorySize(at: item.path)
            itemsToDelete.append((item.path, actualSize))
        }
        
        let paths = itemsToDelete.map { $0.0.path }.joined(separator: " ")
        let script = """
        do shell script "rm -rf \(paths)" with administrator privileges
        """
        
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }
        
        if let error = error {
            errors.append(CleaningError(message: "Failed to delete items: \(error.description)"))
        } else {
            // Calculate actual savings
            for (path, size) in itemsToDelete {
                if !FileManager.default.fileExists(atPath: path.path) {
                    actualSaved += size
                }
            }
        }
        
        await scan()
        
        // Show results before quitting
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            NSApplication.shared.terminate(nil)
        }
    }
    
    private func checkForUpdates() async -> Bool {
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
    
    private func closeAffectedApps() async {
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
    
    private func scanDirectory(_ url: URL, category: String, maxDepth: Int = 0) async -> [CleanableItem] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        
        var items: [CleanableItem] = []
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey])
            
            for item in contents {
                let size = directorySize(at: item)
                if size > 0 {
                    items.append(CleanableItem(path: item, category: category, size: size))
                }
            }
        } catch {}
        
        return items
    }
    
    private func scanOldDownloads(_ url: URL, user: String) async -> [CleanableItem] {
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
}

// MARK: - Models

struct CleanableItem: Identifiable {
    let id = UUID()
    let path: URL
    let category: String
    let size: Int
}

struct CleaningError: Identifiable {
    let id = UUID()
    let message: String
}
