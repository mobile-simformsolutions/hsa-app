//
//  HsaAccountViewModel.swift
//

import SwiftUI
import RealmSwift
import Resolver

class HsaAccountViewModel: ObservableObject {
    
    // MARK: - Variables
    //
    let balanceLabel = "HSA Balance"
    var contributionSummary: ContributionSummaryDataModel?
    private let dateFormatter = DateFormatter()
    private let currencyFormatter = NumberFormatter.defaultCurrencyFormatter()

    @Published var displayBalance: String = ""
    @Published var balanceUpdateDate: String = ""
    @Published var routingNumber: String = ""
    @Published var accountNumber: String = ""
    @Published var contributionMaxAmount: String = ""
    @Published var contributionAmount: String = ""
    @Published var contributionText: String = ""
    @Published var contributionRemainingAmount: String = ""
    @Published var transactionsSections: [TransactionSection] = []
    @Published var isLoading = false
    @Published var shouldDisplayLoading = true
    @Published var retryAlert: AlertConfiguration?
    @Published var listState: TransactionListState = .items(moreAvailable: false)
    @Published var showContributionView = false
    
    @Injected private var repositoryService: RepositoryService

    var contributionProgress: CGFloat {
        guard let summary = contributionSummary else {
            return 1
        }
        return min(CGFloat(summary.amount / summary.maxAmount) * 100, 100)
    }

    init() {
        setup()
    }

    func setup() {
        displayBalance = currencyFormatter.string(from: NSNumber(value: 00))! // swiftlint:disable:this force_unwrapping
        dateFormatter.dateFormat = "EEEE, MMM d"
        balanceUpdateDate = dateFormatter.string(from: Date())
        loadData()
    }

    // MARK: - Load Data APIs
    //
    func loadData(completion: (() -> Void)? = nil) {
        guard listState != .loading else {
            completion?()
            return
        }
        isLoading = shouldDisplayLoading
        listState = .loading

        repositoryService.accountDetails(accountType: .hsa) { [weak self] result in
            onMain {
                defer {
                    self?.shouldDisplayLoading = false
                    self?.isLoading = false
                }

                switch result {
                case let .success(details):
                    self?.updateBalance(from: details)
                    self?.updateContributions(from: details.contributionSummary)
                    self?.updateRoutingNumbers(from: details)
                    self?.updateTransactions(from: details)

                    self?.listState = .items(moreAvailable: details.transactions.count >= Constants.loadMoreLimit)
                case let .failure(error):
                    Log(.error, message: error.localizedDescription)
                    self?.retryAlert = Alert.fetchAlertConfiguration(error, retryBlock: { [weak self] in
                        self?.loadData()
                    })

                    self?.listState = .items(moreAvailable: false)
                }
                completion?()
            }
        }
    }

    func loadMore(completion: (() -> Void)? = nil) {
        guard listState != .loading else {
            completion?()
            return
        }
        
        listState = .loading

        repositoryService.transactions(for: .hsa, offset: transactionCount(), limit: Constants.loadMoreLimit) { [weak self] result in
            onMain {
                switch result {
                case .failure(let error):
                    Log(.error, message: error.localizedDescription)

                    self?.listState = .items(moreAvailable: true)

                    self?.retryAlert = Alert.fetchAlertConfiguration(error, retryBlock: { [weak self] in
                        self?.loadMore(completion: completion)
                    })
                case .success(let transactions):
                    if transactions.isEmpty {
                        self?.listState = .items(moreAvailable: false)
                    } else {
                        self?.listState = .items(moreAvailable: transactions.count >= Constants.loadMoreLimit)
                        let transactionList = transactions.map { TransactionSummaryDataModel(transactionSummary: $0) }
                        self?.addTransactions(transactionList)
                    }

                    completion?()
                }
            }
        }
    }

    func refresh(completion: @escaping () -> Void) {
        loadData(completion: completion)
    }
}

// MARK: - UI Data
//
private extension HsaAccountViewModel {
    func updateBalance(from accountDetails: AccountDetails) {
        displayBalance = currencyFormatter.string(from: NSNumber(value: accountDetails.balance)) ?? "-"
        balanceUpdateDate = dateFormatter.string(from: Date())
    }

    func updateRoutingNumbers(from accountDetails: AccountDetails) {
        accountNumber = accountDetails.accountNumber
        routingNumber = accountDetails.routingNumber
    }

    func updateContributions(from summary: ContributionSummary?) {
        if let summary = summary {
            self.contributionSummary = ContributionSummaryDataModel(contributionSummary: summary)
            let contributionAmount = contributionSummary?.amount ?? 0
            let contributionMaxAmount = contributionSummary?.maxAmount ?? 0
            let contributionRemainingAmount = max(contributionMaxAmount - contributionAmount, 0)
            
            self.contributionMaxAmount = currencyFormatter.string(from: contributionMaxAmount as NSNumber) ?? ""
            self.contributionRemainingAmount = currencyFormatter.string(from: contributionRemainingAmount as NSNumber) ?? ""
            self.contributionAmount = currencyFormatter.string(from: contributionAmount as NSNumber) ?? ""
            
            if let year = contributionSummary?.year {
                contributionText = "\(year) CONTRIBUTION: \(self.contributionAmount)"
            }
        }
    }

    func updateTransactions(from accountDetails: AccountDetails) {
        let transactions = Array(accountDetails.transactions).map { TransactionSummaryDataModel(transactionSummary: $0) }
        addTransactions(transactions)
    }
}

// MARK: - TransactionsManaging

extension HsaAccountViewModel: TransactionsManaging {}

// MARK: - Contants

extension HsaAccountViewModel {
    enum Constants {
        static let loadMoreLimit = 10
    }
}
