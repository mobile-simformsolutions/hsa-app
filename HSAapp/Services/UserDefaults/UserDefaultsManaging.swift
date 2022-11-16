//
//  UserDefaultsManaging.swift
//

import Foundation

protocol UserDefaultsManaging: AnyObject {
    var isPreviouslyRegistered: Bool { get set }
    var isBiometricsAutoLoginEnabled: Bool { get set }
    var userWasAskedForBiometrics: Bool { get set }
    var userOptedInAnalytics: Bool { get set }
    var username: String? { get set }
}
