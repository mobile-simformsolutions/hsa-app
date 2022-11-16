//
//  TransactionSummary.swift
//

import Foundation
import RealmSwift

@objc enum TransactionImage: Int, RealmEnum, Codable {
    case deposit,
         contribution,
         withdrawal
    
    func imageName() -> String {
        switch self {
        case .deposit:
            return "deposit"
        case .contribution:
            return "contribution"
        case .withdrawal:
            return "reimbursement"
        }
    }
    
    init(jsonValue: String) {
        switch jsonValue {
        case "deposit":
            self = .deposit
        case "contribution":
            self = .contribution
        case "ach-withdrawal":
            self = .withdrawal
        default:
            self = .deposit
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self.init(jsonValue: value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self.rawValue {
        case 1:
            try container.encode("deposit")
        case 2:
            try container.encode("contribution")
        case 3:
            try container.encode("ach-withdrawal")
        default:
            try container.encode("non-medical")
        }
    }
}

@objc enum TransactionMode: Int, RealmEnum, Codable {
    case debit = 1, credit
    
    init(jsonValue: String) {
        switch jsonValue.lowercased() {
        case "debit":
            self = .debit
        case "credit":
            self = .credit
        default:
            self = .debit
        }
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self.init(jsonValue: value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self.rawValue {
        case 1:
            try container.encode("debit")
        case 2:
            try container.encode("credit")
        default:
            try container.encode("credit")
        }
    }
}

class TransactionSummary: Object, Codable, Identifiable {
    @objc dynamic var id: String  = "Unknown"
    @objc dynamic var activity: String  = "Unknown"
    @objc dynamic var summaryDescription: String  = "Unknown"
    @objc dynamic var mode: TransactionMode = .credit
    @objc dynamic var amount: Double  = 0
    @objc dynamic var date: Date = Date()
    @objc dynamic var image: TransactionImage = .contribution
    @objc dynamic var needsAttention: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case activity = "activity"
        case summaryDescription = "description"
        case mode = "mode"
        case amount = "amount"
        case date = "date"
        case image = "image"
        case needsAttention = "needs_attention"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try container.decode(String.self, forKey: .mode)
        self.mode = TransactionMode(jsonValue: rawType)
        self.id = try container.decode(String.self, forKey: .id)
        self.activity = try container.decode(String.self, forKey: .activity)
        
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.summaryDescription = try container.decode(String.self, forKey: .summaryDescription)
        let rawImage = try container.decode(String.self, forKey: .image)
        self.image = TransactionImage(jsonValue: rawImage)
        self.needsAttention = try container.decode(Bool.self, forKey: .needsAttention)
        let rawDate = try container.decode(Double.self, forKey: .date)
        self.date = Date(timeIntervalSince1970: rawDate)
    }
    
    override init() {
        super.init()
    }
    
}
