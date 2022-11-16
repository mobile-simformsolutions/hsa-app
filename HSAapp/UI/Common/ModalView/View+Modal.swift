//
//  View+Modal.swift
//

import SwiftUI

public extension View {
    func modal<ModalBody: View>(isPresented: Binding<Bool>, @ViewBuilder modalBody: () -> ModalBody) -> some View {
        ModalView(
            isPresented: isPresented,
            parent: self,
            content: modalBody
        )
        .environment(
            \.modalPresentationMode,
            .constant(ModalPresentationMode(underlyingBinding: isPresented))
        )
    }
    
    func modal<Item: Identifiable, ModalBody: View>(item: Binding<Item?>, @ViewBuilder modalBody: (Item) -> ModalBody) -> some View {
        modal(
            isPresented: Binding<Bool>(
                get: {
                    item.wrappedValue != nil
                },
                set: { newValue in
                    if !newValue {
                        item.wrappedValue = nil
                    }
                }
            ),
            modalBody: {
                if item.wrappedValue != nil {
                    modalBody(item.wrappedValue!) // swiftlint:disable:this force_unwrapping
                }
            }
        )
    }
    
    func modal<Item: Identifiable, ModalBody: View>(isPresented: Binding<Bool>, item: Binding<Item?>, @ViewBuilder modalBody: (Item) -> ModalBody) -> some View {
        modal(
            isPresented: isPresented,
            modalBody: {
                if item.wrappedValue != nil {
                    modalBody(item.wrappedValue!) // swiftlint:disable:this force_unwrapping
                }
            }
        )
    }
}
