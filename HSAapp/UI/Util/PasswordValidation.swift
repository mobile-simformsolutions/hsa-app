//
//  PasswordValidation.swift
//

import SwiftUI

struct PasswordRuleResult: Identifiable {
    let id = UUID()
    let passed: Bool
    let description: String
}

class PasswordValidationResult: Identifiable, ObservableObject {
    let id = UUID()
    
    static let noValidation = PasswordValidationResult(validationResult: .unknown, ruleResults: [])
    @Published var validationResult: ValidationResult
    @Published var ruleResults: [PasswordRuleResult]
    
    init(validationResult: ValidationResult, ruleResults: [PasswordRuleResult]) {
        self.validationResult = validationResult
        self.ruleResults = ruleResults
    }
}

enum PasswordValidation {
    static func validate(_ password: String) -> PasswordValidationResult {
        let ruleResults = [
            lengthCheck(password),
            upperCaseCheck(password),
            lowerCaseCheck(password),
            numberCheck(password),
            specialCharachterCheck(password)
        ]
        let allRulesPassed = ruleResults.allSatisfy { (result) -> Bool in
            return result.passed
        }
        let validationResult: ValidationResult = allRulesPassed ? .valid : .error
        return PasswordValidationResult(validationResult: validationResult, ruleResults: ruleResults)
    }
    
    private static func lengthCheck(_ password: String) -> PasswordRuleResult {
        let passed = password.count > 7
        return PasswordRuleResult(passed: passed, description: appString.eightChar())
    }
    private static func upperCaseCheck(_ password: String) -> PasswordRuleResult {
        let passed = password.range(of: #".*[A-Z]+.*"#,
                                    options: .regularExpression) != nil
        return PasswordRuleResult(passed: passed, description: appString.capitalLetter())
    }
    
    private static func lowerCaseCheck(_ password: String) -> PasswordRuleResult {
        let passed = password.range(of: #".*[a-z]+.*"#,
                                    options: .regularExpression) != nil
        return PasswordRuleResult(passed: passed, description: appString.lowercaseRequierd())
    }
    
    private static func numberCheck(_ password: String) -> PasswordRuleResult {
        let passed = password.range(of: #".*[0-9]+.*"#,
                                    options: .regularExpression) != nil
        return PasswordRuleResult(passed: passed, description: appString.numberRequierd())
    }
    
    private static func specialCharachterCheck(_ password: String) -> PasswordRuleResult {
        let passed = password.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil
        return PasswordRuleResult(passed: passed, description: appString.specialCharRequired())
    }
}
