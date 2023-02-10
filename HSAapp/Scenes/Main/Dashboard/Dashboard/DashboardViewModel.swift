//
//  DashboardViewModel.swift
//

import Foundation
import SwiftUI
import RealmSwift

class DashboardViewModel: ObservableObject {
    
    // MARK: - Variables
    //
    private var dashboardSummary: DashboardSummary?
    private let dateFormatter = DateFormatter()
    private let currencyFormatter = NumberFormatter.defaultCurrencyFormatter()

    @Published var displayBalance: String
    @Published var balanceUpdateDisplay: String
    @Published var availableToSpendDisplay: String
    @Published var hsaTile: DashboardTileViewModel?
    @Published  var recentTransactions: [TransactionSummaryDataModel] = [TransactionSummaryDataModel]() {
        didSet {
            showEmptyRecentActivityState = recentTransactions.isEmpty
        }
    }
    @Published var navigateToTile = false
    @Published var tileToShow: DashboardTileViewModel?
    @Published var navigateToTransaction = false
    @Published var showLoading = false
    @Published var showRefreshIndicator = false
    @Published var retryAlert: AlertConfiguration?
    @Published var showEmptyRecentActivityState: Bool = false
    
    init() {
        dateFormatter.dateFormat = "MMM  dd, yyyy"
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        displayBalance = currencyFormatter.string(from: NSNumber(value: 00)) ?? "00"
        dateFormatter.dateFormat = Constants.balanceUpdateDisplayFormat
        balanceUpdateDisplay = "As of \(dateFormatter.string(from: Date()))"
        availableToSpendDisplay = appString.availableToSpend()
        setup()
    }
    
    func setup() {
        guard let localRealm = try? Realm() else {
            fatalError("Failed to init Realm")
        }
        
        if let dashboardSummary = localRealm.objects(DashboardSummary.self).first {
            self.dashboardSummary = dashboardSummary
        }
        
        guard let dashboardSummary = dashboardSummary, !dashboardSummary.isInvalidated else {
            return
        }
        self.recentTransactions = dashboardSummary.recentTransactions.map { TransactionSummaryDataModel(transactionSummary: $0) }
            .sorted(by: { sum1, sum2 in
            return sum1.date.timeIntervalSince1970 > sum2.date.timeIntervalSince1970
        })
        
        displayBalance = currencyFormatter.string(from: NSNumber(value: dashboardSummary.combinedBalance))! // swiftlint:disable:this force_unwrapping
        if let hsaAccountSummary = dashboardSummary.accountSummary(for: .hsa) {
            hsaTile = DashboardTileViewModel(accountSummary: AccountSummaryDataModel(accountSummary: hsaAccountSummary))
        }
        dateFormatter.dateFormat = Constants.balanceUpdateDisplayFormat
        balanceUpdateDisplay = "As of \(dateFormatter.string(from: Date()))"
        let availableToSpendAmount = currencyFormatter.string(from: NSNumber(value: dashboardSummary.availableBalanceToSpend))! // swiftlint:disable:this force_unwrapping
        availableToSpendDisplay = appString.availableToSpend() + availableToSpendAmount
    }
    
    func showTile(_ tile: DashboardTileViewModel) {
        tileToShow = tile
        navigateToTile = true
    }
    
    // MARK: - API
    //
    func refresh(showLoading: Bool, _ completion: (() -> Void)?) {
        showRefreshIndicator = true
        if showLoading {
            self.showLoading = true
        }
        Sync.shared.start { result in
            onMain {
                if !self.navigateToTransaction {
                    switch result {
                    case .failure(let error):
                        Log(.error, message: error.localizedDescription)
                        self.showRefreshIndicator = false
                        self.retryAlert = Alert.fetchAlertConfiguration(error, retryBlock: { [weak self] in
                            self?.refresh(showLoading: showLoading, completion)
                        })
                    case .success:
                        self.setup()
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if !self.navigateToTransaction {
                        self.showLoading = false
                        self.showRefreshIndicator = false
                    }
                    completion?()
                }
            }
        }
    }
}
