//
//  GenericError.swift
//

import Foundation

struct GenericError: LocalizedError {
    var errorDescription: String? = "Something went wrong."

    init() {}

    init(_ description: String) {
        errorDescription = description
    }
}
