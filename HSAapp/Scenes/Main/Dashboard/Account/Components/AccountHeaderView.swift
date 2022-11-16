//
//  AccountHeaderView.swift
//

import SwiftUI

struct AccountHeaderView: View {
    let displayBalance: String
    let balanceLabel: String
    let balanceUpdateDisplay: String

    var body: some View {
        VStack {
            Text(displayBalance.uppercased())
                .foregroundColor(Color.transactionPositive)
                .styled(.custom(.poppins, .light, 60))
            Text(balanceLabel.uppercased())
                .foregroundColor(Color.transactionDefault)
                .styled(.custom(.poppins, .medium, 18))
            Text(balanceUpdateDisplay)
                .foregroundColor(Color.transactionDefault)
                .styled(.custom(.poppins, .medium, 15))
        }
    }
}
