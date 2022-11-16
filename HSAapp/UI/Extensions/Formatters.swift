//
//  Formatters.swift
//

import Foundation
import RealmSwift

extension NumberFormatter {
    static func defaultCurrencyFormatter() -> NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.roundingMode = .down
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "USD"
        return currencyFormatter
    }
    
    static func formatterWithTwoFractionDigits() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.roundingIncrement = 0
        return formatter
    }
    
    func string(from: Double) -> String? {
        return self.string(from: NSNumber(value: from))
    }
    
    func string(from: Decimal128) -> String? {
        return self.string(from: NSDecimalNumber(decimal: from.decimalValue))
    }
    
    func stringWithDecimalCount(from: Decimal) -> String? {
        self.maximumFractionDigits = 2
        self.minimumFractionDigits = 2
        self.roundingIncrement = 0
        return self.string(from: NSDecimalNumber(decimal: from))
    }
    
    func stringWithDecimalCount(from: Double) -> String? {
        self.maximumFractionDigits = 2
        self.minimumFractionDigits = 2
        self.roundingIncrement = 0
        return self.string(from: from)
    }
    
    func string(from: Decimal) -> String? {
        return self.string(from: NSDecimalNumber(decimal: from))
    }
}

extension DateFormatter {
    static var transactionSectionTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM YYYY")

        return formatter
    }()
    
    static var statementSectionTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("YYYY")

        return formatter
    }()
    
    static var statementRowTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM")

        return formatter
    }()
}
