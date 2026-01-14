import SwiftUI

// MARK: - Setup App

@main
struct ArchitectSetupApp: App {
    var body: some Scene {
        WindowGroup {
            SetupWizardView()
        }
        .windowResizability(.contentSize)
    }
}

// MARK: - Setup Wizard

struct SetupWizardView: View {
    @State private var currentStep = 0
    @State private var isInstalling = false
    @State private var installError: String?
    @State private var showOptimization = false
    
    var body: some View {
        if showOptimization {
            OptimizationProgressView(isPresented: $showOptimization)
        } else {
            mainWizard
        }
    }
    
    private var mainWizard: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("Welcome to ArchitectTasks")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Let's get you set up in 4 easy steps")
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
            
            HStack(spacing: 8) {
                ForEach(0..<4) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.bottom, 30)
            
            TabView(selection: $currentStep) {
                WelcomeStepView().tag(0)
                PermissionsStepView(isInstalling: $isInstalling, error: $installError).tag(1)
                OptimizationStepView(showOptimization: $showOptimization).tag(2)
                CompleteStepView().tag(3)
            }
            .tabViewStyle(.automatic)
            .frame(height: 300)
            
            HStack {
                if currentStep > 0 && currentStep < 3 {
                    Button("Back") {
                        withAnimation { currentStep -= 1 }
                    }
                    .disabled(isInstalling)
                }
                
                Spacer()
                
                if currentStep < 3 {
                    Button(buttonTitle) {
                        handleNext()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isInstalling)
                } else {
                    Button("Finish") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }
    
    private var buttonTitle: String {
        switch currentStep {
        case 1: return "Install Extension"
        case 2: return "Optimize Storage"
        default: return "Next"
        }
    }
    
    private func handleNext() {
        switch currentStep {
        case 1:
            installExtension()
        case 2:
            showOptimization = true
        default:
            withAnimation { currentStep += 1 }
        }
    }
    
    private func installExtension() {
        isInstalling = true
        installError = nil
        
        Task {
            do {
                try await ExtensionInstaller.install()
                await MainActor.run {
                    isInstalling = false
                    withAnimation { currentStep = 2 }
                }
            } catch {
                await MainActor.run {
                    isInstalling = false
                    installError = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Steps

private struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("What is ArchitectTasks?")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "magnifyingglass", title: "Analyzes Your Code", description: "Finds issues and improvement opportunities")
                FeatureRow(icon: "wand.and.stars", title: "Suggests Fixes", description: "Proposes automated refactorings")
                FeatureRow(icon: "checkmark.circle", title: "Applies Changes", description: "Transforms code with your approval")
            }
            .padding()
        }
    }
}

private struct PermissionsStepView: View {
    @Binding var isInstalling: Bool
    @Binding var error: String?
    
    var body: some View {
        VStack(spacing: 20) {
            if isInstalling {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Installing extension...")
                    .foregroundColor(.secondary)
            } else if let error = error {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                Text("Installation Failed")
                    .font(.headline)
                Text(error)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Image(systemName: "lock.shield")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Installation Permissions")
                    .font(.headline)
                
                Text("We'll need your permission to:")
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    PermissionRow(text: "Build the Xcode extension")
                    PermissionRow(text: "Copy to /Applications folder")
                    PermissionRow(text: "Enable in System Settings")
                }
                .padding()
            }
        }
    }
}

private struct CompleteStepView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("All Set!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("ArchitectTasks is now installed")
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Next Steps:")
                    .font(.headline)
                
                StepRow(number: 1, text: "Open Xcode")
                StepRow(number: 2, text: "Go to Editor > ArchitectTasks")
                StepRow(number: 3, text: "Start analyzing your code!")
            }
        }
    }
}

// MARK: - Components

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

private struct PermissionRow: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(text)
        }
    }
}

private struct StepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack {
            Text("\(number)")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.accentColor))
            Text(text)
        }
    }
}

// MARK: - Installer

actor ExtensionInstaller {
    static func install() async throws {
        try await build()
        try await copyToApplications()
        await openExtensionSettings()
    }
    
    private static func build() async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
        process.arguments = ["-scheme", "ArchitectXcodeExtension", "-configuration", "Release", "-derivedDataPath", ".build"]
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw InstallError.buildFailed
        }
    }
    
    private static func copyToApplications() async throws {
        guard let appPath = findBuiltApp() else {
            throw InstallError.appNotFound
        }
        
        let script = "do shell script \"cp -r '\(appPath)' '/Applications/'\" with administrator privileges"
        
        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else {
            throw InstallError.scriptFailed
        }
        
        appleScript.executeAndReturnError(&error)
        
        if error != nil {
            throw InstallError.copyFailed
        }
    }
    
    private static func findBuiltApp() -> String? {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(atPath: ".build") else { return nil }
        
        while let file = enumerator.nextObject() as? String {
            if file.hasSuffix("ArchitectTasks.app") {
                return ".build/\(file)"
            }
        }
        return nil
    }
    
    private static func openExtensionSettings() async {
        await MainActor.run {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.extensions?Xcode Source Editor")!)
        }
    }
    
    enum InstallError: LocalizedError {
        case buildFailed, appNotFound, scriptFailed, copyFailed
        
        var errorDescription: String? {
            switch self {
            case .buildFailed: return "Failed to build extension"
            case .appNotFound: return "Built app not found"
            case .scriptFailed: return "Failed to create install script"
            case .copyFailed: return "Failed to copy to Applications"
            }
        }
    }
}
