//
//  TransactionListEmptyView.swift
//

import SwiftUI

struct TransactionListEmptyView: View {
    
    let title: String
    let image: Image
    let message: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(Font.custom(.poppins, weight: .medium, size: 26))
                .foregroundColor(Color.primaryText)
                .multilineTextAlignment(.center)

            Text(message)
                .styled(.secondary)

            image
                .onboardingStyle()

            Spacer()
        }
    }
}
