import Foundation
import ArchitectCore

@main
struct CleanCommand {
    static func main() async {
        let args = CommandLine.arguments
        
        guard args.count > 1 else {
            printUsage()
            return
        }
        
        let projectPath = args[1]
        let projectURL = URL(fileURLWithPath: projectPath)
        
        print("🧹 ArchitectTasks Storage Optimizer")
        print("===================================\n")
        
        // Clean build artifacts
        print("📦 Cleaning build artifacts...")
        let cleaner = StorageCleaner()
        if let report = try? await cleaner.clean(projectRoot: projectURL) {
            print("   ✅ Removed \(report.buildArtifacts) build artifacts")
            print("   ✅ Removed \(report.duplicates) duplicate files")
            print("   ✅ Merged \(report.merged) projects\n")
        }
        
        // Deduplicate files
        print("🔍 Deduplicating files...")
        let deduplicator = FileDeduplicator()
        if let report = try? await deduplicator.deduplicate(at: projectURL) {
            print("   ✅ Removed \(report.duplicatesRemoved) duplicates")
            print("   ✅ Saved \(String(format: "%.2f", report.spaceSavedMB)) MB\n")
        }
        
        // Merge projects
        let fm = FileManager.default
        let projects = (try? fm.contentsOfDirectory(at: projectURL, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "xcodeproj" }) ?? []
        
        if projects.count > 1 {
            print("🔗 Merging \(projects.count) projects...")
            let merger = ProjectMerger()
            if let report = try? await merger.merge(projects: projects, into: projects[0]) {
                print("   ✅ Merged \(report.projectsMerged) projects")
                print("   ✅ Copied \(report.copied) files")
                print("   ✅ Merged \(report.merged) conflicting files")
                print("   ✅ Skipped \(report.skipped) identical files\n")
            }
        }
        
        print("✨ Optimization complete!")
    }
    
    static func printUsage() {
        print("""
        Usage: architect-clean <project-path>
        
        Optimizes storage by:
        - Removing build artifacts
        - Deduplicating files
        - Merging multiple projects
        
        Example:
          architect-clean ~/Projects/MyApp
        """)
    }
}
