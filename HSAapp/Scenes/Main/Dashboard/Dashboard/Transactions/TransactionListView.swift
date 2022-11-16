//
//  TransactionListView.swift
//  Zenda
//
//  Created by Simon Fortelny on 5/18/21.
//

import SwiftUI
import Introspect

struct TransactionListView: View {
    @ObservedObject var viewModel: TransactionListViewModel
    
    init() {
        self.viewModel = TransactionListViewModel()
        self.viewModel.registerForReload()
    }
    
    var body: some View {
        VStack {
            if let transaction = viewModel.transactionToShow {
                NavigationLink(
                    destination: TransactionDetailView(transactionSummary: transaction),
                    isActive: $viewModel.navigateToTransaction,
                    label: { EmptyView() })
            }
            RouterLink(binding: $viewModel.goToFetch, destination: NavigationLocation.fetch.wrappedView())
            Spacer.large()
            Spacer.small()
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.title)
                    .styled(.customFull(.poppins, .medium, 26, .leading, Color.primaryText))
                Spacer.small()
                Text(viewModel.subtitle)
            }.padding(.horizontal)
            
            list()
            
        }
        .alert(item: $viewModel.retryAlert) { Alert.configure($0) }
//        .withLoadingIndicator(watching: $viewModel.showLoading)
        .navigationBarItems(
            trailing: Button(action: {
                
            }, label: {
                Image(systemName: "plus")
            })
        )
    }
    
    func transactionSection(_ transactionsSection: TransactionSection) -> some View {
        Section(header: sectionHeader(title: transactionsSection.sectionName)) {
            ForEach(transactionsSection.transactions, id: \.id) { transaction in
                ZStack {
                    TransactionSummaryView(transactionSummary: transaction)
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            if transaction.showDetails == true {
                                viewModel.showTransaction(transaction)
                            }
                        }

                }
            }
        }
    }
    
    func list() -> some View {
        RefreshableScrollView(backgroundColor: Color.white, onRefresh: { done in
            onMain {
                viewModel.refresh(showLoading: false, done)
            }
        }) {
            if let transactionToShow = viewModel.transactionToShow {
                NavigationLink(
                    destination: TransactionDetailView(transactionSummary: transactionToShow),
                    isActive: $viewModel.navigateToTransaction,
                    label: {
                        EmptyView()
                    })
            }
            VStack {
                ForEach(viewModel.transactionsSections, id: \.id) { transactionsSection in
                    transactionSection(transactionsSection)
                }
                transactionFooterSection()
            }
        }
    }
    
    func sectionHeader(title: String ) -> some View {
        return HStack {
            Text(title)
                .styled(.customFull(.poppins, .medium, 15, .leading, Color.navigationNotSelected))
                .padding(.horizontal)
                .padding(.vertical, 4)
            
            Spacer()
        }
        .background(Color.navigationBackground)
        .listRowInsets(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0))
    }

    @ViewBuilder
    func transactionFooterSection() -> some View {
        switch viewModel.loadingState {
        case LoadingState.loading:
            Section(footer:
                            HStack {
                                Spacer()
                                VStack {
                                    Text("Loading...").styled(.customFull(.poppins, .medium, 18, .center, Color.navigationBackground))
                                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                                }
                                Spacer()
                            }
            ) {}

        case LoadingState.noMoreAvaliable:
            Section(footer:
                                    HStack {
                                        Spacer()
                                        VStack {
                                            Text("No more transactions").styled(.customFull(.poppins, .medium, 18, .center, Color.navigationBackground))
                                        }
                                        Spacer()
                                    }
                            ) {}

        case LoadingState.notLoading:
            let button = ActionButton(text: "Load More") {
                viewModel.loadMore()
            }.padding(.horizontal, 10)

            Section(footer: button) {}
        }
        
    }
}
    
struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView()
    }
}
