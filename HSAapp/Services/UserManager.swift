//
//  UserManager.swift
//

import Foundation
import Combine
import UIKit
import Resolver
import LocalAuthentication

final class UserManager: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    private var backgroundedDate = Date()
    private var foregroundedDate = Date()
    @Injected private var analytics: AnalyticsType
    @Injected private var networkStatusService: NetworkStatusService

    private let repositoryService: RepositoryService
    private let userDefaultsManager: UserDefaultsManaging
    private let keychainManager: KeychainManaging

    init(repositoryService: RepositoryService, userDefaultsManager: UserDefaultsManaging, keychainManager: KeychainManaging) {
        self.repositoryService = repositoryService
        self.userDefaultsManager = userDefaultsManager
        self.keychainManager = keychainManager

        bindNotifications()
    }

    /// By default the user is loggedOut and we don't store this UserDefaults or Keychain for now, eg. app always starts logged out
    @Published private(set) var state: State = .loggedOut {
        willSet {
            guard newValue != state else {
                return
            }

            Log(.debug, message: "[UserManager]: State was changed to \(state)")
        }
    }

    var isLoggedIn: Bool {
        state == .loggedIn
    }

    var isBiometricsAutoLoginEnabled: Bool {
        get { userDefaultsManager.isBiometricsAutoLoginEnabled }
        set { userDefaultsManager.isBiometricsAutoLoginEnabled = newValue }
    }

    var lastUsedUsername: String? {
        get { userDefaultsManager.username }
        set { userDefaultsManager.username = newValue }
    }

    var userWasAskedForBiometrics: Bool {
        get { userDefaultsManager.userWasAskedForBiometrics }
        set { userDefaultsManager.userWasAskedForBiometrics = newValue }
    }

    func logout(clearData: Bool) {
        self.handleLogout(clearData: clearData)
    }

    func login() {
        state = .loggedIn
        setUserPreviouslyRegistered()

        // This is a workaround for biometrics login
        // If you only login via biometrics and don't touch anything the idle timer wouldn't be reset because it isn't `UIEvent`
        (UIApplication.shared as? HSAAppApplication)?.resetIdleTimer()
    }

    func getUserCredentials() throws -> UserCredentials? {
        try keychainManager.getObject(atKey: .userCredentials)
    }

    func saveUserCredentials(username: String, password: String) throws {
        guard !username.isEmpty, !password.isEmpty else {
            assertionFailure("We can't have empty fields")
            return
        }

        let credentials = UserCredentials(username: username, password: password)
        try keychainManager.setObject(object: credentials, atKey: .userCredentials)
    }

    func removeCredentialsFromKeychain() {
        try? keychainManager.removeValue(atKey: .userCredentials)
    }
}

// MARK: - Private

private extension UserManager {
    func bindNotifications() {
        bindLifecycle()
        bindAppTimeout()
    }

    func bindLifecycle() {
        Publishers.MergeMany(
            NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
            NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification),
            NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification),
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
        ).sink { [weak self] notification in
            guard let self = self else {
                return
            }
            switch notification.name {
            case UIApplication.willResignActiveNotification:
                self.backgroundedDate = Date()
            case UIApplication.willEnterForegroundNotification, UIApplication.didBecomeActiveNotification:
                self.foregroundedDate = Date()

                let isTimedOut = self.foregroundedDate.timeIntervalSince(self.backgroundedDate) <= -Constants.timeoutTreshold
                if isTimedOut {
                    self.logout(clearData: false)
                }
            default:
                break
            }
        }.store(in: &cancellables)
    }

    func bindAppTimeout() {
        NotificationCenter.default.publisher(for: .appTimeout)
            .sink { [weak self] _ in
                if self?.state == .loggedIn {
                    self?.logout(clearData: false)
                }
            }
            .store(in: &cancellables)
    }

    func handleLogout(clearData: Bool) {
        state = .loggedOut

        // If the logout was user action we clear the data
        if clearData {
            isBiometricsAutoLoginEnabled = false
        }
    }
    
    func setUserPreviouslyRegistered() {
        userDefaultsManager.isPreviouslyRegistered = true
    }
    
}

// MARK: - State

extension UserManager {
    enum State: Equatable {
        case loggedIn
        case loggedOut
    }
}
