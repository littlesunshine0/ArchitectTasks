import SwiftUI

@main
struct SpringCleanApp: App {
    var body: some Scene {
        WindowGroup {
            SpringCleanView()
        }
        .windowResizability(.contentSize)
    }
}

struct SpringCleanView: View {
    @StateObject private var cleaner = SystemCleaner()
    @State private var showConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
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
            
            if cleaner.isScanning {
                ProgressView("Scanning system...")
                    .padding()
            } else if cleaner.items.isEmpty && !cleaner.isScanning {
                ResultsView(cleaner: cleaner)
            } else {
                CleanableItemsList(items: cleaner.groupedItems, totalSize: cleaner.totalSize)
            }
            
            ActionsView(cleaner: cleaner, showConfirmation: $showConfirmation)
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
            Text("This will delete \(cleaner.items.count) items and free up approximately \(cleaner.formattedTotalSize). Actual savings may vary. This action cannot be undone.")
        }
    }
}

struct ResultsView: View {
    @ObservedObject var cleaner: SystemCleaner
    
    var body: some View {
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
                ErrorsView(errors: cleaner.errors)
            }
        }
        .padding()
    }
}

struct ErrorsView: View {
    let errors: [CleaningError]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("⚠️ Issues (\(errors.count)):")
                .font(.headline)
                .foregroundColor(.orange)
            
            ForEach(errors.prefix(5)) { error in
                Text("• \(error.message)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if errors.count > 5 {
                Text("... and \(errors.count - 5) more")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ActionsView: View {
    @ObservedObject var cleaner: SystemCleaner
    @Binding var showConfirmation: Bool
    
    var body: some View {
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
}

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

@MainActor
class SystemCleaner: ObservableObject {
    @Published var items: [CleanableItem] = []
    @Published var isScanning = false
    @Published var errors: [CleaningError] = []
    @Published var actualSaved = 0
    
    private let core = SpringCleanCore()
    
    var groupedItems: [String: [CleanableItem]] {
        Dictionary(grouping: items, by: { $0.category })
    }
    
    var totalSize: Int {
        items.reduce(0) { $0 + $1.size }
    }
    
    var formattedTotalSize: String {
        core.formatBytes(totalSize)
    }
    
    var formattedActualSaved: String {
        core.formatBytes(actualSaved)
    }
    
    func scan() async {
        isScanning = true
        items = []
        errors = []
        
        if core.checkForUpdates() {
            errors.append(CleaningError(message: "System update in progress - cleaning blocked"))
            isScanning = false
            return
        }
        
        core.closeAffectedApps()
        
        var scannedItems = core.scanAllUsers()
        scannedItems.append(contentsOf: core.scanSystemWideItems())
        
        items = scannedItems
        isScanning = false
    }
    
    func clean() async {
        errors = []
        actualSaved = 0
        var itemsToDelete: [(URL, Int)] = []
        
        for item in items {
            let actualSize = core.directorySize(at: item.path)
            itemsToDelete.append((item.path, actualSize))
        }
        
        let paths = itemsToDelete.map { "'\($0.0.path)'" }.joined(separator: " ")
        let script = "do shell script \"rm -rf \(paths)\" with administrator privileges"
        
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }
        
        if let error = error {
            errors.append(CleaningError(message: "Failed to delete items: \(error.description)"))
        } else {
            for (path, size) in itemsToDelete {
                if !FileManager.default.fileExists(atPath: path.path) {
                    actualSaved += size
                }
            }
        }
        
        await scan()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            NSApplication.shared.terminate(nil)
        }
    }
}

struct CleaningError: Identifiable {
    let id = UUID()
    let message: String
}
