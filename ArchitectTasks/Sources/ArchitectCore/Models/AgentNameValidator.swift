import Foundation

/// Validates agent names against the established naming convention
public struct AgentNameValidator {
    
    // MARK: - Controlled Vocabulary
    
    private static let domains = Set([
        "Security", "Data", "Network", "Quality", "Performance", "Compliance"
    ])
    
    private static let subDomains = Set([
        "AccessControl", "Vulnerability", "Incident", "Audit",
        "Schema", "Pipeline", "Quality", "Migration",
        "Traffic", "Firewall", "DNS", "Load",
        "Code", "Test", "Validation", "Metrics",
        "Memory", "CPU", "IO", "Cache",
        "Policy", "Report", "Governance"
    ])
    
    private static let areas = Set([
        "Escalation", "Detection", "Prevention", "Analysis",
        "Monitoring", "Reporting", "Resolution"
    ])
    
    private static let subAreas = Set([
        "Privilege", "Threshold", "Pattern", "Anomaly",
        "Baseline", "Trend", "Alert"
    ])
    
    private static let roles = Set([
        "Agent", "Handler", "Checker", "Analyzer", "Monitor", "Reporter", "Resolver"
    ])
    
    // MARK: - Validation
    
    public enum ValidationResult {
        case valid
        case invalidFormat(String)
        case unknownComponent(String, type: String)
        case tooComplex
        case missingRole
    }
    
    public static func validate(_ name: String) -> ValidationResult {
        guard name.first?.isUppercase == true else {
            return .invalidFormat("Must start with uppercase letter")
        }
        
        guard name.allSatisfy({ $0.isLetter || $0.isNumber }) else {
            return .invalidFormat("Must contain only letters and numbers")
        }
        
        // Find the role suffix
        guard let role = roles.first(where: name.hasSuffix) else {
            return .missingRole
        }
        
        // Extract name without role suffix
        let nameWithoutRole = String(name.dropLast(role.count))
        
        // Must start with a valid domain
        guard let domain = domains.first(where: nameWithoutRole.hasPrefix) else {
            return .unknownComponent(nameWithoutRole, type: "domain")
        }
        
        return .valid
    }
    
    public static func suggestName(domain: String, role: String, subdomain: String? = nil, area: String? = nil, subarea: String? = nil) -> String {
        var parts = [domain]
        if let subdomain = subdomain { parts.append(subdomain) }
        if let area = area { parts.append(area) }
        if let subarea = subarea { parts.append(subarea) }
        parts.append(role)
        return parts.joined()
    }
}