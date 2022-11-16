//
//  Account.swift
//

import Foundation
import RealmSwift

@objc enum AccountStatus: Int, RealmEnum {
    case processing = 1,
         failed = 2,
         expired = 3,
         linked = 4,
         delinked = 5
}

extension AccountStatus: Codable {
    init(jsonValue: String) {
        switch jsonValue {
        case "Processing":
            self = .processing
        case "Failed":
            self = .failed
        case "Expired":
            self = .expired
        case "Linked":
            self = .linked
        case "Delinked":
            self = .delinked
        default:
            self = .processing
        }
    }
    
    func stringValue() -> String {
        switch self {
        case .processing:
            return "Processing"
        case .failed:
            return "Failed"
        case .expired:
            return "Expired"
        case .linked:
            return "Linked"
        case .delinked:
            return "Delinked"
        }
    }
}

@objc
class Account: Object, Codable {
    @objc var accountID: String = "Unknown"
    @objc var accountNumber: String = "Unknown"
    @objc var routingNumber: String = "Unknown"
    @objc var bankName: String = "Unknown"
    @objc var ddaAccountNumber: String = "Unknown"
    @objc var ddaRoutingNumber: String = "Unknown"
    @objc dynamic var status: AccountStatus = .failed
    
    enum CodingKeys: String, CodingKey {
        case accountID = "ext_account_id"
        case accountNumber = "ext_account_number"
        case routingNumber = "ext_routing_number"
        case bankName = "institution_name"
        case ddaAccountNumber = "dda_account_number"
        case ddaRoutingNumber = "dda_routing_number"
        case status = "ext_account_link_status"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try container.decode(String.self, forKey: .status)
        self.accountID = try container.decode(String.self, forKey: .accountID)
        self.accountNumber = try container.decode(String.self, forKey: .accountNumber)
        self.routingNumber = try container.decode(String.self, forKey: .routingNumber)
        self.bankName = try container.decode(String.self, forKey: .bankName)
        self.ddaAccountNumber = try container.decode(String.self, forKey: .ddaAccountNumber)
        self.ddaRoutingNumber = try container.decode(String.self, forKey: .ddaRoutingNumber)
        self.status = AccountStatus(jsonValue: rawType.capitalized)
    }
    
    override init() {
        super.init()
    }
    
    init(accountID: String, accountNumber: String, routingNumber: String, bankName: String, linkStatus: AccountStatus, ddaAccountNumber: String, ddaRoutingNumber: String) {
        self.bankName = bankName
        self.accountID = accountID
        self.accountNumber = accountNumber
        self.routingNumber = routingNumber
        self.status = linkStatus
        self.ddaAccountNumber = ddaAccountNumber
        self.ddaRoutingNumber = ddaRoutingNumber
        super.init()
    }
}
