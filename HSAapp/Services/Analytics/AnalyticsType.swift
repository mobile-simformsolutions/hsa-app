//
//  Analytics.swift
//

import Foundation

protocol AnalyticsType {
    func initialize()

    func track(_ event: AnalyticsEvent)
    func track(_ event: AnalyticsEventName)
    func track(_ event: String, parameters: [String: Any]?)
    func logErrorToCrashlytics(error: Error)
    func logGAAttributes(data: [String: Any])
    /// Refresh the tracking metadata for the currently logged-in or anonymous user.
    /// It's good to call this function after a user logs in or out of the app.
    ///
    func refreshUserData()

    /// Check user opt-in for analytics. Set this after user logged in or logged out
    ///
    var userHasOptedIn: Bool { get set }
}
