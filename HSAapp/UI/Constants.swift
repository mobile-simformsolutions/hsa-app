//
//  Constants.swift
//

import Foundation
import UIKit

// swiftlint:disable force_unwrapping
enum Constants {
    
    static let faqURL = URL(string: "https://www.google.com/")!
    static let timeoutTreshold: Double = 20 * 60 // 20 minutes
    static let customerSupportEmailAddress = "{ Support email }"
    static var imageEdgeSize: CGFloat = 40
    
    /// Keychain
    enum Keychain {
        static let serviceName = "com.gethsa"
    }
}
