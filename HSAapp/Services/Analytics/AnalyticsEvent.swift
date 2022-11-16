//
//  AnalyticsEvent.swift
//

import Foundation

struct AnalyticsEvent {
    let name: AnalyticsEventName
    let parameters: [String: Any]?
}
