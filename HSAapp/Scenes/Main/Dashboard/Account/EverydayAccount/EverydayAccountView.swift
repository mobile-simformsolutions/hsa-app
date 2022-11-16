//
//  EverydayAccount.swift
//  Zenda
//
//  Created by Simon Fortelny on 6/17/21.
//

import SwiftUI

struct EverydayAccountView: View {
    @StateObject var viewModel = EverydayAccountViewModel()
    @Binding var selectedTab: MainViewTab
    var body: some View {
        RefreshableScrollView(onRefresh: { done in
            onMain {
                viewModel.refresh(completion: done)
            }
        }) {
            NavigationLink(
                destination: NavigationLazyView(
                    FundEverydayAccountView(
                        viewModel: .init(goToSpecificView: false, accountType: .everyday)
                    )
                ),
                isActive: $viewModel.openFundEverydayAccountView,
                label: {
                    EmptyView()
                }
            )
            .isDetailLink(false)

            VStack(spacing: 0) {
                VStack {
                    AccountHeaderView(
                        displayBalance: viewModel.displayBalance,
                        balanceLabel: viewModel.balanceLabel,
                        balanceUpdateDisplay: viewModel.balanceUpdateDate
                    ).padding(.top, 24)
                    
                    AccountNumbersView(routingNumber: viewModel.routingNumber, accountNumber: viewModel.accountNumber)

                    HStack {
                        Image("deposit")

                        Text("Transfer Funds".uppercased())
                            .font(Font.custom(.poppins, weight: .medium, size: 18))

                        Image(systemName: "chevron.forward")
                            .renderingMode(.template)
                            .foregroundColor(.gray)
                            .font(.system(size: 24.0))
                    }
                    .padding()
                    .onTapGesture {
                        viewModel.openFundEverydayAccountView = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 4)
                .background(Color.darkBackground)

                if !viewModel.pendingTransactions.isEmpty {
                    pendingTransactions
                }

                TransactionListView(
                    transactionSections: viewModel.transactionsSections,
                    listState: $viewModel.listState,
                    wrapInScrollView: false,
                    emptyViewImage: Image("CarouselPage1"),
                    emptyViewTitle: "No recent activity",
                    emptyViewSubTitle: "Your purchase, deposit and withdrawal history will show up here",
                    onLoadMore: {
                        viewModel.loadMore()
                    }
                ).background(Color.white)
            }
        }
        .redacted(reason: viewModel.shouldDisplayLoading ? .placeholder : [])
        .onChange(of: selectedTab) { _ in
            if selectedTab == .everydayAccount {
                onMain {
                    viewModel.loadData(completion: nil)
                }
            }
        }
        .onAppear {
            if RefreshScreen.shouldRefreshEveryDayAccountScreen {
                viewModel.refresh {}
            }
        }
        .zendaAlert(item: $viewModel.retryAlert)
        .withLoadingIndicator(watching: $viewModel.isLoading)
        .configureNavigationTitleZendaImage()
        .background(Color.darkBackground)
    }

    private var pendingTransactions: some View {
        LazyVStack {
            Section(header: pendingTransactionsHeader) {
                ForEach(Array(viewModel.pendingTransactions), id: \.id) { transaction in
                    VStack {
                        VStack {
                            TransactionSummaryView(viewModel: transaction)
                            if !viewModel.pendingTransactions.isLastItem(transaction) {
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .id("\(transaction.id)")
                }
            }
        }
        .padding(.bottom, 10)
        .background(Color.white)
    }

    private var pendingTransactionsHeader: some View {
        HStack {
            Text("Pending Transactions".uppercased())
                .font(Font.custom(.poppins, weight: .medium, size: 15))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .background(Color.transactionDefault)
    }
}

struct EverydayAccountView_Previews: PreviewProvider {
    static var previews: some View {
        let transactions = Array(DashboardSummary.mockData().recentTransactions)

        let pendingTransaction = PendingTransaction()
        pendingTransaction.date = Date()
        pendingTransaction.indicator = .deposit
        pendingTransaction.status = .pending
        pendingTransaction.amount = 100

        let pendingTransaction1 = PendingTransaction()
        pendingTransaction1.date = Date()
        pendingTransaction1.indicator = .deposit
        pendingTransaction1.status = .pending
        pendingTransaction1.amount = 300

        let pendingTransactionsVMs = [pendingTransaction, pendingTransaction1].map {
            TransactionSummaryViewModel(
                iconName: "deposit",
                iconColor: .transactionDefault,
                title: $0.indicator.displayText,
                subtitle: "to Everyday",
                displayAmount: NumberFormatter.defaultCurrencyFormatter().string(from: $0.amount) ?? "",
                amountColor: .transactionDefault,
                needsAttention: false,
                hasZGuarantee: false,
                displayDate: TransactionSummaryViewModel.dateFormatter.string(from: $0.date),
                allowNavigationToDetails: false
            )
        }

        let transactionList = Array(transactions).map { TransactionSummaryDataModel(transactionSummary: $0) }
        let sections = TransactionSection.groupByMonth(transactions: transactionList)

        let viewModel = EverydayAccountViewModel()
        viewModel.transactionsSections = sections
        viewModel.routingNumber = "744713123"
        viewModel.accountNumber = "777813139"
        viewModel.displayBalance = "$1320.00"
        viewModel.isLoading = false
        viewModel.pendingTransactions = pendingTransactionsVMs

        return EverydayAccountView(viewModel: viewModel, selectedTab: .constant(.everydayAccount))
    }
}
