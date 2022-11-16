//
//  View+CardView.swift
//

import SwiftUI

extension View {
    func card() -> some View {
        self
            .padding(.horizontal, 11)
            .padding(.bottom, 12)
            .padding(.top, 16)
            .background(Color.lightBackground)
            .cornerRadius(8)
            .shadow(color: Color.cardShadow, radius: 6, x: 0, y: 4)
            .padding(.horizontal)
    }
}
