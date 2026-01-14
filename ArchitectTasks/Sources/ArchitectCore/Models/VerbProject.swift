import Foundation

/// Verb-rooted project identity
public struct VerbProject: Codable, Identifiable {
    public let id: UUID
    public let verb: String
    public let namespace: String
    public let artifacts: [VerbArtifact]
    public let createdAt: Date
    
    public var projectName: String { "\(verb).\(namespace)" }
    
    public init(verb: String, namespace: String, artifacts: [VerbArtifact] = []) {
        self.id = UUID()
        self.verb = verb
        self.namespace = namespace
        self.artifacts = artifacts
        self.createdAt = Date()
    }
}

/// Individual artifact within a verb project
public struct VerbArtifact: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let type: UnifiedType
    public let path: String
    
    public init(name: String, type: UnifiedType, path: String) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.path = path
    }
}



/// Verb-rooted registry
public class VerbRegistry {
    private var projects: [String: VerbProject] = [:]
    
    public func register(_ project: VerbProject) {
        projects[project.projectName] = project
    }
    
    public func resolve(verb: String, namespace: String) -> VerbProject? {
        projects["\(verb).\(namespace)"]
    }
    
    public func findByVerb(_ verb: String) -> [VerbProject] {
        projects.values.filter { $0.verb == verb }
    }
    
    public func findArtifact(verb: String, namespace: String, type: UnifiedType) -> VerbArtifact? {
        guard let project = resolve(verb: verb, namespace: namespace) else { return nil }
        return project.artifacts.first { $0.type == type }
    }
}