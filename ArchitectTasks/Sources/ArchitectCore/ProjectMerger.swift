import Foundation

// MARK: - Project Merger

struct ProjectMerger {
    func merge(projects: [URL], into target: URL) async throws -> MergeReport {
        var report = MergeReport()
        let fm = FileManager.default
        
        for project in projects where project != target {
            let sources = try collectSources(from: project)
            
            for source in sources {
                let relativePath = source.path.replacingOccurrences(of: project.path, with: "")
                let destination = target.appendingPathComponent(relativePath)
                
                try fm.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
                
                if fm.fileExists(atPath: destination.path) {
                    if try filesAreIdentical(source, destination) {
                        report.skipped += 1
                    } else {
                        try mergeFiles(source: source, destination: destination)
                        report.merged += 1
                    }
                } else {
                    try fm.copyItem(at: source, to: destination)
                    report.copied += 1
                }
            }
            
            report.projectsMerged += 1
        }
        
        return report
    }
    
    private func collectSources(from project: URL) throws -> [URL] {
        let fm = FileManager.default
        var sources: [URL] = []
        
        guard let enumerator = fm.enumerator(at: project, includingPropertiesForKeys: [.isRegularFileKey]) else {
            return []
        }
        
        for case let url as URL in enumerator {
            if url.pathExtension == "swift" {
                sources.append(url)
            }
        }
        
        return sources
    }
    
    private func filesAreIdentical(_ url1: URL, _ url2: URL) throws -> Bool {
        let data1 = try Data(contentsOf: url1)
        let data2 = try Data(contentsOf: url2)
        return data1 == data2
    }
    
    private func mergeFiles(source: URL, destination: URL) throws {
        let sourceContent = try String(contentsOf: source)
        let destContent = try String(contentsOf: destination)
        
        let merged = destContent + "\n\n// MARK: - Merged from \(source.lastPathComponent)\n\n" + sourceContent
        
        try merged.write(to: destination, atomically: true, encoding: .utf8)
    }
}

// MARK: - Report

struct MergeReport {
    var projectsMerged = 0
    var copied = 0
    var merged = 0
    var skipped = 0
    
    var totalFiles: Int {
        copied + merged + skipped
    }
}
