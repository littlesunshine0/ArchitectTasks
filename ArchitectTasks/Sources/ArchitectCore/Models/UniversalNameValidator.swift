import Foundation

/// Type-aware naming validator with appropriate grammars per type
public struct TypeAwareNameValidator {
    
    private static let domains = Set([
        "Security", "Data", "Network", "Quality", "Performance", "Compliance"
    ])
    
    private static let areas = Set([
        "Escalation", "Detection", "Prevention", "Analysis",
        "Monitoring", "Reporting", "Resolution"
    ])
    
    public enum ValidationResult {
        case valid
        case invalidFormat(String)
        case missingType
    }
    
    public static func validate(_ name: String, type: DefinitionType) -> ValidationResult {
        guard name.first?.isUppercase == true else {
            return .invalidFormat("Must start with uppercase letter")
        }
        
        guard name.allSatisfy({ $0.isLetter || $0.isNumber }) else {
            return .invalidFormat("Must contain only letters and numbers")
        }
        
        return validateByType(name, type: type)
    }
    
    private static func validateByType(_ name: String, type: DefinitionType) -> ValidationResult {
        switch type {
        case .tool, .agent, .rule, .policy:
            // Domain-based types: <Domain><Area><Type>
            let expectedSuffix = type.rawValue.capitalized
            guard name.hasSuffix(expectedSuffix) else {
                return .missingType
            }
            return .valid
            
        case .language, .context:
            // Name-based types: <Name><Type>
            let expectedSuffix = type.rawValue.capitalized
            guard name.hasSuffix(expectedSuffix) else {
                return .missingType
            }
            return .valid
        }
    }
    
    public static func suggest(type: DefinitionType, domain: String? = nil, area: String? = nil, name: String? = nil) -> String {
        switch type {
        case .tool, .agent, .rule, .policy:
            guard let domain = domain else { return "" }
            var parts = [domain]
            if let area = area { parts.append(area) }
            parts.append(type.rawValue.capitalized)
            return parts.joined()
            
        case .language, .context:
            guard let name = name else { return "" }
            return name + type.rawValue.capitalized
        }
    }
}