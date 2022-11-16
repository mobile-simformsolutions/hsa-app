//
//  UserDefaultsManager.swift
//

import Foundation

final class UserDefaultsManager: UserDefaultsManaging {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    var isPreviouslyRegistered: Bool {
        get { userDefaults[.isPreviouslyRegistered] ?? false }
        set { userDefaults[.isPreviouslyRegistered] = newValue }
    }

    /// Analytics are enabled by default
    ///
    var userOptedInAnalytics: Bool {
        get { userDefaults[.userOptedInAnalytics] ?? true }
        set { userDefaults[.userOptedInAnalytics] = newValue }
    }

    var username: String? {
        get { userDefaults[.username] }
        set { userDefaults[.username] = newValue }
    }

    var isBiometricsAutoLoginEnabled: Bool {
        get { userDefaults[.isBiometricsAutoLoginEnabled] ?? false }
        set { userDefaults[.isBiometricsAutoLoginEnabled] = newValue }
    }

    var userWasAskedForBiometrics: Bool {
        get { userDefaults[.userWasAskedForBiometrics] ?? false }
        set { userDefaults[.userWasAskedForBiometrics] = newValue }
    }
}
