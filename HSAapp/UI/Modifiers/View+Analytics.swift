//
//  View+Analytics.swift
//

import SwiftUI
import Resolver
import FirebaseAnalytics

extension View {
    /// Logs `screen_view` events in Google Analytics for Firebase when this view appears on screen.
    /// - Parameters:
    ///   - name: Current screen name logged with the `screen_view` event.
    ///   - class: Current screen class or struct logged with the `screen_view` event.
    ///   - extraParameters: Any additional parameters to be logged. These extra parameters must
    ///       follow the same rules as described in the `Analytics.logEvent(_:parameters:)` docs.
    /// - Returns: A view with a custom `ViewModifier` used to log `screen_view` events when this
    ///    view appears on screen.
    func analyticsScreen(
        name: String,
        screenClass: String = "View",
        extraParameters: [String: Any] = [:]
    ) -> some View {
        modifier(
            LoggedAnalyticsModifier(
                screenName: name,
                screenClass: screenClass,
                extraParameters: extraParameters
            )
        )
    }

    func analyticsScreen(
        name: AnalyticsScreen,
        screenClass: String = "View",
        extraParameters: [String: Any] = [:]
    ) -> some View {
        analyticsScreen(name: name.rawValue, screenClass: screenClass, extraParameters: extraParameters)
    }
}

private struct LoggedAnalyticsModifier: ViewModifier {
    @Injected var analytics: AnalyticsType

    let screenName: String
    let screenClass: String
    let extraParameters: [String: Any]

    func body(content: Content) -> some View {
        content.onAppear {
            var parameters = extraParameters
            parameters[AnalyticsParameterScreenName] = screenName
            parameters[AnalyticsParameterScreenClass] = screenClass
            analytics.track(AnalyticsEventScreenView, parameters: parameters)
        }
    }
}
