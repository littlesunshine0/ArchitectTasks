# Unified Architecture

## Overview
The ArchitectTasks system uses a unified definition-driven architecture where all components interoperate through a central integration layer.

## Core Components

### 1. Unified Type System
```swift
UnifiedType: tool | agent | rule | policy | workflow | context | language | task | template | script | menubar | icon
```
- Single enum replaces DefinitionType and ArtifactType
- Categorized by execution model (executable, constraint, process, environment, artifact, interface)
- All systems reference this unified type

### 2. Integration Layer
```swift
IntegrationManager
├── loadVerbProject()     // Load verb.namespace projects
├── createAgentTask()     // Bridge definitions to AgentTasks  
├── execute()             // Orchestrate execution by type
└── registry: UnifiedRegistry
```

### 3. Unified Registry
```swift
UnifiedRegistry
├── definitions: [String: UnifiedDefinition]
├── verbProjects: [String: VerbProject]
├── searchPaths: [system, user, project]
└── loadAll()
```

## System Integration

### VerbProject → AgentTask Bridge
```
validate.elevan → IntegrationManager → AgentTask → TaskRunner
```

### Definition Execution Flow
```
1. CLI: verb-cli validate.elevan tool
2. IntegrationManager.execute(verb: "validate", namespace: "elevan", type: .tool)
3. Registry lookup: find validate.elevan project
4. Load artifact: validate.tool definition
5. Convert: ToolDefinition → AgentTask
6. Execute: TaskRunner.run(task)
```

### Registry Lookup Order
```
1. /usr/local/share/definitions/  (System)
2. ~/.definitions/                (User)  
3. ./.definitions/                (Project)
```

## File Structure
```
validate.elevan              # Verb project definition
├── validate.tool           # Tool implementation
├── validate.agent          # Agent orchestration  
├── validate.rule           # Validation rules
├── validate.policy         # Enforcement policies
└── validate.workflow       # Process definition
```

## Execution Examples

### Direct Tool Execution
```bash
verb-cli validate.elevan tool
# → Loads validate.tool → Creates AgentTask → Executes
```

### Rule Evaluation  
```bash
verb-cli validate.elevan rule
# → Loads validate.rule → Evaluates conditions → Returns result
```

### Workflow Orchestration
```bash
verb-cli validate.elevan workflow  
# → Loads validate.workflow → Executes steps → Coordinates agents
```

## Integration Points

### Existing Swift Analysis
- TaskGenerator creates AgentTasks from Findings
- IntegrationManager creates AgentTasks from Definitions
- Both use same TaskRunner execution engine

### Registry Unification
- Single UnifiedRegistry replaces fragmented registries
- Supports both individual definitions and verb projects
- Maintains backward compatibility with existing systems

### Type System Convergence
- AgentTask.intent maps to UnifiedType.category
- VerbArtifact.type uses UnifiedType
- All definitions implement UnifiedDefinition protocol

This architecture enables seamless interoperation between the concrete Swift analysis system and the abstract definition system through the integration layer.