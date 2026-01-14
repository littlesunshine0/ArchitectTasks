import Foundation
import CryptoKit

// MARK: - File Deduplicator

struct FileDeduplicator {
    func deduplicate(at root: URL) async throws -> DeduplicationReport {
        var report = DeduplicationReport()
        let fm = FileManager.default
        
        var filesByHash: [String: [URL]] = [:]
        
        guard let enumerator = fm.enumerator(at: root, includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey]) else {
            return report
        }
        
        for case let fileURL as URL in enumerator {
            guard try fileURL.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true else { continue }
            guard fileURL.pathExtension == "swift" else { continue }
            
            let hash = try await hashFile(at: fileURL)
            filesByHash[hash, default: []].append(fileURL)
        }
        
        for (_, urls) in filesByHash where urls.count > 1 {
            let canonical = urls[0]
            
            for duplicate in urls.dropFirst() {
                try fm.removeItem(at: duplicate)
                try fm.createSymbolicLink(at: duplicate, withDestinationURL: canonical)
                report.duplicatesRemoved += 1
                report.spaceSaved += try fileSize(at: duplicate)
            }
        }
        
        return report
    }
    
    private func hashFile(at url: URL) async throws -> String {
        let data = try Data(contentsOf: url)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func fileSize(at url: URL) throws -> Int {
        let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
        return attrs[.size] as? Int ?? 0
    }
}

// MARK: - Report

struct DeduplicationReport {
    var duplicatesRemoved = 0
    var spaceSaved = 0
    
    var spaceSavedMB: Double {
        Double(spaceSaved) / 1_048_576
    }
}
