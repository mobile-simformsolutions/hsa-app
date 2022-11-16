//
//  TransactionSummaryView.swift
//

import SwiftUI

struct TransactionSummaryView: View {
    
    @ObservedObject var viewModel: TransactionSummaryViewModel
    
    init(transactionSummary: TransactionSummaryDataModel) {
        self.viewModel = TransactionSummaryViewModel(transactionSummary: transactionSummary)
    }
    
    var body: some View {
        HStack {
            VStack {
                Image(viewModel.iconName)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(viewModel.iconColor)
                    .background(Color.clear)
                    .frame(width: 28, height: 28, alignment: .center)
                    .padding(.vertical, 10)
            }
            Spacer.medium()
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text(viewModel.title)
                    .foregroundColor(viewModel.iconColor)
                    .styled(.custom(.poppins, .medium, 18))

                HStack {
                    if viewModel.needsAttention {
                        Image(systemName: "exclamationmark.circle.fill")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(viewModel.subTitleColor)
                            .frame(width: 14, height: 14, alignment: .center)
                    }
                    Text(viewModel.subtitle)
                        .foregroundColor(viewModel.subTitleColor)
                        .styled(.custom(.openSans, .regular, 15))

                }
                Spacer()
            }
            Spacer()
            HStack {
                VStack(alignment: .trailing, spacing: 0) {
                    Spacer()
                    Text(viewModel.displayAmount)
                        .foregroundColor(viewModel.amountColor)
                        .styled(.custom(.poppins, .semiBold, 18))
                        .multilineTextAlignment(.trailing)

                    Text(viewModel.displayDate)
                        .foregroundColor(viewModel.iconColor)
                        .styled(.custom(.openSans, .regular, 15))
                        .multilineTextAlignment(.trailing)
                    Spacer()
                }
                
                Spacer()
                    .frame(width: 18, height: 18, alignment: .center)
            }
        }
        .padding(.vertical, 8)
        .frame(height: 60)
    }
}


struct TransactionSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Divider()
            let transactionSummary = TransactionSummaryDataModel(transactionSummary: DashboardSummary.mockTransactionsData().first!) // swiftlint:disable:this force_unwrapping
            TransactionSummaryView(transactionSummary: transactionSummary)
        }
    }
}
