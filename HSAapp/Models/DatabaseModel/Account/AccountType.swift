//
//  AccountType.swift
//

import Foundation
import RealmSwift

@objc enum AccountType: Int, RealmEnum, Codable {
    case hsa = 1
    case everyday

    var type: String {
        switch self {
        case .hsa:
            return "hsa"
        case .everyday:
            return "everyday"
        }
    }

    init(jsonValue: String) {
        switch jsonValue.lowercased() {
        case "hsa":
            self = .hsa
        case "everyday":
            self = .everyday
        default:
            self = .everyday
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
            try container.encode("hsa")
        case 2:
            try container.encode("everyday")
        default:
            try container.encode("everyday")
        }
    }
}
