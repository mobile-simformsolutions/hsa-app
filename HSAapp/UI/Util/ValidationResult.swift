//
//  ValidationResult.swift
//

import Foundation
enum ValidationResult {
    case valid, error, unknown
}

enum TextValidationType {
    case notNull, onlyLetters, onlyNumbers, onlyLettersAndSpaces
}

enum TextValidation {
    static func validate(_ type: TextValidationType, input: String) -> ValidationResult {
        var valid: Bool
        switch type {
        
        case .notNull:
            valid = !input.isEmpty
        case .onlyLetters:
            let notLetters = NSCharacterSet.letters.inverted
            let range = input.rangeOfCharacter(from: notLetters)
            valid = range == nil && !input.isEmpty
        case .onlyLettersAndSpaces:
            var notLetters = NSCharacterSet.letters
            notLetters.insert(charactersIn: " ")
            let range = input.rangeOfCharacter(from: notLetters.inverted)
            valid = range == nil && !input.isEmpty && !input.trimmed.isEmpty
        case .onlyNumbers:
            let notNumbers = NSCharacterSet.decimalDigits.inverted
            let range = input.rangeOfCharacter(from: notNumbers)
            valid = range == nil && !input.isEmpty
        }
        
        return valid ? .valid : .error
    }
    
    static func validate(_ type: TextValidationType, lengthRange: Range<Int>, input: String) -> ValidationResult {
        if self.validate(type, input: input) == .valid &&
            input.count >= lengthRange.lowerBound &&
            input.count <= lengthRange.upperBound {
            return ValidationResult.valid
        } else {
            return ValidationResult.error
        }
    }
    
    static func validate(_ type: TextValidationType, valueRange: Range<Double>, input: String) -> ValidationResult {
        guard let inputDouble = Double(input) else {
            return ValidationResult.error
        }
        if self.validate(type, input: input) == .valid &&
            doubleInRange(input: inputDouble, range: valueRange) == true {
            return ValidationResult.valid
        } else {
            return ValidationResult.error
        }
    }
    
    private static func doubleInRange(input: Double, range: Range<Double>) -> Bool {
        if input >= range.lowerBound && input <= range.upperBound {
            return true
        } else {
            return false
        }
    }
    
    static func validate(_ type: TextValidationType, length: Int, input: String) -> ValidationResult {
        if self.validate(type, input: input) == .valid &&
            input.count == length {
            return ValidationResult.valid
        } else {
            return ValidationResult.error
        }
    }
    
    static func validatePhone(_ phoneNumber: String) -> ValidationResult {
        return TextValidation.validate(.onlyNumbers, length: 10, input: phoneNumber)
    }
    
    static func validateMileage(_ amount: String) -> ValidationResult {
        let regex = #"(\d{0,5})(\.\d{0,2})?"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: amount) ? .valid : .error
    }
    
    static func validateAmount(_ amount: String, restrictOnlyDecimal: Bool = false) -> ValidationResult {
        let regex = !restrictOnlyDecimal ? #"(\d{0,4})(\.\d{0,2})?"# : #"(\d{0,})(\.\d{0,2})?"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: amount) ? .valid : .error
    }
    
    static func validateZip(_ text: String) -> ValidationResult {
        let regex = #"(\d{5})(-\d{4})?"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: text) ? .valid : .error
    }
}
