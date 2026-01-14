import Foundation

// MARK: - Storage Cleaner

struct StorageCleaner {
    func clean(projectRoot: URL) async throws -> CleanupReport {
        var report = CleanupReport()
        
        report.buildArtifacts = try await cleanBuildArtifacts(at: projectRoot)
        report.duplicates = try await removeDuplicates(at: projectRoot)
        report.merged = try await mergeProjects(at: projectRoot)
        
        return report
    }
    
    private func cleanBuildArtifacts(at root: URL) async throws -> Int {
        let patterns = [".build", "build", "DerivedData", ".swiftpm", "*.xcworkspace/xcuserdata"]
        var cleaned = 0
        
        for pattern in patterns {
            cleaned += try removeMatching(pattern: pattern, in: root)
        }
        
        return cleaned
    }
    
    private func removeDuplicates(at root: URL) async throws -> Int {
        let fm = FileManager.default
        var hashes: [String: URL] = [:]
        var removed = 0
        
        guard let enumerator = fm.enumerator(at: root, includingPropertiesForKeys: [.isRegularFileKey]) else {
            return 0
        }
        
        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension == "swift" else { continue }
            
            let hash = try hashFile(at: fileURL)
            
            if let existing = hashes[hash] {
                try fm.removeItem(at: fileURL)
                removed += 1
            } else {
                hashes[hash] = fileURL
            }
        }
        
        return removed
    }
    
    private func mergeProjects(at root: URL) async throws -> Int {
        let fm = FileManager.default
        var merged = 0
        
        let projects = try fm.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "xcodeproj" }
        
        guard projects.count > 1 else { return 0 }
        
        let mainProject = projects[0]
        
        for project in projects.dropFirst() {
            try mergeProject(from: project, into: mainProject)
            try fm.removeItem(at: project)
            merged += 1
        }
        
        return merged
    }
    
    private func removeMatching(pattern: String, in root: URL) throws -> Int {
        let fm = FileManager.default
        var count = 0
        
        guard let enumerator = fm.enumerator(at: root, includingPropertiesForKeys: nil) else {
            return 0
        }
        
        for case let url as URL in enumerator {
            if url.lastPathComponent.contains(pattern.replacingOccurrences(of: "*", with: "")) {
                try? fm.removeItem(at: url)
                count += 1
            }
        }
        
        return count
    }
    
    private func hashFile(at url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        return String(data.hashValue)
    }
    
    private func mergeProject(from source: URL, into target: URL) throws {
        let fm = FileManager.default
        let sourceFiles = try fm.contentsOfDirectory(at: source, includingPropertiesForKeys: nil)
        
        for file in sourceFiles {
            let destination = target.appendingPathComponent(file.lastPathComponent)
            if !fm.fileExists(atPath: destination.path) {
                try fm.copyItem(at: file, to: destination)
            }
        }
    }
}

// MARK: - Report

struct CleanupReport {
    var buildArtifacts = 0
    var duplicates = 0
    var merged = 0
    
    var totalSaved: Int {
        buildArtifacts + duplicates + merged
    }
}

// MARK: - CLI Command

extension StorageCleaner {
    static func runCLI(projectPath: String) async {
        let cleaner = StorageCleaner()
        let url = URL(fileURLWithPath: projectPath)
        
        print("🧹 Cleaning project at \(projectPath)...")
        
        do {
            let report = try await cleaner.clean(projectRoot: url)
            
            print("\n✅ Cleanup Complete!")
            print("   Build artifacts removed: \(report.buildArtifacts)")
            print("   Duplicate files removed: \(report.duplicates)")
            print("   Projects merged: \(report.merged)")
            print("   Total items cleaned: \(report.totalSaved)")
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
    }
}
