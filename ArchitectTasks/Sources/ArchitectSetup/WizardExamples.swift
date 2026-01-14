import SwiftUI

// MARK: - Example: Complete Setup Wizard

func createSetupWizard() -> WizardConfiguration {
    WizardConfiguration(
        title: "ArchitectTasks Setup",
        subtitle: "Complete setup in 5 easy steps",
        completionMessage: "Setup complete!"
    ) {
        StepLibrary.welcome(
            title: "What is ArchitectTasks?",
            features: [
                ("magnifyingglass", "Analyzes Your Code", "Finds issues and improvements"),
                ("wand.and.stars", "Suggests Fixes", "Proposes automated refactorings"),
                ("checkmark.circle", "Applies Changes", "Transforms code with approval")
            ]
        )
        
        StepLibrary.permissions(items: [
            "Build the Xcode extension",
            "Copy to /Applications folder",
            "Enable in System Settings"
        ])
        
        StepLibrary.installation {
            try? await ExtensionInstaller.install()
        }
        
        StepLibrary.optimization {
            let cleaner = StorageCleaner()
            _ = try? await cleaner.clean(projectRoot: URL(fileURLWithPath: "."))
        }
        
        StepLibrary.completion(
            message: "ArchitectTasks is now installed",
            nextSteps: [
                "Open Xcode",
                "Go to Editor > ArchitectTasks",
                "Start analyzing your code!"
            ]
        )
    }
}

// MARK: - Example: Quick Optimization Wizard

func createOptimizationWizard() -> WizardConfiguration {
    WizardConfiguration(
        title: "Storage Optimizer",
        subtitle: "Clean and optimize your project",
        completionMessage: "Optimization complete!"
    ) {
        InfoStep(
            id: "intro",
            title: "Optimize Storage",
            icon: "arrow.3.trianglepath",
            content: AnyView(
                VStack(spacing: 16) {
                    Text("This will:")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Remove build artifacts")
                        Text("• Deduplicate files")
                        Text("• Merge projects")
                    }
                }
            )
        )
        
        ProgressStep(
            id: "optimize",
            title: "Optimizing",
            icon: "arrow.3.trianglepath",
            action: {
                let cleaner = StorageCleaner()
                _ = try? await cleaner.clean(projectRoot: URL(fileURLWithPath: "."))
            },
            progressView: AnyView(OptimizationProgressView(isPresented: .constant(true)))
        )
        
        StepLibrary.completion(
            message: "Your project has been optimized",
            nextSteps: ["Continue working on your project"]
        )
    }
}

// MARK: - Example: Configuration Wizard

func createConfigurationWizard() -> WizardConfiguration {
    WizardConfiguration(
        title: "Configure ArchitectTasks",
        subtitle: "Customize your experience",
        completionMessage: "Configuration saved!"
    ) {
        StepLibrary.configuration(options: [
            ("Conservative", "Manual approval for all changes"),
            ("Moderate", "Auto-approve safe changes"),
            ("Permissive", "Auto-approve most changes"),
            ("Strict", "Require approval for everything")
        ])
        
        ActionStep(
            id: "analysis",
            title: "Analysis Settings",
            icon: "magnifyingglass",
            canSkip: true,
            action: nil,
            content: AnyView(
                VStack(spacing: 12) {
                    Text("Complexity Thresholds")
                        .font(.headline)
                    Text("Configure when to flag code as complex")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            )
        )
        
        StepLibrary.completion(
            message: "Settings configured",
            nextSteps: ["Start using ArchitectTasks"]
        )
    }
}
