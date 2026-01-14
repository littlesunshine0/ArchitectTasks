import SwiftUI

// MARK: - Wizard Step Protocol

protocol WizardStep {
    var id: String { get }
    var title: String { get }
    var icon: String { get }
    var view: AnyView { get }
    var canSkip: Bool { get }
    var action: (() async -> Void)? { get }
}

// MARK: - Wizard Configuration

struct WizardConfiguration {
    var steps: [any WizardStep]
    var title: String
    var subtitle: String
    var completionMessage: String
}

// MARK: - Generic Wizard View

struct WizardView: View {
    let config: WizardConfiguration
    @State private var currentIndex = 0
    @State private var isProcessing = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: currentStep.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text(config.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(config.subtitle)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
            
            // Progress
            HStack(spacing: 8) {
                ForEach(0..<config.steps.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentIndex ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.bottom, 30)
            
            // Content
            currentStep.view
                .frame(height: 300)
            
            // Navigation
            HStack {
                if currentIndex > 0 {
                    Button("Back") {
                        withAnimation { currentIndex -= 1 }
                    }
                    .disabled(isProcessing)
                }
                
                if currentStep.canSkip {
                    Button("Skip") {
                        withAnimation { currentIndex += 1 }
                    }
                    .disabled(isProcessing)
                }
                
                Spacer()
                
                if currentIndex < config.steps.count - 1 {
                    Button("Next") {
                        executeStepAction()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                } else {
                    Button("Finish") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }
    
    private var currentStep: any WizardStep {
        config.steps[currentIndex]
    }
    
    private func executeStepAction() {
        guard let action = currentStep.action else {
            withAnimation { currentIndex += 1 }
            return
        }
        
        isProcessing = true
        Task {
            await action()
            await MainActor.run {
                isProcessing = false
                withAnimation { currentIndex += 1 }
            }
        }
    }
}

// MARK: - Concrete Step Types

struct InfoStep: WizardStep {
    let id: String
    let title: String
    let icon: String
    let canSkip: Bool = false
    let action: (() async -> Void)? = nil
    let content: AnyView
    
    var view: AnyView {
        content
    }
}

struct ActionStep: WizardStep {
    let id: String
    let title: String
    let icon: String
    let canSkip: Bool
    let action: (() async -> Void)?
    let content: AnyView
    
    var view: AnyView {
        content
    }
}

struct ProgressStep: WizardStep {
    let id: String
    let title: String
    let icon: String
    let canSkip: Bool = false
    let action: (() async -> Void)?
    let progressView: AnyView
    
    var view: AnyView {
        progressView
    }
}

// MARK: - Wizard Builder

@resultBuilder
struct WizardBuilder {
    static func buildBlock(_ steps: any WizardStep...) -> [any WizardStep] {
        steps
    }
}

extension WizardConfiguration {
    init(title: String, subtitle: String, completionMessage: String, @WizardBuilder steps: () -> [any WizardStep]) {
        self.title = title
        self.subtitle = subtitle
        self.completionMessage = completionMessage
        self.steps = steps()
    }
}
