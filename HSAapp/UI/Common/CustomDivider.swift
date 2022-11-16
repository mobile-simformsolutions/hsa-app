//
//  CustomDivider.swift
//

import SwiftUI

struct CustomDivider: View {
    var height: CGFloat = 1
    var color: Color = Color.dividerBackground
    var opacity: Double = 1

    var body: some View {
        Group {
            Rectangle()
        }
        .frame(height: height)
        .foregroundColor(color)
        .opacity(opacity)
    }
}
