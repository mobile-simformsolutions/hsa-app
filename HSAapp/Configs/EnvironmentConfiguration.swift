//
//  EnvironmentConfiguration.swift
//

import Foundation

// swiftlint:disable nesting
public enum EnvironmentConfiguration {
    // MARK: - Keys
    enum Keys {
        enum Plist {
            static let rootURL = "ROOT_URL"
        }
    }
    
    // MARK: - Plist
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    // MARK: - Plist values
    static let rootURL: URL = {
        guard let rootURLstring = EnvironmentConfiguration.infoDictionary[Keys.Plist.rootURL] as? String else {
            fatalError("Root URL not set in plist for this environment")
        }
        guard let url = URL(string: "https://\(rootURLstring)") else {
            fatalError("Root URL is invalid")
        }
        return url
    }()
}
// swiftlint:enable nesting
