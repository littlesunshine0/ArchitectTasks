import Foundation

/// Central integration layer that unifies all systems
public class IntegrationManager {
    private let registry: UnifiedRegistry
    
    public init(registry: UnifiedRegistry = UnifiedRegistry()) {
        self.registry = registry
    }
    
    // MARK: - VerbProject Integration
    
    public func loadVerbProject(from path: String) throws -> VerbProject {
        guard let data = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw IntegrationError.invalidProject(path)
        }
        
        let verb = json["verb"] as? String ?? ""
        let namespace = json["namespace"] as? String ?? ""
        let artifactData = json["artifacts"] as? [[String: Any]] ?? []
        
        let artifacts = artifactData.compactMap { dict -> VerbArtifact? in
            guard let name = dict["name"] as? String,
                  let typeStr = dict["type"] as? String,
                  let type = UnifiedType(rawValue: typeStr),
                  let path = dict["path"] as? String else { return nil }
            return VerbArtifact(name: name, type: type, path: path)
        }
        
        return VerbProject(verb: verb, namespace: namespace, artifacts: artifacts)
    }
    
    // MARK: - Definition to AgentTask Bridge
    
    public func createAgentTask(from definition: any UnifiedDefinition, findings: [Finding] = []) -> AgentTask {
        let intent = mapDefinitionToIntent(definition)
        let scope = TaskScope.file(definition.name)
        
        return AgentTask(
            title: definition.statement,
            intent: intent,
            scope: scope,
            sourceFindings: findings.map(\.id)
        )
    }
    
    private func mapDefinitionToIntent(_ definition: any UnifiedDefinition) -> TaskIntent {
        switch definition.type.category {
        case .executable:
            return .runTool(definition.name)
        case .constraint:
            return .enforcePolicy(definition.name)
        case .process:
            return .executeWorkflow(definition.name)
        default:
            return .fixWarning(definition.statement)
        }
    }
    
    // MARK: - Execution Orchestration
    
    public func execute(verb: String, namespace: String, type: UnifiedType) async throws -> ExecutionResult {
        // Find the verb project
        guard let project = registry.findVerbProject(verb: verb, namespace: namespace) else {
            throw IntegrationError.projectNotFound(verb, namespace)
        }
        
        // Find the specific artifact
        guard let artifact = project.artifacts.first(where: { $0.type == type }) else {
            throw IntegrationError.artifactNotFound(type.rawValue)
        }
        
        // Load the definition
        let definition = try registry.loadDefinition(from: artifact.path, type: type)
        
        // Execute based on type category
        switch type.category {
        case .executable:
            return try await executeDefinition(definition)
        case .constraint:
            return try await evaluateDefinition(definition)
        case .process:
            return try await runWorkflow(definition)
        default:
            return ExecutionResult(success: true, output: "Loaded \(definition.name)")
        }
    }
    
    private func executeDefinition(_ definition: any UnifiedDefinition) async throws -> ExecutionResult {
        // Convert to AgentTask and run through existing TaskRunner
        let task = createAgentTask(from: definition)
        // Integration with existing TaskRunner would go here
        return ExecutionResult(success: true, output: "Executed \(definition.name)")
    }
    
    private func evaluateDefinition(_ definition: any UnifiedDefinition) async throws -> ExecutionResult {
        // Rule/Policy evaluation logic
        return ExecutionResult(success: true, output: "Evaluated \(definition.name)")
    }
    
    private func runWorkflow(_ definition: any UnifiedDefinition) async throws -> ExecutionResult {
        // Workflow execution logic
        return ExecutionResult(success: true, output: "Ran workflow \(definition.name)")
    }
}

public enum IntegrationError: Error {
    case invalidProject(String)
    case projectNotFound(String, String)
    case artifactNotFound(String)
    case executionFailed(String)
}