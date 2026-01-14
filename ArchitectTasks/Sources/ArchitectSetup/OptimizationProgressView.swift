import SwiftUI

// MARK: - Optimization Progress View

struct OptimizationProgressView: View {
    @Binding var isPresented: Bool
    @State private var currentPhase: OptimizationPhase = .idle
    @State private var report = OptimizationReport()
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "arrow.3.trianglepath")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
                .rotationEffect(.degrees(currentPhase == .idle ? 0 : 360))
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: currentPhase)
            
            Text("Optimizing Storage")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                PhaseRow(phase: .cleaning, current: currentPhase, count: report.buildArtifacts)
                PhaseRow(phase: .deduplicating, current: currentPhase, count: report.duplicates)
                PhaseRow(phase: .merging, current: currentPhase, count: report.projectsMerged)
            }
            .padding()
            
            if currentPhase == .complete {
                VStack(spacing: 8) {
                    Text("✨ Optimization Complete!")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("Saved \(String(format: "%.2f", report.spaceSavedMB)) MB")
                        .foregroundColor(.secondary)
                }
                
                Button("Continue") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(width: 500, height: 400)
        .onAppear {
            runOptimization()
        }
    }
    
    private func runOptimization() {
        Task {
            currentPhase = .cleaning
            let cleaner = StorageCleaner()
            if let cleanReport = try? await cleaner.clean(projectRoot: URL(fileURLWithPath: ".")) {
                await MainActor.run {
                    report.buildArtifacts = cleanReport.buildArtifacts
                }
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            currentPhase = .deduplicating
            let deduplicator = FileDeduplicator()
            if let dedupReport = try? await deduplicator.deduplicate(at: URL(fileURLWithPath: ".")) {
                await MainActor.run {
                    report.duplicates = dedupReport.duplicatesRemoved
                    report.spaceSavedMB = dedupReport.spaceSavedMB
                }
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            currentPhase = .merging
            let merger = ProjectMerger()
            let fm = FileManager.default
            let projects = (try? fm.contentsOfDirectory(at: URL(fileURLWithPath: "."), includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "xcodeproj" }) ?? []
            
            if projects.count > 1 {
                if let mergeReport = try? await merger.merge(projects: projects, into: projects[0]) {
                    await MainActor.run {
                        report.projectsMerged = mergeReport.projectsMerged
                    }
                }
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            await MainActor.run {
                currentPhase = .complete
            }
        }
    }
}

// MARK: - Phase Row

private struct PhaseRow: View {
    let phase: OptimizationPhase
    let current: OptimizationPhase
    let count: Int
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(phase.title)
                .fontWeight(.medium)
            
            Spacer()
            
            if current.rawValue > phase.rawValue {
                Text("\(count)")
                    .foregroundColor(.secondary)
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if current == phase {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray.opacity(0.3))
            }
        }
    }
    
    private var icon: String {
        switch phase {
        case .cleaning: return "trash"
        case .deduplicating: return "doc.on.doc"
        case .merging: return "arrow.triangle.merge"
        default: return "circle"
        }
    }
    
    private var color: Color {
        if current.rawValue >= phase.rawValue {
            return .accentColor
        }
        return .gray.opacity(0.3)
    }
}

// MARK: - Models

enum OptimizationPhase: Int {
    case idle = 0
    case cleaning = 1
    case deduplicating = 2
    case merging = 3
    case complete = 4
    
    var title: String {
        switch self {
        case .idle: return "Starting..."
        case .cleaning: return "Cleaning build artifacts"
        case .deduplicating: return "Removing duplicates"
        case .merging: return "Merging projects"
        case .complete: return "Complete"
        }
    }
}

struct OptimizationReport {
    var buildArtifacts = 0
    var duplicates = 0
    var projectsMerged = 0
    var spaceSavedMB = 0.0
}
