//
//  Constants.swift
//

import Foundation
import UIKit

let appString = R.string.localizable

enum Constants {
    
    /// Keychain
    enum Keychain {
        static let serviceName = "com.gethsa"
    }
    
    static let faqURL = URL(string: "https://www.google.com/")
    static let timeoutTreshold: Double = 20 * 60 // 20 minutes
    static let customerSupportEmailAddress = "{ Support email }"
    static var imageEdgeSize: CGFloat = 40
    static let balanceUpdateDisplayFormat = "EE, MMM d h:mm a"
    static let phoneNumberFormate = "0123456789"
    static let handlerName = "handler"
    static let statusKey = "status"
    static let responseUrlKey = "responseURL"
}
