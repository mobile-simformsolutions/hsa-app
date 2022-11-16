//
//  Environment+ModalPresentation.swift
//

import SwiftUI

struct ModalPresentationModeKey: EnvironmentKey {
    static let defaultValue: Binding<ModalPresentationMode> = .constant(
        ModalPresentationMode(underlyingBinding: .constant(false))
    )
}

public extension EnvironmentValues {
    var modalPresentationMode: Binding<ModalPresentationMode> {
        get {
            self[ModalPresentationModeKey.self]
        }
        set {
            self[ModalPresentationModeKey.self] = newValue
        }
    }
}
