# Verb-Rooted Naming Convention

## Pattern
```
<verb>.<namespace>
```

Where:
- **verb**: The action (validate, analyze, deploy, test, build)
- **namespace**: The project/domain scope (elevan, security, data)

## Project Structure
Every verb project contains multiple artifact types:

```
validate.elevan          # Project definition
├── validate.definition  # Formal definition
├── validate.tool        # Tool implementation  
├── validate.agent       # Agent orchestration
├── validate.policy      # Policy constraints
├── validate.workflow    # Workflow steps
├── validate.context     # Execution context
├── validate.sh          # Shell script
├── validate.py          # Python script
└── validate.menubar     # Menu bar integration
```

## Artifact Types
- `.definition` - Formal statement and metadata
- `.tool` - Executable tool implementation
- `.agent` - Orchestration and coordination
- `.rule` - Evaluation conditions
- `.policy` - Constraint enforcement
- `.workflow` - Step-by-step process
- `.context` - Execution environment
- `.language` - Syntax definitions
- `.task` - Individual work units
- `.template` - Reusable patterns
- `.script` - Shell/Python/etc scripts
- `.menubar` - UI integration
- `.icon` - Visual assets

## Examples

### Quality Projects
- `validate.elevan` - Validation framework
- `analyze.codebase` - Code analysis
- `test.integration` - Integration testing

### Security Projects  
- `scan.vulnerabilities` - Security scanning
- `audit.permissions` - Permission auditing
- `encrypt.secrets` - Secret management

### DevOps Projects
- `deploy.production` - Production deployment
- `monitor.performance` - Performance monitoring
- `backup.databases` - Database backup

## Registry Lookup
1. System level: `/usr/local/share/verbs/`
2. User level: `~/.verbs/`
3. Project level: `./.verbs/`

## Execution Model
```
verb.namespace → resolve project → select artifact → execute
```

The verb becomes the entry point, the namespace provides scope, and the artifact type determines execution strategy.