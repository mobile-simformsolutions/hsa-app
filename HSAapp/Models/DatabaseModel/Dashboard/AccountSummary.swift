//
//  AccountSummary.swift
//

import Foundation
import RealmSwift

class DashboardSummary: Object, Decodable {
    @objc dynamic var combinedBalance: Double = 0
    @objc dynamic var availableBalanceToSpend: Double = 0
    var accountSummary = List<AccountSummary>()
    @objc dynamic var contributionSummary: ContributionSummary?
    var recentTransactions = List<TransactionSummary>()
    
    enum CodingKeys: String, CodingKey {
        case combinedBalance = "combined_balance"
        case availableBalanceToSpend = "available_balance_to_spend"
        case accountSummary = "summary"
        case contributionSummary = "contributions"
        case recentTransactions = "transactions"
        case achTransactions = "ach_transactions"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        combinedBalance = try container.decode(Double.self, forKey: .combinedBalance)
        if container.contains(.availableBalanceToSpend) {
            availableBalanceToSpend = try container.decode(Double.self, forKey: .availableBalanceToSpend)
        }
        accountSummary = try container.decode(List<AccountSummary>.self, forKey: .accountSummary)
        if container.contains(.contributionSummary) {
            contributionSummary = try container.decode(ContributionSummary.self, forKey: .contributionSummary)
        }
        recentTransactions = try container.decode(List<TransactionSummary>.self, forKey: .recentTransactions)
    }
    
    func accountSummary(for type: AccountType) -> AccountSummary? {
        accountSummary.first { summary in
            return summary.type == type
        }
    }
    override init() {
        super.init()
    }
}

@objc enum AccountSummaryStatus: Int, RealmEnum, Codable {
    case active = 1, suspended, pending, terminated, inactive
    
    init(jsonValue: String) {
        switch jsonValue.lowercased() {
        case "active":
            self = .active
        case "suspended":
            self = .suspended
        case "pending":
            self = .pending
        case "terminated":
            self = .terminated
        case "inactive":
            self = .inactive
        default:
            self = .inactive
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self.init(jsonValue: value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.stringValue())
    }
    
    func stringValue() -> String {
        switch self {
        case .active:
             return "active"
        case .suspended:
            return "suspended"
        case .pending:
            return "pending"
        case .terminated:
            return "terminated"
        case .inactive:
            return "inactive"
        }
    }
}

class AccountSummary: Object, Codable {
    @objc dynamic var _id = ObjectId.generate() // swiftlint:disable:this identifier_name
    @objc dynamic var type: AccountType = .hsa
    @objc dynamic var maskedBankAccountNumber: String = ""
    @objc dynamic var amount: Double = 0
    @objc dynamic var status: AccountSummaryStatus = .suspended
    
    override static func primaryKey() -> String? {
            return "_id"
        }
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case maskedBankAccountNumber = "masked_bank_account_number"
        case amount = "amount"
        case status = "status"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try container.decode(String.self, forKey: .type)
        self.type = AccountType(jsonValue: rawType)
        self.maskedBankAccountNumber = try container.decode(String.self, forKey: .maskedBankAccountNumber)
        self.amount = try container.decode(Double.self, forKey: .amount)
        
        let rawStatus = try container.decode(String.self, forKey: .status)
        self.status = AccountSummaryStatus(jsonValue: rawStatus)
    }
    
    override init() {
        super.init()
    }

}

class ContributionSummary: Object, Codable {
    @objc dynamic var amount: Double = 0
    @objc dynamic var maxAmount: Double = 0
    @objc dynamic var previousYearEligible: Bool = false
    let year = RealmProperty<Int?>()
    @objc dynamic var previousYearDetails: PreviousYearContributionSummary?
    
    enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case maxAmount = "max_amount"
        case year = "year"
        case previousYearEligible = "prev_year_eligible"
        case previousYearDetails = "prev_year_details"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.maxAmount = try container.decode(Double.self, forKey: .maxAmount)
        self.year.value = try container.decodeIfPresent(Int.self, forKey: .year)
        if container.contains(.previousYearEligible) {
            self.previousYearEligible = try container.decode(Bool.self, forKey: .previousYearEligible)
        }
        
        if container.contains(.previousYearDetails) {
            self.previousYearDetails = try container.decode(PreviousYearContributionSummary.self, forKey: .previousYearDetails)
        }
    }

    override init() {
        super.init()
    }
}

class PreviousYearContributionSummary: Object, Codable {
    @objc dynamic var amount: Double = 0
    @objc dynamic var maxAmount: Double = 0
    let year = RealmProperty<Int?>()
    
    enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case maxAmount = "max_amount"
        case year = "year"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.maxAmount = try container.decode(Double.self, forKey: .maxAmount)
        self.year.value = try container.decodeIfPresent(Int.self, forKey: .year)
    }

    override init() {
        super.init()
    }
}
