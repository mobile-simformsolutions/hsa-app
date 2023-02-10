//
//  TransactionListViewModel.swift
//

import Foundation
import RealmSwift
import SwiftUI
import Resolver

typealias TransactionListState = ListState

class TransactionListViewModel: ObservableObject {
    
    // MARK: - Variables
    //
    let limit = 10
    let sectionTitleFormatter: DateFormatter

    @Injected private var repositoryService: RepositoryService

    @Published var listState: TransactionListState = .items(moreAvailable: true)
    @Published var transactionsSections = [TransactionSection]()
    @Published var retryAlert: AlertConfiguration?
    @Published var showRefreshIndicator = false
    @Published var showLoading = false
    
    init() {
        self.sectionTitleFormatter = DateFormatter()
        self.sectionTitleFormatter.setLocalizedDateFormatFromTemplate("MMM YYYY")
        
       setup()
    }
    
    func setup() {
        guard let localRealm = try? Realm() else {
            fatalError("Failed to init Realm")
        }
        
        let dashboard = localRealm.objects(DashboardSummary.self).first
        if let dashboard = dashboard {
            var cachedTransactions = [TransactionSummaryDataModel]()
            dashboard.recentTransactions.forEach { transactionSummary in
                cachedTransactions.append(TransactionSummaryDataModel(transactionSummary: transactionSummary))
            }
            addTransactions(cachedTransactions)
        } else {
            return
        }

        loadMore()
    }

    // MARK: - APIs
    //
    func loadMore() {
        guard listState != .loading else {
            return
        }

        listState = .loading
        repositoryService.fetchMoreTransactions(offset: transactionCount(), limit: limit) { [weak self] result in
            onMain {
                guard let self = self else {
                    return
                }
                
                switch result {
                case .failure(let error):
                    Log(.error, message: "\(error.localizedDescription)")

                    self.listState = .items(moreAvailable: false)
                    self.retryAlert = Alert.fetchAlertConfiguration(error) {
                        self.loadMore()
                    }
                case .success(let transactions):
                    if transactions.isEmpty {
                        self.listState = .items(moreAvailable: false)
                    } else {
                        self.listState = .items(moreAvailable: transactions.count >= Constants.loadMoreLimit)
                    
                        self.storeTransactionsInRealm(transactions: transactions)
                        let transactionList = Array(transactions).map { TransactionSummaryDataModel(transactionSummary: $0) }
                        self.addTransactions(transactionList)
                    }
                }
            }
        }
    }

    func refresh(showLoading: Bool, _ completion: @escaping (() -> Void)) {
        listState = .loading

        showRefreshIndicator = true
        if showLoading {
            self.showLoading = true
        }
        onMain {
            Sync.shared.start { [weak self] result in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .failure(let error):
                    Log(.error, message: "Failed to refresh transaction: \(error.localizedDescription)")
                    self.showRefreshIndicator = false
                case .success:
                    self.setup()
                    self.showRefreshIndicator = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showLoading = false
                    self.listState = .items(moreAvailable: true)
                    completion()
                }
            }
        }
    }
    
    private func storeTransactionsInRealm(transactions: [TransactionSummary]) {
        do {
            let localRealm = try Realm()
            let transactionSummaries = localRealm.objects(TransactionSummary.self)
            let newTransactions = transactions.filter { newTransaction in
                !transactionSummaries.map(\.id).contains(newTransaction.id)
            }
            
            if !newTransactions.isEmpty {
                try localRealm.write {
                    localRealm.add(newTransactions)
                }
            }
        } catch {
            Log(.error, message: "Failed to save transactions to Realm, error: \(error.localizedDescription)")
        }
    }
}

// MARK: - TransactionsManaging

extension TransactionListViewModel: TransactionsManaging {}

extension TransactionListViewModel {
    enum Constants {
        static let loadMoreLimit = 10
    }
}
