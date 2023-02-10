//
//  ViewExtensions.swift
//

import SwiftUI
import Combine
import Introspect

extension View {
    var screenName: String {
        return "FIX ME"// String(describing: self)
    }
    
    func setBackgroundColor() -> some View {
        return Color("DefaultBackground")
    }

    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
        func placeholder<Content: View>(
            when shouldShow: Bool,
            alignment: Alignment = .leading,
            @ViewBuilder placeholder: () -> Content) -> some View {
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

extension Spacer {
    static func small() -> some View {
        return Spacer().frame(width: 8, height: 8, alignment: .center)
    }
    static func medium() -> some View {
        return Spacer().frame(width: 20, height: 20, alignment: .center)
    }
    static func large() -> some View {
        return Spacer().frame(width: 40, height: 40, alignment: .center)
    }
}

extension UIApplication {
    
    func resetScene(to newRoot: AnyView) {
        onMain {
            SceneDelegate.setRootController(to: newRoot)
        }
    }
}


enum NavigationLocation {
    case main(selectedTab: MainViewTab = .dashboard)
    
    func view() -> some View {
        Group {
            switch self {
            case .main(let selectedTab):
                MainView(selectedTab)
            }
        }.configureNavBar()
    }
    
    func wrappedView() -> AnyView {
        return AnyView(self.view())
    }
}

enum FontFace: String, RawRepresentable {
    case poppins = "Poppins"
}

enum FontWeight: String, RawRepresentable {
    case medium = "Medium"
    case regular = "Regular"
    case semiBold = "SemiBold"
    case bold = "Bold"
    case light = "Light"
}

extension UIFont {

    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {

        // create a new font descriptor with the given traits
        guard let fontDescriptor = fontDescriptor.withSymbolicTraits(traits) else {
            // the given traits couldn't be applied, return self
            return self
        }

        // return a new font with the created font descriptor
        return UIFont(descriptor: fontDescriptor, size: pointSize)
    }

    func italics() -> UIFont {
        return withTraits(.traitItalic)
    }

    func bold() -> UIFont {
        return withTraits(.traitBold)
    }

    func boldItalics() -> UIFont {
        return withTraits([ .traitBold, .traitItalic ])
    }
}

extension Font {
    static func custom(_ face: FontFace, weight: FontWeight, size: CGFloat) -> Font {
        let name = "\(face.rawValue)-\(weight.rawValue)"
        return Font.custom(name, size: size)
    }

    static func custom(_ face: FontFace, weight: FontWeight, size: CGFloat, relativeTo textStyle: TextStyle) -> Font {
        let name = "\(face.rawValue)-\(weight.rawValue)"

        return Font.custom(name, size: size, relativeTo: textStyle)
    }

    static func customFixed(_ face: FontFace, weight: FontWeight, size: CGFloat) -> Font {
        let name = "\(face.rawValue)-\(weight.rawValue)"
        return Font.custom(name, fixedSize: size)
    }
}

extension UIFont {
    static func custom(_ face: FontFace, weight: FontWeight, size: CGFloat) -> UIFont {
        let name = "\(face.rawValue)-\(weight.rawValue)"
        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size)
    }
}

struct DoneButtonOnKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .introspectTextField { (textField) in
                let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textField.frame.size.width, height: 45))
                let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
                let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(textField.doneButtonTapped(button:)))
                doneButton.tintColor = .white
                toolBar.isTranslucent = false
                toolBar.barTintColor = .lightGray
                toolBar.items = [flexButton, doneButton]
                toolBar.setItems([flexButton, doneButton], animated: true)
                textField.inputAccessoryView = toolBar
            }
            .introspectTextView { textView in
                let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textView.frame.size.width, height: 45))
                let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
                let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(textView.doneButtonTapped(button:)))
                doneButton.tintColor = .white
                toolBar.isTranslucent = false
                toolBar.barTintColor = .lightGray
                toolBar.items = [flexButton, doneButton]
                toolBar.setItems([flexButton, doneButton], animated: true)
                textView.inputAccessoryView = toolBar
            }
    }
}

extension View {
    func withDoneButton()  -> some View {
        modifier(DoneButtonOnKeyboard())
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func isDisabled(_ value: Bool) -> some View {
        self
            .disabled(value)
            .introspectNavigationController { navigationController in
                navigationController.view.isUserInteractionEnabled = !value
            }
    }
}

enum DividerType {
    case textEntry, list, menu
}

extension Divider {
    func style(_ type: DividerType) -> some View {
        switch type {
        case .textEntry:
            return background(Color.defaultBackground)
        case .list:
            return background(Color.navigationBackground)
        case .menu:
            return background(Color.navigationNotSelected)
        }
    }
}

extension View {
    
    func accessibilityIdentifier(id: String, suffix: String) -> some View {
        self
            .accessibilityIdentifier("\(id)\(suffix)".replacingOccurrences(of: " ", with: "").lowercased())
    }
}
