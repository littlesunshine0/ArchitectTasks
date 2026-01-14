#!/usr/bin/env swift

import Foundation

/// Command-line interface for executing verb projects
public struct VerbCLI {
    private let integration = IntegrationManager()
    
    public func run(args: [String]) async {
        guard args.count >= 2 else {
            print("Usage: verb-cli <verb.namespace> [type]")
            return
        }
        
        let projectName = args[1]
        let components = projectName.split(separator: ".")
        guard components.count == 2 else {
            print("Invalid format. Use: verb.namespace")
            return
        }
        
        let verb = String(components[0])
        let namespace = String(components[1])
        let type = args.count > 2 ? UnifiedType(rawValue: args[2]) : .tool
        
        do {
            let result = try await integration.execute(
                verb: verb, 
                namespace: namespace, 
                type: type ?? .tool
            )
            print(result.output)
        } catch {
            print("Error: \(error)")
        }
    }
}

// Execute if run directly
if CommandLine.arguments.count > 1 {
    let cli = VerbCLI()
    await cli.run(args: CommandLine.arguments)
}