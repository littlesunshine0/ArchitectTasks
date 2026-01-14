import Foundation

/// Unified registry for all definitions, verb projects, and artifacts
public class UnifiedRegistry {
    private var definitions: [String: any UnifiedDefinition] = [:]
    private var verbProjects: [String: VerbProject] = [:]
    private let searchPaths: [String]
    
    public init(searchPaths: [String] = []) {
        self.searchPaths = searchPaths.isEmpty ? defaultSearchPaths() : searchPaths
        loadAll()
    }
    
    private func defaultSearchPaths() -> [String] {
        [
            "/usr/local/share/definitions",  // System level
            NSHomeDirectory() + "/.definitions",  // User level
            FileManager.default.currentDirectoryPath + "/.definitions"  // Project level
        ]
    }
    
    // MARK: - Registration
    
    public func register(_ definition: any UnifiedDefinition) {
        definitions[definition.name] = definition
    }
    
    public func register(_ project: VerbProject) {
        verbProjects[project.projectName] = project
    }
    
    // MARK: - Lookup
    
    public func findDefinition(name: String) -> (any UnifiedDefinition)? {
        definitions[name]
    }
    
    public func findDefinitions(type: UnifiedType) -> [any UnifiedDefinition] {
        definitions.values.filter { $0.type == type }
    }
    
    public func findVerbProject(verb: String, namespace: String) -> VerbProject? {
        verbProjects["\(verb).\(namespace)"]
    }
    
    public func findVerbProjects(verb: String) -> [VerbProject] {
        verbProjects.values.filter { $0.verb == verb }
    }
    
    // MARK: - Loading
    
    public func loadDefinition(from path: String, type: UnifiedType) throws -> any UnifiedDefinition {
        guard let data = FileManager.default.contents(atPath: path) else {
            throw RegistryError.fileNotFound(path)
        }
        
        switch type {
        case .tool:
            return try JSONDecoder().decode(ToolDefinition.self, from: data)
        case .rule:
            return try JSONDecoder().decode(RuleDefinition.self, from: data)
        case .policy:
            return try JSONDecoder().decode(PolicyDefinition.self, from: data)
        default:
            throw RegistryError.unsupportedType(type.rawValue)
        }
    }
    
    private func loadAll() {
        for searchPath in searchPaths {
            loadFromPath(searchPath)
        }
    }
    
    private func loadFromPath(_ path: String) {
        guard let enumerator = FileManager.default.enumerator(atPath: path) else { return }
        
        for case let file as String in enumerator {
            let fullPath = "\(path)/\(file)"
            
            // Load verb projects
            if file.contains(".") && !file.hasPrefix(".") {
                if let project = try? loadVerbProjectFile(fullPath) {
                    register(project)
                }
            }
            
            // Load individual definitions
            for type in UnifiedType.allCases {
                if file.hasSuffix(".\(type.fileExtension)") {
                    if let definition = try? loadDefinition(from: fullPath, type: type) {
                        register(definition)
                    }
                }
            }
        }
    }
    
    private func loadVerbProjectFile(_ path: String) throws -> VerbProject {
        guard let data = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw RegistryError.invalidFormat(path)
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
}

public enum RegistryError: Error {
    case fileNotFound(String)
    case invalidFormat(String)
    case unsupportedType(String)
}