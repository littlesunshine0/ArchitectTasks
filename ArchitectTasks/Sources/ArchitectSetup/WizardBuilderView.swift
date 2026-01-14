import SwiftUI

// MARK: - Wizard Builder GUI

struct WizardBuilderView: View {
    @State private var wizardTitle = "Setup Wizard"
    @State private var wizardSubtitle = "Complete the following steps"
    @State private var steps: [EditableStep] = []
    @State private var showPreview = false
    
    var body: some View {
        HSplitView {
            // Editor
            VStack(alignment: .leading, spacing: 20) {
                Text("Wizard Builder")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Wizard Info
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Wizard Title", text: $wizardTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Subtitle", text: $wizardSubtitle)
                        .textFieldStyle(.roundedBorder)
                }
                
                Divider()
                
                // Steps
                Text("Steps")
                    .font(.headline)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(steps.indices, id: \.self) { index in
                            StepEditorRow(step: $steps[index], onDelete: {
                                steps.remove(at: index)
                            })
                        }
                    }
                }
                
                // Add Step
                Menu("Add Step") {
                    Button("Info Step") {
                        steps.append(EditableStep(type: .info))
                    }
                    Button("Action Step") {
                        steps.append(EditableStep(type: .action))
                    }
                    Button("Progress Step") {
                        steps.append(EditableStep(type: .progress))
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                // Actions
                HStack {
                    Button("Preview") {
                        showPreview = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Export") {
                        exportWizard()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(minWidth: 400)
            
            // Preview
            if showPreview {
                WizardPreview(config: buildConfiguration())
            }
        }
        .frame(minWidth: 900, minHeight: 600)
    }
    
    private func buildConfiguration() -> WizardConfiguration {
        WizardConfiguration(
            title: wizardTitle,
            subtitle: wizardSubtitle,
            completionMessage: "Complete!"
        ) {
            for step in steps {
                step.toWizardStep()
            }
        }
    }
    
    private func exportWizard() {
        let code = generateSwiftCode()
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.swiftSource]
        panel.nameFieldStringValue = "GeneratedWizard.swift"
        
        if panel.runModal() == .OK, let url = panel.url {
            try? code.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    private func generateSwiftCode() -> String {
        """
        import SwiftUI
        
        struct GeneratedWizard: View {
            var body: some View {
                WizardView(config: WizardConfiguration(
                    title: "\(wizardTitle)",
                    subtitle: "\(wizardSubtitle)",
                    completionMessage: "Complete!"
                ) {
        \(steps.map { $0.generateCode() }.joined(separator: "\n"))
                })
            }
        }
        """
    }
}

// MARK: - Step Editor Row

private struct StepEditorRow: View {
    @Binding var step: EditableStep
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: step.icon)
                    .foregroundColor(.accentColor)
                
                TextField("Title", text: $step.title)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
            }
            
            HStack {
                TextField("Icon", text: $step.icon)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
                
                Toggle("Can Skip", isOn: $step.canSkip)
            }
            
            TextField("Description", text: $step.description, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Wizard Preview

private struct WizardPreview: View {
    let config: WizardConfiguration
    
    var body: some View {
        VStack {
            Text("Preview")
                .font(.headline)
                .padding()
            
            WizardView(config: config)
        }
    }
}

// MARK: - Editable Step

struct EditableStep: Identifiable {
    let id = UUID()
    var type: StepType
    var title = "Step Title"
    var icon = "star.fill"
    var description = "Step description"
    var canSkip = false
    
    enum StepType {
        case info, action, progress
    }
    
    func toWizardStep() -> any WizardStep {
        let content = AnyView(
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.headline)
                Text(description)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        )
        
        switch type {
        case .info:
            return InfoStep(id: id.uuidString, title: title, icon: icon, content: content)
        case .action:
            return ActionStep(id: id.uuidString, title: title, icon: icon, canSkip: canSkip, action: nil, content: content)
        case .progress:
            return ProgressStep(id: id.uuidString, title: title, icon: icon, action: nil, progressView: content)
        }
    }
    
    func generateCode() -> String {
        let typeStr = type == .info ? "InfoStep" : type == .action ? "ActionStep" : "ProgressStep"
        return """
                    \(typeStr)(
                        id: "\(id.uuidString)",
                        title: "\(title)",
                        icon: "\(icon)",
                        \(canSkip ? "canSkip: true," : "")
                        content: AnyView(Text("\(description)"))
                    )
        """
    }
}
