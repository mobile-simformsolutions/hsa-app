//
//  Environment+ModalStyle.swift
//

import SwiftUI

struct ModalStyleKey: EnvironmentKey {
    static let defaultValue: AnyModalStyle = AnyModalStyle(DefaultModalStyle())
}

public extension EnvironmentValues {
    var modalStyle: AnyModalStyle {
        get {
            self[ModalStyleKey.self]
        }
        set {
            self[ModalStyleKey.self] = newValue
        }
    }
}
