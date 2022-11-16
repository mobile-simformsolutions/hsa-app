//
//  Styles.swift
//

import SwiftUI
import UIKit

// MARK: TextField
enum TextFieldStyleType {
    case onboarding, onboardingForeground(Color), currency(Color)
}

extension TextField {
    func styled(_ style: TextFieldStyleType) -> some View {
        self.modifier(StyleTextField(style))
    }
}

struct CommonTextFieldStyle: TextFieldStyle {
    typealias Body = Text
    private let style: TextFieldStyleType
    
    init(_ style: TextFieldStyleType) {
        self.style = style
    }

    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<_Label>) -> some View {
        switch style {
        case .onboarding:
            return configuration
                .font(Font.custom(.poppins, weight: .regular, size: 22, relativeTo: .headline))
                .foregroundColor(Color.onboardingTextFieldText)
        case .onboardingForeground(let color):
            return configuration
                .font(Font.custom(.poppins, weight: .regular, size: 19, relativeTo: .headline))
                .foregroundColor(color)
        case .currency(let color):
            return configuration
                .font(Font.custom(.poppins, weight: .light, size: 60))
                .foregroundColor(color)
        }
    }
}

struct StyleTextField: ViewModifier {
    typealias Body = TextField
    private let style: TextFieldStyleType
    
    init(_ style: TextFieldStyleType) {
        self.style = style
    }
    
    func body(content: Content) -> some View {
        switch style {
        case .onboarding:
            return content.font(.headline)
                .foregroundColor(Color.onboardingTextFieldText)
        case .onboardingForeground(let color):
            return content
                .font(.headline)
                .foregroundColor(color)
        case .currency(let color):
            return content
                .font(.headline)
                .foregroundColor(color)
        }
    }
    
}

// MARK: Text

enum TextStyleType {
    case onboardingPrimary,
         onboardingSecondary,
         onboardingLinkButton,
         onboardingLinkButtonLight,
         primary,
         secondary,
         secondaryHeading,
         custom(FontFace, FontWeight, Int),
         customFull(FontFace, FontWeight, Int, TextAlignment, Color)
}

extension Text {
    func styled(_ style: TextStyleType) -> some View {
        self.modifier(StyleText(style))
    }
}

struct StyleText: ViewModifier {
    typealias Body = TextField
    private let style: TextStyleType
    
    init(_ style: TextStyleType) {
        self.style = style
    }
    
    func body(content: Content) -> some View {
        switch style {
        case .onboardingPrimary:
            return content
                .font(Font.custom(.poppins, weight: .medium, size: 24, relativeTo: .title3))
                .foregroundColor(Color.onboardingPrimaryText)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        case .onboardingSecondary:
            return content
                .font(Font.custom(.openSans, weight: .regular, size: 16, relativeTo: .body))
                .foregroundColor(Color.onboardingSecondaryText)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        case .onboardingLinkButton:
            return content
                .font(Font.custom(.poppins, weight: .semiBold, size: 16, relativeTo: .body))
                .foregroundColor(Color.onboardingLinkColor)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        case .onboardingLinkButtonLight:
            return content
                .font(Font.custom(.poppins, weight: .semiBold, size: 16, relativeTo: .body))
                .foregroundColor(Color.onboardingSecondaryText)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        case .primary:
            return content
                .font(Font.custom(.poppins, weight: .medium, size: 24, relativeTo: .body))
                .foregroundColor(Color.primaryText)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        case .secondary:
            return content
                .font(Font.custom(.openSans, weight: .regular, size: 15, relativeTo: .body))
                .foregroundColor(Color.secondaryText)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        case .secondaryHeading:
            return content
                .font(Font.custom(.openSans, weight: .semiBold, size: 15))
                .foregroundColor(Color.secondaryText)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
        case .custom(let face, let weight, let size):
            return content
                .font(Font.custom(face, weight: weight, size: CGFloat(size)))
                .foregroundColor(Color.secondaryText)
                .padding(.horizontal, 0)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        case .customFull(let face, let weight, let size, let alignment, let color):
            return content
                .font(Font.custom(face, weight: weight, size: CGFloat(size)))
                .foregroundColor(color)
                .padding(.horizontal, 0)
                .multilineTextAlignment(alignment)
                .lineLimit(nil)
        }
    }
    
}

// MARK: Image

enum ImageStyleType {
    case hero,
         cellRight
}

extension Image {
    func styled(_ style: ImageStyleType) -> some View {
        switch style {
        case .hero:
            return AnyView(
                self.resizable()
                    .foregroundColor(Color.onboardingPrimaryText)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200, alignment: .center)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.bottom, 10)
                )
        case .cellRight:
            return AnyView(
                self.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20, alignment: .center)
            )
            
        }
    }
}


// MARK: RoundedBox
extension View {
    func roundedBox() -> some View {
        self.modifier(RoundedBox())
    }
    func roundedBox(_ backgroundColor: Color) -> some View {
        self.modifier(RoundedBox(backgroundColor: backgroundColor))
    }
}

struct RoundedBox: ViewModifier {
    let edgePadding: CGFloat = 16.0
    var backgroundColor: Color = Color.onboardingBoxBackground
    func body(content: Content) -> some View {
        HStack {
            Spacer().frame(width: edgePadding, height: edgePadding, alignment: .center)
            HStack {
                content
            }
            .padding(8)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.onboardingBorder, lineWidth: 2)
            )
//            .cornerRadius(10.0)
            Spacer().frame(width: edgePadding, height: edgePadding, alignment: .center)
        }
       
    }
}

extension View {
    func leftAlign() -> some View {
        self.modifier(LeftAligned())
    }
}

struct LeftAligned: ViewModifier {
    typealias Body = TextField
    
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}
