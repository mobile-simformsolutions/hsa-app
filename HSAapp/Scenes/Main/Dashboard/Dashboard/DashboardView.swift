//
//  DashboardView.swift
//

import SwiftUI
import Introspect
import RealmSwift

struct DashboardView: View {
    
    
    @StateObject var viewModel = DashboardViewModel()
    @Binding var selectedTab: MainViewTab
        
    var body: some View {
        VStack {
            RefreshableScrollView(onRefresh: { done in
                onMain {
                    viewModel.refresh(showLoading: false, done)
                }
            }) {
                VStack(spacing: 0) {
                    VStack(spacing: 16) {
                        balance
                        dashboardTiles
                    }

                    Spacer()

                    if viewModel.showEmptyRecentActivityState {
                        emptyRecentActivityView
                    } else {
                        recentActivity

                        recentTransactions
                    }
                }
            }
            .configureNavBar()
            .background(Color.darkBackground)
            .hsaAlert(item: $viewModel.retryAlert)
            .onChange(of: selectedTab) { _ in
                if selectedTab == .dashboard {
                    self.viewModel.refresh(showLoading: false) {}
                }
            }
        }
    }

    var balance: some View {
        VStack {
            Text(viewModel.displayBalance)
                .foregroundColor(Color.transactionPositive)
                .styled(.custom(.poppins, .light, 54))
            Text(viewModel.balanceLabel)
                .foregroundColor(Color.transactionDefault)
                .styled(.custom(.poppins, .medium, 15))
            Text(viewModel.balanceUpdateDisplay)
                .foregroundColor(Color.transactionDefault)
                .styled(.custom(.poppins, .medium, 13))
            Text(viewModel.availableToSpendDisplay)
                .foregroundColor(Color.transactionDefault)
                .styled(.custom(.poppins, .medium, 13))
        }.padding(.top, 30)
    }

    var dashboardTiles: some View {
        VStack(spacing: 18) {
            if let hsaTile = viewModel.hsaTile {
                DashboardTileView(viewModel: hsaTile, onButtonTap: { selectedTab = .hsaAccount })
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }

    var recentActivity: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Recent Activity")
                    .font(Font.custom(.poppins, weight: .medium, size: 18))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                NavigationLink("See all", destination: NavigationLazyView(TransactionListScreen()))
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal)
        .background(Color.lightBackground)
    }

    var recentTransactions: some View {
        VStack {
            HStack {
                Text("Recent Transactions".uppercased())
                    .font(Font.custom(.poppins, weight: .medium, size: 15))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .background(Color.transactionDefault)

            Group {
                ForEach(viewModel.recentTransactions, id: \.id) { transaction in
                    TransactionSummaryView(transactionSummary: transaction)
                    Divider()
                }
            }.padding(.horizontal)
        }
        .background(Color.lightBackground)
    }
    
    var emptyRecentActivityView: some View {
        VStack {
            VStack(alignment: .leading) {
            Text("Recent Activity")
                .styled(.custom(.poppins, .medium, 18))
                .padding(.top, 20)
            Spacer.medium()
            Divider()
                .style(.list)
            }
            
            Text("When you make a purchase or a deposit it will appear below.")
                .styled(.custom(.poppins, .medium, 18))
            Spacer.medium()
            Image("card")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding([.leading, .trailing], 30)
            Spacer()
        }.padding(.horizontal).background(Color.lightBackground)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let accountSummary = AccountSummary()
        accountSummary._id = ObjectId.generate()
        accountSummary.amount = 123.11
        accountSummary.status = .active
        accountSummary.type = .everyday
        let tileVM = DashboardTileViewModel(accountSummary: AccountSummaryDataModel(accountSummary: accountSummary))
        
        let viewModel = DashboardViewModel()
        viewModel.hsaTile = tileVM
        
        let transaction = TransactionSummary()
        transaction.activity = "Dr. Lindquist"
        transaction.summaryDescription = "Purchase - pending"
        transaction.amount = 25
        transaction.needsAttention = false
        viewModel.recentTransactions = [transaction].map { TransactionSummaryDataModel(transactionSummary: $0) }
        
        return DashboardView(viewModel: viewModel, selectedTab: .constant(.dashboard))
    }
}
