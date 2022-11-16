//
//  Analytics.swift
//

import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics
import Resolver

class Analytics: AnalyticsType {
    private let userDefaultsManager: UserDefaultsManaging

    init(userDefaultsManager: UserDefaultsManaging) {
        self.userDefaultsManager = userDefaultsManager
    }

    var userHasOptedIn: Bool {
        get { userDefaultsManager.userOptedInAnalytics }
        set {
            userDefaultsManager.userOptedInAnalytics = newValue
            refreshUserData()
        }
    }

    func initialize() {
        refreshUserData()
    }

    func track(_ event: AnalyticsEvent) {
        guard userHasOptedIn else {
            return
        }

        FirebaseAnalytics.Analytics.logEvent(event.name.rawValue, parameters: event.parameters)
    }

    func track(_ event: AnalyticsEventName) {
        guard userHasOptedIn else {
            return
        }

        FirebaseAnalytics.Analytics.logEvent(event.rawValue, parameters: nil)
    }

    func track(_ event: String, parameters: [String: Any]?) {
        guard userHasOptedIn else {
            return
        }

        FirebaseAnalytics.Analytics.logEvent(event, parameters: parameters)
    }

    func refreshUserData() {
        FirebaseAnalytics.Analytics.setAnalyticsCollectionEnabled(userHasOptedIn)
    }
    
    func logGAAttributes(data: [String: Any]) {
        FirebaseAnalytics.Analytics.setAnalyticsCollectionEnabled(userHasOptedIn)
        FirebaseAnalytics.Analytics.setDefaultEventParameters(data)
    }
    
    func logErrorToCrashlytics(error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
}
