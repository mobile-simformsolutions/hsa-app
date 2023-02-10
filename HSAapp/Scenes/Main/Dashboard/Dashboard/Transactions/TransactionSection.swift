//
//  TransactionSection.swift
//

import Foundation

class TransactionSection: Identifiable {
    
    let sectionDate: Date
    var sectionName: String {
        DateFormatter.transactionSectionTitleFormatter.string(from: sectionDate)
    }
    var transactions: [TransactionSummaryDataModel] = [TransactionSummaryDataModel]()
    var id: Date {
        sectionDate
    }

    init(sectionDate: Date, transactions: [TransactionSummaryDataModel]) {
        self.sectionDate = sectionDate
        self.transactions = transactions
    }
    
    func add(_ summary: TransactionSummaryDataModel) {
        transactions.removeAll { transaction in
            transaction.id == summary.id
        }
        transactions.append(summary)
        transactions = transactions.sorted { $0.date > $1.date }
    }

    static func groupByMonth(transactions: [TransactionSummaryDataModel]) -> [TransactionSection] {
        group(transactions: transactions, by: { $0.date.firstDayOfMonth })
            .sorted(by: { $0.sectionDate > $1.sectionDate })
    }

    static func group(transactions: [TransactionSummaryDataModel], by criteria: (TransactionSummaryDataModel) -> Date) -> [TransactionSection] {
        let groups = Dictionary(grouping: transactions, by: criteria)
        return groups.map(TransactionSection.init)
    }
}
