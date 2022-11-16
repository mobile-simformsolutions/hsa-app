//
//  AccountNumbersView.swift
//

import SwiftUI

struct AccountNumbersView: View {
    
    @State private var isMasked: Bool = true

    let routingNumber: String
    let accountNumber: String

    private func maskedNumber(number: String) -> String {
        String(repeating: "•", count: max(0, number.count - 4)) + number.suffix(4)
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider().background(Color.black)

            HStack {
                if !routingNumber.isEmpty {
                    Text("Routing: \(isMasked ? maskedNumber(number: routingNumber): routingNumber)")
                        .font(Font.custom(.openSans, weight: .regular, size: 15))
                        .foregroundColor(Color.secondaryText)
                    Spacer()
                }
                
                HStack(spacing: 0) {
                    Text("Account: \(isMasked ? maskedNumber(number: accountNumber): accountNumber )")
                        .font(Font.custom(.openSans, weight: .regular, size: 15))
                        .foregroundColor(Color.secondaryText)
                    Button(action: {
                        isMasked.toggle()
                    }) {
                        EyeImage(type: isMasked ? .normal : .slashed)
                    }
                }
            }.padding(.vertical, 0)

            Divider().background(Color.black)
        }
    }
}

struct AccountNumbersView_Previews: PreviewProvider {
    static var previews: some View {
        AccountNumbersView(
            routingNumber: "744613232",
            accountNumber: "7776487648"
        )
    }
}
