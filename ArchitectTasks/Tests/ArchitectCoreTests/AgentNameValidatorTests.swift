import XCTest
@testable import ArchitectCore

final class AgentNameValidatorTests: XCTestCase {
    
    func testValidNames() {
        XCTAssertEqual(AgentNameValidator.validate("SecurityAgent"), .valid)
s    func testInvalidFormat() {
        if case .invalidFormat = AgentNameValidator.validate("securityAgent") {
            // Expected lowercase start
        } else {
            XCTFail("Should reject lowercase start")
        }
        
        if case .invalidFormat = AgentNameValidator.validate("Security-Agent") {
            // Expected special characters
        } else {
            XCTFail("Should reject special characters")
        }
    }
    
    func testMissingRole() {
        if case .missingRole = AgentNameValidator.validate("Security") {
            // Expected missing role
        } else {
            XCTFail("Should require role suffix")
        }
    }
    
    func testNameSuggestion() {
        let name = AgentNameValidator.suggestName(
            domain: "Security",
            role: "Agent",
            subdomain: "AccessControl"
        )
        XCTAssertEqual(name, "SecurityAccessControlAgent")
    }
}