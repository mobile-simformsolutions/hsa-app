//
//  SupportRequestType.swift
//

import Foundation

enum SupportRequestType: String, Identifiable, Codable {
    
    var id: String {
        rawValue
    }

    case replace
    case cancel
    case generic
}
