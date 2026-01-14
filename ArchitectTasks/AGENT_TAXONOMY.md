# Agent Naming Taxonomy

## Controlled Vocabulary

### Domains
- **Security**: Authentication, authorization, vulnerability management
- **Data**: Storage, processing, validation, transformation
- **Network**: Traffic, connectivity, routing, protocols
- **Quality**: Code quality, testing, validation
- **Performance**: Monitoring, optimization, profiling
- **Compliance**: Regulatory, policy, audit requirements

### SubDomains
#### Security
- AccessControl
- Vulnerability
- Incident
- Audit

#### Data
- Schema
- Pipeline
- Quality
- Migration

#### Network
- Traffic
- Firewall
- DNS
- Load

#### Quality
- Code
- Test
- Validation
- Metrics

#### Performance
- Memory
- CPU
- IO
- Cache

#### Compliance
- Policy
- Audit
- Report
- Governance

### Areas
- Escalation
- Validation
- Detection
- Prevention
- Analysis
- Monitoring
- Reporting
- Resolution

### SubAreas
- Privilege
- Schema
- Threshold
- Pattern
- Anomaly
- Baseline
- Trend
- Alert

### Roles
- **Agent**: General-purpose autonomous entity
- **Handler**: Processes specific events or requests
- **Checker**: Validates conditions or states
- **Analyzer**: Examines and interprets data
- **Monitor**: Continuously observes systems
- **Reporter**: Generates reports or notifications
- **Resolver**: Fixes or resolves issues

## Decision Tree

```
1. What is the primary domain?
   └─ Use Domain (Security, Data, Network, etc.)

2. Is it a specialized subdomain?
   └─ Add SubDomain (AccessControl, Schema, etc.)

3. Does it handle a specific type of problem?
   └─ Add Area (Escalation, Validation, etc.)

4. Is there a specific problem class?
   └─ Add SubArea (Privilege, Schema, etc.)

5. What is the agent's primary function?
   └─ Add Role (Agent, Handler, Checker, etc.)

6. Use the shortest meaningful combination
```

## Examples by Complexity

### Simple (Domain + Role)
- `SecurityAgent`
- `DataAgent`
- `NetworkAgent`

### Moderate (Domain + SubDomain + Role)
- `SecurityAccessControlAgent`
- `DataSchemaAgent`
- `NetworkTrafficAgent`

### Complex (Domain + SubDomain + Area + Role)
- `SecurityAccessControlEscalationAgent`
- `DataSchemaValidationAgent`
- `NetworkTrafficAnalysisAgent`

### Highly Specialized (All Layers)
- `SecurityAccessControlPrivilegeEscalationHandler`
- `DataSchemaValidationThresholdChecker`
- `NetworkTrafficAnomalyDetectionAnalyzer`

## Cross-Domain Patterns

When an agent spans multiple domains, use:
`<PrimaryDomain><SecondaryDomain><Area>Agent`

Examples:
- `SecurityNetworkTrafficAgent`
- `DataQualityValidationAgent`
- `NetworkSecurityFirewallAgent`

## Versioning Guidelines

Only add version suffixes when:
1. Significant architectural changes require a new implementation
2. Breaking changes in the agent interface
3. Major algorithm updates that warrant distinction

Format: `<AgentName>V2`, `<AgentName>V3`

**Avoid versioning for:**
- Minor bug fixes
- Performance improvements
- Configuration changes

# Agent Taxonomy: Who, What, When, Where, Why, How

Agent naming and taxonomy can be mapped to the classic questions to clarify each agent’s identity and responsibility:

| Question | Taxonomy Layer / Attribute | Example Value                |
|----------|---------------------------|------------------------------|
| Who      | Agent (the entity)        | AccessControlEscalationAgent |
| What     | Role                      | Handler, Checker, Analyzer   |
| When     | Trigger/Condition (code)  | OnLogin, OnError, OnChange   |
| Where    | Domain/SubDomain/Area     | Security, AccessControl      |
| Why      | Purpose/Intent (code)     | Prevent privilege escalation |
| How      | Implementation (code)     | Uses audit logs, policies    |

**Example:**
- **Who:** AccessControlEscalationAgent
- **What:** Handler (role)
- **When:** On privilege escalation attempt (trigger/condition)
- **Where:** Security domain, AccessControl subdomain
- **Why:** To prevent unauthorized privilege escalation
- **How:** By monitoring access logs and enforcing policies

> Note: Only the Who (agent name) and What (role) are typically in the agent’s class name. The rest are captured in code, configuration, or documentation for clarity and maintainability.