import Foundation



/// Tool-specific definition
public struct ToolDefinition: UnifiedDefinition {
    public let id: UUID
    public let type: UnifiedType = .tool
    public let name: String
    public let version: String
    public let statement: String
    public let explanation: String
    public let metadata: [String: String]
    public let createdAt: Date
    
    // Tool-specific fields
    public let capabilities: [String]
    public let contexts: [String]
    public let dependencies: [String]
}

/// Rule-specific definition
public struct RuleDefinition: UnifiedDefinition {
    public let id: UUID
    public let type: UnifiedType = .rule
    public let name: String
    public let version: String
    public let statement: String
    public let explanation: String
    public let metadata: [String: String]
    public let createdAt: Date
    
    // Rule-specific fields
    public let conditions: [String]
    public let severity: String
    public let remediation: String
}

/// Policy-specific definition
public struct PolicyDefinition: UnifiedDefinition {
    public let id: UUID
    public let type: UnifiedType = .policy
    public let name: String
    public let version: String
    public let statement: String
    public let explanation: String
    public let metadata: [String: String]
    public let createdAt: Date
    
    // Policy-specific fields
    public let constraints: [String]
    public let enforcementLevel: String
}





/// Type-specific execution engines
public protocol ToolExecutor {
    func execute(_ tool: ToolDefinition, context: ExecutionContext) throws -> ExecutionResult
}

public protocol RuleEvaluator {
    func evaluate(_ rule: RuleDefinition, context: ExecutionContext) throws -> EvaluationResult
}

public protocol PolicyEnforcer {
    func enforce(_ policy: PolicyDefinition, context: ExecutionContext) throws -> EnforcementResult
}

public struct ExecutionContext: Codable {
    public let parameters: [String: String]
    public let environment: [String: String]
    
    public init(parameters: [String: String] = [:], environment: [String: String] = [:]) {
        self.parameters = parameters
        self.environment = environment
    }
}

public struct ExecutionResult: Codable {
    public let success: Bool
    public let output: String
    public let metadata: [String: String]
    
    public init(success: Bool, output: String, metadata: [String: String] = [:]) {
        self.success = success
        self.output = output
        self.metadata = metadata
    }
}