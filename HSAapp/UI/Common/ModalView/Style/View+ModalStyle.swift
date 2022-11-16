//
//  View+ModalStyle.swift
//

import SwiftUI

public extension View {
    func modalStyle<Style: ModalStyle>(_ style: Style) -> some View {
        self
            .environment(\.modalStyle, AnyModalStyle(style))
    }
}
