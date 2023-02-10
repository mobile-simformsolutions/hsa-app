//
//  ColorExtensions.swift
//

import SwiftUI
import UIKit

extension Color {
    static let onboardingBackground = Color("OnboardingBackground")
    static let onboardingPrimaryText = Color("OnboardingPrimaryText")
    static let onboardingSecondaryText = Color("OnboardingSecondaryText")
    static let onboardingBoxBackground = Color("OnboardingBoxBackground")
    static let onboardingBorder = Color("OnboardingBorder")
    static let onboardingTextFieldText = Color("OnboardingTextFieldText")
    static let onboardingLinkColor = Color("OnboardingLinkColor")
    static let errorText = Color("Error")
    static let darkBackground = Color("DarkBackground")
    static let lightBackground = Color("LightBackground")
    static let primaryText = Color("OnboardingPrimaryText")
    static let secondaryText = Color("secondaryText")
    static let defaultText = Color("DefaultText")
    static let okText = Color("ok")
    static let defaultControlBackground = Color("DefaultControlBackground")
    static let defaultBackground = Color("DefaultBackground")
    static let whiteBackground = Color("WhiteBackground")
    static let navigationBackground = Color("navigationBackground")
    static let navigationSelected = Color("navigationSelected")
    static let navigationNotSelected = Color("navigationNotSelected")
    static let transactionNegative = Color("transactionNegative")
    static let transactionDefault = Color("transactionDefault")
    static let transactionPositive = Color("transactionPositive")
    static let actionNeededState = Color("ActionNeeded")
    static let errorState = Color("Error")
    static let activeState = Color("Pending")
    static let modalAcceptColor = Color("ModalAcceptButton")
    static let cardShadow = Color("cardShadow")
    static let dividerBackground = Color("DividerBackground")
    static let myCardSecondaryText = Color("MyCardSecondaryText")
    
    func uiColor() -> UIColor {

        if #available(iOS 14.0, *) {
            return UIColor(self)
        }

        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    // swiftlint:disable large_tuple identifier_name
    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {

        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
    // swiftlint:enable large_tuple identifier_name
}
