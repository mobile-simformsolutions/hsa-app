//
//  View+WhenRedacted.swift
//

import SwiftUI

extension View {
    func whenRedacted<T: View>(
        apply modifier: @escaping (Self) -> T
    ) -> some View {
        RedactingView(content: self, modifier: modifier)
    }
}

struct RedactingView<Input: View, Output: View>: View {
    var content: Input
    var modifier: (Input) -> Output

    @Environment(\.redactionReasons) private var reasons

    var body: some View {
        if reasons.isEmpty {
            content
        } else {
            modifier(content)
        }
    }
}
