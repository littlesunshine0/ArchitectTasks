import Foundation

/// Unified type system for all definitions and artifacts
public enum UnifiedType: String, Codable, CaseIterable {
    case tool
    case agent
    case rule
    case policy
    case workflow
    case context
    case language
    case task
    case template
    case script
    case menubar
    case icon
    
    public var fileExtension: String { rawValue }
    public var category: TypeCategory {
        switch self {
        case .tool, .agent: return .executable
        case .rule, .policy: return .constraint
        case .workflow, .task: return .process
        case .context, .language: return .environment
        case .template, .script: return .artifact
        case .menubar, .icon: return .interface
        }
    }
}

public enum TypeCategory: String, Codable {
    case executable    // Can be executed
    case constraint    // Evaluates conditions
    case process      // Defines workflows
    case environment  // Provides context
    case artifact     // Static resources
    case interface    // UI components
}

/// Base protocol for all unified definitions
public protocol UnifiedDefinition: Codable, Identifiable, Sendable {
    var id: UUID { get }
    var type: UnifiedType { get }
    var name: String { get }
    var version: String { get }
    var statement: String { get }
    var explanation: String { get }
    var metadata: [String: String] { get }
    var createdAt: Date { get }
}