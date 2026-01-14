import SwiftUI

// MARK: - Step Library

struct StepLibrary {
    // Welcome Steps
    static func welcome(title: String, features: [(icon: String, title: String, description: String)]) -> InfoStep {
        InfoStep(
            id: "welcome",
            title: "Welcome",
            icon: "hand.wave.fill",
            content: AnyView(
                VStack(spacing: 20) {
                    Text(title)
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(features.indices, id: \.self) { index in
                            FeatureRow(
                                icon: features[index].icon,
                                title: features[index].title,
                                description: features[index].description
                            )
                        }
                    }
                    .padding()
                }
            )
        )
    }
    
    // Permission Steps
    static func permissions(items: [String]) -> ActionStep {
        ActionStep(
            id: "permissions",
            title: "Permissions",
            icon: "lock.shield",
            canSkip: false,
            action: nil,
            content: AnyView(
                VStack(spacing: 20) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Permissions Required")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(items, id: \.self) { item in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(item)
                            }
                        }
                    }
                    .padding()
                }
            )
        )
    }
    
    // Installation Step
    static func installation(action: @escaping () async -> Void) -> ActionStep {
        ActionStep(
            id: "installation",
            title: "Installation",
            icon: "arrow.down.circle",
            canSkip: false,
            action: action,
            content: AnyView(
                VStack(spacing: 20) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Ready to Install")
                        .font(.headline)
                    
                    Text("Click Next to begin installation")
                        .foregroundColor(.secondary)
                }
            )
        )
    }
    
    // Optimization Step
    static func optimization(action: @escaping () async -> Void) -> ActionStep {
        ActionStep(
            id: "optimization",
            title: "Optimization",
            icon: "arrow.3.trianglepath",
            canSkip: true,
            action: action,
            content: AnyView(
                VStack(spacing: 20) {
                    Image(systemName: "arrow.3.trianglepath")
                        .font(.system(size: 50))
                        .foregroundColor(.purple)
                    
                    Text("Optimize Storage")
                        .font(.headline)
                    
                    Text("Clean up build artifacts and duplicates")
                        .foregroundColor(.secondary)
                }
            )
        )
    }
    
    // Completion Step
    static func completion(message: String, nextSteps: [String]) -> InfoStep {
        InfoStep(
            id: "completion",
            title: "Complete",
            icon: "checkmark.circle.fill",
            content: AnyView(
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("All Set!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(message)
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Next Steps:")
                            .font(.headline)
                        
                        ForEach(nextSteps.indices, id: \.self) { index in
                            HStack {
                                Text("\(index + 1)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Circle().fill(Color.accentColor))
                                Text(nextSteps[index])
                            }
                        }
                    }
                }
            )
        )
    }
    
    // Configuration Step
    static func configuration(options: [(title: String, description: String)]) -> ActionStep {
        ActionStep(
            id: "configuration",
            title: "Configuration",
            icon: "slider.horizontal.3",
            canSkip: true,
            action: nil,
            content: AnyView(
                VStack(spacing: 20) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Configure Settings")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(options.indices, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(options[index].title)
                                    .fontWeight(.semibold)
                                Text(options[index].description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
            )
        )
    }
}

// MARK: - Feature Row Component

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
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
