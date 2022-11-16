//
//  Dispatch.swift
//

import Foundation
func onMain(block: @escaping () -> Void) {
    DispatchQueue.main.async {
        block()
    }
}
