//
//  ActionButton.swift
//

import SwiftUI

struct ActionButton: View {
    var text: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text.uppercased())
                .state(.normal(""), defaultState: .normal(""), shouldShowErrorState: false)
        }
    }

}
