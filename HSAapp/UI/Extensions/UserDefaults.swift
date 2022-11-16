//
//  UserDefaults.swift
//

import Foundation

// MARK: - UserDefaults Keys
//
extension UserDefaults {
    enum Key: String {
        case userOptedInAnalytics
        case analyticsUsername
        case isPreviouslyRegistered
        case username
        case isBiometricsAutoLoginEnabled

        /// This is used to determine whether user was asked for biometrics in signup or after login
        case userWasAskedForBiometrics
    }
}


// MARK: - Convenience Methods
//
extension UserDefaults {
    func object<T>(forKey key: Key) -> T? {
        value(forKey: key.rawValue) as? T
    }

    func set<T>(_ value: T?, forKey key: Key) {
        set(value, forKey: key.rawValue)
    }

    func removeObject(forKey key: Key) {
        removeObject(forKey: key.rawValue)
    }

    func containsObject(forKey key: Key) -> Bool {
        value(forKey: key.rawValue) != nil
    }

    subscript<T>(key: Key) -> T? {
        get {
            value(forKey: key.rawValue) as? T
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    subscript(key: Key) -> Any? {
        get {
            value(forKey: key.rawValue)
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }
}
