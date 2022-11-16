//
//  StateButton.swift
//

import SwiftUI

struct StateButton: View {
    @Binding var state: ButtonState
    var defaultState: ButtonState
    @Binding var shouldShowErrorState: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            if shouldShowErrorState {
                Text(state.label().uppercased())
                    .state(state, defaultState: defaultState, shouldShowErrorState: shouldShowErrorState)
            } else {
                Text(defaultState.label().uppercased())
                    .state(state, defaultState: defaultState, shouldShowErrorState: shouldShowErrorState)
            }
        }.disabled(isDisabled)
    }

    var isDisabled: Bool {
        switch state {
        case .disabled, .processing:
            return true
        case .normal, .error:
            return false
        }
    }
}
