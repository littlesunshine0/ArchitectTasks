import Foundation

/// Universal registry with typed entries, not typed folders
public class UniversalDefinitionRegistry {
    private var entries: [String: RegistryEntry] = [:]
    private let searchPaths: [String]
    
    public init(searchPaths: [String] = []) {
        self.searchPaths = searchPaths.isEmpty ? defaultSearchPaths() : searchPaths
        loadAllDefinitions()
    }
    
    private func defaultSearchPaths() -> [String] {
        [
            "/usr/local/share/definitions",  // System level
            NSHomeDirectory() + "/.definitions",  // User level
            FileManager.default.currentDirectoryPath + "/.definitions"  // Project level
        ]
    }
    
    public func register<T: DefinitionBase>(_ definition: T) throws {
        let entry = RegistryEntry(
            type: definition.type,
            name: definition.name,
            version: definition.version,
            path: "", // Will be set when saved
            metadata: definition.metadata
        )
        entries[definition.name] = entry
    }
    
    public func resolve<T: DefinitionBase>(name: String, type: DefinitionType, as definitionType: T.Type) throws -> T {
        guard let entry = entries[name], entry.type == type else {
            throw RegistryError.definitionNotFound(name: name, type: type)
        }
        
        guard let data = FileManager.default.contents(atPath: entry.path),
              let definition = try? JSONDecoder().decode(definitionType, from: data) else {
            throw RegistryError.invalidDefinition("Could not load \(name)")
        }
        
        return definition
    }
    
    public func list(type: DefinitionType) -> [RegistryEntry] {
        entries.values.filter { $0.type == type }
    }
    
    private func loadAllDefinitions() {
        for searchPath in searchPaths {
            loadDefinitionsFromPath(searchPath)
        }
    }
    
    private func loadDefinitionsFromPath(_ path: String) {
        guard let enumerator = FileManager.default.enumerator(atPath: path) else { return }
        
        for case let file as String in enumerator {
            for type in DefinitionType.allCases {
                if file.hasSuffix(".\(type.fileExtension)") {
                    let fullPath = "\(path)/\(file)"
                    if let entry = loadEntry(from: fullPath, type: type) {
                        entries[entry.name] = entry
                    }
                }
            }
        }
    }
    
    private func loadEntry(from path: String, type: DefinitionType) -> RegistryEntry? {
        guard let data = FileManager.default.contents(atPath: path) else { return nil }
        
        // Extract basic info without full deserialization
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let name = json["name"] as? String,
              let version = json["version"] as? String,
              let metadata = json["metadata"] as? [String: String] else {
            return nil
        }
        
        return RegistryEntry(
            type: type,
            name: name,
            version: version,
            path: path,
            metadata: metadata
        )
    }
}

public struct RegistryEntry {
    public let type: DefinitionType
    public let name: String
    public let version: String
    public let path: String
    public let metadata: [String: String]
}

public enum RegistryError: Error {
    case definitionNotFound(name: String, type: DefinitionType)
    case invalidDefinition(String)
}