//
//  ModalPresentationMode.swift
//

import SwiftUI

public struct ModalPresentationMode {
    let underlyingBinding: Binding<Bool>
    
    public var isPresented: Bool {
        underlyingBinding.wrappedValue
    }
    
    public func dismiss() {
        underlyingBinding.wrappedValue = false
    }
}
