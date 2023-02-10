//
//  HsaAccountView.swift
//

import SwiftUI

struct HsaAccountView: View {
    
    @StateObject var viewModel = HsaAccountViewModel()
    @Binding var selectedTab: MainViewTab

    var body: some View {
        RefreshableScrollView(onRefresh: { done in
            onMain {
                viewModel.refresh(completion: done)
            }
        }) {
            VStack(spacing: 0) {
                VStack {
                    AccountHeaderView(
                        displayBalance: viewModel.displayBalance,
                        balanceLabel: appString.hsaBalance(),
                        balanceUpdateDisplay: viewModel.balanceUpdateDate
                    ).padding(.top, 24)

                    AccountNumbersView(routingNumber: viewModel.routingNumber, accountNumber: viewModel.accountNumber)
                        .padding(.bottom)

                    Text(viewModel.contributionText)
                        .font(Font.custom(.poppins, weight: .medium, size: 18))

                    ProgressBarView(progress: viewModel.contributionProgress, foregroundColor: .transactionPositive, backgroundColor: .white)
                        .frame(height: 30)
                    
                    Text(appString.remainingLimit(viewModel.contributionRemainingAmount, viewModel.contributionMaxAmount))
                        .font(Font.custom(.poppins, weight: .medium, size: 18)).lineLimit(1).minimumScaleFactor(0.5)

                    Divider()
                        .foregroundColor(.black)

                    HStack {
                        Image("contribution")
                        
                        Text(appString.editContribution())
                            .font(Font.custom(.poppins, weight: .medium, size: 18))
                        
                        Image(systemName: "chevron.forward")
                            .renderingMode(.template)
                            .foregroundColor(.gray)
                            .font(.system(size: 24.0))
                    }
                    .padding()
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 4)
                .background(Color.darkBackground)

                TransactionListView(
                    transactionSections: viewModel.transactionsSections,
                    listState: $viewModel.listState,
                    wrapInScrollView: false,
                    emptyViewImage: Image("emptyHSAActivity"),
                    emptyViewTitle: appString.contributeNow(),
                    emptyViewSubTitle: appString.yourAccountIsSet(),
                    onLoadMore: {
                        viewModel.loadMore(completion: nil)
                    }
                ).background(Color.white)
            }
        }
        .redacted(reason: viewModel.shouldDisplayLoading ? .placeholder : [])
        .hsaAlert(item: $viewModel.retryAlert)
        .background(Color.darkBackground)
        .configureNavigationTitleImage()
        .analyticsScreen(name: .hsaDetails)
        .onChange(of: selectedTab) { _ in
            if selectedTab == .hsaAccount {
                onMain {
                    viewModel.loadData()
                }
            }
        }
    }
}

struct HsaAccountView_Previews: PreviewProvider {
    static var previews: some View {
        let transactions = Array(DashboardSummary.mockData().recentTransactions).map { TransactionSummaryDataModel(transactionSummary: $0) }
        let sections = TransactionSection.groupByMonth(transactions: transactions)

        let viewModel = HsaAccountViewModel()
        viewModel.isLoading = false
        viewModel.shouldDisplayLoading = false
        viewModel.transactionsSections = sections
        viewModel.contributionMaxAmount = "$1000"
        viewModel.contributionRemainingAmount = "$500"
        viewModel.routingNumber = "744713123"
        viewModel.accountNumber = "777813139"
        viewModel.displayBalance = "$1320.00"
        viewModel.contributionText = "You’ve contributed \(viewModel.contributionAmount) in 2021".uppercased()

        return HsaAccountView(viewModel: viewModel, selectedTab: .constant(.hsaAccount))
    }
}
