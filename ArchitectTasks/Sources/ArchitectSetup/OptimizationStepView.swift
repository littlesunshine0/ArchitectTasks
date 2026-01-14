import SwiftUI

// MARK: - Optimization Step

struct OptimizationStepView: View {
    @Binding var showOptimization: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.3.trianglepath")
                .font(.system(size: 50))
                .foregroundColor(.purple)
            
            Text("Optimize Storage")
                .font(.headline)
            
            Text("Clean up build artifacts, remove duplicates, and merge projects to save space.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 12) {
                OptimizationFeature(icon: "trash", title: "Clean Build Artifacts", description: "Remove .build, DerivedData")
                OptimizationFeature(icon: "doc.on.doc", title: "Deduplicate Files", description: "Replace copies with symlinks")
                OptimizationFeature(icon: "arrow.triangle.merge", title: "Merge Projects", description: "Consolidate multiple .xcodeproj")
            }
        }
        .padding()
    }
}

private struct OptimizationFeature: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
