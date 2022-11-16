//
//  ButtonState.swift
//

import SwiftUI

enum ButtonState {
    case normal(String), disabled(String), processing(String?), error(String)
    
    static func errorTitle(_ parts: [String]) -> String {
        let partsCapatilized = parts.map { (part) -> String in
            return part.prefix(1).uppercased() + part.dropFirst()
        }
        if partsCapatilized.isEmpty {
            return "Check fields"
        } else if partsCapatilized.count == 1 {
            return "Check \(partsCapatilized.first ?? "")"
        } else {
            let partsJoined = partsCapatilized.joined(separator: ", ")
            return "Check \(partsJoined)"
        }
    }
    
    static func errorFrom(_ parts: [String]) -> ButtonState {
        return .error(ButtonState.errorTitle(parts))
    }
    static func errorFrom(_ part: String) -> ButtonState {
        return .error(ButtonState.errorTitle([part]))
    }
    
    static func errorFrom(customError: String) -> ButtonState {
        .error(customError)
    }
    
    func label() -> String {
        switch self {
        case .error(let label):
            return label
        case .normal(let label), .disabled(let label):
            return label
        case .processing(let label):
            return label ?? "processing"
        }
    }
}

extension View {
    func state(_ state: ButtonState) -> some View {
        modifier(ApplyButtonState(state: state, defaultState: state, shouldShowErrorState: true))
    }
    
    func state(_ state: ButtonState, defaultState: ButtonState, shouldShowErrorState: Bool) -> some View {
        modifier(ApplyButtonState(state: state, defaultState: defaultState, shouldShowErrorState: shouldShowErrorState))
    }
}

struct ApplyButtonState: ViewModifier {
    typealias Body = Button
    @Environment(\.sizeCategory) private var sizeCategory
    
    let state: ButtonState
    var defaultState: ButtonState
    let shouldShowErrorState: Bool
    
    func body(content: Content) -> some View {
        if !shouldShowErrorState {
            switch state {
            case .disabled:
                return apply(content: content, background: Color.defaultBackground, disabled: true)
            default:
                return apply(content: content, background: Color("DefaultControlBackground"), disabled: false)
            }
        }
//        let base = content.modifier(ButtonBase())
        switch state {
        case .normal:
            return apply(content: content, background: Color("DefaultControlBackground"), disabled: false)
        case .processing:
            return apply(content: content, background: Color("DefaultControlBackground"), disabled: true)
        case .disabled:
            return apply(content: content, background: Color.defaultBackground, disabled: true)
        case .error:
            return apply(content: content, background: Color("ErrorControlBackground"), disabled: false)
        }
    }

    func apply(content: Content, background: Color, disabled: Bool) -> some View {
        content
            .font(buttonFont)
            .disabled(disabled)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color("DefaultText"))
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(background)
            .cornerRadius(40)
    }

    var buttonFont: Font {
        switch sizeCategory {
        case .accessibilityMedium:
            return .customFixed(.poppins, weight: .semiBold, size: 24)
        case .accessibilityLarge:
            return .customFixed(.poppins, weight: .semiBold, size: 26)
        case .accessibilityExtraLarge:
            return .customFixed(.poppins, weight: .semiBold, size: 30)
        case .accessibilityExtraExtraLarge:
            return .customFixed(.poppins, weight: .semiBold, size: 34)
        case .accessibilityExtraExtraExtraLarge:
            return .customFixed(.poppins, weight: .semiBold, size: 40)
        default:
            return .custom(.poppins, weight: .semiBold, size: 20, relativeTo: .body)
        }
    }
}
