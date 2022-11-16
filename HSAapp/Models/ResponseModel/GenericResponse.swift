//
//  GenericResponse.swift
//

import Foundation

struct StatusOnlyResponse: Codable {
    let status: String
}

struct MessageOnlyResponse: Codable {
    let message: String
}

struct MessageWithCodeResponse: Codable, Equatable, Hashable {
    let message: String
    let code: String?
}

struct ErrorResponse: Codable {
    let error: MessageWithCodeResponse
}
