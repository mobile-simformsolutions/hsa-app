//
//  AccountDetails.swift
//

import Foundation
import RealmSwift

class AccountDetails: Object, Decodable {
    @objc dynamic var _id = ObjectId.generate() // swiftlint:disable:this identifier_name
    @objc dynamic var type: AccountType = .hsa
    @objc dynamic var balance: Double = 0
    @objc dynamic var routingNumber: String = ""
    @objc dynamic var contribution: String = ""
    @objc dynamic var accountNumber: String = ""
    @objc dynamic var contributionSummary: ContributionSummary?
    var transactions = List<TransactionSummary>()

    override static func primaryKey() -> String? {
        return "_id"
    }

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case balance = "balance"
        case routingNumber = "routing_number"
        case accountNumber = "account_number"
        case contributionSummary = "contributions"
        case transactions = "transactions"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try container.decode(String.self, forKey: .type)
        self.type = AccountType(jsonValue: rawType)
        self.balance = try container.decode(Double.self, forKey: .balance)
        self.accountNumber = try container.decodeIfPresent(String.self, forKey: .accountNumber) ?? ""
        self.routingNumber = try container.decodeIfPresent(String.self, forKey: .routingNumber) ?? ""
        self.contributionSummary = try container .decodeIfPresent(ContributionSummary.self, forKey: .contributionSummary)
        self.transactions = try container.decode(List<TransactionSummary>.self, forKey: .transactions)

    }

    override init() {
        super.init()
    }

}

class AccountBalance: Codable {
    var accountNumber: String
    var balance: Double
    
    enum CodingKeys: String, CodingKey {
        case accountNumber = "account_number"
        case balance = "amount"
    }
}
