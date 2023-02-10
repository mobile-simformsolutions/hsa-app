//
//  TransactionSummaryViewModel.swift
//

import SwiftUI
class TransactionSummaryViewModel: ObservableObject, Identifiable {
    
    // MARK: - Variables
    //
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let displayAmount: String
    let amountColor: Color
    let needsAttention: Bool
    let displayDate: String
    let subTitleColor: Color
    
    init(transactionSummary: TransactionSummaryDataModel) {
        self.iconName = transactionSummary.image.imageName()
        self.title = transactionSummary.activity
        self.subtitle = transactionSummary.summaryDescription
        
        let currencyFormatter = NumberFormatter.defaultCurrencyFormatter()
        if let amountString = currencyFormatter.string(from: NSNumber(value: transactionSummary.amount)) {
            self.displayAmount = (transactionSummary.mode == .debit ? "-" : "") + amountString
        } else {
            self.displayAmount = "??"
        }
        
        if transactionSummary.needsAttention {
            self.amountColor = .transactionNegative
            self.iconColor = .transactionNegative
            self.subTitleColor = iconColor
        } else if transactionSummary.mode == .credit {
            self.amountColor = .transactionPositive
            self.iconColor = .transactionDefault
            self.subTitleColor = iconColor
        } else {
            self.amountColor = .transactionDefault
            self.iconColor = .transactionDefault
            self.subTitleColor = iconColor
        }
        self.needsAttention = transactionSummary.needsAttention
        self.displayDate = Self.dateFormatter.string(from: transactionSummary.date)
    }

    init(
        iconName: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        displayAmount: String,
        amountColor: Color,
        needsAttention: Bool,
        displayDate: String
    ) {
        self.iconName = iconName
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.displayAmount = displayAmount
        self.amountColor = amountColor
        self.needsAttention = needsAttention
        self.displayDate = displayDate
        self.subTitleColor = self.iconColor
    }
}
