//
//  AccountSummaryDataModel.swift
//

import Foundation

struct AccountSummaryDataModel {
    var type: AccountType = .hsa
    var maskedBankAccountNumber: String = ""
    var amount: Double = 0
    var status: AccountSummaryStatus = .suspended
    
    init(accountSummary: AccountSummary) {
        self.type = accountSummary.type
        self.maskedBankAccountNumber = accountSummary.maskedBankAccountNumber
        self.amount = accountSummary.amount
        self.status = accountSummary.status
    }
}
