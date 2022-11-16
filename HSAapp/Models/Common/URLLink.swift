//
//  URLLink.swift
//

import SwiftUI

struct URLLink {
    let title: String
    let url: URL
}

extension URLLink: Identifiable, Hashable {
    var id: Int {
        hashValue
    }
}
