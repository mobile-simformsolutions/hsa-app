//
//  TransactionListView.swift
//

import SwiftUI
import Introspect

struct TransactionListScreen: View {
    
    @StateObject var viewModel = TransactionListViewModel()
    
    var body: some View {
        RefreshableScrollView { done in
            viewModel.refresh(showLoading: false, done)
        } content: {
            VStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(appString.transactionHistory())
                        .styled(.customFull(.poppins, .medium, 26, .leading, Color.primaryText))
                        .padding(.top)
                    Spacer.small()
                    Text(appString.theTransactionHistoryPage())
                        .styled(.customFull(.poppins, .regular, 13, .leading, Color.secondaryText))
                }
                .padding(.horizontal)
                .padding(.bottom, 4)

                list()

                Spacer()

            }
            .hsaAlert(item: $viewModel.retryAlert)
            .configureNavigationTitleImage()
        }
    }

    func list() -> some View {
        TransactionListView(
            transactionSections: viewModel.transactionsSections,
            listState: $viewModel.listState,
            wrapInScrollView: false,
            emptyViewImage: nil,
            emptyViewTitle: appString.checkBackSoon(),
            emptyViewSubTitle: "",
            onLoadMore: {
                viewModel.loadMore()
            }
        )
    }
}
    
struct TransactionListScreen_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListScreen()
    }
}
