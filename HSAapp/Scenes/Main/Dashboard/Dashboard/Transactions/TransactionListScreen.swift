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
                    Text(viewModel.title)
                        .styled(.customFull(.poppins, .medium, 26, .leading, Color.primaryText))
                        .padding(.top)
                    Spacer.small()
                    Text(viewModel.subtitle)
                        .styled(.customFull(.openSans, .regular, 13, .leading, Color.secondaryText))
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
            emptyViewTitle: "Check back soon",
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
