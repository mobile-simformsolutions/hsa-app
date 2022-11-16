//
//  PrimaryButtonStyle.swift
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.custom(.poppins, weight: .semiBold, size: 22))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundColor(Color("DefaultText"))
            .background(Color.defaultControlBackground)
            .cornerRadius(44)
    }
}
