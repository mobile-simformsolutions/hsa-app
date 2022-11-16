//
//  TransactionsManaging.swift
//

import Foundation

protocol TransactionsManaging: AnyObject {
    var transactionsSections: [TransactionSection] { get set }
}

extension TransactionsManaging {
    func addTransactions(_ transactions: [TransactionSummaryDataModel]) {
        for transaction in transactions {
            var section: TransactionSection
            if let existingSection = transactionsSections.first(where: { $0.sectionDate == transaction.date.firstDayOfMonth }) {
                section = existingSection
            } else {
                section = TransactionSection(sectionDate: transaction.date.firstDayOfMonth, transactions: [])
                transactionsSections.append(section)
            }
            section.add(transaction)
        }
        transactionsSections = transactionsSections.sorted { $0.sectionDate > $1.sectionDate }
    }
    
    func transactionCount() -> Int {
        transactionsSections.reduce(0) { acc, section in
            acc + section.transactions.count
        }
    }

    func transactionSectionName(_ transaction: TransactionSummaryDataModel) -> String {
        DateFormatter.transactionSectionTitleFormatter.string(from: transaction.date)
    }
}
