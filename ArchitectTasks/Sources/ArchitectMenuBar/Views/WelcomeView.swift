import SwiftUI

// MARK: - Welcome View

struct WelcomeView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Welcome to ArchitectTasks")
                .font(.title)
                .fontWeight(.bold)
            
            TabView(selection: $currentStep) {
                Step1View().tag(0)
                Step2View().tag(1)
                Step3View().tag(2)
            }
            .tabViewStyle(.automatic)
            .frame(height: 250)
            
            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation { currentStep -= 1 }
                    }
                }
                
                Spacer()
                
                if currentStep < 2 {
                    Button("Next") {
                        withAnimation { currentStep += 1 }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 500, height: 450)
    }
}

// MARK: - Steps

private struct Step1View: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("Auto-Launch Configured")
                .font(.headline)
            
            Text("ArchitectTasks will now start automatically when you log in.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Monitors Xcode activity", systemImage: "eye.fill")
                Label("Analyzes code in real-time", systemImage: "magnifyingglass")
                Label("Suggests improvements", systemImage: "lightbulb.fill")
            }
            .font(.subheadline)
        }
        .padding()
    }
}

private struct Step2View: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.gearshape")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Project Detection")
                .font(.headline)
            
            Text("When you open a project in Xcode, ArchitectTasks will automatically detect it.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("1")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.accentColor))
                    Text("Open Xcode")
                }
                
                HStack {
                    Text("2")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.accentColor))
                    Text("Click menu bar icon")
                }
                
                HStack {
                    Text("3")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.accentColor))
                    Text("Select or auto-detect project")
                }
            }
        }
        .padding()
    }
}

private struct Step3View: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 50))
                .foregroundColor(.purple)
            
            Text("Choose Your Policy")
                .font(.headline)
            
            Text("Control how ArchitectTasks handles code improvements.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 10) {
                PolicyBadge(name: "Conservative", color: .blue, description: "Manual approval for all")
                PolicyBadge(name: "Moderate", color: .green, description: "Auto-approve safe changes")
                PolicyBadge(name: "Permissive", color: .orange, description: "Auto-approve most")
                PolicyBadge(name: "Strict", color: .red, description: "Require approval for everything")
            }
            .font(.caption)
        }
        .padding()
    }
}

private struct PolicyBadge: View {
    let name: String
    let color: Color
    let description: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(name)
                .fontWeight(.semibold)
            Text("—")
                .foregroundColor(.secondary)
            Text(description)
                .foregroundColor(.secondary)
        }
    }
}
