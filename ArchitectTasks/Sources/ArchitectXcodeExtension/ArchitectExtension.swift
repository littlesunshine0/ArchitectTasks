import Foundation
import XcodeKit

// MARK: - Xcode Extension

class ArchitectExtension: NSObject, XCSourceEditorExtension {
    func extensionDidFinishLaunching() {
        // Extension loaded
    }
}

// MARK: - Command Provider

class ArchitectCommandProvider: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let command = invocation.commandIdentifier.split(separator: ".").last ?? ""
        
        switch command {
        case "analyzeFile":
            analyzeCurrentFile(invocation: invocation, completionHandler: completionHandler)
        case "fixAll":
            fixAllIssues(invocation: invocation, completionHandler: completionHandler)
        case "applyTask":
            applySelectedTask(invocation: invocation, completionHandler: completionHandler)
        case "showPanel":
            showTaskPanel(invocation: invocation, completionHandler: completionHandler)
        default:
            completionHandler(NSError(domain: "ArchitectTasks", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown command"]))
        }
    }
    
    private func analyzeCurrentFile(invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let source = invocation.buffer.completeBuffer
        let path = invocation.buffer.contentUTI
        
        Task {
            do {
                let findings = try await analyzeSource(source, path: path)
                await MainActor.run {
                    showFindings(findings, in: invocation)
                    completionHandler(nil)
                }
            } catch {
                completionHandler(error)
            }
        }
    }
    
    private func fixAllIssues(invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let source = invocation.buffer.completeBuffer
        
        Task {
            do {
                let transformed = try await applyAllFixes(source)
                await MainActor.run {
                    invocation.buffer.completeBuffer = transformed
                    completionHandler(nil)
                }
            } catch {
                completionHandler(error)
            }
        }
    }
    
    private func applySelectedTask(invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        completionHandler(nil)
    }
    
    private func showTaskPanel(invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        completionHandler(nil)
    }
    
    private func analyzeSource(_ source: String, path: String) async throws -> [Finding] {
        let analyzers: [any Analyzer] = [
            SwiftUIBindingAnalyzer(),
            ComplexityAnalyzer(),
            SecurityAnalyzer(),
            NamingAnalyzer(),
            DeadCodeAnalyzer()
        ]
        
        var findings: [Finding] = []
        for analyzer in analyzers {
            findings.append(contentsOf: try analyzer.analyze(fileAt: path, content: source))
        }
        return findings
    }
    
    private func applyAllFixes(_ source: String) async throws -> String {
        let findings = try await analyzeSource(source, path: "")
        let pipeline = TransformPipeline.standard()
        
        let host = LocalHost(
            projectRoot: URL(fileURLWithPath: "/tmp"),
            config: .default,
            approvalHandler: { task in
                TaskApprovalResult(task: task, decision: .approved)
            }
        )
        
        let tasks = host.proposeTasks(from: findings)
        let intents = tasks.map { $0.intent }
        
        let result = try pipeline.execute(
            intents: intents,
            source: source,
            context: TransformContext(filePath: "")
        )
        
        return result.transformedSource
    }
    
    private func showFindings(_ findings: [Finding], in invocation: XCSourceEditorCommandInvocation) {
        for finding in findings {
            let line = finding.location.line - 1
            if line < invocation.buffer.lines.count {
                let lineText = invocation.buffer.lines[line] as! String
                let annotation = "// ⚠️ \(finding.message)"
                invocation.buffer.lines[line] = lineText.trimmingCharacters(in: .newlines) + " " + annotation + "\n"
            }
        }
    }
}
