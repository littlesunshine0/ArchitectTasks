# Contributing to ArchitectTasks

Thank you for your interest in contributing to ArchitectTasks!

## Development Setup

```bash
# Clone the repository
git clone https://github.com/yourorg/ArchitectTasks.git
cd ArchitectTasks

# Build
swift build

# Run tests
swift test

# Run the CLI
swift run architect-cli help
```

## Project Structure

```
ArchitectTasks/
├── Sources/
│   ├── ArchitectCore/       # Models, protocols, persistence (no deps)
│   ├── ArchitectAnalysis/   # SwiftSyntax-based analyzers
│   ├── ArchitectPlanner/    # Task generation (Agent A)
│   ├── ArchitectExecutor/   # Deterministic transforms (Agent B)
│   ├── ArchitectHost/       # Host contract + LocalHost
│   └── architect-cli/       # CLI executable
├── Tests/
├── Package.swift
└── README.md
```

## Adding a New Analyzer

1. Create a new file in `Sources/ArchitectAnalysis/Analyzers/`
2. Implement the `Analyzer` protocol:

```swift
struct MyAnalyzer: Analyzer {
    var supportedFindingTypes: [Finding.FindingType] { [.myFindingType] }
    
    func analyze(fileAt path: String, content: String) throws -> [Finding] {
        // Your analysis logic
    }
}
```

3. Add the finding type to `Finding.FindingType` if needed
4. Register in `ProjectScanner` or allow users to configure

## Adding a New Transform

1. Create a new file in `Sources/ArchitectExecutor/Transforms/`
2. Implement the `DeterministicTransform` protocol:

```swift
struct MyTransform: DeterministicTransform {
    var supportedIntents: [String] { ["myIntent"] }
    
    func apply(to source: String, intent: TaskIntent, context: TransformContext) throws -> TransformResult {
        // Pure, deterministic transformation
    }
}
```

3. Register in `TransformRegistry.registerBuiltins()`
4. Add tests

## Guidelines

### Code Style

- Follow Swift API Design Guidelines
- Use `// MARK: -` for section organization
- Keep functions focused and testable
- Prefer value types (structs/enums) over classes

### Testing

- All new features must have tests
- Aim for deterministic, fast tests
- Use `InMemoryRunStore` for persistence tests

### Commits

- Use conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
- Keep commits focused and atomic
- Reference issues when applicable

### Pull Requests

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Run `swift test` to ensure all tests pass
5. Submit a PR with a clear description

## Architecture Principles

1. **Tasks are the unit of intelligence** - not files, not diffs
2. **Planner/Executor split** - Agent A proposes, Agent B executes
3. **Deterministic transforms** - no LLMs in the execution path
4. **Policy-driven approval** - declarative, not procedural
5. **Persistence for auditability** - every run is recorded

## Unified Architecture

The system now uses a unified definition-driven architecture with three integrated layers:

### 1. Type System
- **UnifiedType**: Single enum for all definitions (tool, agent, rule, policy, workflow, etc.)
- **TypeCategory**: Groups types by execution model (executable, constraint, process, etc.)
- **UnifiedDefinition**: Base protocol for all definitions

### 2. Integration Layer  
- **IntegrationManager**: Central bridge between systems
- **UnifiedRegistry**: Consolidated registry for all definitions and verb projects
- **VerbCLI**: Command-line interface for executing verb projects

### 3. Execution Flow
```
verb.namespace → IntegrationManager → AgentTask → TaskRunner
```

See `UNIFIED_ARCHITECTURE.md` for complete integration details.

## Agent Naming Convention

Agents follow a hierarchical naming structure based on four semantic layers:

```
<Domain>[<SubDomain>][<Area>][<SubArea>]<Role>
```

Where:
- **Domain**: Broad problem space (e.g., Security, Data, Network)
- **SubDomain**: Narrower functional category (e.g., AccessControl, Quality)
- **Area**: Type of problem (e.g., Escalation, Validation)
- **SubArea**: Specific problem class (e.g., Privilege, Schema)
- **Role**: Agent, Handler, Checker, Analyzer, Monitor, Reporter, Resolver

### Usage Patterns

**General-purpose agents** - Use the shortest meaningful form:
```swift
SecurityIncidentAgent
DataSchemaAgent
```

**Specialized agents** - Add layers as needed:
```swift
SecurityAccessControlEscalationAgent
QualityValidationAgent
```

**Highly specialized agents** - Add a role suffix:
```swift
AccessControlEscalationHandler
QualityValidationChecker
```

**Cross-domain agents**:
```swift
SecurityNetworkTrafficAgent
```

**Versioned agents** (rare):
```swift
DataSchemaAgentV2
```

### Naming Rules

1. Always use PascalCase
2. Acronyms are fully capitalized (AIML, API)
3. Avoid abbreviations unless standardized
4. Intent and purpose (Detect, Prevent, etc.) are not in the name
5. Use the shortest meaningful form
6. Add layers only as needed for clarity

### Governance

- Maintain a controlled vocabulary for each layer (see `AGENT_TAXONOMY.md`)
- Use the naming decision tree before creating new agents
- Audit agent names regularly for consistency

## Questions?

Open an issue for discussion before starting major work.
