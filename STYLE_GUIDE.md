# Google Swift Style Guide: Rule Mapping & Implementation

This document aggregates and maps rules from the following sources:
- Google Swift Style Guide
- Apple’s Swift API Design Guidelines
- Swift.org’s Swift Language Guide
- Ray Wenderlich Swift Style Guide
- GitHub’s Swift Style Guide
- Community best practices (e.g., SwiftLint)

## Summary Table

| # | Rule | Source | Analyzer Coverage | Details |
|---|------|--------|------------------|---------|
| 1 | Whitespace Characters | Google | Not yet implemented | [Details](#rule-1) |
| 2 | Indentation | Google, Ray Wenderlich, SwiftLint | Partial | [Details](#rule-2) |
| 3 | Line Length | Google, Ray Wenderlich, SwiftLint | Implemented | [Details](#rule-3) |
| 4 | Trailing Whitespace | Google, Ray Wenderlich, SwiftLint | Implemented | [Details](#rule-4) |
| 5 | Blank Lines | Google, Ray Wenderlich | Implemented | [Details](#rule-5) |
| 6 | Import Organization | Google, Ray Wenderlich | Implemented | [Details](#rule-6) |
| 7 | File Structure | Google, Ray Wenderlich | Implemented | [Details](#rule-7) |
| 8 | Naming Conventions | Apple, Google, Ray Wenderlich, GitHub, SwiftLint | Partial | [Details](#rule-8) |
| 9 | Commenting & Documentation | Apple, Google, Ray Wenderlich | Not yet implemented | [Details](#rule-9) |
| 10 | Code Quality Metrics | Google, SwiftLint | Partial | [Details](#rule-10) |
| 11 | Unused Code | Google, SwiftLint | Implemented | [Details](#rule-11) |
| 12 | Compound Statements | Google, Ray Wenderlich | Not yet implemented | [Details](#rule-12) |
| 13 | Language Best Practices | Apple, Google, Ray Wenderlich, GitHub | Partial | [Details](#rule-13) |

---

## Rule Details

### 1. Whitespace Characters
<a name="rule-1"></a>
**Description:** Only ASCII horizontal spaces and tabs are allowed in source files, except in comments and string literals. No non-breaking spaces, etc.

**Sources:** Google

**Analyzer Coverage:** Not yet implemented

**Implementation Plan:**
- Add a check for non-ASCII whitespace outside comments/strings.

**Swift Example:**
```swift
// Good
let x = 1 // regular space
// Bad
let y = 2 // non-breaking space (U+00A0)
```

### 2. Indentation
<a name="rule-2"></a>
**Description:** Use 2 or 4 spaces per indentation level (never tabs). Indentation must be consistent throughout the file.

**Sources:** Google, Ray Wenderlich, SwiftLint

**Analyzer Coverage:** Partial (line length, blank lines)

**Implementation Plan:**
- Add a check for tabs vs spaces and consistent indentation width.

**Swift Example:**
```swift
// Good
func foo() {
  print("bar")
}
// Bad
func foo() {
	print("bar") // tab
}
```

### 3. Line Length
<a name="rule-3"></a>
**Description:** Limit lines to a maximum length (typically 100-120 characters).

**Sources:** Google, Ray Wenderlich, SwiftLint

**Analyzer Coverage:** Implemented

**Implementation Plan:**
- Already implemented in StyleAnalyzer.

**Swift Example:**
```swift
// Good
let message = "Short line."
// Bad
let message = "This is a very long line that exceeds the maximum allowed length for a single line in Swift code."
```

### 4. Trailing Whitespace
<a name="rule-4"></a>
**Description:** No trailing whitespace at the end of any line.

**Sources:** Google, Ray Wenderlich, SwiftLint

**Analyzer Coverage:** Implemented

**Implementation Plan:**
- Already implemented in StyleAnalyzer.

**Swift Example:**
```swift
// Good
let x = 1
// Bad
let x = 1 
```

### 5. Blank Lines
<a name="rule-5"></a>
**Description:** Use blank lines to separate logical sections of code, but avoid multiple consecutive blank lines.

**Sources:** Google, Ray Wenderlich

**Analyzer Coverage:** Implemented

**Implementation Plan:**
- Already implemented in StyleAnalyzer.

**Swift Example:**
```swift
// Good
func foo() {
  // ...
}

func bar() {
  // ...
}
// Bad
func foo() {
  // ...
}


func bar() {
  // ...
}
```

<!-- More rules and details will be added in order as the mapping continues. -->
