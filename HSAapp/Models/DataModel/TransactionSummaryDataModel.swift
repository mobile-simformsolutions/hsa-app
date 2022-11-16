//
//  TransactionSummaryDataModel.swift
//

import Foundation

struct TransactionSummaryDataModel: Identifiable {
    var id: String  = "Unknown"
    var activity: String  = "Unknown"
    var summaryDescription: String  = "Unknown"
    var mode: TransactionMode = .credit
    var amount: Double  = 0
    var date: Date = Date()
    var image: TransactionImage = .contribution
    var needsAttention: Bool = true
    
    init(transactionSummary: TransactionSummary) {
        self.mode = transactionSummary.mode
        self.id = transactionSummary.id
        self.activity = transactionSummary.activity
        self.amount = transactionSummary.amount
        self.summaryDescription = transactionSummary.summaryDescription
        self.image = transactionSummary.image
        self.needsAttention = transactionSummary.needsAttention
        self.date = transactionSummary.date
    }
}
