//
//  SecondaryButtonStyle.swift
//

import SwiftUI

struct OnboardingLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.custom(.openSans, weight: .bold, size: 16))
            .foregroundColor(Color.onboardingLinkColor)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
    }
}
