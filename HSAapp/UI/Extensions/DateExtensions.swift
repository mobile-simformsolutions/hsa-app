//
//  DateExtensions.swift
//

import Foundation

extension Date {
    var firstDayOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        guard let date = calendar.date(from: components) else {
            fatalError("Failed to create a date from components")
        }

        return date
    }

    var currentYear: Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)

        return components.year
    }
}
