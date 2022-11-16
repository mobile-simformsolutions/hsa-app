//
//  SupportRequest.swift
//

import Foundation

struct SupportRequest: Codable {
    let message: String
    let type: SupportRequestType

    enum CodingKeys: String, CodingKey {
        case message = "message"
        case type = "support_type"
    }
}
